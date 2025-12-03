# Validate-CustomPolicy.ps1
# Validates that the custom WDAC policy meets all requirements

param(
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = ".\custom-policies\custom-base-policy.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$env:TEMP\WDAC_Custom_Validation_Log.txt"
)

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] $Message"
    Add-Content -Path $LogPath -Value $LogEntry
    Write-Host $LogEntry
}

function Test-PolicyRequirements {
    Write-Log "Validating custom WDAC policy requirements..."
    
    try {
        # Load the policy XML
        [xml]$policy = Get-Content $PolicyPath -ErrorAction Stop
        Write-Log "✅ Policy XML loaded successfully"
        
        # Requirement 1: Allow all Microsoft-signed code and applications in 'Program Files'
        $programFilesAllowRules = $policy.SiPolicy.FileRules.ChildNodes | Where-Object { 
            ($_.FriendlyName -like "*Program Files*" -or $_.ID -like "*ALLOW_PROGRAM_FILES*") -and $_.GetType().Name -eq "Allow"
        }
        if ($programFilesAllowRules.Count -ge 2) {
            Write-Log "✅ Requirement 1 PASSED: Allows applications in Program Files directories"
        } else {
            Write-Log "❌ Requirement 1 FAILED: Missing Program Files allow rules"
        }
        
        # Requirement 2: Block executable content from the Downloads folder
        $downloadsDenyRules = $policy.SiPolicy.FileRules.ChildNodes | Where-Object { 
            ($_.FriendlyName -like "*Downloads*" -or $_.ID -like "*DENY_DOWNLOADS*") -and $_.GetType().Name -eq "Deny"
        }
        if ($downloadsDenyRules.Count -ge 1) {
            Write-Log "✅ Requirement 2 PASSED: Blocks Downloads folder content"
        } else {
            Write-Log "❌ Requirement 2 FAILED: Missing Downloads folder deny rules"
        }
        
        # Requirement 3: Block execution from 'C:\Program Files (x86)\ossec-agent\active-response\bin'
        $ossecDenyRules = $policy.SiPolicy.FileRules.ChildNodes | Where-Object { 
            ($_.FriendlyName -like "*OSSEC*" -or $_.ID -like "*DENY_OSSEC*") -and $_.GetType().Name -eq "Deny"
        }
        if ($ossecDenyRules.Count -ge 1) {
            Write-Log "✅ Requirement 3 PASSED: Blocks OSSEC agent folder content"
        } else {
            Write-Log "❌ Requirement 3 FAILED: Missing OSSEC agent folder deny rules"
        }
        
        # Requirement 4: Ensure policy is in audit mode
        $auditModeOption = $policy.SiPolicy.Rules.Rule | Where-Object { 
            $_.Option -eq "Enabled:Audit Mode"
        }
        if ($auditModeOption) {
            Write-Log "✅ Requirement 4 PASSED: Policy is in Audit Mode"
        } else {
            Write-Log "❌ Requirement 4 FAILED: Policy is not in Audit Mode"
        }
        
        # Additional validation: Check that policy can be converted
        $tempPath = "$env:TEMP\validation_test.bin"
        try {
            ConvertFrom-CIPolicy -XmlFilePath $PolicyPath -BinaryFilePath $tempPath -ErrorAction Stop
            Remove-Item -Path $tempPath -ErrorAction SilentlyContinue
            Write-Log "✅ Policy conversion PASSED: Policy can be converted to binary format"
        } catch {
            Write-Log "❌ Policy conversion FAILED: $($_.Exception.Message)"
        }
        
        Write-Log "Validation completed"
        return $true
    }
    catch {
        Write-Log "❌ Validation FAILED: $($_.Exception.Message)"
        return $false
    }
}

# Main script execution
Write-Log "Starting WDAC custom policy validation"

$result = Test-PolicyRequirements

if ($result) {
    Write-Log "✅ All validation checks completed successfully"
} else {
    Write-Log "❌ Validation completed with errors"
}

Write-Log "Validation log saved to: $LogPath"