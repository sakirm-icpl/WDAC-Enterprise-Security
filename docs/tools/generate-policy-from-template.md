# generate-policy-from-template.ps1

This tool generates WDAC policy files from templates using organization configuration.

## Overview

The `generate-policy-from-template.ps1` script allows you to create customized WDAC policies by combining parameterized templates with organization-specific configuration files. This approach enables consistent policy generation across your enterprise while maintaining flexibility for different environments.

## Syntax

```powershell
generate-policy-from-template.ps1
    [-TemplatePath <String>]
    [-ConfigPath <String>]
    [-OutputPath <String>]
    [-Mode <String>]
    [-Version <String>]
    [-ConvertToBinary]
    [-Validate]
```

## Parameters

### -TemplatePath
Specifies the path to the policy template file. Default is `..\templates\parametrized-base-policy.xml`.

### -ConfigPath
Specifies the path to the organization configuration file. Default is `..\config\organization-config.json`.

### -OutputPath
Specifies the path where the generated policy will be saved. Default is `.\generated-policy.xml`.

### -Mode
Specifies the policy enforcement mode. Valid values are "Audit" and "Enforce". Default is "Audit".

### -Version
Specifies the policy version. Default is "1.0.0.0".

### -ConvertToBinary
Converts the generated XML policy to binary format (.bin) after generation.

### -Validate
Validates the generated policy for syntax and structural correctness.

## Usage Examples

### Basic Policy Generation

```powershell
# Generate a policy using default paths
.\generate-policy-from-template.ps1

# Generate a policy with custom paths
.\generate-policy-from-template.ps1 -TemplatePath "C:\templates\custom-template.xml" -ConfigPath "C:\config\myorg-config.json" -OutputPath "C:\policies\myorg-policy.xml"
```

### Generate Policy in Enforce Mode

```powershell
.\generate-policy-from-template.ps1 -Mode Enforce -Version "2.1.0.0"
```

### Generate and Validate Policy

```powershell
.\generate-policy-from-template.ps1 -Validate
```

### Generate Policy and Convert to Binary

```powershell
.\generate-policy-from-template.ps1 -ConvertToBinary
```

## Template Placeholders

The parametrized template uses the following placeholders that are replaced with values from the configuration file:

| Placeholder | Description |
|-------------|-------------|
| `{{VERSION}}` | Policy version |
| `{{MODE}}` | Enforcement mode (Audit/Enforce) |
| `{{PLATFORM_ID}}` | Organization's platform identifier |
| `{{GENERATION_DATE}}` | Policy generation date |
| `{{WINDOWS_STORE_EKU}}` | Windows Store EKU value |
| `{{MICROSOFT_PRODUCT_SIGNING_ROOT}}` | Microsoft product signing certificate root |
| `{{MICROSOFT_CODE_SIGNING_ROOT}}` | Microsoft code signing PCA 2011 root |
| `{{PROGRAM_FILES_PATH}}` | Program Files directory path |
| `{{PROGRAM_FILES_X86_PATH}}` | Program Files (x86) directory path |
| `{{WINDOWS_FOLDER_PATH}}` | Windows directory path |
| `{{DOWNLOADS_PATH}}` | User Downloads directory path |
| `{{TEMP_PATH}}` | Temp directory path |
| `{{PUBLIC_PATH}}` | Public directory path |

## Configuration File Format

The configuration file is a JSON document with the following structure:

```json
{
  "organization": {
    "name": "Organization Name",
    "platformId": "{GUID}",
    "policyVersion": "1.0.0.0"
  },
  "certificates": {
    "windowsStoreEKU": "hex_value",
    "microsoftProductSigning": "hex_value",
    "microsoftCodeSigningPCA2011": "hex_value"
  },
  "paths": {
    "programFiles": "%PROGRAMFILES%",
    "programFilesX86": "%PROGRAMFILES(X86)%",
    "windowsFolder": "%WINDIR%",
    "downloads": "%USERPROFILE%\\Downloads",
    "temp": "%TEMP%",
    "public": "%PUBLIC%"
  }
}
```

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- Administrator privileges (for some operations)

## Output

The script generates:

1. An XML policy file at the specified output path
2. Optionally, a binary version of the policy (.bin file)
3. Validation results if the `-Validate` parameter is used

## Error Handling

The script includes comprehensive error handling:

- Validates PowerShell version compatibility
- Checks for required modules
- Verifies file paths exist
- Handles XML parsing errors
- Provides detailed error messages

## Best Practices

1. **Always validate policies** before deployment using the `-Validate` parameter
2. **Test in audit mode** first before switching to enforce mode
3. **Use version control** for templates and configuration files
4. **Maintain consistent naming** conventions for policies
5. **Document policy changes** and the rationale behind them
6. **Regularly update certificates** and paths as needed

## Troubleshooting

### Common Issues

1. **Module not found**: Ensure the ConfigCI module is available
2. **Permission denied**: Run PowerShell as Administrator
3. **Invalid template**: Verify template syntax and placeholders
4. **Configuration errors**: Check JSON syntax and required fields

### Diagnostic Information

The script provides detailed logging to help troubleshoot issues:

- Informational messages about the process
- Warning messages for potential issues
- Error messages with specific details
- Success confirmation when operations complete

## Related Tools

- [test-xml-validity.ps1](test-xml-validity.md) - Validate policy syntax
- [merge_policies.ps1](merge_policies.md) - Combine multiple policies
- [deploy-policy.ps1](deploy-policy.md) - Deploy policies to systems

## See Also

- [WDAC Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)