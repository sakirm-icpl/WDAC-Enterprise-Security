# test-xml-validity.ps1

This tool validates WDAC policy XML files for syntax and structure.

## Overview

The `test-xml-validity.ps1` script performs comprehensive validation of WDAC policy XML files to ensure they conform to the required structure and contain all necessary elements. It can also automatically fix common policy issues.

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
Specifies the path to the WDAC policy XML file to validate. This parameter is mandatory.

### -DetailedLogging
Enables detailed logging to a temporary file for troubleshooting.

### -FixIssues
Attempts to automatically fix common policy issues.

### -OutputPath
Specifies the path where the fixed policy should be saved when using the `-FixIssues` parameter.

## Usage Examples

### Basic Policy Validation

```powershell
# Validate a policy file
.\test-xml-validity.ps1 -PolicyPath "C:\policies\my-policy.xml"
```

### Validate with Detailed Logging

```powershell
# Validate with detailed logging
.\test-xml-validity.ps1 -PolicyPath "C:\policies\my-policy.xml" -DetailedLogging
```

### Validate and Fix Issues

```powershell
# Validate and fix common issues
.\test-xml-validity.ps1 -PolicyPath "C:\policies\my-policy.xml" -FixIssues -OutputPath "C:\policies\fixed-policy.xml"
```

## Validation Checks

The script performs the following validation checks:

### XML Structure
- Valid XML syntax
- Presence of root Policy element
- Correct namespace declaration

### Required Elements
- VersionEx element
- Rules element with proper structure
- FileRules element
- SigningScenarios element
- PolicyType attribute

### Policy-Type Specific Checks
- Base policies: PlatformID presence
- Supplemental policies: BasePolicyID presence
- Invalid elements for policy type

### Rule Validation
- Valid rule options
- Proper rule structure
- No conflicting rules

### Common Issues Fixed
When using the `-FixIssues` parameter, the script can automatically fix:

- Missing VersionEx element
- Missing PlatformID in Base policies
- Incorrect BasePolicyID in Base policies
- Missing Rules element
- Invalid rule options

## Output

The script provides detailed console output including:

- Validation progress information
- Success messages for passing checks
- Warning messages for potential issues
- Error messages for failing checks
- Summary of validation results

### Exit Codes
- `0`: Policy is valid
- `1`: Policy has validation errors
- `2`: Script execution error

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- Administrator privileges (for some operations)

## Best Practices

1. **Always validate policies** before deployment
2. **Use detailed logging** when troubleshooting validation failures
3. **Review fixed policies** before deployment
4. **Integrate validation** into your CI/CD pipeline
5. **Document validation results** for audit purposes

## Troubleshooting

### Common Issues

1. **XML parsing errors**: Check for malformed XML syntax
2. **Missing elements**: Ensure all required elements are present
3. **Invalid policy type**: Verify PolicyType attribute value
4. **Certificate issues**: Check certificate references and values

### Diagnostic Information

With detailed logging enabled, the script writes additional information to:
`$env:TEMP\WDAC_XML_Test_Log.txt`

This log includes:
- Timestamped entries
- Detailed validation steps
- Raw error messages
- Processing information

## Integration Examples

### Batch Validation Script

```powershell
# Validate all policies in a directory
Get-ChildItem -Path "C:\policies" -Filter "*.xml" | ForEach-Object {
    Write-Host "Validating $($_.Name)"
    .\test-xml-validity.ps1 -PolicyPath $_.FullName
}
```

### CI/CD Pipeline Integration

```yaml
# Example GitHub Actions workflow step
- name: Validate WDAC Policies
  run: |
    Get-ChildItem -Path policies -Filter "*.xml" | ForEach-Object {
      .\tools\test-xml-validity.ps1 -PolicyPath $_.FullName
      if ($LASTEXITCODE -ne 0) {
        throw "Policy validation failed for $($_.Name)"
      }
    }
```

## Related Tools

- [generate-policy-from-template.ps1](generate-policy-from-template.md) - Generate policies from templates
- [merge_policies.ps1](merge_policies.md) - Combine multiple policies
- [deploy-policy.ps1](deploy-policy.md) - Deploy policies to systems

## See Also

- [WDAC Policy Structure Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/wdac-policy-schema)
- [PowerShell XML Processing](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-xml)