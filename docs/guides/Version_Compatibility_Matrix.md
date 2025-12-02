# WDAC Version Compatibility Matrix

This document provides a comprehensive compatibility matrix for Windows Defender Application Control (WDAC) features across different Windows versions and hardware configurations.

## Windows Version Compatibility

### Windows 10

| Feature | Version 1507 | Version 1511 | Version 1607 | Version 1703 | Version 1709 | Version 1803 | Version 1809 | Version 1903 | Version 1909 | Version 2004 | Version 20H2 | Version 21H1 | Version 21H2 | Version 22H2 |
|---------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|
| Basic WDAC | No | No | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Supplemental Policies | No | No | No | No | No | No | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Managed Installer | No | No | No | No | No | No | No | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Dynamic Rule Generation | No | No | No | No | No | No | No | No | No | Yes | Yes | Yes | Yes | Yes |
| User Mode Code Integrity (UMCI) | No | No | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| HVCI Support | No | No | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Audit Mode | No | No | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Enforce Mode | No | No | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Script Enforcement | No | No | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| AppX/MSIX Support | No | No | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |

### Windows 11

| Feature | Version 21H2 | Version 22H2 | Version 23H2 |
|---------|--------------|--------------|--------------|
| Basic WDAC | Yes | Yes | Yes |
| Supplemental Policies | Yes | Yes | Yes |
| Managed Installer | Yes | Yes | Yes |
| Dynamic Rule Generation | Yes | Yes | Yes |
| User Mode Code Integrity (UMCI) | Yes | Yes | Yes |
| HVCI Support | Yes | Yes | Yes |
| Audit Mode | Yes | Yes | Yes |
| Enforce Mode | Yes | Yes | Yes |
| Script Enforcement | Yes | Yes | Yes |
| AppX/MSIX Support | Yes | Yes | Yes |
| Advanced Event Logging | Yes | Yes | Yes |
| Policy Refresh Without Reboot | Yes | Yes | Yes |

### Windows Server

| Feature | 2016 | 2019 | 2022 | 2025 |
|---------|------|------|------|------|
| Basic WDAC | Yes | Yes | Yes | Yes |
| Supplemental Policies | Yes | Yes | Yes | Yes |
| Managed Installer | Yes | Yes | Yes | Yes |
| Dynamic Rule Generation | Yes | Yes | Yes | Yes |
| User Mode Code Integrity (UMCI) | Yes | Yes | Yes | Yes |
| HVCI Support | Yes | Yes | Yes | Yes |
| Audit Mode | Yes | Yes | Yes | Yes |
| Enforce Mode | Yes | Yes | Yes | Yes |
| Script Enforcement | Yes | Yes | Yes | Yes |
| AppX/MSIX Support | Yes | Yes | Yes | Yes |
| Server Core Support | Yes | Yes | Yes | Yes |
| Nano Server Support | Limited | Limited | Limited | Limited |

## Hardware Compatibility

### CPU Architecture

| Feature | x86 | x64 | ARM64 |
|---------|-----|-----|-------|
| Basic WDAC | No | Yes | Yes |
| Supplemental Policies | No | Yes | Yes |
| Managed Installer | No | Yes | Yes |
| Dynamic Rule Generation | No | Yes | Yes |
| User Mode Code Integrity (UMCI) | No | Yes | Yes |
| HVCI Support | No | Yes | Yes |
| Audit Mode | No | Yes | Yes |
| Enforce Mode | No | Yes | Yes |
| Script Enforcement | No | Yes | Yes |

### Virtualization-Based Security (VBS) Requirements

| Component | Requirement | Notes |
|-----------|-------------|-------|
| CPU | Intel VT-x or AMD-V | Hardware virtualization support |
| BIOS/UEFI | Virtualization enabled | Must be enabled in firmware |
| TPM | 2.0 | Required for Credential Guard |
| Secure Boot | Required | Ensures boot integrity |
| Memory | 4GB minimum | Recommended 8GB or more |
| Storage | SATA, NVMe, or USB 3.0+ | For policy storage |

## PowerShell Version Compatibility

| Feature | PowerShell 3.0 | PowerShell 4.0 | PowerShell 5.0 | PowerShell 5.1 | PowerShell 7.0+ |
|---------|----------------|----------------|----------------|----------------|------------------|
| Code Integrity Cmdlets | Limited | Limited | Yes | Yes | Yes |
| New-CIPolicy | No | No | Yes | Yes | Yes |
| Merge-CIPolicy | No | No | Yes | Yes | Yes |
| ConvertFrom-CIPolicy | No | No | Yes | Yes | Yes |
| Get-CimInstance Support | Limited | Limited | Yes | Yes | Yes |
| Advanced Policy Management | No | No | Limited | Yes | Yes |

## Policy Format Compatibility

### XML Schema Versions

| Schema Version | Windows 10 Version | Features | Notes |
|----------------|-------------------|----------|-------|
| 1.0 | 1607+ | Basic policy elements | Legacy format |
| 2.0 | 1903+ | Supplemental policies | Enhanced features |
| 2.1 | 2004+ | Dynamic rules | Latest enhancements |
| 2.2 | 21H1+ | Advanced scenarios | Current version |

### Policy Type Compatibility

| Policy Type | Minimum Windows Version | Notes |
|-------------|-------------------------|-------|
| Base Policy | 1607 | Core policy functionality |
| Supplemental Policy | 1809 | Requires base policy |
| Audit Policy | 1607 | Separate audit-only policies |
| Signed Policy | 1607 | Requires certificate infrastructure |
| Unsigned Policy | 1607 | Development/testing only |

## Feature-Specific Requirements

### Managed Installer

| Component | Requirement |
|-----------|-------------|
| Windows Version | 1903+ |
| Installer Type | Supported managed installers |
| Policy Configuration | Managed Installer rule enabled |
| Group Policy | Device Guard policy settings |

### Dynamic Rule Generation

| Component | Requirement |
|-----------|-------------|
| Windows Version | 2004+ |
| Audit Mode | Required for learning |
| Event Log Access | Administrative privileges |
| PowerShell | 5.1+ |

### HVCI (Hypervisor-Protected Code Integrity)

| Component | Requirement |
|-----------|-------------|
| Windows Version | 1607+ |
| CPU | Intel VT-x or AMD-V |
| VBS | Enabled in Group Policy |
| Compatible Drivers | WHQL-signed or HVCI-compatible |
| Memory | Sufficient for hypervisor |

## Deployment Method Compatibility

### Group Policy Deployment

| Windows Version | Supported | Notes |
|-----------------|-----------|-------|
| Windows 10 1607+ | Yes | Native support |
| Windows 11 | Yes | Native support |
| Windows Server 2016+ | Yes | Native support |
| Domain Requirements | Yes | Requires Active Directory |

### Microsoft Intune Deployment

| Feature | Supported | Notes |
|---------|-----------|-------|
| Windows 10 | Yes | Requires Azure AD join |
| Windows 11 | Yes | Native support |
| Windows Server | Limited | Workarounds may be needed |
| Profile Types | Yes | Multiple profile options |

### SCCM/ConfigMgr Deployment

| Feature | Supported | Notes |
|---------|-----------|-------|
| Windows 10 | Yes | Native support |
| Windows 11 | Yes | Native support |
| Windows Server | Yes | Native support |
| Package Types | Yes | Various deployment methods |

## Performance Considerations by Version

### Policy Load Times

| Windows Version | Approximate Load Time | Notes |
|-----------------|----------------------|-------|
| 1607-1803 | 2-5 seconds | Basic policy loading |
| 1809-1909 | 1-3 seconds | Improved performance |
| 2004+ | <1 second | Optimized loading |
| Windows 11 | <1 second | Best performance |

### Memory Usage

| Policy Complexity | Memory Impact | Notes |
|-------------------|---------------|-------|
| Simple (100 rules) | <10MB | Minimal impact |
| Medium (1000 rules) | 10-50MB | Moderate impact |
| Complex (10000+ rules) | 50MB+ | Significant impact |
| Hash-heavy policies | Higher | More processing required |

## Known Issues and Limitations

### Windows 10 1607-1803

| Issue | Description | Workaround |
|-------|-------------|------------|
| No Supplemental Policies | Cannot extend base policies | Monolithic policy approach |
| Limited Event Logging | Fewer audit events | Manual monitoring |
| No Managed Installer | Cannot trust installers | Manual policy updates |

### Windows 10 1903-1909

| Issue | Description | Workaround |
|-------|-------------|------------|
| Dynamic Rule Bugs | Occasional policy generation issues | Manual rule creation |
| Performance with Large Policies | Slower policy processing | Policy optimization |
| Limited Intune Support | Fewer deployment options | Group Policy preferred |

### Windows Server Limitations

| Issue | Description | Workaround |
|-------|-------------|------------|
| Nano Server Support | Limited WDAC features | Use Server Core instead |
| GUI Dependencies | Some tools require desktop | Use PowerShell alternatives |
| Driver Compatibility | HVCI may block drivers | Update to compatible drivers |

## Best Practices by Version

### For Windows 10 1607-1803

1. Use monolithic policy approach
2. Implement thorough testing procedures
3. Maintain detailed policy documentation
4. Plan for manual policy updates

### For Windows 10 1903+

1. Leverage supplemental policies
2. Implement managed installer rules
3. Use dynamic rule generation for testing
4. Take advantage of enhanced event logging

### For Windows 11

1. Utilize latest policy schema features
2. Implement advanced event monitoring
3. Leverage performance optimizations
4. Use modern deployment methods

### For Windows Server

1. Test driver compatibility with HVCI
2. Plan for server-specific deployment methods
3. Consider Core vs Desktop experience needs
4. Implement server-specific monitoring

## Upgrade Path Recommendations

### From Windows 10 1607-1803

1. Plan for supplemental policy implementation
2. Prepare for managed installer adoption
3. Update deployment procedures
4. Enhance monitoring capabilities

### From Windows 10 1903-1909

1. Adopt dynamic rule generation
2. Implement advanced policy features
3. Update to latest policy schema
4. Enhance performance monitoring

### From Older WDAC Implementations

1. Review policy compatibility
2. Update policy schema versions
3. Implement new security features
4. Optimize policy performance

This compatibility matrix helps ensure successful WDAC implementation across different environments and provides guidance for planning upgrades and feature adoption.