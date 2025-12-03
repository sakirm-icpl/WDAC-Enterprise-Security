# Implement-FolderRestrictions.ps1

<#
.SYNOPSIS
    Script to implement folder restrictions using WDAC policies

.DESCRIPTION
    This script demonstrates how to create and deploy WDAC policies that restrict
    execution from specific folders while allowing trusted applications to run.

.PARAMETER RestrictDownloads
    Restrict execution from user Downloads folders

.PARAMETER RestrictTemp
    Restrict execution from user Temp folders

.PARAMETER RestrictPublic
    Restrict execution from Public folders

.PARAMETER AllowProgramFiles
    Allow execution from Program Files directories

.PARAMETER AllowWindows
    Allow execution from Windows directories

.PARAMETER CustomAllowFolder
    Allow execution from a custom folder path

.PARAMETER CustomDenyFolder
    Deny execution from a custom folder path

.PARAMETER OutputPath
    Path to save the generated policy file

.PARAMETER Deploy
    Deploy the policy immediately after creation

.EXAMPLE
    .\Implement-FolderRestrictions.ps1 -RestrictDownloads -RestrictTemp -AllowProgramFiles -Deploy
    Creates and deploys a policy that restricts Downloads and Temp folders but allows Program Files

.EXAMPLE
    .\Implement-FolderRestrictions.ps1 -CustomDenyFolder "C:\UntrustedApps" -CustomAllowFolder "C:\TrustedApps"
    Creates a policy with custom folder restrictions
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$RestrictDownloads,
    
    [Parameter(Mandatory=$false)]
    [switch]$RestrictTemp,
    
    [Parameter(Mandatory=$false)]
    [switch]$RestrictPublic,
    
    [Parameter(Mandatory=$false)]
    [switch]$AllowProgramFiles,
    
    [Parameter(Mandatory=$false)]
    [switch]$AllowWindows,
    
    [Parameter(Mandatory=$false)]
    [string]$CustomAllowFolder,
    
    [Parameter(Mandatory=$false)]
    [string]$CustomDenyFolder,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\temp\FolderRestrictionPolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [switch]$Deploy
)

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "WARN") { "Yellow" } elseif ($Level -eq "SUCCESS") { "Green" } else { "White" })
}

function New-Guid {
    return "{" + [System.Guid]::NewGuid().ToString().ToUpper() + "}"
}

function Create-FolderRestrictionPolicy {
    param(
        [bool]$RestrictDownloads,
        [bool]$RestrictTemp,
        [bool]$RestrictPublic,
        [bool]$AllowProgramFiles,
        [bool]$AllowWindows,
        [string]$CustomAllowFolder,
        [string]$CustomDenyFolder,
        [string]$OutputPath
    )
    
    Write-Log "Creating folder restriction policy"
    
    # Generate a unique PlatformID
    $platformId = New-Guid
    
    # Start building the policy XML
    $policyXml = @"
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>$platformId</PlatformID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Audit Mode</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Advanced Boot Options Menu</Option>
    </Rule>
    <Rule>
      <Option>Required:Enforce Store Applications</Option>
    </Rule>
    <Rule>
      <Option>Enabled:UMCI</Option>
    </Rule>
  </Rules>
  <!--EKUS-->
  <EKUs>
    <Eku Id="ID_EKU_STORE" Value="010A2B0601040182370A0301" FriendlyName="Windows Store EKU - 1.3.6.1.4.1.311.76.3.1 Windows Store" />
  </EKUs>
  <!--File Rules-->
  <FileRules>
"@
    
    # Add deny rules
    if ($RestrictDownloads) {
        $policyXml += @"
    <!--Deny executables in user downloads folder-->
    <Deny ID="ID_DENY_DOWNLOADS_FOLDER" FriendlyName="Deny Downloads Folder Executables" FileName="*" FilePath="%OSDRIVE%\Users\*\Downloads\*" />

"@
    }
    
    if ($RestrictTemp) {
        $policyXml += @"
    <!--Deny executables in user temp folder-->
    <Deny ID="ID_DENY_TEMP_FOLDER" FriendlyName="Deny Temp Folder Executables" FileName="*" FilePath="%OSDRIVE%\Users\*\AppData\Local\Temp\*" />

"@
    }
    
    if ($RestrictPublic) {
        $policyXml += @"
    <!--Deny executables in public folders-->
    <Deny ID="ID_DENY_PUBLIC_FOLDERS" FriendlyName="Deny Public Folder Executables" FileName="*" FilePath="%OSDRIVE%\Users\Public\*" />

"@
    }
    
    if ($CustomDenyFolder) {
        $policyXml += @"
    <!--Deny executables in custom folder-->
    <Deny ID="ID_DENY_CUSTOM_FOLDER" FriendlyName="Deny Custom Folder Executables" FileName="*" FilePath="$CustomDenyFolder\*" />

"@
    }
    
    # Add allow rules
    if ($AllowProgramFiles) {
        $policyXml += @"
    <!--Allow applications in Program Files-->
    <Allow ID="ID_ALLOW_PROGRAM_FILES" FriendlyName="Allow Program Files" FileName="*" FilePath="%PROGRAMFILES%\*" />
    <Allow ID="ID_ALLOW_PROGRAM_FILES_X86" FriendlyName="Allow Program Files x86" FileName="*" FilePath="%PROGRAMFILES(X86)%\*" />

"@
    }
    
    if ($AllowWindows) {
        $policyXml += @"
    <!--Allow Windows folder-->
    <Allow ID="ID_ALLOW_WINDOWS_FOLDER" FriendlyName="Allow Windows Folder" FileName="*" FilePath="%WINDIR%\*" />

"@
    }
    
    if ($CustomAllowFolder) {
        $policyXml += @"
    <!--Allow applications in custom folder-->
    <Allow ID="ID_ALLOW_CUSTOM_FOLDER" FriendlyName="Allow Custom Folder" FileName="*" FilePath="$CustomAllowFolder\*" />

"@
    }
    
    # Close FileRules and continue with the rest of the policy
    $policyXml += @"
  </FileRules>
  <!--Signers-->
  <Signers>
    <Signer Name="Microsoft Product Signing" ID="ID_SIGNER_MS_PRODUCT_SIGNING">
      <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
    </Signer>
    <Signer Name="Microsoft Code Signing PCA 2011" ID="ID_SIGNER_MICROSOFT_CODE_SIGNING">
      <CertRoot Type="TBS" Value="AE9C1AE54763822EEC48CC4D8B154558570E247F4039714C204530831517894C" />
    </Signer>
    <Signer Name="Windows Store" ID="ID_SIGNER_WINDOWS_PUBLISHER_1">
      <CertRoot Type="TBS" Value="32C499C5E5E46CB3B7A2B923806F3E2F4715B58898C64FF1ED1183F4070BF887" />
      <CertEKU ID="ID_EKU_STORE" />
    </Signer>
  </Signers>
  <!--Driver Signing Scenarios-->
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1" FriendlyName="Auto generated policy on $(Get-Date -Format 'MM-dd-yyyy')">
      <ProductSigners>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_MS_PRODUCT_SIGNING" />
          <AllowedSigner SignerId="ID_SIGNER_MICROSOFT_CODE_SIGNING" />
        </AllowedSigners>
        <FileRulesRef>
"@
    
    # Add file rule references
    if ($AllowProgramFiles) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES" />
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES_X86" />
"@
    }
    
    if ($AllowWindows) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_ALLOW_WINDOWS_FOLDER" />
"@
    }
    
    if ($CustomAllowFolder) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_ALLOW_CUSTOM_FOLDER" />
"@
    }
    
    if ($RestrictDownloads) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_DENY_DOWNLOADS_FOLDER" />
"@
    }
    
    if ($RestrictTemp) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_DENY_TEMP_FOLDER" />
"@
    }
    
    if ($RestrictPublic) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_DENY_PUBLIC_FOLDERS" />
"@
    }
    
    if ($CustomDenyFolder) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_DENY_CUSTOM_FOLDER" />
"@
    }
    
    # Close the policy
    $policyXml += @"
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS" FriendlyName="Windows">
      <ProductSigners>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_WINDOWS_PUBLISHER_1" />
          <AllowedSigner SignerId="ID_SIGNER_MS_PRODUCT_SIGNING" />
          <AllowedSigner SignerId="ID_SIGNER_MICROSOFT_CODE_SIGNING" />
        </AllowedSigners>
        <FileRulesRef>
"@
    
    # Add file rule references for Windows scenario
    if ($AllowProgramFiles) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES" />
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES_X86" />
"@
    }
    
    if ($AllowWindows) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_ALLOW_WINDOWS_FOLDER" />
"@
    }
    
    if ($CustomAllowFolder) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_ALLOW_CUSTOM_FOLDER" />
"@
    }
    
    if ($RestrictDownloads) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_DENY_DOWNLOADS_FOLDER" />
"@
    }
    
    if ($RestrictTemp) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_DENY_TEMP_FOLDER" />
"@
    }
    
    if ($RestrictPublic) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_DENY_PUBLIC_FOLDERS" />
"@
    }
    
    if ($CustomDenyFolder) {
        $policyXml += @"
          <FileRuleRef RuleID="ID_DENY_CUSTOM_FOLDER" />
"@
    }
    
    # Close the policy completely
    $policyXml += @"
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
  <UpdatePolicySigners>
  </UpdatePolicySigners>
  <CiSigners>
    <CiSigner SignerId="ID_SIGNER_MS_PRODUCT_SIGNING" />
    <CiSigner SignerId="ID_SIGNER_MICROSOFT_CODE_SIGNING" />
  </CiSigners>
  <HvciOptions>0</HvciOptions>
</Policy>
"@
    
    # Save the policy
    $outputDir = Split-Path $OutputPath -Parent
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    
    Set-Content -Path $OutputPath -Value $policyXml -Encoding UTF8
    Write-Log "Policy saved to $OutputPath" -Level "SUCCESS"
    
    return $OutputPath
}

function Deploy-Policy {
    param(
        [string]$PolicyPath
    )
    
    Write-Log "Deploying policy in audit mode"
    
    try {
        # Convert to binary
        $binaryPath = [System.IO.Path]::ChangeExtension($PolicyPath, ".p7b")
        ConvertFrom-CIPolicy -XmlFilePath $PolicyPath -BinaryFilePath $binaryPath
        
        # Deploy the policy
        $deployPath = "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
        Copy-Item -Path $binaryPath -Destination $deployPath -Force
        Write-Log "Policy deployed to $deployPath" -Level "SUCCESS"
        
        Write-Log "IMPORTANT: Restart the computer for changes to take effect" -Level "WARN"
    } catch {
        Write-Log "Failed to deploy policy: $_" -Level "ERROR"
    }
}

# Main script execution
Write-Log "Starting Folder Restriction Implementation"

# Create the policy
$policyPath = Create-FolderRestrictionPolicy -RestrictDownloads $RestrictDownloads.IsPresent -RestrictTemp $RestrictTemp.IsPresent -RestrictPublic $RestrictPublic.IsPresent -AllowProgramFiles $AllowProgramFiles.IsPresent -AllowWindows $AllowWindows.IsPresent -CustomAllowFolder $CustomAllowFolder -CustomDenyFolder $CustomDenyFolder -OutputPath $OutputPath

# Deploy if requested
if ($Deploy) {
    Deploy-Policy -PolicyPath $policyPath
}

Write-Log "Folder Restriction Implementation Complete"
Write-Log "Policy file: $policyPath"
if ($Deploy) {
    Write-Log "Policy deployed in audit mode. Restart computer to activate." -Level "WARN"
} else {
    Write-Log "Policy created. Use -Deploy flag to deploy immediately." -Level "INFO"
}