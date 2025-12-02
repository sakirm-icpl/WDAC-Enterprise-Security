# Update-ADPolicy.ps1
# Updates existing WDAC policies deployed through Active Directory Group Policy

param(
    [Parameter(Mandatory=$false)]
    [string]$GPOName = "WDAC Enterprise Policy",
    
    [Parameter(Mandatory=$false)]
    [string]$BasePolicyPath = "..\policies\enterprise-base-policy.xml",
    
    [Parameter(Mandatory=$false)]
    [string[]]$SupplementalPolicyPaths = @(
        "..\policies\department-supplemental-policies\finance-policy.xml",
        "..\policies\department-supplemental-policies\hr-policy.xml",
        "..\policies\department-supplemental-policies\it-policy.xml"
    ),
    
    [Parameter(Mandatory=$false)]
    [switch]$ForceUpdate,
    
    [Parameter(Mandatory=$false)]
    [switch]$RestartClients
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

Write-Log "Starting WDAC Active Directory Policy Update" "INFO"

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

# Check if GPO exists
try {
    $GPO = Get-GPO -Name $GPOName -ErrorAction Stop
    Write-Log "GPO '$GPOName' found" "SUCCESS"
} catch {
    Write-Log "GPO '$GPOName' not found" "ERROR"
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
    
    if (-not $ForceUpdate) {
        $Confirmation = Read-Host "Continue with update without missing policies? (Y/N)"
        if ($Confirmation -ne 'Y' -and $Confirmation -ne 'y') {
            Write-Log "Update cancelled by user" "INFO"
            exit 0
        }
    }
}

# Convert policies to binary format
Write-Log "Converting policies to binary format..." "INFO"

# Create temporary directory
$TempDir = "$env:TEMP\WDAC_AD_Update"
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
    
    # Copy updated policy files to SYSVOL
    $SysvolPath = "\\$env:USERDNSDOMAIN\SYSVOL\$env:USERDNSDOMAIN\Policies\{$($GPO.Id)\}"
    
    if (-not (Test-Path $SysvolPath)) {
        Write-Log "SYSVOL path not found: $SysvolPath" "ERROR"
        exit 1
    }
    
    Write-Log "Updating policy files in SYSVOL..." "INFO"
    
    # Copy base policy
    $DestBasePath = Join-Path $SysvolPath "enterprise-base-policy.p7b"
    Copy-Item -Path $BaseBinaryPath -Destination $DestBasePath -Force
    Write-Log "Base policy updated in SYSVOL: $DestBasePath" "SUCCESS"
    
    # Copy supplemental policies
    foreach ($BinaryPath in $SupplementalBinaryPaths) {
        $FileName = [System.IO.Path]::GetFileName($BinaryPath)
        $DestPath = Join-Path $SysvolPath $FileName
        Copy-Item -Path $BinaryPath -Destination $DestPath -Force
        Write-Log "Supplemental policy updated in SYSVOL: $DestPath" "SUCCESS"
    }
    
    # Force Group Policy update on domain controllers
    Write-Log "Refreshing Group Policy on domain controllers..." "INFO"
    
    $DomainControllers = Get-ADDomainController -Filter *
    foreach ($DC in $DomainControllers) {
        try {
            Invoke-GPUpdate -Computer $DC.HostName -Force | Out-Null
            Write-Log "GPUpdate initiated on domain controller: $($DC.HostName)" "SUCCESS"
        } catch {
            Write-Log "Failed to initiate GPUpdate on domain controller $($DC.HostName): $_" "WARN"
        }
    }
    
    if ($RestartClients) {
        Write-Log "Restarting client systems to apply updated policies..." "INFO"
        
        # Get all computers in the domain
        $Computers = Get-ADComputer -Filter {OperatingSystem -like "*Windows*"}
        
        foreach ($Computer in $Computers) {
            try {
                if (Test-Connection -ComputerName $Computer.Name -Count 1 -Quiet) {
                    Restart-Computer -ComputerName $Computer.Name -Force -ErrorAction Stop
                    Write-Log "Restart initiated on: $($Computer.Name)" "SUCCESS"
                } else {
                    Write-Log "Cannot reach computer: $($Computer.Name)" "WARN"
                }
            } catch {
                Write-Log "Failed to restart computer $($Computer.Name): $_" "WARN"
            }
        }
    } else {
        Write-Log "Policy update completed. Client systems will receive updates within 90 minutes." "INFO"
        Write-Log "Use 'gpupdate /force' on client systems to expedite policy application." "INFO"
        Write-Log "Use -RestartClients parameter to automatically restart client systems." "INFO"
    }
    
    Write-Log "=== POLICY UPDATE COMPLETE ===" "SUCCESS"
    Write-Log "Updated policies deployed to SYSVOL" "INFO"
    Write-Log "Domain controllers refreshed" "INFO"
    
} catch {
    Write-Log "Policy update failed: $_" "ERROR"
    exit 1
} finally {
    # Clean up temporary files (optional, can keep for inspection)
    # Remove-Item $TempDir -Recurse -Force
}

Write-Log "WDAC Active Directory Policy Update Process Completed" "INFO"