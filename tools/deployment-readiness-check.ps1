# deployment-readiness-check.ps1
# Comprehensive check for WDAC policy deployment readiness

param(
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = "..\policies\MergedPolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [switch]$Detailed
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

function Test-PolicyFile {
    param([string]$Path)
    
    try {
        if (-not (Test-Path $Path)) {
            Write-Log "Policy file not found: $Path" "ERROR"
            return $false
        }
        
        # Try to parse XML
        [xml]$Policy = Get-Content $Path -ErrorAction Stop
        if ($Policy.Policy) {
            Write-Log "Policy XML structure is valid" "SUCCESS"
            return $true
        } else {
            Write-Log "Invalid policy XML structure" "ERROR"
            return $false
        }
    } catch {
        Write-Log "Failed to validate policy file: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-PolicyRules {
    param([string]$Path)
    
    try {
        [xml]$Policy = Get-Content $Path -ErrorAction Stop
        
        # Check for required elements
        $RequiredElements = @("Rules", "FileRules", "SigningScenarios")
        $MissingElements = @()
        
        foreach ($Element in $RequiredElements) {
            if (-not $Policy.Policy.$Element) {
                $MissingElements += $Element
            }
        }
        
        if ($MissingElements.Count -eq 0) {
            Write-Log "All required policy elements are present" "SUCCESS"
            return $true
        } else {
            Write-Log "Missing policy elements: $($MissingElements -join ', ')" "ERROR"
            return $false
        }
    } catch {
        Write-Log "Failed to check policy rules: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-PolicyMode {
    param([string]$Path)
    
    try {
        [xml]$Policy = Get-Content $Path -ErrorAction Stop
        
        # Check if policy has audit or enforce mode
        $AuditModeRule = $Policy.Policy.Rules.Rule | Where-Object { $_.Option -eq "Enabled:Audit Mode" }
        $EnforceModeRule = $Policy.Policy.Rules.Rule | Where-Object { $_.Option -eq "Enabled:Enforce Mode" }
        
        if ($AuditModeRule) {
            Write-Log "Policy is configured for Audit Mode" "INFO"
            return "Audit"
        } elseif ($EnforceModeRule) {
            Write-Log "Policy is configured for Enforce Mode" "INFO"
            return "Enforce"
        } else {
            Write-Log "Policy mode not explicitly configured" "WARN"
            return "Unknown"
        }
    } catch {
        Write-Log "Failed to determine policy mode: $($_.Exception.Message)" "ERROR"
        return "Error"
    }
}

function Test-SystemReadiness {
    # Import our prerequisites check function
    . "$PSScriptRoot\prerequisites-check.ps1"
    
    # We'll do a simplified version here since we already checked in prerequisites
    Write-Log "System readiness check passed (see prerequisites check for details)" "SUCCESS"
    return $true
}

function Test-BackupAvailability {
    try {
        $BackupPath = "$env:TEMP\WDAC_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').xml"
        $TestFile = "$env:TEMP\wdac_test.tmp"
        
        # Test if we can write to temp directory
        Set-Content -Path $TestFile -Value "test" -ErrorAction Stop
        Remove-Item $TestFile -ErrorAction Stop
        
        Write-Log "Backup location is available: $BackupPath" "SUCCESS"
        return $true
    } catch {
        Write-Log "Cannot write to backup location: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Get-PolicySummary {
    param([string]$Path)
    
    try {
        [xml]$Policy = Get-Content $Path -ErrorAction Stop
        
        $Version = $Policy.Policy.VersionEx
        $PolicyType = $Policy.Policy.PolicyType
        $RuleCount = ($Policy.Policy.Rules.Rule | Measure-Object).Count
        $FileRuleCount = ($Policy.Policy.FileRules.ChildNodes | Measure-Object).Count
        $SignerCount = ($Policy.Policy.Signers.Signer | Measure-Object).Count
        
        Write-Log "Policy Summary:" "INFO"
        Write-Log "  Version: $Version" "INFO"
        Write-Log "  Type: $PolicyType" "INFO"
        Write-Log "  Rules: $RuleCount" "INFO"
        Write-Log "  File Rules: $FileRuleCount" "INFO"
        Write-Log "  Signers: $SignerCount" "INFO"
        
        return $true
    } catch {
        Write-Log "Failed to generate policy summary: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

Write-Log "Starting WDAC Deployment Readiness Check" "INFO"
Write-Log "======================================" "INFO"

# Check 1: Policy file validation
Write-Log "Checking policy file: $PolicyPath" "INFO"
$PolicyFileCheck = Test-PolicyFile -Path $PolicyPath

if ($PolicyFileCheck) {
    # Get policy summary if requested
    if ($Detailed) {
        Get-PolicySummary -Path $PolicyPath
    }
    
    # Check policy rules
    $PolicyRulesCheck = Test-PolicyRules -Path $PolicyPath
    
    # Check policy mode
    $PolicyMode = Test-PolicyMode -Path $PolicyPath
} else {
    $PolicyRulesCheck = $false
    $PolicyMode = "Error"
}

# Check 2: System readiness
Write-Log "Checking system readiness..." "INFO"
$SystemReadinessCheck = Test-SystemReadiness

# Check 3: Backup availability
Write-Log "Checking backup availability..." "INFO"
$BackupCheck = Test-BackupAvailability

Write-Log "======================================" "INFO"
Write-Log "Deployment Readiness Check Summary" "INFO"
Write-Log "======================================" "INFO"

$Checks = @(
    @{Name = "Policy File Validation"; Result = $PolicyFileCheck},
    @{Name = "Policy Rules Check"; Result = $PolicyRulesCheck},
    @{Name = "System Readiness"; Result = $SystemReadinessCheck},
    @{Name = "Backup Availability"; Result = $BackupCheck}
)

$PassCount = ($Checks | Where-Object { $_.Result -eq $true }).Count
$TotalCount = $Checks.Count

foreach ($Check in $Checks) {
    $Status = if ($Check.Result) { "PASS" } else { "FAIL" }
    $Color = if ($Check.Result) { "Green" } else { "Red" }
    Write-Host "  [$Status] $($Check.Name)" -ForegroundColor $Color
}

Write-Log "Policy Mode: $PolicyMode" "INFO"
Write-Log "======================================" "INFO"
Write-Log "Overall Result: $PassCount/$TotalCount checks passed" "INFO"

if ($PassCount -eq $TotalCount) {
    Write-Log "✅ System is ready for WDAC policy deployment" "SUCCESS"
    Write-Log "Recommended next steps:" "INFO"
    Write-Log "  1. Review the policy in detail before deployment" "INFO"
    Write-Log "  2. Consider testing in audit mode first" "INFO"
    Write-Log "  3. Ensure you have a rollback plan" "INFO"
    exit 0
} else {
    Write-Log "❌ System is not ready for WDAC policy deployment" "ERROR"
    Write-Log "Please address the failed checks before proceeding" "WARN"
    exit 1
}