# Creating New Base Policies

This guide explains how to create new base WDAC policies using the WDAC Policy Toolkit. Base policies form the foundation of your application control strategy.

## Understanding Base Policies

A base policy is the primary policy that defines the fundamental rules for what applications can run on your systems. It typically includes:

- Rules for trusted publishers (Microsoft, Adobe, etc.)
- Allowances for system directories (%WINDIR%, %PROGRAMFILES%)
- Deny rules for untrusted locations (Downloads, Temp folders)
- UMCI (User Mode Code Integrity) settings

## Creating a Base Policy Using Templates

### Selecting a Template

The toolkit provides several base policy templates with different security postures:

1. **Default Windows Mode** - Most restrictive, trusts only essential Windows components and Microsoft Store apps
2. **Allow Microsoft Mode** - Trusts all Microsoft-signed software for better compatibility
3. **Signed and Reputable Mode** - Broader trust for signed and reputable applications

### Using the Command-Line Tool

To create a new base policy from a template:

```powershell
.\cli\generate-policy-from-template.ps1 -TemplatePath templates\BasePolicy_Template.xml -OutputPath MyNewBasePolicy.xml
```

### Customizing the Policy

After generating from a template, you may want to customize:

1. **Policy Version**: Update the `<VersionEx>` element
2. **Platform ID**: Change the `<PlatformID>` to a unique GUID for your organization
3. **Allowed Publishers**: Modify the `<Signers>` section to add/remove trusted publishers
4. **File Rules**: Adjust the `<FileRules>` section to refine path allowances

## Creating a Base Policy from Scratch

For advanced users who want complete control:

1. Create a new XML file with the basic WDAC policy structure:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
     <!-- Policy content here -->
   </Policy>
   ```

2. Add the required elements:
   - `<VersionEx>` - Policy version identifier
   - `<PlatformID>` - Unique platform identifier
   - `<Rules>` - Policy rules (UMCI, Audit/Enforce mode, etc.)
   - `<EKUs>` - Extended Key Usage identifiers
   - `<FileRules>` - File path and hash rules
   - `<Signers>` - Trusted certificate signers
   - `<SigningScenarios>` - Signing scenarios for kernel and user mode
   - `<UpdatePolicySigners>` - Policy update signers
   - `<HvciOptions>` - Hypervisor-protected code integrity options

## Policy Configuration Options

### Security Levels

Choose an appropriate security level based on your environment:

1. **High Security** - Minimal allowances, maximum protection
2. **Standard Security** - Balanced allowances for typical business applications
3. **Compatibility Mode** - More allowances for legacy applications

### Policy Rules

Essential rules to configure:

- `Enabled:Unsigned System Integrity Policy` - Required for modern WDAC policies
- `Enabled:Audit Mode` or `Enabled:Enforce Mode` - Determines policy behavior
- `Enabled:UMCI` - Enables User Mode Code Integrity
- `Enabled:Advanced Boot Options Menu` - Controls boot menu access
- `Required:Enforce Store Applications` - Enforces Microsoft Store app policies

## Validating Your Policy

Before deployment, always validate your policy:

```powershell
.\test-xml-validity.ps1 -PolicyPath MyNewBasePolicy.xml
```

## Testing Your Policy

Test in audit mode first to identify any legitimate applications that might be blocked:

```powershell
.\cli\convert_to_audit_mode.ps1 -PolicyPath MyNewBasePolicy.xml -OutputPath MyNewBasePolicy_Audit.xml -Deploy
```

Monitor audit logs for blocked applications and adjust your policy accordingly.

## Next Steps

- Learn about [creating supplemental policies](supplemental-policy.md) to extend your base policy
- Understand [editing existing policies](editing-policy.md) for ongoing management
- Explore [merging policies](merging-policies.md) for complex scenarios

## Troubleshooting

Common issues when creating base policies:

1. **Invalid XML Structure** - Ensure all required elements are present and properly formatted
2. **Missing Platform ID** - Base policies must have a unique PlatformID
3. **Incorrect File Paths** - Verify all file path rules use correct environment variables
4. **Certificate Issues** - Ensure certificate thumbprints are correct and properly formatted

For detailed troubleshooting, refer to the [FAQ](../guides/FAQ.md) or open an issue on our GitHub repository.