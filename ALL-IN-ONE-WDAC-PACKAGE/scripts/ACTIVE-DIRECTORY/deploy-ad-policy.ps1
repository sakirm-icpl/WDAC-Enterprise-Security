# Deploy-ADPolicy.ps1
# Deploys WDAC policies through Active Directory Group Policy

param(
    [Parameter(Mandatory=$false)]
    [string]$BasePolicyPath = "..\policies\enterprise-base-policy.xml",
    
    [Parameter(Mandatory=$false)]
    [string[]]$SupplementalPolicyPaths = @(
        "..\policies\department-supplemental-policies\finance-policy.xml",
        "..\policies\department-supplemental-policies\hr-policy.xml",
        "..\policies\department-supplemental-policies\it-policy.xml"
    ),
    
    [Parameter(Mandatory=$false)]
    [string]$GPOName = "WDAC Enterprise Policy",
    
    [Parameter(Mandatory=$false)]
    [string]$TargetOU = "OU=Workstations,DC=company,DC=com",
    
    [Parameter(Mandatory=$false)]
    [switch]$Deploy,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    switch ($Level) {
        "ERROR" { Write-Host $LogMessage -ForegroundColor Red }
        "WARN" { Write-Host $LogMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $LogMessage -ForegroundColor Green }
        default { Write-Host $LogMessage -ForegroundColor White }
    }
}

Write-Log "Starting WDAC Active Directory Policy Deployment" "INFO"

# Check if running as administrator
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Log "This script must be run as Administrator" "ERROR"
    exit 1
}

# Import required modules
try {
    Import-Module GroupPolicy -ErrorAction Stop
    Write-Log "GroupPolicy module imported successfully" "SUCCESS"
} catch {
    Write-Log "Failed to import GroupPolicy module: $_" "ERROR"
    exit 1
}

# Check if base policy exists
if (-not (Test-Path $BasePolicyPath)) {
    Write-Log "Base policy not found at $BasePolicyPath" "ERROR"
    exit 1
}

Write-Log "Base policy found: $BasePolicyPath" "SUCCESS"

# Check if supplemental policies exist
$MissingPolicies = @()
foreach ($PolicyPath in $SupplementalPolicyPaths) {
    if (-not (Test-Path $PolicyPath)) {
        $MissingPolicies += $PolicyPath
    }
}

if ($MissingPolicies.Count -gt 0) {
    Write-Log "Missing supplemental policies:" "WARN"
    foreach ($MissingPolicy in $MissingPolicies) {
        Write-Log "  $MissingPolicy" "WARN"
    }
    
    if (-not $Force) {
        $Confirmation = Read-Host "Continue with deployment without missing policies? (Y/N)"
        if ($Confirmation -ne 'Y' -and $Confirmation -ne 'y') {
            Write-Log "Deployment cancelled by user" "INFO"
            exit 0
        }
    }
}

# Convert policies to binary format
Write-Log "Converting policies to binary format..." "INFO"

# Create temporary directory
$TempDir = "$env:TEMP\WDAC_AD_Deploy"
if (-not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir | Out-Null
}

try {
    # Convert base policy
    $BaseBinaryPath = Join-Path $TempDir "enterprise-base-policy.p7b"
    ConvertFrom-CIPolicy -XmlFilePath $BasePolicyPath -BinaryFilePath $BaseBinaryPath
    Write-Log "Base policy converted to binary: $BaseBinaryPath" "SUCCESS"
    
    # Convert supplemental policies
    $SupplementalBinaryPaths = @()
    foreach ($PolicyPath in $SupplementalPolicyPaths) {
        if (Test-Path $PolicyPath) {
            $PolicyName = [System.IO.Path]::GetFileNameWithoutExtension($PolicyPath)
            $BinaryPath = Join-Path $TempDir "$PolicyName.p7b"
            ConvertFrom-CIPolicy -XmlFilePath $PolicyPath -BinaryFilePath $BinaryPath
            $SupplementalBinaryPaths += $BinaryPath
            Write-Log "Supplemental policy converted: $BinaryPath" "SUCCESS"
        }
    }
    
    if ($Deploy) {
        Write-Log "Deploying policies through Group Policy..." "INFO"
        
        # Check if GPO already exists
        try {
            $ExistingGPO = Get-GPO -Name $GPOName -ErrorAction Stop
            Write-Log "GPO '$GPOName' already exists" "WARN"
            
            if (-not $Force) {
                $Confirmation = Read-Host "Replace existing GPO? (Y/N)"
                if ($Confirmation -ne 'Y' -and $Confirmation -ne 'y') {
                    Write-Log "Deployment cancelled by user" "INFO"
                    exit 0
                }
            }
            
            # Remove existing GPO
            Remove-GPO -Name $GPOName -Confirm:$false
            Write-Log "Existing GPO removed" "SUCCESS"
        } catch {
            Write-Log "GPO '$GPOName' does not exist, creating new GPO" "INFO"
        }
        
        # Create new GPO
        $GPO = New-GPO -Name $GPOName
        Write-Log "GPO '$GPOName' created successfully" "SUCCESS"
        
        # Link GPO to target OU
        try {
            New-GPLink -Name $GPOName -Target $TargetOU -Confirm:$false | Out-Null
            Write-Log "GPO linked to OU: $TargetOU" "SUCCESS"
        } catch {
            Write-Log "Failed to link GPO to OU: $_" "ERROR"
            exit 1
        }
        
        # Copy policy files to SYSVOL
        $SysvolPath = "\\$env:USERDNSDOMAIN\SYSVOL\$env:USERDNSDOMAIN\Policies\{$($GPO.Id)\}"
        if (-not (Test-Path $SysvolPath)) {
            New-Item -ItemType Directory -Path $SysvolPath -Force | Out-Null
        }
        
        # Copy base policy
        $DestBasePath = Join-Path $SysvolPath "enterprise-base-policy.p7b"
        Copy-Item -Path $BaseBinaryPath -Destination $DestBasePath -Force
        Write-Log "Base policy copied to SYSVOL: $DestBasePath" "SUCCESS"
        
        # Copy supplemental policies
        foreach ($BinaryPath in $SupplementalBinaryPaths) {
            $FileName = [System.IO.Path]::GetFileName($BinaryPath)
            $DestPath = Join-Path $SysvolPath $FileName
            Copy-Item -Path $BinaryPath -Destination $DestPath -Force
            Write-Log "Supplemental policy copied to SYSVOL: $DestPath" "SUCCESS"
        }
        
        # Configure GPO settings
        # Enable Device Guard
        Set-GPRegistryValue -Name $GPOName -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" -ValueName "EnableVirtualizationBasedSecurity" -Type DWord -Value 1 | Out-Null
        Set-GPRegistryValue -Name $GPOName -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" -ValueName "RequirePlatformSecurityFeatures" -Type DWord -Value 1 | Out-Null
        Set-GPRegistryValue -Name $GPOName -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" -ValueName "HypervisorEnforcedCodeIntegrity" -Type DWord -Value 1 | Out-Null
        
        # Set policy path
        Set-GPRegistryValue -Name $GPOName -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" -ValueName "DeployedPolicies" -Type String -Value $DestBasePath | Out-Null
        
        Write-Log "GPO settings configured successfully" "SUCCESS"
        
        Write-Log "=== DEPLOYMENT COMPLETE ===" "SUCCESS"
        Write-Log "GPO Name: $GPOName" "INFO"
        Write-Log "Target OU: $TargetOU" "INFO"
        Write-Log "Policy files deployed to SYSVOL" "INFO"
        Write-Log "Group Policy will apply to target systems within 90 minutes" "INFO"
        Write-Log "Use 'gpupdate /force' to expedite policy application" "INFO"
    } else {
        Write-Log "Policy conversion completed. Use -Deploy parameter to deploy policies." "INFO"
        Write-Log "Binary policies located in: $TempDir" "INFO"
    }
} catch {
    Write-Log "Deployment failed: $_" "ERROR"
    exit 1
} finally {
    # Clean up temporary files (optional, can keep for inspection)
    # Remove-Item $TempDir -Recurse -Force
}

Write-Log "WDAC Active Directory Policy Deployment Process Completed" "INFO"