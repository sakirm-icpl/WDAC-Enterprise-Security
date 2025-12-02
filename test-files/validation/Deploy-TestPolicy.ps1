# Deploy-TestPolicy.ps1
# Deploys a WDAC policy in audit mode for testing

param(
    [Parameter(Mandatory=$true)]
    [string]$PolicyPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    
    [Parameter(Mandatory=$false)]
    [string]$BackupPath = "$env:TEMP\Current_WDAC_Policy_Backup.p7b"
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

Write-Log "Starting WDAC Test Policy Deployment" "INFO"

# Check if policy file exists
if (-not (Test-Path $PolicyPath)) {
    Write-Log "Policy file not found: $PolicyPath" "ERROR"
    exit 1
}

Write-Log "Using policy file: $PolicyPath" "SUCCESS"

try {
    # Check for existing policy
    $CurrentPolicyPath = "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
    
    if (Test-Path $CurrentPolicyPath) {
        Write-Log "Existing policy detected" "WARN"
        
        if (-not $Force) {
            $Confirmation = Read-Host "Do you want to backup and replace the existing policy? (Y/N)"
            if ($Confirmation -ne 'Y' -and $Confirmation -ne 'y') {
                Write-Log "Deployment cancelled by user" "INFO"
                exit 0
            }
        }
        
        # Backup current policy
        Write-Log "Backing up current policy to $BackupPath" "INFO"
        Copy-Item -Path $CurrentPolicyPath -Destination $BackupPath -Force
        Write-Log "Backup completed" "SUCCESS"
    }
    
    # Validate policy XML
    Write-Log "Validating policy XML structure..." "INFO"
    [xml]$Policy = Get-Content $PolicyPath
    
    # Check if policy is in audit mode
    $AuditModeRule = $Policy.Policy.Rules.Rule | Where-Object { $_.Option -eq "Enabled:Audit Mode" }
    $EnforceModeRule = $Policy.Policy.Rules.Rule | Where-Object { $_.Option -eq "Enabled:Enforce Mode" }
    
    if ($EnforceModeRule -and -not $AuditModeRule) {
        Write-Log "Policy is in enforce mode. Converting to audit mode for testing..." "WARN"
        
        # Add audit mode rule
        $AuditRule = $Policy.CreateElement("Rule")
        $Option = $Policy.CreateElement("Option")
        $Option.InnerText = "Enabled:Audit Mode"
        $AuditRule.AppendChild($Option) | Out-Null
        
        # Remove enforce mode rule if it exists
        if ($EnforceModeRule) {
            $Policy.Policy.Rules.RemoveChild($EnforceModeRule) | Out-Null
        }
        
        # Save modified policy
        $AuditPolicyPath = [System.IO.Path]::ChangeExtension($PolicyPath, "_audit.xml")
        $Policy.Save($AuditPolicyPath)
        Write-Log "Audit mode policy saved to $AuditPolicyPath" "SUCCESS"
        $PolicyPath = $AuditPolicyPath
    } elseif ($AuditModeRule) {
        Write-Log "Policy is already in audit mode" "SUCCESS"
    } else {
        Write-Log "Policy has no mode specified. Adding audit mode for testing..." "WARN"
        
        # Add audit mode rule
        $AuditRule = $Policy.CreateElement("Rule")
        $Option = $Policy.CreateElement("Option")
        $Option.InnerText = "Enabled:Audit Mode"
        $AuditRule.AppendChild($Option) | Out-Null
        $Policy.Policy.Rules.AppendChild($AuditRule) | Out-Null
        
        # Save modified policy
        $AuditPolicyPath = [System.IO.Path]::ChangeExtension($PolicyPath, "_audit.xml")
        $Policy.Save($AuditPolicyPath)
        Write-Log "Audit mode policy saved to $AuditPolicyPath" "SUCCESS"
        $PolicyPath = $AuditPolicyPath
    }
    
    # Convert policy to binary format
    Write-Log "Converting policy to binary format..." "INFO"
    $BinaryPath = [System.IO.Path]::ChangeExtension($PolicyPath, ".p7b")
    ConvertFrom-CIPolicy -XmlFilePath $PolicyPath -BinaryFilePath $BinaryPath
    Write-Log "Binary policy created at $BinaryPath" "SUCCESS"
    
    # Deploy policy
    Write-Log "Deploying policy..." "INFO"
    Copy-Item -Path $BinaryPath -Destination $CurrentPolicyPath -Force
    Write-Log "Policy deployed successfully" "SUCCESS"
    
    Write-Log "=== DEPLOYMENT COMPLETE ===" "SUCCESS"
    Write-Log "Policy deployed in AUDIT MODE for testing" "WARN"
    Write-Log "Review audit logs to analyze policy effectiveness" "INFO"
    Write-Log "Restart the computer for changes to take full effect" "INFO"
    
} catch {
    Write-Log "Deployment failed: $_" "ERROR"
    exit 1
}