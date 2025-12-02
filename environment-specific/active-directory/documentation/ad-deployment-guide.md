# Active Directory WDAC Deployment Guide

## Overview

This guide provides detailed instructions for deploying Windows Defender Application Control (WDAC) policies in Active Directory environments using Group Policy Objects (GPOs). This approach offers centralized management and automated policy distribution to domain-joined systems.

## Prerequisites

- Active Directory domain with domain controllers
- Domain administrator privileges
- Windows 10/11 Pro, Enterprise, or Education (version 1903 or later)
- PowerShell 5.1 or later
- SYSVOL replication functioning properly

## Deployment Process

### 1. Prepare Policy Files

First, ensure your WDAC policy files are ready:
- Base policy (enterprise-base-policy.xml)
- Supplemental policies (department-specific policies)
- Exception policies (emergency access policies)

Convert XML policies to binary format:
```powershell
# Convert base policy
ConvertFrom-CIPolicy -XmlFilePath "enterprise-base-policy.xml" -BinaryFilePath "enterprise-base-policy.bin"

# Convert supplemental policies
ConvertFrom-CIPolicy -XmlFilePath "finance-policy.xml" -BinaryFilePath "finance-policy.bin"
ConvertFrom-CIPolicy -XmlFilePath "hr-policy.xml" -BinaryFilePath "hr-policy.bin"
ConvertFrom-CIPolicy -XmlFilePath "it-policy.xml" -BinaryFilePath "it-policy.bin"

# Convert exception policies
ConvertFrom-CIPolicy -XmlFilePath "emergency-access-policy.xml" -BinaryFilePath "emergency-access-policy.bin"
```

### 2. Create Group Policy Object

Create a new GPO for WDAC policy deployment:
```powershell
# Using PowerShell
New-GPO -Name "WDAC Enterprise Policy" | New-GPLink -Target "OU=Workstations,DC=company,DC=com"
```

Or using Group Policy Management Console:
1. Open Group Policy Management
2. Right-click the appropriate OU
3. Select "Create a GPO in this domain, and Link it here"
4. Name the GPO "WDAC Enterprise Policy"

### 3. Configure GPO Settings

Navigate to:
Computer Configuration → Policies → Administrative Templates → System → Device Guard

Enable the following settings:
- **Turn On Virtualization Based Security** - Enabled
- **Configure Code Integrity Policy** - Enabled
- **Deploy Code Integrity Policy** - Enabled

For the "Deploy Code Integrity Policy" setting:
1. Click "Show Files" to open the policy file location
2. Copy your binary policy files to this location
3. In the policy setting, specify the base policy file

### 4. Deploy Supplemental Policies

For department-specific policies:
1. Create additional GPOs for each department
2. Link to appropriate OUs
3. Deploy supplemental policies using the same process

### 5. Verify Deployment

Check policy deployment on client systems:
```powershell
# Check Device Guard status
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard

# Check Code Integrity policy status
Get-CimInstance -ClassName Win32_CodeIntegrityPolicy -Namespace root\Microsoft\Windows\CodeIntegrity
```

### 6. Monitor and Maintain

Use the monitoring scripts provided:
- [monitor-ad-systems.ps1](../scripts/monitor-ad-systems.ps1) - For ongoing monitoring
- [update-ad-policy.ps1](../scripts/update-ad-policy.ps1) - For policy updates

## Best Practices

1. **Start with Audit Mode**: Deploy policies in audit mode first to identify legitimate applications
2. **Phased Rollout**: Deploy to pilot groups before full organization rollout
3. **Regular Updates**: Schedule regular policy reviews and updates
4. **Exception Management**: Establish clear processes for temporary policy exceptions
5. **Documentation**: Maintain detailed documentation of all policies and changes

## Troubleshooting

### Common Issues

1. **Policy Not Applying**
   - Verify GPO linking to correct OUs
   - Check SYSVOL replication status
   - Force group policy update: `gpupdate /force`

2. **Application Blocking**
   - Check CodeIntegrity operational logs
   - Use audit mode to identify required applications
   - Update policies with appropriate allowances

3. **Performance Issues**
   - Modern WDAC implementations have minimal performance impact
   - Check for conflicting security software

### Useful Commands

```powershell
# Force group policy update
gpupdate /force

# Check GPO replication status
repadmin /syncall

# View CodeIntegrity events
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-CodeIntegrity/Operational'; ID=3076,3077,3089}

# Check current policy status
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
```

## Security Considerations

- Protect policy files from unauthorized modification
- Use signed policies where possible
- Implement least privilege principles
- Regular compliance auditing
- Secure GPO permissions

This guide provides a comprehensive approach to deploying WDAC policies in Active Directory environments. Following these steps will help ensure successful implementation while maintaining security and operational efficiency.