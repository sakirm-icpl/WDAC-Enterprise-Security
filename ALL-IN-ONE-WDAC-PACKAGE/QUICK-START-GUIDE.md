# Quick Start Guide for WDAC Enterprise Security

This guide provides the fastest path to implementing Windows Defender Application Control (WDAC) in your environment.

## Prerequisites

- Windows 10 version 1903 or later, Windows 11, or Windows Server 2016 or later
- PowerShell 5.1 or later
- Administrative privileges
- Basic understanding of Windows security concepts

## Step 1: Environment Selection

Determine your environment type:
- **Active Directory**: If you have a domain environment with Group Policy
- **Non-AD**: If you have standalone or workgroup systems
- **Hybrid**: If you have a mix of both

## Step 2: Policy Selection

Choose the appropriate policy set from the `/policies` directory:
- For Active Directory environments, use policies in `/policies/ACTIVE-DIRECTORY/`
- For Non-AD environments, use policies in `/policies/NON-AD/`
- For Hybrid environments, use policies in `/policies/HYBRID/`

## Step 3: Policy Customization

Edit the policies to match your environment:

1. Open the base policy file in a text editor
2. Review allowed publishers and paths
3. Update PlatformID to a unique GUID for your organization
4. Add any additional trusted publishers
5. Save your changes

## Step 4: Policy Merging

Combine the policies into a single deployment file:

```powershell
cd scripts
.\merge-policies.ps1
```

This creates a merged policy file with all your rules.

## Step 5: Test in Audit Mode

Before enforcing, test the policy in audit mode:

```powershell
.\convert-to-audit-mode.ps1 -Deploy
```

Restart your computer when prompted.

## Step 6: Monitor Audit Logs

Review audit logs to identify any legitimate applications that would be blocked:

```powershell
# View recent Code Integrity events
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-CodeIntegrity/Operational'; Level=2} -MaxEvents 20
```

Add any legitimate applications to your trusted policy as needed.

## Step 7: Deploy in Enforce Mode

Once satisfied with audit results, deploy in enforce mode:

```powershell
.\convert-to-enforce-mode.ps1 -Deploy
```

Restart your computer when prompted.

## Step 8: Verify Deployment

Check that the policy is active:

```powershell
Import-Module .\scripts\SHARED\utils.psm1
Get-WDACStatus
```

## Common Deployment Scenarios

### Scenario 1: Basic Enterprise Deployment

1. Use the provided base policy as-is
2. Customize deny policy to block specific locations in your environment
3. Test and deploy in audit mode for one week
4. Review logs and adjust as needed
5. Deploy in enforce mode

### Scenario 2: Highly Secure Environment

1. Start with audit mode only
2. Use hash rules for all applications
3. Monitor for 2-4 weeks
4. Create specific allow rules based on audit data
5. Deploy in enforce mode

### Scenario 3: Department-Specific Policies

1. Deploy base policy organization-wide
2. Create supplemental policies for specific departments
3. Deploy supplemental policies to appropriate groups

## Troubleshooting Quick Reference

### Policy Not Applying

1. Verify policy file exists at `C:\Windows\System32\CodeIntegrity\SIPolicy.p7b`
2. Check that policy is properly signed (if required)
3. Restart computer to ensure policy loads

### Legitimate Applications Blocked

1. Review audit logs to identify blocked applications
2. Add appropriate allow rules to trusted policy
3. Merge and redeploy policies

### Performance Issues

1. Simplify complex policies
2. Use publisher rules instead of hash rules when possible
3. Remove unused rules

## Next Steps

After successful deployment:

1. Monitor audit logs regularly
2. Update policies as new applications are deployed
3. Review and refine policies quarterly
4. Document all policy changes

## Additional Resources

- [Implementation Guide](docs/IMPLEMENTATION-GUIDE.md)
- [Real-World Use Cases](docs/REAL-WORLD-USE-CASES.md)
- Template policies in the `/templates` directory
- Testing scripts in the `/testing` directory

For detailed information on any of these steps, refer to the documentation in the respective directories.