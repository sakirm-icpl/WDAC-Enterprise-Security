# test-xml-validity.ps1
# Validates WDAC policy XML files for syntax and structure

param(
    [Parameter(Mandatory=$true)]
    [string]$PolicyPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$DetailedLogging
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
    
    if ($DetailedLogging) {
        Add-Content -Path "$env:TEMP\WDAC_XML_Test_Log.txt" -Value $LogMessage
    }
}

Write-Log "Starting WDAC Policy XML Validity Test" "INFO"
Write-Log "Policy file: $PolicyPath" "INFO"

# Check if policy file exists
if (-not (Test-Path $PolicyPath)) {
    Write-Log "Policy file not found: $PolicyPath" "ERROR"
    exit 1
}

Write-Log "Policy file found" "SUCCESS"

try {
    # Validate XML structure
    Write-Log "Validating XML structure..." "INFO"
    [xml]$Policy = Get-Content $PolicyPath -ErrorAction Stop
    Write-Log "XML structure is valid" "SUCCESS"
    
    # Check policy root element
    if (-not $Policy.Policy) {
        Write-Log "Missing Policy root element" "ERROR"
        exit 1
    }
    
    Write-Log "Policy root element found" "SUCCESS"
    
    # Check required elements
    Write-Log "Checking required elements..." "INFO"
    $RequiredElements = @("VersionEx", "PlatformID", "Rules", "FileRules", "SigningScenarios")
    $MissingElements = @()
    
    foreach ($Element in $RequiredElements) {
        if ($Policy.Policy.$Element) {
            Write-Log "$Element element found" "SUCCESS"
        } else {
            Write-Log "$Element element missing" "ERROR"
            $MissingElements += $Element
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
    
    # Count signers
    $SignerCount = ($Policy.Policy.Signers.Signer | Measure-Object).Count
    Write-Log "Found $SignerCount signers" "INFO"
    
    # Check for common issues
    Write-Log "Checking for common issues..." "INFO"
    
    if ($PolicyType -eq "Base Policy") {
        $BasePolicyID = $Policy.Policy.BasePolicyID
        if ($BasePolicyID) {
            Write-Log "Base policy has BasePolicyID element (should only be in supplemental policies)" "WARN"
        }
    }
    
    # Check for valid rule options
    $ValidOptions = @(
        "Enabled:Unsigned System Integrity Policy",
        "Enabled:Audit Mode",
        "Enabled:Enforce Mode",
        "Enabled:Advanced Boot Options Menu",
        "Required:Enforce Store Applications",
        "Enabled:UMCI",
        "Enabled:Inherit Default Policy",
        "Enabled:Update Policy No Reboot",
        "Enabled:Allow Supplemental Policies",
        "Enabled:Dynamic Code Security"
    )
    
    $InvalidRules = @()
    foreach ($Rule in $Policy.Policy.Rules.Rule) {
        if ($Rule.Option -and $ValidOptions -notcontains $Rule.Option) {
            $InvalidRules += $Rule.Option
        }
    }
    
    if ($InvalidRules.Count -gt 0) {
        Write-Log "Found invalid rule options: $($InvalidRules -join ', ')" "WARN"
    } else {
        Write-Log "All rule options are valid" "SUCCESS"
    }
    
    # Check file rule types
    $FileRuleTypes = @()
    foreach ($FileRule in $Policy.Policy.FileRules.ChildNodes) {
        $FileRuleTypes += $FileRule.Name
    }
    
    $UniqueFileRuleTypes = $FileRuleTypes | Sort-Object -Unique
    Write-Log "File rule types found: $($UniqueFileRuleTypes -join ', ')" "INFO"
    
    Write-Log "WDAC Policy XML Validity Test Completed" "INFO"
    
    if ($MissingElements.Count -eq 0) {
        Write-Log "✅ Policy XML is valid and ready for deployment" "SUCCESS"
        exit 0
    } else {
        Write-Log "❌ Policy XML has missing required elements" "ERROR"
        Write-Log "Missing elements: $($MissingElements -join ', ')" "ERROR"
        exit 1
    }
    
} catch [System.Xml.XmlException] {
    Write-Log "XML parsing failed: $($_.Exception.Message)" "ERROR"
    Write-Log "Line: $($_.Exception.LineNumber), Position: $($_.Exception.LinePosition)" "ERROR"
    exit 1
} catch {
    Write-Log "Validation failed: $($_.Exception.Message)" "ERROR"
    exit 1
}