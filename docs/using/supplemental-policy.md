# Creating Supplemental Policies

This guide explains how to create supplemental WDAC policies to extend an existing base policy. Supplemental policies allow you to add specific rules without modifying the base policy.

## Understanding Supplemental Policies

Supplemental policies are used to extend a base policy with additional rules. They are particularly useful for:

- Department-specific applications
- Temporary exceptions
- Environment-specific allowances
- Adding rules for new software without changing the base policy

Key characteristics of supplemental policies:

- Must reference a base policy using the BasePolicyID
- Cannot exist independently (require a base policy)
- Are evaluated in conjunction with the base policy
- Can add allow or deny rules
- Cannot modify base policy rules

## Creating a Supplemental Policy

### Using Templates

The toolkit provides supplemental policy templates:

```powershell
.\cli\generate-policy-from-template.ps1 -TemplatePath templates\supplemental-policy-template.xml -OutputPath MySupplementalPolicy.xml
```

### Manual Creation

To create a supplemental policy from scratch:

1. Create a new XML file with the supplemental policy structure:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Supplemental Policy">
     <!-- Policy content here -->
   </Policy>
   ```

2. Add the required elements:
   - `<BasePolicyID>` - Must match the PlatformID of your base policy
   - `<Rules>` - Policy rules (typically fewer than base policies)
   - `<FileRules>` - Additional file path and hash rules
   - `<Signers>` - Additional trusted certificate signers (optional)
   - `<SigningScenarios>` - Signing scenarios for the additional rules

### Example Supplemental Policy

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
      <Option>Enabled:UMCI</Option>
    </Rule>
  </Rules>
  <FileRules>
    <Allow ID="ID_ALLOW_FINANCE_APP" FriendlyName="Finance Department Application" FileName="finance-app.exe" FilePath="%OSDRIVE%\Apps\Finance\*" />
  </FileRules>
  <SigningScenarios>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS" FriendlyName="Windows">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_FINANCE_APP" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

## Common Use Cases

### Department-Specific Policies

Create policies for specific departments:

```xml
<FileRules>
  <Allow ID="ID_ALLOW_HR_APPS" FriendlyName="HR Department Applications" FileName="*" FilePath="%OSDRIVE%\Apps\HR\*" />
</FileRules>
```

### Temporary Exception Policies

For temporary allowances with expiration dates:

```xml
<FileRules>
  <Allow ID="ID_ALLOW_TEMP_VENDOR" FriendlyName="Vendor Software - Expires 2023-12-31" FileName="vendor-tool.exe" FilePath="%OSDRIVE%\Temp\Vendors\*" />
</FileRules>
```

### Application-Specific Policies

For specific applications that require special permissions:

```xml
<FileRules>
  <Allow ID="ID_ALLOW_PYTHON_SCRIPTS" FriendlyName="Python Scripts" FileName="*.py" FilePath="%OSDRIVE%\Scripts\Python\*" />
</FileRules>
```

## Validating Supplemental Policies

Validate your supplemental policy before deployment:

```powershell
.\test-xml-validity.ps1 -PolicyPath MySupplementalPolicy.xml
```

Ensure the BasePolicyID matches your base policy's PlatformID.

## Deploying Supplemental Policies

Supplemental policies can be deployed alongside base policies:

1. Convert to binary format:
   ```powershell
   ConvertFrom-CIPolicy -XmlFilePath MySupplementalPolicy.xml -BinaryFilePath MySupplementalPolicy.bin
   ```

2. Deploy both policies:
   - Place both base and supplemental policy binaries in the CodeIntegrity directory
   - Or use Group Policy to deploy both policies

## Merging with Base Policies

Alternatively, you can merge supplemental policies with base policies:

```powershell
.\cli\merge_policies.ps1 -BasePolicyPath MyBasePolicy.xml -SupplementalPolicyPath MySupplementalPolicy.xml -OutputPath MyMergedPolicy.xml
```

## Best Practices

1. **Use Descriptive Names**: Give policies clear, descriptive names and IDs
2. **Limit Scope**: Keep supplemental policies focused on specific use cases
3. **Regular Review**: Periodically review and remove unnecessary supplemental policies
4. **Version Control**: Maintain version control for all policies
5. **Documentation**: Document the purpose of each supplemental policy

## Troubleshooting

Common issues with supplemental policies:

1. **Mismatched BasePolicyID**: Ensure the BasePolicyID exactly matches the base policy's PlatformID
2. **Deployment Order**: Base policies must be deployed before supplemental policies
3. **Rule Conflicts**: Understand that deny rules take precedence over allow rules
4. **Policy Limits**: Be aware of Windows limits on the number of policies

For detailed troubleshooting, refer to the [FAQ](../guides/FAQ.md) or open an issue on our GitHub repository.