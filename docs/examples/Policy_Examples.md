# WDAC Policy Examples

This document provides practical examples of WDAC policies for common scenarios.

## Example 1: Basic Enterprise Policy

This policy allows Microsoft applications, applications in Program Files, and denies executables in user directories:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>{2E07F7E4-194C-4D20-B7C9-6F44A6C5A234}</PlatformID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Enforce Mode</Option>
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
  <EKUs>
    <Eku Id="ID_EKU_STORE" Value="010A2B0601040182370A0301" FriendlyName="Windows Store" />
  </EKUs>
  <FileRules>
    <!-- Allow Windows Store applications -->
    <Allow ID="ID_ALLOW_WINDOWS_STORE" FriendlyName="Windows Store" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_WINDOWS_STORE">
        <CertRoot Type="TBS" Value="32C499C5E5E46CB3B7A2B923806F3E2F4715B58898C64FF1ED1183F4070BF887" />
        <CertEKU ID="ID_EKU_STORE" />
      </Signer>
    </Allow>
    
    <!-- Allow Microsoft applications -->
    <Allow ID="ID_ALLOW_MS_PUBLISHER" FriendlyName="Microsoft Applications" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_MS">
        <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
        <CertPublisher Value="Microsoft Corporation" />
      </Signer>
    </Allow>
    
    <!-- Allow applications in Program Files -->
    <Allow ID="ID_ALLOW_PROGRAM_FILES" FriendlyName="Program Files" FileName="*" FilePath="%PROGRAMFILES%\*" />
    <Allow ID="ID_ALLOW_PROGRAM_FILES_X86" FriendlyName="Program Files x86" FileName="*" FilePath="%PROGRAMFILES(X86)%\*" />
    
    <!-- Deny executables in user directories -->
    <Deny ID="ID_DENY_USER_DOWNLOADS" FriendlyName="User Downloads" FileName="*" FilePath="%OSDRIVE%\Users\*\Downloads\*" />
    <Deny ID="ID_DENY_USER_TEMP" FriendlyName="User Temp" FileName="*" FilePath="%OSDRIVE%\Users\*\AppData\Local\Temp\*" />
    <Deny ID="ID_DENY_PUBLIC" FriendlyName="Public Folder" FileName="*" FilePath="%OSDRIVE%\Users\Public\*" />
  </FileRules>
  <Signers>
    <Signer Name="Microsoft Publisher" ID="ID_SIGNER_MS">
      <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
      <CertPublisher Value="Microsoft Corporation" />
    </Signer>
    <Signer Name="Windows Store" ID="ID_SIGNER_WINDOWS_STORE">
      <CertRoot Type="TBS" Value="32C499C5E5E46CB3B7A2B923806F3E2F4715B58898C64FF1ED1183F4070BF887" />
      <CertEKU ID="ID_EKU_STORE" />
    </Signer>
  </Signers>
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES" />
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES_X86" />
          <FileRuleRef RuleID="ID_DENY_USER_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_USER_TEMP" />
          <FileRuleRef RuleID="ID_DENY_PUBLIC" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS">
      <ProductSigners>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_MS" />
          <AllowedSigner SignerId="ID_SIGNER_WINDOWS_STORE" />
        </AllowedSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES" />
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES_X86" />
          <FileRuleRef RuleID="ID_DENY_USER_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_USER_TEMP" />
          <FileRuleRef RuleID="ID_DENY_PUBLIC" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
  <UpdatePolicySigners>
  </UpdatePolicySigners>
  <CiSigners>
    <CiSigner SignerId="ID_SIGNER_MS" />
  </CiSigners>
  <HvciOptions>0</HvciOptions>
</Policy>
```

## Example 2: Supplemental Policy for Third-Party Vendor

This supplemental policy allows applications from a specific third-party vendor:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Supplemental Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <BasePolicyID>{2E07F7E4-194C-4D20-B7C9-6F44A6C5A234}</BasePolicyID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
  </Rules>
  <FileRules>
    <!-- Allow vendor applications by publisher -->
    <Allow ID="ID_ALLOW_VENDOR_PUBLISHER" FriendlyName="Vendor Applications" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_VENDOR">
        <CertRoot Type="TBS" Value="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" />
        <CertPublisher Value="Vendor Corporation" />
      </Signer>
    </Allow>
    
    <!-- Allow vendor applications by path -->
    <Allow ID="ID_ALLOW_VENDOR_PATH" FriendlyName="Vendor Path" FileName="*" FilePath="%PROGRAMFILES%\Vendor\*" />
  </FileRules>
  <Signers>
    <Signer Name="Vendor Publisher" ID="ID_SIGNER_VENDOR">
      <CertRoot Type="TBS" Value="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" />
      <CertPublisher Value="Vendor Corporation" />
    </Signer>
  </Signers>
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_VENDOR_PATH" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS">
      <ProductSigners>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_VENDOR" />
        </AllowedSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_VENDOR_PATH" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

## Example 3: Deny Policy for High-Risk Locations

This policy specifically denies execution from high-risk locations:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Supplemental Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <BasePolicyID>{2E07F7E4-194C-4D20-B7C9-6F44A6C5A234}</BasePolicyID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
  </Rules>
  <FileRules>
    <!-- Deny removable drives -->
    <Deny ID="ID_DENY_REMOVABLE" FriendlyName="Removable Drives" FileName="*" FilePath="%OSDRIVE%\*" />
    
    <!-- Deny network locations -->
    <Deny ID="ID_DENY_NETWORK" FriendlyName="Network Locations" FileName="*" FilePath="\\*\*" />
    
    <!-- Deny browser download folders -->
    <Deny ID="ID_DENY_BROWSER_DOWNLOADS" FriendlyName="Browser Downloads" FileName="*" FilePath="%OSDRIVE%\Users\*\Downloads\*" />
    
    <!-- Deny temporary internet files -->
    <Deny ID="ID_DENY_INTERNET_FILES" FriendlyName="Internet Files" FileName="*" FilePath="%OSDRIVE%\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" />
    
    <!-- Deny email attachments -->
    <Deny ID="ID_DENY_EMAIL_ATTACHMENTS" FriendlyName="Email Attachments" FileName="*" FilePath="%OSDRIVE%\Users\*\AppData\Local\Microsoft\Windows\INetCache\*" />
  </FileRules>
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_DENY_REMOVABLE" />
          <FileRuleRef RuleID="ID_DENY_NETWORK" />
          <FileRuleRef RuleID="ID_DENY_BROWSER_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_INTERNET_FILES" />
          <FileRuleRef RuleID="ID_DENY_EMAIL_ATTACHMENTS" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_DENY_REMOVABLE" />
          <FileRuleRef RuleID="ID_DENY_NETWORK" />
          <FileRuleRef RuleID="ID_DENY_BROWSER_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_INTERNET_FILES" />
          <FileRuleRef RuleID="ID_DENY_EMAIL_ATTACHMENTS" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

## Example 4: Audit-Only Policy

This policy is configured for audit mode to monitor application execution without blocking:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>{2E07F7E4-194C-4D20-B7C9-6F44A6C5A234}</PlatformID>
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
  <EKUs>
    <Eku Id="ID_EKU_STORE" Value="010A2B0601040182370A0301" FriendlyName="Windows Store" />
  </EKUs>
  <FileRules>
    <!-- Allow Windows Store applications -->
    <Allow ID="ID_ALLOW_WINDOWS_STORE_AUDIT" FriendlyName="Windows Store" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_WINDOWS_STORE_AUDIT">
        <CertRoot Type="TBS" Value="32C499C5E5E46CB3B7A2B923806F3E2F4715B58898C64FF1ED1183F4070BF887" />
        <CertEKU ID="ID_EKU_STORE" />
      </Signer>
    </Allow>
    
    <!-- Allow Microsoft applications -->
    <Allow ID="ID_ALLOW_MS_PUBLISHER_AUDIT" FriendlyName="Microsoft Applications" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_MS_AUDIT">
        <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
        <CertPublisher Value="Microsoft Corporation" />
      </Signer>
    </Allow>
  </FileRules>
  <Signers>
    <Signer Name="Microsoft Publisher" ID="ID_SIGNER_MS_AUDIT">
      <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
      <CertPublisher Value="Microsoft Corporation" />
    </Signer>
    <Signer Name="Windows Store" ID="ID_SIGNER_WINDOWS_STORE_AUDIT">
      <CertRoot Type="TBS" Value="32C499C5E5E46CB3B7A2B923806F3E2F4715B58898C64FF1ED1183F4070BF887" />
      <CertEKU ID="ID_EKU_STORE" />
    </Signer>
  </Signers>
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1_AUDIT">
      <ProductSigners>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS_AUDIT">
      <ProductSigners>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_MS_AUDIT" />
          <AllowedSigner SignerId="ID_SIGNER_WINDOWS_STORE_AUDIT" />
        </AllowedSigners>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
  <UpdatePolicySigners>
  </UpdatePolicySigners>
  <CiSigners>
    <CiSigner SignerId="ID_SIGNER_MS_AUDIT" />
  </CiSigners>
  <HvciOptions>0</HvciOptions>
</Policy>
```

## Example 5: Hash-Based Policy for Specific Applications

This policy uses hash rules for specific applications that cannot be controlled by other rule types:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Supplemental Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <BasePolicyID>{2E07F7E4-194C-4D20-B7C9-6F44A6C5A234}</BasePolicyID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
  </Rules>
  <FileRules>
    <!-- Specific application hashes -->
    <Allow ID="ID_ALLOW_APP1_HASH" FriendlyName="Application 1" Hash="9F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F8F" />
    <Allow ID="ID_ALLOW_APP2_HASH" FriendlyName="Application 2" Hash="A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2" />
    <Allow ID="ID_ALLOW_APP3_HASH" FriendlyName="Application 3" Hash="C4D5E6F7G8H9C4D5E6F7G8H9C4D5E6F7G8H9C4D5E6F7G8H9C4D5E6F7G8H9C4D5" />
  </FileRules>
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1_HASH">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_APP1_HASH" />
          <FileRuleRef RuleID="ID_ALLOW_APP2_HASH" />
          <FileRuleRef RuleID="ID_ALLOW_APP3_HASH" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS_HASH">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_APP1_HASH" />
          <FileRuleRef RuleID="ID_ALLOW_APP2_HASH" />
          <FileRuleRef RuleID="ID_ALLOW_APP3_HASH" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

## Using These Examples

To use these examples in your environment:

1. Copy the appropriate XML content to a new file
2. Modify the GUID values to match your environment
3. Update certificate thumbprints for your trusted publishers
4. Adjust file paths to match your environment
5. Test thoroughly in audit mode before enforcing

Remember to always:
- Test policies in audit mode first
- Keep backups of working policies
- Document all policy changes
- Monitor audit logs for blocked applications