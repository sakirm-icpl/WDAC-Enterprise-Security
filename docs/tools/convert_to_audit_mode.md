# convert_to_audit_mode.ps1

This tool converts WDAC policies to audit mode for testing purposes.

## Overview

The `convert_to_audit_mode.ps1` script modifies WDAC policy files to enable audit mode, which allows administrators to test policies without blocking applications. In audit mode, policy violations are logged but not enforced.

## Syntax

```powershell
convert_to_audit_mode.ps1
    [-PolicyPath <String>]
    [-OutputPath <String>]
    [-Deploy]
```

## Parameters

### -PolicyPath
Specifies the path to the policy file to convert to audit mode. Default is `..\policies\MergedPolicy.xml`.

### -OutputPath
Specifies the path where the converted audit policy will be saved. Default is `..\policies\MergedPolicy_Audit.xml`.

### -Deploy
Deploys the converted policy to the system after conversion.

## Usage Examples

### Basic Conversion
```powershell
# Convert a policy to audit mode
.\convert_to_audit_mode.ps1 -PolicyPath "C:\policies\my-policy.xml"
```

### Convert with Custom Output Path
```powershell
# Convert with custom output path
.\convert_to_audit_mode.ps1 -PolicyPath "C:\policies\my-policy.xml" -OutputPath "C:\policies\audit-policy.xml"
```

### Convert and Deploy
```powershell
# Convert to audit mode and deploy immediately
.\convert_to_audit_mode.ps1 -PolicyPath "C:\policies\my-policy.xml" -Deploy
```

## Conversion Process

The script converts policies to audit mode by:

1. **Adding Audit Mode Rule**: Inserts the "Enabled:Audit Mode" option into the policy
2. **Removing Enforce Mode Rule**: Removes any existing "Enabled:Enforce Mode" option
3. **Saving Policy**: Writes the modified policy to the output file
4. **Deploying Policy**: Optionally deploys the policy to the system

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- Administrator privileges (for deployment)

## Output

The script generates:
1. An XML policy file in audit mode at the specified output path
2. Optionally, a binary version of the policy (.p7b file)
3. Deployment of the policy if the `-Deploy` parameter is used

## Best Practices

1. **Always backup policies** before converting to audit mode
2. **Monitor audit logs** to identify applications that would be blocked
3. **Review audit findings** before switching to enforce mode
4. **Document policy changes** and the rationale behind them
5. **Test thoroughly** in audit mode before enforcement

## Troubleshooting

### Common Issues

1. **Permission denied**: Run PowerShell as Administrator
2. **Module not found**: Ensure the ConfigCI module is available
3. **Invalid policy**: Verify policy structure and content
4. **Deployment failed**: Check system event logs for details

### Diagnostic Information

The script provides detailed logging to help troubleshoot issues:
- Informational messages about the conversion process
- Warning messages for potential issues
- Error messages with specific details
- Success confirmation when operations complete

## Related Tools

- [convert_to_enforce_mode.ps1](convert_to_enforce_mode.md) - Convert policies to enforce mode
- [test-xml-validity.ps1](test-xml-validity.md) - Validate policy syntax
- [deploy-policy.ps1](deploy-policy.md) - Deploy policies to systems

## See Also

- [WDAC Audit Mode Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/audit-windows-defender-application-control-policies)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)