# deploy-policy.ps1

This tool deploys WDAC policies to Windows systems.

## Overview

The `deploy-policy.ps1` script provides a comprehensive solution for deploying WDAC policies to Windows systems. It includes validation, mode conversion, and deployment capabilities.

## Syntax

```powershell
deploy-policy.ps1
    [-PolicyPath <String>]
    [-Mode <String>]
    [-Validate]
    [-ConvertToBinary]
    [-Deploy]
    [-Force]
```

## Parameters

### -PolicyPath
Specifies the path to the policy file to deploy. Default is `.\policy.xml`.

### -Mode
Specifies the policy enforcement mode. Valid values are "Audit", "Enforce", and "None". Default is "None".

### -Validate
Validates the policy before deployment.

### -ConvertToBinary
Converts the policy to binary format before deployment.

### -Deploy
Actually deploys the policy to the system.

### -Force
Forces deployment even if a policy is already deployed.

## Usage Examples

### Basic Policy Deployment

```powershell
# Deploy a policy
.\deploy-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -Deploy
```

### Deploy in Audit Mode

```powershell
# Deploy policy in audit mode
.\deploy-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -Mode Audit -Deploy
```

### Validate Before Deployment

```powershell
# Validate policy before deployment
.\deploy-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -Validate -Deploy
```

### Convert to Binary and Deploy

```powershell
# Convert policy to binary format and deploy
.\deploy-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -ConvertToBinary -Deploy
```

### Force Deployment

```powershell
# Force deployment (overwrites existing policy)
.\deploy-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -Deploy -Force
```

## Deployment Process

The script performs the following steps during deployment:

1. **Validation**: Validates the policy if `-Validate` is specified
2. **Mode Conversion**: Converts the policy mode if `-Mode` is specified
3. **Binary Conversion**: Converts to binary format if `-ConvertToBinary` is specified
4. **Deployment**: Copies the policy to the system if `-Deploy` is specified

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- Administrator privileges (mandatory for deployment)

## Security Considerations

### Administrator Privileges
Deployment requires administrator privileges because:
- Policies are copied to protected system directories
- System-wide security policies are modified
- Kernel-mode code integrity is affected

### Policy Validation
Always validate policies before deployment:
- Use the `-Validate` parameter
- Test in audit mode first
- Review policy rules carefully

### Backup Existing Policies
Before deployment:
- Check for existing policies
- Backup current policies if needed
- Use `-Force` only when intentional

## Output

The script provides detailed console output including:

- Progress information for each step
- Success messages for completed operations
- Warning messages for potential issues
- Error messages for failures
- System restart requirements

## Error Handling

The script includes comprehensive error handling:

- Validates PowerShell version compatibility
- Checks for required modules
- Verifies policy file existence
- Handles deployment errors
- Provides detailed error messages

## Best Practices

1. **Always validate policies** before deployment using the `-Validate` parameter
2. **Test in audit mode** first before switching to enforce mode
3. **Backup existing policies** before deployment
4. **Document deployment operations** and the policies involved
5. **Use version control** for all policies
6. **Plan for system restarts** after policy deployment

## Troubleshooting

### Common Issues

1. **Permission denied**: Run PowerShell as Administrator
2. **Module not found**: Ensure the ConfigCI module is available
3. **Policy already deployed**: Use `-Force` to overwrite or backup existing policy
4. **Invalid policy**: Validate policy structure and content
5. **Deployment failed**: Check system event logs for details

### Diagnostic Information

The script provides detailed logging to help troubleshoot issues:

- Informational messages about the deployment process
- Warning messages for potential issues
- Error messages with specific details
- Success confirmation when operations complete

## Post-Deployment Steps

After deploying a policy:

1. **Restart the system** for changes to take effect
2. **Monitor audit logs** in audit mode
3. **Verify policy enforcement** in enforce mode
4. **Document the deployment** for future reference

## Related Tools

- [generate-policy-from-template.ps1](generate-policy-from-template.md) - Generate policies from templates
- [test-xml-validity.ps1](test-xml-validity.md) - Validate policy syntax
- [merge_policies.ps1](merge_policies.md) - Combine multiple policies

## See Also

- [WDAC Deployment Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/windows-defender-application-control-deployment-guide)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)