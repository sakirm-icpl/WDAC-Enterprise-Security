# convert-applocker-to-wdac.ps1

This tool converts AppLocker policies to WDAC policies.

## Overview

The `convert-applocker-to-wdac.ps1` script transforms existing AppLocker policies into equivalent WDAC policies. This facilitates migration from AppLocker to WDAC for organizations looking to leverage advanced application control capabilities.

## Syntax

```powershell
convert-applocker-to-wdac.ps1
    -AppLockerPolicyPath <String>
    [-OutputPath <String>]
    [-ConvertToBinary]
    [-Validate]
```

## Parameters

### -AppLockerPolicyPath
Specifies the path to the AppLocker policy file to convert. This parameter is mandatory.

### -OutputPath
Specifies the path where the converted WDAC policy will be saved. Default is `.\converted-wdac-policy.xml`.

### -ConvertToBinary
Converts the converted WDAC policy to binary format (.bin) after conversion.

### -Validate
Validates the converted WDAC policy for syntax and structural correctness.

## Usage Examples

### Basic Conversion

```powershell
# Convert an AppLocker policy to WDAC
.\convert-applocker-to-wdac.ps1 -AppLockerPolicyPath "C:\applocker\policy.xml"
```

### Convert with Custom Output Path

```powershell
# Convert with custom output path
.\convert-applocker-to-wdac.ps1 -AppLockerPolicyPath "C:\applocker\policy.xml" -OutputPath "C:\wdac\converted-policy.xml"
```

### Convert and Validate

```powershell
# Convert and validate the resulting policy
.\convert-applocker-to-wdac.ps1 -AppLockerPolicyPath "C:\applocker\policy.xml" -Validate
```

### Convert and Create Binary Version

```powershell
# Convert and create binary version
.\convert-applocker-to-wdac.ps1 -AppLockerPolicyPath "C:\applocker\policy.xml" -ConvertToBinary
```

## Conversion Process

The script converts AppLocker policies to WDAC policies by:

1. **Parsing AppLocker Rules**: Reads and interprets AppLocker policy rules
2. **Mapping Rule Types**: Converts AppLocker rule types to equivalent WDAC constructs
3. **Creating WDAC Structure**: Builds a compliant WDAC policy structure
4. **Preserving Logic**: Maintains the security logic of the original policy

### Supported Rule Conversions

| AppLocker Rule Type | WDAC Equivalent | Status |
|---------------------|-----------------|--------|
| FilePathRule | Allow/Deny FilePath rules | ✅ Supported |
| FileHashRule | Allow/Deny FileHash rules | ✅ Supported |
| FilePublisherRule | Signer rules | ✅ Supported |
| Exe Rules | Executable rules | ✅ Supported |
| Dll Rules | Library rules | ✅ Supported |
| Script Rules | Script rules | ✅ Supported |
| Msi Rules | Installer rules | ✅ Supported |

## Output

The script generates:

1. A converted WDAC XML policy file at the specified output path
2. Optionally, a binary version of the policy (.bin file)
3. Validation results if the `-Validate` parameter is used

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- Administrator privileges (for some operations)

## Limitations

### Unsupported Features

Some AppLocker features don't have direct WDAC equivalents:

- **Rule Collections**: WDAC uses a unified policy structure
- **User/Group Context**: WDAC policies apply system-wide
- **Audit Only Mode**: WDAC has separate audit mode configuration
- **Custom Rule Types**: Some specialized rules may need manual adjustment

### Manual Review Required

After conversion, review the following:

- **Certificate Information**: May require manual certificate data entry
- **Path Substitutions**: Environment variables may need adjustment
- **Rule Specificity**: Some rules may be more permissive than intended
- **Publisher Rules**: Certificate thumbprints may need updating

## Best Practices

1. **Review Converted Policies** carefully before deployment
2. **Test in Audit Mode** first to validate effectiveness
3. **Compare Coverage** between original and converted policies
4. **Document Differences** and required adjustments
5. **Maintain Original Policies** until migration is complete
6. **Validate Security Posture** after conversion

## Troubleshooting

### Common Issues

1. **Unsupported rule types**: Some specialized rules may not convert
2. **Missing certificate data**: Publisher rules may need manual updates
3. **Path translation issues**: Environment variables may not translate correctly
4. **Permission denied**: Run PowerShell as Administrator if needed

### Diagnostic Information

The script provides detailed logging to help troubleshoot issues:

- Informational messages about the conversion process
- Warning messages for potential issues
- Error messages with specific details
- Success confirmation when operations complete

## Migration Workflow

### Step 1: Prepare AppLocker Policies

```powershell
# Export existing AppLocker policies
Get-AppLockerPolicy -Effective -Xml > "C:\applocker\effective-policy.xml"
```

### Step 2: Convert Policies

```powershell
# Convert the policy
.\convert-applocker-to-wdac.ps1 -AppLockerPolicyPath "C:\applocker\effective-policy.xml" -OutputPath "C:\wdac\converted-policy.xml" -Validate
```

### Step 3: Review and Adjust

- Compare original and converted policies
- Adjust certificate information as needed
- Fine-tune path rules
- Add additional security rules

### Step 4: Test Converted Policies

```powershell
# Deploy in audit mode for testing
.\deploy-policy.ps1 -PolicyPath "C:\wdac\converted-policy.xml" -Mode Audit -Deploy
```

### Step 5: Deploy in Enforce Mode

```powershell
# Deploy in enforce mode after validation
.\deploy-policy.ps1 -PolicyPath "C:\wdac\converted-policy.xml" -Mode Enforce -Deploy
```

## Related Tools

- [generate-policy-from-template.ps1](generate-policy-from-template.md) - Generate policies from templates
- [test-xml-validity.ps1](test-xml-validity.md) - Validate policy syntax
- [merge_policies.ps1](merge_policies.md) - Combine multiple policies
- [deploy-policy.ps1](deploy-policy.md) - Deploy policies to systems

## See Also

- [AppLocker Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/applocker/applocker-overview)
- [WDAC Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/windows-defender-application-control)
- [Migration Guide](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/migrate-from-applocker-to-windows-defender-application-control)