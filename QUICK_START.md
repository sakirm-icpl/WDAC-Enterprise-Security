# Quick Start Guide

This guide provides the fastest path to implementing Windows Defender Application Control (WDAC) in your environment.

## Prerequisites

- Windows 10 version 1903 or later, Windows 11, or Windows Server 2016 or later
- PowerShell 5.1 or later
- Administrative privileges
- Basic understanding of Windows security concepts

## Step 1: Download Repository

Clone or download this repository to your local system:

```powershell
git clone https://github.com/sakirm-icpl/WDAC-Enterprise-Security.git
cd WDAC-Enterprise-Security
```

## Step 2: Review Policies

Examine the provided policies in the [policies/](policies/) directory:

- [BasePolicy.xml](policies/BasePolicy.xml) - Core policy allowing trusted applications
- [DenyPolicy.xml](policies/DenyPolicy.xml) - Policy blocking untrusted locations
- [TrustedApp.xml](policies/TrustedApp.xml) - Policy for explicitly trusted applications

## Step 3: Customize Policies

Edit the policies to match your environment:

1. Open [policies/BasePolicy.xml](policies/BasePolicy.xml) in a text editor
2. Review allowed publishers and paths
3. Add any additional trusted publishers
4. Save your changes

## Step 4: Merge Policies

Combine the policies into a single deployment file:

```powershell
cd scripts
.\merge_policies.ps1
```

This creates [policies/MergedPolicy.xml](policies/MergedPolicy.xml) with all your rules.

## Step 5: Test in Audit Mode

Before enforcing, test the policy in audit mode:

```powershell
.\convert_to_audit_mode.ps1 -Deploy
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
.\convert_to_enforce_mode.ps1 -Deploy
```

Restart your computer when prompted.

## Step 8: Verify Deployment

Check that the policy is active:

```powershell
Import-Module .\utils\WDAC-Utils.psm1
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

- [Full WDAC Overview](docs/WDAC_Full_Overview.md)
- [Policy Deployment Guide](docs/guides/Policy_Deployment_Guide.md)
- [Rollback Instructions](docs/Rollback_Instructions.md)
- [Advanced Configuration Guide](docs/guides/Advanced_Policy_Configuration.md)

For detailed information on any of these steps, refer to the full documentation in the [docs/](docs/) directory.