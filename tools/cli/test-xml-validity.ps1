# test-xml-validity.ps1
# Validates WDAC policy XML files for syntax and structure

param(
    [Parameter(Mandatory=$true)]
    [string]$PolicyPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$DetailedLogging,
    
    [Parameter(Mandatory=$false)]
    [switch]$FixIssues,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath
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

function Test-PowerShellVersionCompatibility {
    # Check PowerShell version
    $PSVersion = $PSVersionTable.PSVersion
    if ($PSVersion.Major -lt 5) {
        throw "PowerShell 5.0 or higher is required. Current version: $PSVersion"
    }
    
    # Check if required modules are available
    try {
        Import-Module ConfigCI -ErrorAction Stop
        return $true
    } catch {
        throw "ConfigCI module not available. This module is required for WDAC policy management."
    }
}

function Fix-PolicyIssues {
    param(
        [xml]$Policy,
        [string]$PolicyType
    )
    
    Write-Log "Attempting to fix common policy issues..." "INFO"
    
    # Fix missing VersionEx
    if (-not $Policy.Policy.VersionEx) {
        $VersionEx = $Policy.Policy.AppendChild($Policy.CreateElement("VersionEx"))
        $VersionEx.InnerText = "1.0.0.0"
        Write-Log "Added missing VersionEx element" "SUCCESS"
    }
    
    # Fix missing PlatformID for Base policies
    if ($PolicyType -eq "Base Policy" -and -not $Policy.Policy.PlatformID) {
        $PlatformID = $Policy.Policy.AppendChild($Policy.CreateElement("PlatformID"))
        $PlatformID.InnerText = "{11111111-1111-1111-1111-111111111111}"
        Write-Log "Added missing PlatformID element (please customize this GUID)" "WARN"
    }
    
    # Fix BasePolicyID in Base policies
    if ($PolicyType -eq "Base Policy" -and $Policy.Policy.BasePolicyID) {
        $Policy.Policy.RemoveChild($Policy.Policy.BasePolicyID) | Out-Null
        Write-Log "Removed incorrect BasePolicyID from Base policy" "SUCCESS"
    }
    
    # Add required rules if missing
    if (-not $Policy.Policy.Rules) {
        $Rules = $Policy.Policy.AppendChild($Policy.CreateElement("Rules"))
        Write-Log "Added missing Rules element" "SUCCESS"
    }
    
    return $Policy
}

Write-Log "Starting WDAC Policy XML Validity Test" "INFO"
Write-Log "Policy file: $PolicyPath" "INFO"

# Check prerequisites
try {
    Write-Log "Checking PowerShell version compatibility..." "INFO"
    Test-PowerShellVersionCompatibility | Out-Null
    Write-Log "PowerShell version compatibility check passed" "SUCCESS"
} catch {
    Write-Log "PowerShell compatibility check failed: $($_.Exception.Message)" "ERROR"
    exit 1
}

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
    $RequiredElements = @("VersionEx", "Rules", "FileRules", "SigningScenarios")
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
        $PolicyType = "Unknown"
    }
    
    # Check PlatformID for Base policies
    if ($PolicyType -eq "Base Policy" -and -not $Policy.Policy.PlatformID) {
        Write-Log "PlatformID missing in Base Policy" "ERROR"
        $MissingElements += "PlatformID"
    }
    
    # Check BasePolicyID for Supplemental policies
    if ($PolicyType -eq "Supplemental Policy" -and -not $Policy.Policy.BasePolicyID) {
        Write-Log "BasePolicyID missing in Supplemental Policy" "WARN"
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
        
        # Fix issues if requested
        if ($FixIssues) {
            $Policy = Fix-PolicyIssues -Policy $Policy -PolicyType $PolicyType
            
            # Save fixed policy
            if ($OutputPath) {
                $Policy.Save($OutputPath)
                Write-Log "Fixed policy saved to: $OutputPath" "SUCCESS"
            } else {
                Write-Log "Use -OutputPath parameter to save the fixed policy" "INFO"
            }
        }
        
        exit 0
    } else {
        Write-Log "❌ Policy XML has missing required elements" "ERROR"
        Write-Log "Missing elements: $($MissingElements -join ', ')" "ERROR"
        
        # Try to fix issues if requested
        if ($FixIssues) {
            $Policy = Fix-PolicyIssues -Policy $Policy -PolicyType $PolicyType
            
            # Save fixed policy
            if ($OutputPath) {
                $Policy.Save($OutputPath)
                Write-Log "Fixed policy saved to: $OutputPath" "SUCCESS"
                Write-Log "Please review the fixed policy before deployment" "WARN"
            } else {
                Write-Log "Use -OutputPath parameter to save the fixed policy" "INFO"
            }
        }
        
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