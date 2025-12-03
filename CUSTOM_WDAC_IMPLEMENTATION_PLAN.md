# Custom WDAC Policy Implementation for Your Machine

Based on the example files you've provided and the existing repository structure, this document outlines a specific implementation plan for your machine.

## Current Environment Analysis

From examining your example files, I can see:
1. You have a large BasePolicy.xml with many hash-based rules (66,730 lines)
2. You have a DenyPolicy.xml that blocks Downloads and Temp folders
3. You have a TrustedApp.xml with publisher-based rules
4. You have a Merged.xml that combines all policies

## Recommended Implementation Approach

### Phase 1: Base Policy Design
We'll create a streamlined base policy that:
1. Allows Microsoft-signed applications
2. Permits applications in Program Files directories
3. Blocks execution from user profile folders
4. Enables Windows Store applications

### Phase 2: Supplemental Policies
We'll create targeted supplemental policies for:
1. Specific applications you need to run
2. Department-specific software
3. Legacy applications that can't be signed

### Phase 3: Deny Policies
We'll implement policies to block:
1. Downloads folder execution
2. Temp folder execution
3. Public folder execution
4. Removable drive execution (optional)

## Implementation Steps

### Step 1: Create Custom Base Policy

We'll use the existing base policy as a template but optimize it for your environment:

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
  <!--EKUS-->
  <EKUs>
    <Eku Id="ID_EKU_STORE" Value="010A2B0601040182370A0301" FriendlyName="Windows Store EKU - 1.3.6.1.4.1.311.76.3.1 Windows Store" />
  </EKUs>
  <!--File Rules-->
  <FileRules>
    <!--Allow Windows Publisher-->
    <Allow ID="ID_ALLOW_WINDOWS_PUBLISHER_1" FriendlyName="Allow Windows Publisher - Microsoft Corporation" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_WINDOWS_PUBLISHER_1">
        <CertRoot Type="TBS" Value="32C499C5E5E46CB3B7A2B923806F3E2F4715B58898C64FF1ED1183F4070BF887" />
        <CertEKU ID="ID_EKU_STORE" />
      </Signer>
    </Allow>
    <!--Allow Microsoft Product Signing-->
    <Allow ID="ID_ALLOW_MS_PRODUCT_SIGNING" FriendlyName="Allow Microsoft Product Signing" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_MS_PRODUCT_SIGNING">
        <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
      </Signer>
    </Allow>
    <!--Allow Microsoft Code Signing PCA 2011-->
    <Allow ID="ID_ALLOW_MICROSOFT_CODE_SIGNING" FriendlyName="Allow Microsoft Code Signing PCA 2011" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_MICROSOFT_CODE_SIGNING">
        <CertRoot Type="TBS" Value="AE9C1AE54763822EEC48CC4D8B154558570E247F4039714C204530831517894C" />
      </Signer>
    </Allow>
    <!--Allow applications in Program Files-->
    <Allow ID="ID_ALLOW_PROGRAM_FILES" FriendlyName="Allow Program Files" FileName="*" FilePath="%PROGRAMFILES%\*" />
    <Allow ID="ID_ALLOW_PROGRAM_FILES_X86" FriendlyName="Allow Program Files x86" FileName="*" FilePath="%PROGRAMFILES(X86)%\*" />
    <!--Allow Windows folder-->
    <Allow ID="ID_ALLOW_WINDOWS_FOLDER" FriendlyName="Allow Windows Folder" FileName="*" FilePath="%WINDIR%\*" />
    <!--Deny user profile folders for security-->
    <Deny ID="ID_DENY_USER_PROFILE" FriendlyName="Deny User Profile Folder" FilePath="%USERPROFILE%\*" />
    <Deny ID="ID_DENY_PUBLIC_FOLDER" FriendlyName="Deny Public Folder" FilePath="%PUBLIC%\*" />
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
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1" FriendlyName="Auto generated policy on 08-15-2022">
      <ProductSigners>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_MS_PRODUCT_SIGNING" />
          <AllowedSigner SignerId="ID_SIGNER_MICROSOFT_CODE_SIGNING" />
        </AllowedSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES" />
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES_X86" />
          <FileRuleRef RuleID="ID_ALLOW_WINDOWS_FOLDER" />
          <FileRuleRef RuleID="ID_DENY_USER_PROFILE" />
          <FileRuleRef RuleID="ID_DENY_PUBLIC_FOLDER" />
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
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES" />
          <FileRuleRef RuleID="ID_ALLOW_PROGRAM_FILES_X86" />
          <FileRuleRef RuleID="ID_ALLOW_WINDOWS_FOLDER" />
          <FileRuleRef RuleID="ID_DENY_USER_PROFILE" />
          <FileRuleRef RuleID="ID_DENY_PUBLIC_FOLDER" />
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
```

### Step 2: Create Supplemental Policy for Trusted Applications

```xml
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Supplemental Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <BasePolicyID>{2E07F7E4-194C-4D20-B7C9-6F44A6C5A234}</BasePolicyID>
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
  <!--File Rules - Allow specific trusted applications-->
  <FileRules>
    <!--Add your specific trusted applications here-->
    <!--Example: Allow Chrome by hash-->
    <!--
    <Allow ID="ID_ALLOW_CHROME" FriendlyName="Google Chrome" Hash="YOUR_CHROME_HASH_HERE" />
    -->
    
    <!--Example: Allow applications in a specific folder-->
    <!--
    <Allow ID="ID_ALLOW_CUSTOM_FOLDER" FriendlyName="Custom Applications Folder" FileName="*" FilePath="%PROGRAMFILES%\MyCompany\Tools\*" />
    -->
    
    <!--Example: Allow a specific publisher-->
    <!--
    <Allow ID="ID_ALLOW_VENDOR_PUBLISHER" FriendlyName="Vendor Applications" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_VENDOR_PUBLISHER">
        <CertRoot Type="TBS" Value="VENDOR_CERTIFICATE_THUMBPRINT" />
        <CertPublisher Value="Vendor Company Name" />
      </Signer>
    </Allow>
    -->
  </FileRules>
  <!--Signers-->
  <Signers>
    <!--Add signer information for publisher-based rules-->
    <!--
    <Signer Name="Vendor Publisher" ID="ID_SIGNER_VENDOR_PUBLISHER">
      <CertRoot Type="TBS" Value="VENDOR_CERTIFICATE_THUMBPRINT" />
      <CertPublisher Value="Vendor Company Name" />
    </Signer>
    -->
  </Signers>
  <!--Driver Signing Scenarios-->
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1" FriendlyName="Auto generated policy on 08-15-2022">
      <ProductSigners>
        <FileRulesRef>
          <!--Reference your file rules here-->
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS" FriendlyName="Windows">
      <ProductSigners>
        <FileRulesRef>
          <!--Reference your file rules here-->
        </FileRulesRef>
        <AllowedSigners>
          <!--Reference your signers here-->
        </AllowedSigners>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
  <UpdatePolicySigners>
  </UpdatePolicySigners>
  <HvciOptions>0</HvciOptions>
</Policy>
```

### Step 3: Create Deny Policy for Restricted Folders

```xml
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Supplemental Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <BasePolicyID>{2E07F7E4-194C-4D20-B7C9-6F44A6C5A234}</BasePolicyID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
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
  <!--File Rules - Deny untrusted locations-->
  <FileRules>
    <!--Deny executables in user downloads folder-->
    <Deny ID="ID_DENY_DOWNLOADS_FOLDER" FriendlyName="Deny Downloads Folder Executables" FileName="*" FilePath="%OSDRIVE%\Users\*\Downloads\*" />
    
    <!--Deny executables in user temp folder-->
    <Deny ID="ID_DENY_TEMP_FOLDER" FriendlyName="Deny Temp Folder Executables" FileName="*" FilePath="%OSDRIVE%\Users\*\AppData\Local\Temp\*" />
    
    <!--Deny executables in public folders-->
    <Deny ID="ID_DENY_PUBLIC_FOLDERS" FriendlyName="Deny Public Folder Executables" FileName="*" FilePath="%OSDRIVE%\Users\Public\*" />
    
    <!--Deny executables on removable drives (optional)-->
    <!--
    <Deny ID="ID_DENY_REMOVABLE_DRIVES" FriendlyName="Deny Removable Drive Executables" FileName="*" FilePath="%OSDRIVE%\*\*" />
    -->
  </FileRules>
  <!--Driver Signing Scenarios-->
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1" FriendlyName="Auto generated policy on 08-15-2022">
      <ProductSigners />
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS" FriendlyName="Windows">
      <ProductSigners />
    </SigningScenario>
  </SigningScenarios>
  <UpdatePolicySigners>
  </UpdatePolicySigners>
  <HvciOptions>0</HvciOptions>
</Policy>
```

## Deployment Process

### 1. Prepare Your Environment
- Ensure PowerShell execution policy allows script execution
- Backup current system state
- Identify applications that need to be allowed

### 2. Customize Policies
- Modify the base policy to match your environment
- Add specific applications to the supplemental policy
- Adjust folder restrictions as needed

### 3. Test in Audit Mode
- Deploy base policy in audit mode
- Monitor Code Integrity events
- Identify blocked applications
- Create supplemental policies for legitimate applications

### 4. Deploy in Enforce Mode
- Switch policy to enforce mode
- Validate critical applications still work
- Test blocked applications are prevented
- Verify folder restrictions are effective

## Monitoring and Maintenance

### Monitor Code Integrity Events
- Check Event Viewer > Applications and Services Logs > Microsoft > Windows > CodeIntegrity > Operational
- Look for events with ID 3076 (blocked applications in audit mode)
- Review events with ID 3077 (blocked applications in enforce mode)

### Update Policies Regularly
- Add new trusted applications as needed
- Remove outdated allowances
- Review and refine folder restrictions
- Maintain policy version control

## Troubleshooting Tips

### Common Issues
1. **Applications blocked unexpectedly** - Check Code Integrity logs to identify the blocked application and create appropriate allowance
2. **Policy not taking effect** - Ensure policy is deployed correctly and system has been restarted
3. **Performance issues** - Simplify policies by removing unnecessary rules

### Recovery Procedures
1. **Immediate rollback** - Use the rollback_policy.ps1 script to remove the policy
2. **Policy refinement** - Modify policies in audit mode, test, then redeploy
3. **Emergency access** - Use exception policies for temporary access during troubleshooting

## Next Steps

1. Review the sample policies in this repository
2. Customize the policies for your specific applications and environment
3. Test in audit mode first to identify any issues
4. Deploy in enforce mode after validation
5. Monitor and maintain policies regularly