# WDAC Policy Deployment Guide

This guide provides step-by-step instructions for deploying WDAC policies in your environment.

## Prerequisites

Before deploying WDAC policies, ensure the following prerequisites are met:

- Windows 10 version 1903 or later, Windows 11, or Windows Server 2016 or later
- PowerShell 5.1 or later
- Administrative privileges on target systems
- Understanding of your organization's application landscape

## Deployment Process

### Step 1: Environment Assessment

1. Inventory all applications currently running in your environment
2. Identify trusted publishers and applications
3. Determine untrusted locations (Downloads, Temp folders, etc.)
4. Plan your policy architecture (base policy + supplemental policies)

### Step 2: Policy Preparation

Navigate to the repository root and prepare your policies:

```powershell
# Review and customize the base policy
notepad policies\BasePolicy.xml

# Review and customize the deny policy
notepad policies\DenyPolicy.xml

# Review and customize the trusted applications policy
notepad policies\TrustedApp.xml
```

### Step 3: Policy Merging

Merge the individual policies into a single policy file:

```powershell
cd scripts
.\merge_policies.ps1
```

This script will:
- Merge BasePolicy.xml, DenyPolicy.xml, and TrustedApp.xml
- Create MergedPolicy.xml in the policies directory
- Optionally convert the policy to binary format

### Step 4: Audit Mode Testing

Before enforcing the policy, test it in audit mode to identify potential issues:

```powershell
# Convert the merged policy to audit mode
.\convert_to_audit_mode.ps1

# Deploy the audit policy
.\convert_to_audit_mode.ps1 -Deploy
```

After deployment, restart the computer and monitor the audit logs for blocked applications.

### Step 5: Audit Log Analysis

Review the audit logs to identify legitimate applications that were blocked:

```powershell
# View recent Code Integrity events
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-CodeIntegrity/Operational'; Level=2} -MaxEvents 20
```

Add any legitimate applications to your trusted policy as needed.

### Step 6: Enforce Mode Deployment

Once satisfied with the audit results, deploy the policy in enforce mode:

```powershell
# Convert the merged policy to enforce mode
.\convert_to_enforce_mode.ps1

# Deploy the enforce policy
.\convert_to_enforce_mode.ps1 -Deploy
```

Restart the computer to activate the enforce policy.

### Step 7: Post-Deployment Verification

Verify that the policy is working correctly:

```powershell
# Check policy status
Import-Module .\utils\WDAC-Utils.psm1
Get-WDACStatus
```

Monitor for any unexpected blocking events and adjust policies as needed.

## Deployment Methods

### Local Deployment

For individual systems or small deployments, use the scripts directly on each system.

### Group Policy Deployment

1. Open Group Policy Management Console
2. Create or edit a Group Policy Object
3. Navigate to Computer Configuration > Policies > Administrative Templates > System > Device Guard
4. Configure "Deploy Windows Defender Application Control Policy"
5. Specify the path to your policy file

### Intune Deployment

1. In Microsoft Endpoint Manager admin center, go to Devices > Configuration profiles
2. Create a new profile with platform "Windows 10 and later"
3. Select profile type "Templates" > "Windows Defender Application Control"
4. Upload your policy file and configure settings
5. Assign to appropriate device groups

### SCCM/ConfigMgr Deployment

1. Create a new application or package containing your policy file
2. Create a deployment script that copies the policy to the target systems
3. Schedule the deployment through ConfigMgr

## Monitoring and Maintenance

### Ongoing Monitoring

Regularly monitor Code Integrity events:

```powershell
# Check for recent blocking events
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-CodeIntegrity/Operational'; Id=3076} -MaxEvents 10
```

### Policy Updates

When new applications need to be added:

1. Update the appropriate policy XML file
2. Merge policies using merge_policies.ps1
3. Test in audit mode
4. Deploy updated policy in enforce mode

### Performance Considerations

Monitor system performance after policy deployment:
- CPU usage during application launches
- Memory consumption
- Boot times

Large or complex policies may impact system performance.

## Troubleshooting

### Common Issues

1. **System Won't Boot**: Use Safe Mode or WinRE to remove the policy
2. **Critical Applications Blocked**: Review audit logs and add appropriate rules
3. **Policy Not Applying**: Verify policy file location and permissions
4. **Performance Degradation**: Simplify complex policies

### Diagnostic Commands

```powershell
# Check if CI policy is loaded
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard

# View Code Integrity events
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-CodeIntegrity/Operational'} -MaxEvents 50

# Check policy file details
Get-ItemProperty "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
```

## Rollback Procedures

If issues occur after deployment, follow the rollback procedures in [Rollback_Instructions.md](Rollback_Instructions.md).

## Additional Resources

- [WDAC Full Overview](WDAC_Full_Overview.md)
- [Policy Templates](../examples/templates/)
- [Reference Implementations](../examples/reference/)
- Microsoft Documentation: [Deploy Windows Defender Application Control policies](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/windows-defender-application-control-deployment-guide)