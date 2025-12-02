# WDAC Policy Rollback Instructions

This document provides detailed instructions for rolling back WDAC policies in case of issues or emergencies.

## When to Use Rollback Procedures

Rollback procedures should be used in the following situations:

- Critical business applications are blocked and cannot be quickly remediated
- System instability occurs after policy deployment
- Emergency access is required to blocked administrative tools
- Policy conflicts cause system boot issues

## Prerequisites

Before performing a rollback, ensure you have:

- Administrative privileges on the target system
- Access to the system console (physical or remote desktop)
- Backup copies of the deployed policy (if available)
- Understanding of the system's boot process

## Method 1: Standard Rollback Using Provided Scripts

The repository includes a rollback script that automates the rollback process:

```powershell
# Navigate to the scripts directory
cd scripts

# Run the rollback script
.\rollback_policy.ps1 -Restore
```

This script will:
1. Check for an active policy at `C:\Windows\System32\CodeIntegrity\SIPolicy.p7b`
2. Create a backup if one doesn't already exist
3. Remove the active policy file
4. Prompt for a system restart

## Method 2: Manual Rollback

If the automated script is unavailable, you can manually rollback the policy:

### Step 1: Boot into Safe Mode

1. Restart the computer
2. Press and hold Shift while clicking Restart
3. Select Troubleshoot > Advanced Options > Startup Settings
4. Click Restart
5. Press F4 to boot in Safe Mode

### Step 2: Remove Policy File

Open an elevated Command Prompt or PowerShell and execute:

```cmd
del "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
```

### Step 3: Restart Normally

Restart the computer to boot normally without the WDAC policy.

## Method 3: Using Windows Recovery Environment (WinRE)

If the system won't boot normally:

1. Boot from Windows installation media
2. Select Repair your computer
3. Choose Troubleshoot > Advanced Options > Command Prompt
4. Execute the following commands:

```cmd
diskpart
list volume
# Note the drive letter for your Windows installation (typically C:)
exit

del "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
```

5. Restart the computer

## Post-Rollback Verification

After rollback, verify that:

1. The system boots normally
2. Previously blocked applications now execute
3. No residual policy artifacts remain
4. System stability is restored

## Prevention and Best Practices

To minimize the need for rollbacks:

- Always test policies in audit mode first
- Deploy policies to a small group before broad rollout
- Maintain detailed documentation of policy changes
- Keep backup copies of previous policy versions
- Implement gradual policy tightening rather than restrictive initial policies

## Emergency Contacts

In case of emergency rollback requirements outside business hours, contact:

- IT Security Team: security@yourcompany.com
- System Administrators: admins@yourcompany.com

## Additional Resources

- [WDAC Full Overview](WDAC_Full_Overview.md)
- [Policy Deployment Guide](guides/Policy_Deployment_Guide.md)
- Microsoft Documentation: [Windows Defender Application Control](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/)