# rollback_policy.ps1

This tool rolls back WDAC policies to restore system functionality.

## Overview

The `rollback_policy.ps1` script provides a safe mechanism to remove or restore WDAC policies when issues occur. It can either remove the currently deployed policy or restore a previously backed up policy.

## Syntax

```powershell
rollback_policy.ps1
    [-PolicyPath <String>]
    [-BackupPath <String>]
    [-Restore]
```

## Parameters

### -PolicyPath
Specifies the path to the currently deployed policy file. Default is `C:\Windows\System32\CodeIntegrity\SIPolicy.p7b`.

### -BackupPath
Specifies the path to the backup policy file. Default is `..\policies\MergedPolicy_Backup.p7b`.

### -Restore
Performs the rollback operation by removing the active policy or restoring the backup.

## Usage Examples

### Check Policy Status
```powershell
# Check if a policy is deployed and if backups exist
.\rollback_policy.ps1
```

### Remove Active Policy
```powershell
# Remove the currently deployed policy
.\rollback_policy.ps1 -Restore
```

### Restore Backup Policy
```powershell
# Restore a previously backed up policy
.\rollback_policy.ps1 -BackupPath "C:\policies\backup.p7b" -Restore
```

## Rollback Process

The script handles rollback operations in the following way:

1. **Policy Detection**: Checks if an active policy exists at the specified path
2. **Backup Management**: Creates backups of current policies if they don't exist
3. **Restore Operations**: Either removes active policies or restores backups based on parameters
4. **System Restart**: Notifies users that a system restart is required for changes to take effect

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- Administrator privileges (mandatory for policy removal)

## Security Considerations

### Administrator Privileges
Rollback operations require administrator privileges because:
- Policies are stored in protected system directories
- System-wide security policies are modified
- Kernel-mode code integrity is affected

### Backup Strategy
Always maintain backup policies:
- Create backups before initial policy deployment
- Store backups in secure, accessible locations
- Regularly verify backup integrity
- Document backup procedures and locations

## Output

The script provides detailed console output including:
- Status information about active and backup policies
- Success messages for completed operations
- Warning messages for potential issues
- Error messages for failures
- System restart requirements

## Error Handling

The script includes comprehensive error handling:
- Validates PowerShell version compatibility
- Checks for required modules
- Verifies policy file existence
- Handles rollback errors
- Provides detailed error messages

## Best Practices

1. **Always create backups** before initial policy deployment
2. **Test rollback procedures** in non-production environments
3. **Document rollback operations** and the reasons for them
4. **Communicate with stakeholders** before performing rollbacks
5. **Plan for system restarts** after rollback operations
6. **Verify system functionality** after rollback completion

## Troubleshooting

### Common Issues

1. **Permission denied**: Run PowerShell as Administrator
2. **Policy file locked**: Ensure no other processes are accessing the policy file
3. **Backup not found**: Verify backup file path and permissions
4. **Rollback failed**: Check system event logs for details

### Diagnostic Information

The script provides detailed logging to help troubleshoot issues:
- Informational messages about the rollback process
- Warning messages for potential issues
- Error messages with specific details
- Success confirmation when operations complete

## Post-Rollback Steps

After performing a rollback:
1. **Restart the system** for changes to take effect
2. **Verify policy removal** through system checks
3. **Test system functionality** to ensure normal operation
4. **Document the rollback** for future reference
5. **Plan next steps** for policy redeployment if needed

## Related Tools

- [deploy-policy.ps1](deploy-policy.md) - Deploy policies to systems
- [convert_to_audit_mode.ps1](convert_to_audit_mode.md) - Convert policies to audit mode
- [convert_to_enforce_mode.ps1](convert_to_enforce_mode.md) - Convert policies to enforce mode

## See Also

- [WDAC Policy Management Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/windows-defender-application-control-management)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)