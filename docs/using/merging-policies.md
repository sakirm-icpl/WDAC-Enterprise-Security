# Merging Existing Policies

This guide explains how to merge two or more existing WDAC policies to create a new consolidated policy.

## Why Merge Policies

Merging policies is useful when:

- Combining base and supplemental policies into a single deployment
- Consolidating multiple departmental policies
- Simplifying policy management
- Creating a unified policy from different sources
- Integrating third-party policy templates

## Using the Merge Utility

The toolkit provides a command-line utility for merging policies:

```powershell
.\cli\merge_policies.ps1 -BasePolicyPath Policy1.xml -SupplementalPolicyPath Policy2.xml -OutputPath MergedPolicy.xml
```

### Parameters

- `-BasePolicyPath`: Path to the primary policy file
- `-SupplementalPolicyPath`: Path to the policy to merge with the base policy
- `-OutputPath`: Path where the merged policy will be saved
- `-ConvertToBinary`: Optional flag to convert the merged policy to binary format

## Manual Policy Merging

For complex merges or when more control is needed:

### 1. Identify Policy Types

Determine which policies are base policies and which are supplemental policies. Base policies should typically be merged first.

### 2. Combine File Rules

Copy all `<Allow>` and `<Deny>` rules from the second policy to the first policy's `<FileRules>` section.

### 3. Combine Signers

Copy all signer definitions from the second policy to the first policy's `<Signers>` section.

### 4. Update Signing Scenarios

Merge the `<FileRulesRef>` elements in the signing scenarios to include references to all rules from both policies.

### 5. Handle Policy Settings

Combine or reconcile policy settings as needed.

## Example Merge Process

Let's walk through merging a base policy with a supplemental policy:

### Base Policy (BasePolicy.xml)
```xml
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>{11111111-1111-1111-1111-111111111111}</PlatformID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
    <Rule>
      <Option>Enabled:UMCI</Option>
    </Rule>
  </Rules>
  <FileRules>
    <Allow ID="ID_ALLOW_WINDOWS" FriendlyName="Windows Components" FileName="*" FilePath="%WINDIR%\*" />
  </FileRules>
  <Signers>
    <Signer Name="Microsoft" ID="ID_SIGNER_MICROSOFT">
      <CertRoot Type="TBS" Value="MICROSOFT_CERT_THUMBPRINT" />
    </Signer>
  </Signers>
  <SigningScenarios>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS" FriendlyName="Windows">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_WINDOWS" />
        </FileRulesRef>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_MICROSOFT" />
        </AllowedSigners>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

### Supplemental Policy (SupplementalPolicy.xml)
```xml
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Supplemental Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <BasePolicyID>{11111111-1111-1111-1111-111111111111}</BasePolicyID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
  </Rules>
  <FileRules>
    <Allow ID="ID_ALLOW_FINANCE_APP" FriendlyName="Finance Application" FileName="finance.exe" FilePath="%PROGRAMFILES%\Finance\*" />
  </FileRules>
  <Signers>
    <Signer Name="Finance Corp" ID="ID_SIGNER_FINANCE">
      <CertRoot Type="TBS" Value="FINANCE_CERT_THUMBPRINT" />
    </Signer>
  </Signers>
  <SigningScenarios>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS" FriendlyName="Windows">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_FINANCE_APP" />
        </FileRulesRef>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_FINANCE" />
        </AllowedSigners>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

### Merged Policy (MergedPolicy.xml)
```xml
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>{11111111-1111-1111-1111-111111111111}</PlatformID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
    <Rule>
      <Option>Enabled:UMCI</Option>
    </Rule>
  </Rules>
  <FileRules>
    <Allow ID="ID_ALLOW_WINDOWS" FriendlyName="Windows Components" FileName="*" FilePath="%WINDIR%\*" />
    <Allow ID="ID_ALLOW_FINANCE_APP" FriendlyName="Finance Application" FileName="finance.exe" FilePath="%PROGRAMFILES%\Finance\*" />
  </FileRules>
  <Signers>
    <Signer Name="Microsoft" ID="ID_SIGNER_MICROSOFT">
      <CertRoot Type="TBS" Value="MICROSOFT_CERT_THUMBPRINT" />
    </Signer>
    <Signer Name="Finance Corp" ID="ID_SIGNER_FINANCE">
      <CertRoot Type="TBS" Value="FINANCE_CERT_THUMBPRINT" />
    </Signer>
  </Signers>
  <SigningScenarios>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS" FriendlyName="Windows">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_WINDOWS" />
          <FileRuleRef RuleID="ID_ALLOW_FINANCE_APP" />
        </FileRulesRef>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_MICROSOFT" />
          <AllowedSigner SignerId="ID_SIGNER_FINANCE" />
        </AllowedSigners>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

## Best Practices for Merging

1. **Backup Original Policies**: Always keep backups of original policies before merging
2. **Validate Before Merging**: Ensure both policies are valid before attempting to merge
3. **Check for Conflicts**: Look for conflicting rules that might cause unexpected behavior
4. **Test Merged Policy**: Always test the merged policy in audit mode first
5. **Document the Merge**: Record which policies were merged and why

## Common Merging Scenarios

### Merging Base and Supplemental Policies

This is the most common scenario. The resulting policy becomes a standalone base policy.

### Merging Multiple Supplemental Policies

Combine several supplemental policies into one for simpler deployment.

### Merging Policies from Different Sources

Integrate third-party policy templates with your organization's policies.

## Troubleshooting Merge Issues

Common issues when merging policies:

1. **ID Conflicts**: Ensure all rule IDs and signer IDs are unique in the merged policy
2. **Policy Type Confusion**: Remember that merging a supplemental policy with a base policy results in a base policy
3. **Missing References**: Ensure all rule references in signing scenarios point to existing rules
4. **Rule Precedence**: Understand that deny rules take precedence over allow rules

For detailed troubleshooting, refer to the [FAQ](../guides/FAQ.md) or open an issue on our GitHub repository.