# merge_policies.ps1

This tool merges multiple WDAC policies into a single policy file.

## Overview

The `merge_policies.ps1` script combines multiple WDAC policy files into a single consolidated policy. This is useful for creating complex policies that combine base rules with supplemental and deny policies.

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
Converts the merged XML policy to binary format (.bin) after merging.

### -Validate
Validates all policies before merging and the merged policy after merging.

### -NewVersion
Specifies a new version for the merged policy.

## Usage Examples

### Basic Policy Merging

```powershell
# Merge policies using default paths
.\merge_policies.ps1

# Merge policies with custom paths
.\merge_policies.ps1 -BasePolicyPath "C:\policies\base.xml" -DenyPolicyPath "C:\policies\deny.xml" -TrustedAppPolicyPath "C:\policies\trusted.xml"
```

### Merge with Additional Policies

```powershell
# Merge with additional policies
.\merge_policies.ps1 -AdditionalPolicyPaths @("C:\policies\department1.xml", "C:\policies\department2.xml")
```

### Merge and Validate Policies

```powershell
# Validate all policies before and after merging
.\merge_policies.ps1 -Validate
```

### Merge and Convert to Binary

```powershell
# Convert merged policy to binary format
.\merge_policies.ps1 -ConvertToBinary
```

### Update Policy Version

```powershell
# Set a new version for the merged policy
.\merge_policies.ps1 -NewVersion "2.0.0.0"
```

## Merging Process

The script merges policies in the following order:

1. **Base Policy**: The foundation policy
2. **Deny Policy**: Rules that explicitly deny applications
3. **Trusted App Policy**: Rules that explicitly allow applications
4. **Additional Policies**: Any additional policies specified

Each policy is merged sequentially using the `Merge-CIPolicy` cmdlet.

## Output

The script generates:

1. A merged XML policy file at the specified output path
2. Optionally, a binary version of the policy (.bin file)
3. Validation results if the `-Validate` parameter is used

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- Administrator privileges (for some operations)

## Error Handling

The script includes comprehensive error handling:

- Validates PowerShell version compatibility
- Checks for required modules
- Verifies all policy files exist
- Handles merge conflicts
- Provides detailed error messages

## Best Practices

1. **Always validate policies** before merging using the `-Validate` parameter
2. **Test merged policies** in audit mode first
3. **Document merge operations** and the policies involved
4. **Use meaningful names** for merged policies
5. **Maintain version control** for all policies
6. **Backup original policies** before merging

## Troubleshooting

### Common Issues

1. **Merge conflicts**: Check for conflicting rules between policies
2. **Invalid policies**: Validate individual policies before merging
3. **Permission denied**: Run PowerShell as Administrator
4. **Module not found**: Ensure the ConfigCI module is available

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