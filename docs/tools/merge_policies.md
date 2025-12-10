# merge_policies.ps1

This tool merges multiple WDAC policies into a single policy file.

## Overview

The `merge_policies.ps1` script combines multiple WDAC policy files into a single merged policy. This is useful for combining base policies, deny policies, trusted application policies, and additional supplemental policies into one comprehensive policy file.

## Syntax

```powershell
merge_policies.ps1
    [-BasePolicyPath <String>]
    [-DenyPolicyPath <String>]
    [-TrustedAppPolicyPath <String>]
    [-AdditionalPolicyPaths <String[]>]
    [-OutputPath <String>]
    [-ConvertToBinary]
    [-Validate]
    [-NewVersion <String>]
```

## Parameters

### -BasePolicyPath
Specifies the path to the base policy file. Default is `.\BasePolicy.xml`.

### -DenyPolicyPath
Specifies the path to the deny policy file. Default is `.\DenyPolicy.xml`.

### -TrustedAppPolicyPath
Specifies the path to the trusted application policy file. Default is `.\TrustedApp.xml`.

### -AdditionalPolicyPaths
Specifies an array of additional policy file paths to merge.

### -OutputPath
Specifies the path where the merged policy will be saved. Default is `.\MergedPolicy.xml`.

### -ConvertToBinary
Converts the merged policy to binary format (.bin) after merging.

### -Validate
Validates all policies before and after merging.

### -NewVersion
Specifies a new version number for the merged policy.

## Usage Examples

### Basic Policy Merge
```powershell
# Merge base, deny, and trusted app policies
.\merge_policies.ps1
```

### Merge with Custom Paths
```powershell
# Merge policies with custom paths
.\merge_policies.ps1 -BasePolicyPath "C:\policies\base.xml" -DenyPolicyPath "C:\policies\deny.xml" -TrustedAppPolicyPath "C:\policies\trusted.xml" -OutputPath "C:\policies\merged.xml"
```

### Merge with Additional Policies
```powershell
# Merge with additional supplemental policies
.\merge_policies.ps1 -AdditionalPolicyPaths @("C:\policies\department1.xml", "C:\policies\department2.xml")
```

### Merge and Convert to Binary
```powershell
# Merge policies and convert to binary format
.\merge_policies.ps1 -ConvertToBinary
```

### Merge with Validation
```powershell
# Merge policies with validation
.\merge_policies.ps1 -Validate
```

### Merge with New Version
```powershell
# Merge policies and set a new version
.\merge_policies.ps1 -NewVersion "2.0.0.0"
```

## Merge Process

The script merges policies in the following order:

1. **Base Policy**: The foundation policy that all others merge into
2. **Deny Policy**: Policies that explicitly deny applications
3. **Trusted App Policy**: Policies that explicitly allow trusted applications
4. **Additional Policies**: Any supplemental policies specified
5. **Validation**: Optional validation of the merged policy
6. **Conversion**: Optional conversion to binary format

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- Administrator privileges (for some operations)

## Output

The script generates:
1. A merged XML policy file at the specified output path
2. Optionally, a binary version of the policy (.bin file)
3. Validation results if the `-Validate` parameter is used

## Policy Merge Considerations

### Policy Types
- **Base Policies**: Foundation policies that can have supplemental policies
- **Supplemental Policies**: Extend base policies with additional rules
- **Deny Policies**: Explicitly block applications or paths
- **Trusted App Policies**: Explicitly allow specific applications

### Merge Order
Policies are merged in a specific order to ensure proper rule precedence:
1. Base policy is loaded first
2. Deny policies are merged next (deny rules take precedence)
3. Trusted app policies are merged
4. Additional policies are merged last

### Conflict Resolution
When merging policies:
- Deny rules typically take precedence over allow rules
- More specific rules override less specific ones
- Later merged policies can override earlier ones

## Best Practices

1. **Validate Policies Before Merging**: Use the `-Validate` parameter to ensure all policies are syntactically correct
2. **Test Merged Policies**: Deploy in audit mode first to verify effectiveness
3. **Document Merge Operations**: Keep records of which policies were merged and when
4. **Use Meaningful Names**: Name policies descriptively to aid in management
5. **Version Control**: Maintain version history of merged policies
6. **Backup Original Policies**: Keep copies of original policies before merging

## Troubleshooting

### Common Issues

1. **Policy validation failures**: Check policy syntax and structure
2. **Merge conflicts**: Review policy rules for overlapping or conflicting rules
3. **Missing policies**: Verify all specified policy files exist
4. **Permission denied**: Run PowerShell as Administrator if needed

### Diagnostic Information

The script provides detailed logging to help troubleshoot issues:
- Informational messages about the merge process
- Warning messages for potential issues
- Error messages with specific details
- Success confirmation when operations complete

## Related Tools

- [generate-policy-from-template.ps1](generate-policy-from-template.md) - Generate policies from templates
- [test-xml-validity.ps1](test-xml-validity.md) - Validate policy syntax
- [deploy-policy.ps1](deploy-policy.md) - Deploy policies to systems

## See Also

- [WDAC Policy Merging Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/merge-windows-defender-application-control-policies)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)