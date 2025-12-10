# Editing Existing Policies

This guide explains how to edit existing WDAC policies to modify specific components without starting from scratch.

## When to Edit Policies

Editing existing policies is appropriate when:

- Adding new trusted applications
- Removing outdated rules
- Changing policy modes (audit to enforce or vice versa)
- Updating publisher certificates
- Adjusting file path rules
- Modifying policy settings

## Editing with Command-Line Tools

### Converting Between Audit and Enforce Modes

To convert a policy from audit to enforce mode:

```powershell
.\cli\convert_to_enforce_mode.ps1 -PolicyPath MyPolicy.xml -OutputPath MyPolicy_Enforce.xml
```

To convert a policy from enforce to audit mode:

```powershell
.\cli\convert_to_audit_mode.ps1 -PolicyPath MyPolicy.xml -OutputPath MyPolicy_Audit.xml
```

### Adding File Rules

To add new file rules to an existing policy:

1. Open the policy XML file in a text editor
2. Locate the `<FileRules>` section
3. Add new `<Allow>` or `<Deny>` rules as needed:
   ```xml
   <Allow ID="ID_ALLOW_NEW_APP" FriendlyName="New Application" FileName="new-app.exe" FilePath="%PROGRAMFILES%\NewApp\*" />
   ```

4. Update the `<SigningScenarios>` section to reference the new rules:
   ```xml
   <FileRuleRef RuleID="ID_ALLOW_NEW_APP" />
   ```

### Removing File Rules

To remove file rules:

1. Open the policy XML file
2. Locate and delete the unwanted `<Allow>` or `<Deny>` rule
3. Remove references to the rule from the `<SigningScenarios>` section

## Editing with XML Editors

For more complex edits, use an XML editor:

1. Open the policy XML file
2. Navigate to the section you want to modify
3. Make the necessary changes
4. Save the file

### Common Edits

#### Updating Policy Version

Change the `<VersionEx>` element:
```xml
<VersionEx>2.0.0.0</VersionEx>
```

#### Adding Signers

Add new signers to the `<Signers>` section:
```xml
<Signer Name="New Publisher" ID="ID_SIGNER_NEW_PUBLISHER">
  <CertRoot Type="TBS" Value="NEW_CERTIFICATE_THUMBPRINT" />
</Signer>
```

Then reference the signer in the appropriate `<SigningScenarios>` section.

#### Modifying Policy Rules

Edit the `<Rules>` section to add or remove policy options:
```xml
<Rule>
  <Option>Enabled:Advanced Boot Options Menu</Option>
</Rule>
```

## Validating Edited Policies

Always validate edited policies before deployment:

```powershell
.\test-xml-validity.ps1 -PolicyPath MyEditedPolicy.xml
```

## Testing Edited Policies

Test edited policies in audit mode first:

```powershell
.\cli\convert_to_audit_mode.ps1 -PolicyPath MyEditedPolicy.xml -OutputPath MyEditedPolicy_Audit.xml -Deploy
```

Monitor audit logs to ensure the changes work as expected.

## Best Practices for Editing

1. **Backup First**: Always create a backup of the original policy before editing
2. **Incremental Changes**: Make small, incremental changes rather than large modifications
3. **Version Control**: Use version control systems to track changes
4. **Documentation**: Document all changes made to policies
5. **Testing**: Thoroughly test all changes in audit mode before enforcing

## Common Editing Scenarios

### Adding Trusted Applications

To add a trusted application:

1. Add a new `<Allow>` rule in the `<FileRules>` section
2. Reference the rule in the appropriate `<SigningScenarios>`
3. Validate and test the policy

### Blocking Specific Applications

To block specific applications:

1. Add a new `<Deny>` rule in the `<FileRules>` section
2. Reference the rule in the appropriate `<SigningScenarios>`
3. Validate and test the policy

### Updating Publisher Certificates

To update publisher certificates:

1. Locate the signer in the `<Signers>` section
2. Update the `<CertRoot>` value with the new certificate thumbprint
3. Validate and test the policy

## Troubleshooting Editing Issues

Common issues when editing policies:

1. **Invalid XML**: Ensure all XML tags are properly closed and nested
2. **Missing References**: Ensure all rule IDs referenced in `<SigningScenarios>` exist in `<FileRules>`
3. **Duplicate IDs**: Ensure all rule IDs are unique within the policy
4. **Certificate Format**: Ensure certificate thumbprints are in the correct format

For detailed troubleshooting, refer to the [FAQ](../guides/FAQ.md) or open an issue on our GitHub repository.