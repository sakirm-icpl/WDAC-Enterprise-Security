# convert_to_enforce_mode.ps1

This tool converts WDAC policies to enforce mode for active protection.

## Overview

The `convert_to_enforce_mode.ps1` script modifies WDAC policy files to enable enforce mode, which actively blocks unauthorized applications based on policy rules. In enforce mode, policy violations prevent application execution.

## Syntax

```powershell
convert_to_enforce_mode.ps1
    [-PolicyPath <String>]
    [-OutputPath <String>]
    [-Deploy]
```

## Parameters

### -PolicyPath
Specifies the path to the policy file to convert to enforce mode. Default is `..\policies\MergedPolicy.xml`.

### -OutputPath
Specifies the path where the converted enforce policy will be saved. Default is `..\policies\MergedPolicy_Enforce.xml`.

### -Deploy
Deploys the converted policy to the system after conversion.

## Usage Examples

### Basic Conversion
```powershell
# Convert a policy to enforce mode
.\convert_to_enforce_mode.ps1 -PolicyPath "C:\policies\my-policy.xml"
```

### Convert with Custom Output Path
```powershell
# Convert with custom output path
.\convert_to_enforce_mode.ps1 -PolicyPath "C:\policies\my-policy.xml" -OutputPath "C:\policies\enforce-policy.xml"
```

### Convert and Deploy
```powershell
# Convert to enforce mode and deploy immediately
.\convert_to_enforce_mode.ps1 -PolicyPath "C:\policies\my-policy.xml" -Deploy
```

## Conversion Process

The script converts policies to enforce mode by:

1. **Adding Enforce Mode Rule**: Inserts the "Enabled:Enforce Mode" option into the policy
2. **Removing Audit Mode Rule**: Removes any existing "Enabled:Audit Mode" option
3. **Saving Policy**: Writes the modified policy to the output file
4. **Deploying Policy**: Optionally deploys the policy to the system

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- Administrator privileges (for deployment)

## Output

The script generates:
1. An XML policy file in enforce mode at the specified output path
2. Optionally, a binary version of the policy (.p7b file)
3. Deployment of the policy if the `-Deploy` parameter is used

## Security Considerations

### Before Deployment
1. **Test in audit mode first** to identify applications that would be blocked
2. **Review all policy rules** to ensure they align with business requirements
3. **Create backup policies** before deployment
4. **Plan for system restart** after deployment

### During Deployment
1. **Run as Administrator** to ensure proper permissions
2. **Monitor deployment logs** for errors
3. **Verify deployment success** through system checks

## Best Practices

1. **Always test in audit mode** before switching to enforce mode
2. **Have rollback plans** ready before deployment
3. **Communicate with users** about potential application blocking
4. **Monitor system performance** after deployment
5. **Document policy changes** and deployment procedures

## Troubleshooting

### Common Issues

1. **Permission denied**: Run PowerShell as Administrator
2. **Module not found**: Ensure the ConfigCI module is available
3. **Invalid policy**: Verify policy structure and content
4. **Deployment failed**: Check system event logs for details
5. **Applications blocked**: Review audit logs from audit mode testing

### Diagnostic Information

The script provides detailed logging to help troubleshoot issues:
- Informational messages about the conversion process
- Warning messages for potential issues
- Error messages with specific details
- Success confirmation when operations complete

## Related Tools

- [convert_to_audit_mode.ps1](convert_to_audit_mode.md) - Convert policies to audit mode
- [test-xml-validity.ps1](test-xml-validity.md) - Validate policy syntax
- [deploy-policy.ps1](deploy-policy.md) - Deploy policies to systems

## See Also

- [WDAC Enforce Mode Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/windows-defender-application-control)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)