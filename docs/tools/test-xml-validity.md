# test-xml-validity.ps1

This tool validates WDAC policy XML files for syntax and structure.

## Overview

The `test-xml-validity.ps1` script performs comprehensive validation of WDAC policy XML files to ensure they conform to the required schema and structure. This helps identify syntax errors, missing elements, and other issues before deployment.

## Syntax

```powershell
test-xml-validity.ps1
    -PolicyPath <String>
    [-DetailedLogging]
    [-FixIssues]
    [-OutputPath <String>]
```

## Parameters

### -PolicyPath
Specifies the path to the policy file to validate. This parameter is mandatory.

### -DetailedLogging
Enables detailed logging to a temporary file for troubleshooting.

### -FixIssues
Attempts to automatically fix common policy issues.

### -OutputPath
Specifies the path where the fixed policy will be saved when using `-FixIssues`.

## Usage Examples

### Basic Policy Validation
```powershell
# Validate a policy file
.\test-xml-validity.ps1 -PolicyPath "C:\policies\my-policy.xml"
```

### Detailed Logging
```powershell
# Enable detailed logging for troubleshooting
.\test-xml-validity.ps1 -PolicyPath "C:\policies\my-policy.xml" -DetailedLogging
```

### Fix Common Issues
```powershell
# Attempt to fix common policy issues
.\test-xml-validity.ps1 -PolicyPath "C:\policies\my-policy.xml" -FixIssues -OutputPath "C:\policies\fixed-policy.xml"
```

## Validation Process

The script performs the following validation checks:

### XML Structure Validation
- Verifies the file is valid XML
- Checks for proper XML syntax and formatting
- Ensures the root Policy element exists

### Required Element Checks
- **VersionEx**: Policy version information
- **Rules**: Policy rules container
- **FileRules**: File-based rules container
- **SigningScenarios**: Signing scenario definitions

### Policy Type Validation
- **Base Policy**: Checks for PlatformID requirement
- **Supplemental Policy**: Checks for BasePolicyID requirement

### Common Issue Detection
- Missing VersionEx element
- Missing PlatformID in Base policies
- Incorrect BasePolicyID in Base policies
- Missing Rules element
- Invalid rule options

## Automatic Fixes

When using the `-FixIssues` parameter, the script can automatically fix:

### Missing Elements
- **VersionEx**: Adds default version "1.0.0.0"
- **PlatformID**: Adds default placeholder GUID for Base policies
- **Rules**: Creates empty Rules element
- **FileRules**: Creates empty FileRules element
- **SigningScenarios**: Creates empty SigningScenarios element

### Policy Type Corrections
- **Base Policy**: Removes incorrect BasePolicyID elements
- **Supplemental Policy**: Adds BasePolicyID placeholder (requires manual update)

## Output

The script provides:

1. Console output showing validation results
2. Exit codes indicating success (0) or failure (1)
3. Optional detailed logging to a temporary file
4. Fixed policy file when using `-FixIssues`

## Exit Codes

- **0**: Policy is valid or issues were successfully fixed
- **1**: Policy validation failed or an error occurred

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- Administrator privileges (recommended but not required)

## Supported Policy Types

The script validates the following policy types:

### Base Policy
- Requires PlatformID element
- Should not have BasePolicyID element
- Supports all base policy features

### Supplemental Policy
- Requires BasePolicyID element
- Extends an existing base policy
- Cannot exist independently

## Common Validation Issues

### Missing Required Elements
- **VersionEx**: Essential for policy versioning
- **PlatformID**: Required for Base policies
- **Rules**: Container for policy rules
- **FileRules**: Container for file-based rules

### Policy Type Issues
- **Base Policy with BasePolicyID**: Incorrect structure
- **Supplemental Policy without BasePolicyID**: Missing reference
- **Invalid PolicyType value**: Unsupported policy type

### Rule Validation
- **Invalid rule options**: Unsupported or misspelled options
- **Missing rule elements**: Incomplete rule definitions
- **Conflicting rules**: Potentially problematic rule combinations

## Best Practices

1. **Validate Before Deployment**: Always validate policies before deployment
2. **Use Automated Fixes Carefully**: Review auto-fixed policies before deployment
3. **Maintain Version Control**: Track policy changes in version control systems
4. **Document Validation Results**: Keep records of validation outcomes
5. **Regular Validation**: Validate policies regularly as part of maintenance
6. **Team Validation**: Have multiple team members validate critical policies

## Troubleshooting

### Common Issues

1. **XML parsing errors**: Check for malformed XML syntax
2. **Missing elements**: Add required elements as indicated
3. **Policy type mismatches**: Correct policy type-specific requirements
4. **Invalid rule options**: Refer to WDAC documentation for valid options

### Diagnostic Information

The script provides detailed logging to help troubleshoot issues:

- Informational messages about the validation process
- Warning messages for potential issues
- Error messages with specific details
- Line numbers for XML parsing errors

## Security Considerations

### File Access
The script reads policy files but does not modify them (unless using `-FixIssues`):
- Requires read access to policy files
- Does not execute or modify files by default
- Fixed policies are saved to new files

### Data Privacy
The script handles policy configuration data:
- Policy files contain security configuration information
- Detailed logs may contain sensitive data
- Store validation results securely

## Related Tools

- [deploy-policy.ps1](deploy-policy.md) - Deploy policies to systems
- [merge_policies.ps1](merge_policies.md) - Combine multiple policies
- [generate-policy-from-template.ps1](generate-policy-from-template.md) - Generate policies from templates

## See Also

- [WDAC Policy Schema Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/wdac-wizard)
- [PowerShell XML Processing](https://learn.microsoft.com/en-us/powershell/scripting/developer/help/writing-help-for-windows-powershell-cmdlets)
- [WDAC Policy Structure](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/understand-windows-defender-application-control-policy-design)