# Deploy-NonADPolicy.ps1
# Deploys WDAC policies in non-Active Directory environments

param(
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = ".\policies",
    
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$env:TEMP\WDAC_Deployment_Log.txt",
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] $Message"
    Add-Content -Path $LogPath -Value $LogEntry
    Write-Host $LogEntry
}

function Test-AdminPrivileges {
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $WindowsPrincipal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
    return $WindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Deploy-Policy {
    param(
        [string]$PolicyFile,
        [string]$PolicyType
    )
    
    try {
        Write-Log "Deploying $PolicyType policy: $PolicyFile"
        
        # Convert XML to binary policy
        $BinaryPolicyPath = "$env:TEMP\temp_policy.bin"
        ConvertFrom-CIPolicy -XmlFilePath $PolicyFile -BinaryFilePath $BinaryPolicyPath
        
        # Deploy policy
        Copy-Item -Path $BinaryPolicyPath -Destination "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b" -Force
        
        # Cleanup temp file
        Remove-Item -Path $BinaryPolicyPath -Force
        
        Write-Log "Successfully deployed $PolicyType policy"
        return $true
    }
    catch {
        Write-Log "Failed to deploy $PolicyType policy: $($_.Exception.Message)"
        return $false
    }
}

# Main script execution
Write-Log "Starting WDAC policy deployment for non-AD environment"

# Check for admin privileges
if (-not (Test-AdminPrivileges)) {
    Write-Log "Error: This script requires administrator privileges"
    exit 1
}

# Validate policy path
if (-not (Test-Path $PolicyPath)) {
    Write-Log "Error: Policy path '$PolicyPath' does not exist"
    exit 1
}

# Deploy base policy
$BasePolicy = Join-Path $PolicyPath "non-ad-base-policy.xml"
if (Test-Path $BasePolicy) {
    $Result = Deploy-Policy -PolicyFile $BasePolicy -PolicyType "Base"
    if (-not $Result) {
        Write-Log "Failed to deploy base policy. Exiting."
        exit 1
    }
} else {
    Write-Log "Warning: Base policy not found at $BasePolicy"
}

# Deploy supplemental policies
$SupplementalPath = Join-Path $PolicyPath "department-supplemental-policies"
if (Test-Path $SupplementalPath) {
    Get-ChildItem -Path $SupplementalPath -Filter "*.xml" | ForEach-Object {
        $Result = Deploy-Policy -PolicyFile $_.FullName -PolicyType "Supplemental"
        if (-not $Result) {
            Write-Log "Warning: Failed to deploy supplemental policy $($_.Name)"
        }
    }
}

# Deploy exception policies
$ExceptionPath = Join-Path $PolicyPath "exception-policies"
if (Test-Path $ExceptionPath) {
    Get-ChildItem -Path $ExceptionPath -Filter "*.xml" | ForEach-Object {
        $Result = Deploy-Policy -PolicyFile $_.FullName -PolicyType "Exception"
        if (-not $Result) {
            Write-Log "Warning: Failed to deploy exception policy $($_.Name)"
        }
    }
}

# Refresh policy
try {
    Write-Log "Refreshing WDAC policy"
    Invoke-CimMethod -Namespace root/Microsoft/Windows/CI -ClassName PS_UpdateAndCompareInfo -MethodName Update -Arguments @{UpdatedPSObjects = $null}
    Write-Log "Policy refresh completed"
} catch {
    Write-Log "Warning: Failed to refresh policy: $($_.Exception.Message)"
}

Write-Log "WDAC policy deployment completed"
Write-Log "Please restart the system for changes to take effect"