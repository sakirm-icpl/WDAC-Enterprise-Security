# convert-applocker-to-wdac.ps1
# Converts AppLocker policies to WDAC policies
#
# Usage: .\convert-applocker-to-wdac.ps1 -AppLockerPolicyPath "C:\path\to\applocker.xml" -OutputPath "C:\path\to\wdac.xml"

param(
    [Parameter(Mandatory=$true)]
    [string]$AppLockerPolicyPath,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\converted-wdac-policy.xml",
    
    [Parameter(Mandatory=$false)]
    [switch]$ConvertToBinary,
    
    [Parameter(Mandatory=$false)]
    [switch]$Validate
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

function Test-PolicySyntax {
    param([string]$PolicyPath)
    
    try {
        # Load XML and validate structure
        [xml]$PolicyXml = Get-Content $PolicyPath
        
        # Check for required elements
        if (-not $PolicyXml.Policy) {
            Write-Log "Invalid policy structure: Missing Policy root element" "ERROR"
            return $false
        }
        
        # Validate PolicyType
        $validPolicyTypes = @("Base Policy", "Supplemental Policy")
        if ($PolicyXml.Policy.PolicyType -notin $validPolicyTypes) {
            Write-Log "Unexpected PolicyType: $($PolicyXml.Policy.PolicyType). Expected: Base Policy or Supplemental Policy" "WARN"
        }
        
        # Check for VersionEx
        if (-not $PolicyXml.Policy.VersionEx) {
            Write-Log "Missing VersionEx element" "WARN"
        }
        
        # For Base policies, check for PlatformID
        if ($PolicyXml.Policy.PolicyType -eq "Base Policy" -and -not $PolicyXml.Policy.PlatformID) {
            Write-Log "Missing PlatformID in Base Policy" "ERROR"
            return $false
        }
        
        # For Supplemental policies, check for BasePolicyID
        if ($PolicyXml.Policy.PolicyType -eq "Supplemental Policy" -and -not $PolicyXml.Policy.BasePolicyID) {
            Write-Log "Missing BasePolicyID in Supplemental Policy" "ERROR"
            return $false
        }
        
        Write-Log "Policy syntax validation passed" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Policy syntax validation failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Convert-AppLockerToWDAC {
    param(
        [string]$AppLockerPath,
        [string]$OutputPath
    )
    
    try {
        Write-Log "Loading AppLocker policy from $AppLockerPath" "INFO"
        [xml]$AppLockerPolicy = Get-Content $AppLockerPath
        
        # Create new WDAC policy structure
        [xml]$WDACPolicy = New-Object System.Xml.XmlDocument
        
        # Create root policy element
        $PolicyElement = $WDACPolicy.CreateElement("Policy")
        $PolicyElement.SetAttribute("xmlns", "urn:schemas-microsoft-com:sipolicy")
        $PolicyElement.SetAttribute("PolicyType", "Base Policy")
        $WDACPolicy.AppendChild($PolicyElement) | Out-Null
        
        # Add version
        $VersionElement = $WDACPolicy.CreateElement("VersionEx")
        $VersionElement.InnerText = "1.0.0.0"
        $PolicyElement.AppendChild($VersionElement) | Out-Null
        
        # Add platform ID
        $PlatformElement = $WDACPolicy.CreateElement("PlatformID")
        $PlatformElement.InnerText = "{12345678-1234-1234-1234-123456789012}"
        $PolicyElement.AppendChild($PlatformElement) | Out-Null
        
        # Add default rules
        $RulesElement = $WDACPolicy.CreateElement("Rules")
        $PolicyElement.AppendChild($RulesElement) | Out-Null
        
        # Add audit mode rule
        $RuleElement = $WDACPolicy.CreateElement("Rule")
        $OptionElement = $WDACPolicy.CreateElement("Option")
        $OptionElement.InnerText = "Enabled:Audit Mode"
        $RuleElement.AppendChild($OptionElement) | Out-Null
        $RulesElement.AppendChild($RuleElement) | Out-Null
        
        # Add UMCI rule
        $RuleElement2 = $WDACPolicy.CreateElement("Rule")
        $OptionElement2 = $WDACPolicy.CreateElement("Option")
        $OptionElement2.InnerText = "Enabled:UMCI"
        $RuleElement2.AppendChild($OptionElement2) | Out-Null
        $RulesElement.AppendChild($RuleElement2) | Out-Null
        
        # Create FileRules section
        $FileRulesElement = $WDACPolicy.CreateElement("FileRules")
        $PolicyElement.AppendChild($FileRulesElement) | Out-Null
        
        # Create Signers section
        $SignersElement = $WDACPolicy.CreateElement("Signers")
        $PolicyElement.AppendChild($SignersElement) | Out-Null
        
        # Process AppLocker rules
        $RuleCounter = 1
        $SignerCounter = 1
        
        # Handle executable rules
        if ($AppLockerPolicy.AppLockerPolicy.RuleCollection) {
            foreach ($RuleCollection in $AppLockerPolicy.AppLockerPolicy.RuleCollection) {
                if ($RuleCollection.Type -eq "Exe") {
                    foreach ($Rule in $RuleCollection.FilePathRule) {
                        # Convert FilePathRule to WDAC Allow rule
                        $AllowElement = $WDACPolicy.CreateElement("Allow")
                        $AllowElement.SetAttribute("ID", "ID_ALLOW_$RuleCounter")
                        $AllowElement.SetAttribute("FriendlyName", $Rule.Name)
                        
                        if ($Rule.FilePath -like "*\*") {
                            $FilePathElement = $WDACPolicy.CreateElement("FilePath")
                            $FilePathElement.InnerText = $Rule.FilePath
                            $AllowElement.AppendChild($FilePathElement) | Out-Null
                        }
                        
                        $FileRulesElement.AppendChild($AllowElement) | Out-Null
                        $RuleCounter++
                    }
                    
                    foreach ($Rule in $RuleCollection.FileHashRule) {
                        # Convert FileHashRule to WDAC Allow rule
                        $AllowElement = $WDACPolicy.CreateElement("Allow")
                        $AllowElement.SetAttribute("ID", "ID_ALLOW_$RuleCounter")
                        $AllowElement.SetAttribute("FriendlyName", $Rule.Name)
                        
                        $FileHashElement = $WDACPolicy.CreateElement("FileHash")
                        $FileHashElement.SetAttribute("Type", "SHA256")
                        $FileHashElement.InnerText = $Rule.FileHash.Hash
                        $AllowElement.AppendChild($FileHashElement) | Out-Null
                        
                        $FileRulesElement.AppendChild($AllowElement) | Out-Null
                        $RuleCounter++
                    }
                }
                
                # Handle publisher rules
                if ($RuleCollection.Type -eq "Dll" -or $RuleCollection.Type -eq "Exe") {
                    foreach ($Rule in $RuleCollection.FilePublisherRule) {
                        # Convert FilePublisherRule to WDAC signer
                        $SignerElement = $WDACPolicy.CreateElement("Signer")
                        $SignerElement.SetAttribute("Name", $Rule.Name)
                        $SignerElement.SetAttribute("ID", "ID_SIGNER_$SignerCounter")
                        
                        # Add certificate information
                        if ($Rule.Conditions.FilePublisherCondition) {
                            $PublisherCondition = $Rule.Conditions.FilePublisherCondition
                            
                            # Add CertRoot
                            $CertRootElement = $WDACPolicy.CreateElement("CertRoot")
                            $CertRootElement.SetAttribute("Type", "TBS")
                            # This would need to be extracted from the actual certificate
                            $CertRootElement.InnerText = "CERT_ROOT_PLACEHOLDER"
                            $SignerElement.AppendChild($CertRootElement) | Out-Null
                            
                            # Add CertPublisher
                            if ($PublisherCondition.PublisherName) {
                                $CertPublisherElement = $WDACPolicy.CreateElement("CertPublisher")
                                $CertPublisherElement.InnerText = $PublisherCondition.PublisherName
                                $SignerElement.AppendChild($CertPublisherElement) | Out-Null
                            }
                        }
                        
                        $SignersElement.AppendChild($SignerElement) | Out-Null
                        $SignerCounter++
                    }
                }
            }
        }
        
        # Add SigningScenarios section
        $SigningScenariosElement = $WDACPolicy.CreateElement("SigningScenarios")
        $PolicyElement.AppendChild($SigningScenariosElement) | Out-Null
        
        # Add default signing scenario for Windows
        $SigningScenarioElement = $WDACPolicy.CreateElement("SigningScenario")
        $SigningScenarioElement.SetAttribute("Value", "12")
        $SigningScenarioElement.SetAttribute("ID", "ID_SIGNINGSCENARIO_WINDOWS")
        $SigningScenarioElement.SetAttribute("FriendlyName", "Windows")
        $SigningScenariosElement.AppendChild($SigningScenarioElement) | Out-Null
        
        # Add CiSigners section
        $CiSignersElement = $WDACPolicy.CreateElement("CiSigners")
        $PolicyElement.AppendChild($CiSignersElement) | Out-Null
        
        # Add HvciOptions
        $HvciOptionsElement = $WDACPolicy.CreateElement("HvciOptions")
        $HvciOptionsElement.InnerText = "0"
        $PolicyElement.AppendChild($HvciOptionsElement) | Out-Null
        
        # Save the converted policy
        Write-Log "Saving converted WDAC policy to $OutputPath" "INFO"
        $WDACPolicy.Save($OutputPath)
        
        Write-Log "AppLocker policy converted to WDAC format successfully" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to convert AppLocker policy: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

Write-Log "Starting AppLocker to WDAC Policy Converter" "INFO"

# Check prerequisites
try {
    Write-Log "Checking PowerShell version compatibility..." "INFO"
    Test-PowerShellVersionCompatibility | Out-Null
    Write-Log "PowerShell version compatibility check passed" "SUCCESS"
} catch {
    Write-Log "PowerShell compatibility check failed: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Check if AppLocker policy file exists
if (-not (Test-Path $AppLockerPolicyPath)) {
    Write-Log "AppLocker policy file not found at $AppLockerPolicyPath" "ERROR"
    exit 1
}

Write-Log "AppLocker policy file found: $AppLockerPolicyPath" "SUCCESS"

# Perform conversion
if (-not (Convert-AppLockerToWDAC -AppLockerPath $AppLockerPolicyPath -OutputPath $OutputPath)) {
    Write-Log "Failed to convert AppLocker policy to WDAC format" "ERROR"
    exit 1
}

# Validate if requested
if ($Validate) {
    Write-Log "Validating converted policy..." "INFO"
    if (Test-PolicySyntax -PolicyPath $OutputPath) {
        Write-Log "Policy validation passed" "SUCCESS"
    } else {
        Write-Log "Policy validation failed" "ERROR"
        exit 1
    }
}

# Convert to binary if requested
if ($ConvertToBinary) {
    Write-Log "Converting policy to binary format..." "INFO"
    try {
        $BinaryPath = [System.IO.Path]::ChangeExtension($OutputPath, ".bin")
        ConvertFrom-CIPolicy -XmlFilePath $OutputPath -BinaryFilePath $BinaryPath
        Write-Log "Policy converted to binary format: $BinaryPath" "SUCCESS"
    } catch {
        Write-Log "Failed to convert policy to binary format: $($_.Exception.Message)" "ERROR"
        exit 1
    }
}

Write-Log "AppLocker to WDAC Policy Conversion completed successfully" "INFO"
Write-Log "Converted policy saved to: $OutputPath" "INFO"