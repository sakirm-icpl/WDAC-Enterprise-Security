# Deploy-CustomPolicy.ps1
# Deploys the custom WDAC policy for testing specific scenarios

param(
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = ".\custom-policies\custom-base-policy.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$env:TEMP\WDAC_Custom_Deployment_Log.txt"
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

# Main script execution
Write-Log "Starting custom WDAC policy deployment"

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

try {
    Write-Log "Deploying custom policy: $PolicyPath"
    
    # Convert XML to binary policy
    $BinaryPolicyPath = "$env:TEMP\custom_policy.bin"
    ConvertFrom-CIPolicy -XmlFilePath $PolicyPath -BinaryFilePath $BinaryPolicyPath
    
    # Deploy policy
    Copy-Item -Path $BinaryPolicyPath -Destination "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b" -Force
    
    # Cleanup temp file
    Remove-Item -Path $BinaryPolicyPath -Force
    
    Write-Log "Successfully deployed custom policy"
    
    # Refresh policy
    Write-Log "Refreshing WDAC policy"
    Invoke-CimMethod -Namespace root/Microsoft/Windows/CI -ClassName PS_UpdateAndCompareInfo -MethodName Update -Arguments @{UpdatedPSObjects = $null}
    Write-Log "Policy refresh completed"
    
    Write-Log "Custom WDAC policy deployment completed"
    Write-Log "Please restart the system for changes to take effect"
    
    return $true
}
catch {
    Write-Log "Failed to deploy custom policy: $($_.Exception.Message)"
    return $false
}