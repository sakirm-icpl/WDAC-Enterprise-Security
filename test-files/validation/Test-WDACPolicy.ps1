# Test-WDACPolicy.ps1
# Validates the syntax and structure of WDAC policy XML files

param(
    [Parameter(Mandatory=$true)]
    [string]$PolicyPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
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
    
    if ($Verbose) {
        Add-Content -Path "$env:TEMP\WDAC_Test_Log.txt" -Value $LogMessage
    }
}

Write-Log "Starting WDAC Policy Validation" "INFO"

# Check if policy file exists
if (-not (Test-Path $PolicyPath)) {
    Write-Log "Policy file not found: $PolicyPath" "ERROR"
    exit 1
}

Write-Log "Policy file found: $PolicyPath" "SUCCESS"

try {
    # Validate XML structure
    Write-Log "Validating XML structure..." "INFO"
    [xml]$Policy = Get-Content $PolicyPath
    Write-Log "XML structure is valid" "SUCCESS"
    
    # Check policy root element
    if (-not $Policy.Policy) {
        Write-Log "Missing Policy root element" "ERROR"
        exit 1
    }
    
    Write-Log "Policy root element found" "SUCCESS"
    
    # Check required elements
    $RequiredElements = @("Rules", "FileRules", "SigningScenarios")
    foreach ($Element in $RequiredElements) {
        if ($Policy.Policy.$Element) {
            Write-Log "$Element element found" "SUCCESS"
        } else {
            Write-Log "$Element element missing" "ERROR"
        }
    }
    
    # Check policy type
    $PolicyType = $Policy.Policy.PolicyType
    if ($PolicyType) {
        Write-Log "Policy Type: $PolicyType" "SUCCESS"
    } else {
        Write-Log "Policy Type not specified" "WARN"
    }
    
    # Count rules
    $RuleCount = ($Policy.Policy.Rules.Rule | Measure-Object).Count
    Write-Log "Found $RuleCount policy rules" "INFO"
    
    # Count file rules
    $FileRuleCount = ($Policy.Policy.FileRules.ChildNodes | Measure-Object).Count
    Write-Log "Found $FileRuleCount file rules" "INFO"
    
    # Check for common issues
    if ($PolicyType -eq "Base Policy") {
        $BasePolicyID = $Policy.Policy.BasePolicyID
        if ($BasePolicyID) {
            Write-Log "Base policy has BasePolicyID element (should only be in supplemental policies)" "WARN"
        }
    }
    
    Write-Log "WDAC Policy Validation Completed Successfully" "SUCCESS"
    
} catch {
    Write-Log "Validation failed: $_" "ERROR"
    exit 1
}