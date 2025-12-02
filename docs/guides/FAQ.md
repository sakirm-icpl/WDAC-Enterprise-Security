# WDAC Frequently Asked Questions (FAQ)

This document addresses common questions about Windows Defender Application Control (WDAC) implementation, troubleshooting, and best practices.

## General Questions

### What is WDAC?

Windows Defender Application Control (WDAC) is a Windows security feature that controls which applications can run on Windows 10, Windows 11, and Windows Server systems. It implements a zero-trust execution model by allowing only trusted applications to execute while blocking all others.

### How does WDAC differ from AppLocker?

WDAC is the successor to AppLocker with several key improvements:
- Kernel-level enforcement for stronger security
- Better performance with large policy sets
- Support for modern application formats (MSIX, etc.)
- Integration with virtualization-based security (VBS)
- Enhanced policy management capabilities

### What are the system requirements for WDAC?

WDAC requires:
- Windows 10 version 1903 or later
- Windows 11 (all versions)
- Windows Server 2016 or later
- PowerShell 5.1 or later
- Administrative privileges for policy deployment

### Can WDAC be used with other security solutions?

Yes, WDAC complements other security solutions:
- Works alongside traditional antivirus software
- Integrates with Endpoint Detection and Response (EDR) solutions
- Compatible with network firewalls and IPS systems
- Can be part of a defense-in-depth security strategy

## Policy Questions

### What policy rule types are supported?

WDAC supports four main rule types:
1. **Publisher Rules**: Based on digital signatures
2. **Path Rules**: Based on file system paths
3. **Hash Rules**: Based on cryptographic hashes
4. **File Attribute Rules**: Based on file metadata

### Which rule type should I use?

The choice depends on your security requirements and environment:
- **Publisher Rules**: Best for enterprise environments with signed applications
- **Path Rules**: Good for organized file structures
- **Hash Rules**: Highest security for critical applications
- **File Attribute Rules**: Flexible option for various scenarios

### How do I create a basic WDAC policy?

1. Start with the base policy templates in this repository
2. Customize allowed publishers and paths for your environment
3. Add deny policies for high-risk locations
4. Test in audit mode before enforcing
5. Deploy in enforce mode after validation

### Can I combine multiple policy files?

Yes, WDAC supports policy merging:
- Base policies define core rules
- Supplemental policies extend base policies
- Use the `Merge-CIPolicy` PowerShell cmdlet to combine policies
- Policies are merged in a logical hierarchy

## Deployment Questions

### How do I deploy WDAC policies?

WDAC policies can be deployed through:
1. **Group Policy**: Computer Configuration > Policies > Administrative Templates > System > Device Guard
2. **Microsoft Intune**: Device configuration profiles
3. **SCCM/ConfigMgr**: Application or package deployment
4. **Manual Deployment**: Copy policy file to `C:\Windows\System32\CodeIntegrity\SIPolicy.p7b`

### Do I need to restart after deploying a policy?

Yes, a system restart is required for:
- Initial policy deployment
- Policy updates
- Switching between audit and enforce modes

### How do I test policies before enforcing them?

1. Deploy policies in audit mode using `Enabled:Audit Mode` rule
2. Monitor Code Integrity operational logs
3. Review blocked application attempts
4. Refine policies based on audit findings
5. Only deploy in enforce mode after thorough testing

### What happens if I deploy a restrictive policy?

If a policy is too restrictive:
- Legitimate applications may be blocked
- Users may experience functionality issues
- System stability could be affected
- Always test in audit mode first and have rollback procedures

## Troubleshooting Questions

### How do I check if a WDAC policy is active?

Use PowerShell to check policy status:
```powershell
# Check if CI policy is loaded
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard

# Check policy file details
Get-ItemProperty "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
```

### How do I view WDAC audit logs?

WDAC audit logs are in the Event Viewer:
- **Log Location**: Applications and Services Logs > Microsoft > Windows > CodeIntegrity > Operational
- **Key Events**: 
  - Event ID 3076: Unsigned policy blocked
  - Event ID 3077: Unsigned file blocked
  - Event ID 3089: File hash not authorized

### What should I do if legitimate applications are blocked?

1. Review audit logs to identify blocked applications
2. Add appropriate allow rules to your policy
3. Merge and redeploy the updated policy
4. Test the changes in audit mode first

### How do I rollback a WDAC policy?

Several rollback options are available:
1. **Remove Policy File**: Delete `C:\Windows\System32\CodeIntegrity\SIPolicy.p7b`
2. **Use Rollback Script**: Run the provided rollback script in audit mode
3. **Boot in Safe Mode**: WDAC is disabled in Safe Mode
4. **Windows Recovery Environment**: Remove policy file from WinRE

## Performance Questions

### Does WDAC impact system performance?

WDAC has minimal performance impact:
- Policy loading is optimized for fast boot times
- Application launch overhead is typically negligible
- Large or complex policies may have minor impact
- Hash-based policies may have slightly higher overhead

### How can I optimize WDAC policy performance?

1. **Use Publisher Rules**: When possible, as they're more efficient than hash rules
2. **Minimize Policy Size**: Remove unused rules regularly
3. **Avoid Redundancy**: Eliminate overlapping or duplicate rules
4. **Organize Rules Logically**: Place frequently matched rules earlier in the policy

### What is the maximum policy size?

WDAC policies can be quite large:
- Theoretical limit is several megabytes
- Practical limit depends on system resources
- Very large policies may impact performance
- Consider supplemental policies for complex environments

## Security Questions

### How secure is WDAC?

WDAC provides strong security through:
- Kernel-level enforcement that's difficult to bypass
- Integration with Virtualization-Based Security (VBS)
- Cryptographic policy signing to prevent tampering
- Comprehensive audit logging for monitoring

### Can WDAC policies be bypassed?

While WDAC is very secure, potential bypass scenarios include:
- Kernel-mode exploits (extremely difficult)
- Policy misconfigurations
- Physical access to systems
- Vulnerabilities in signed applications
- Proper implementation minimizes these risks

### How do I secure WDAC policies?

To secure WDAC policies:
1. **Sign Policies**: Use code signing certificates for production policies
2. **Protect Policy Files**: Use appropriate file system permissions
3. **Regular Updates**: Keep policies current with environment changes
4. **Monitor Logs**: Regularly review audit logs for anomalies

## Integration Questions

### Can WDAC integrate with SIEM solutions?

Yes, WDAC integrates with SIEM solutions:
- Audit logs are available through Windows Event Log
- Events can be forwarded to SIEM through standard mechanisms
- Custom dashboards can be created for WDAC monitoring
- Alerting can be configured for policy violations

### How does WDAC work with cloud management?

WDAC works well with cloud management:
- **Microsoft Intune**: Native support for WDAC policy deployment
- **Azure Policy**: Can enforce WDAC compliance requirements
- **Cloud Monitoring**: Audit logs can be sent to cloud monitoring solutions
- **Automated Deployment**: CI/CD pipelines can deploy policies

### Does WDAC support modern applications?

Yes, WDAC supports modern application formats:
- **MSIX/AppX**: Native support for modern Windows applications
- **Store Apps**: Windows Store applications are supported
- **Packaged Apps**: Support for various application packaging formats
- **Containerized Apps**: Works with Windows container technologies

## Best Practices Questions

### What are the best practices for WDAC implementation?

Key best practices include:
1. **Start Simple**: Begin with permissive policies and gradually tighten
2. **Test Extensively**: Always use audit mode before enforce mode
3. **Document Everything**: Maintain detailed policy documentation
4. **Monitor Continuously**: Regularly review audit logs
5. **Plan for Updates**: Design policies with maintenance in mind

### How often should I update WDAC policies?

Policy update frequency depends on your environment:
- **Highly Dynamic**: Weekly reviews and updates
- **Standard Enterprise**: Monthly reviews
- **Stable Environment**: Quarterly reviews
- **Regulatory Requirements**: As needed for compliance

### How do I handle application updates?

Application update handling varies by rule type:
- **Publisher Rules**: Automatic for same publisher updates
- **Hash Rules**: Require new rules for each version
- **Path Rules**: Generally unaffected by updates
- **File Attributes**: May require updates for version changes

## Advanced Questions

### Can I use multiple WDAC policies simultaneously?

Yes, WDAC supports multiple policy types:
- **Base Policies**: Primary policies defining core rules
- **Supplemental Policies**: Extend base policies with additional rules
- **Audit Policies**: Separate policies for audit-only scenarios
- **Exception Policies**: Handle specific exception cases

### How does WDAC handle policy conflicts?

When policies conflict:
- Most restrictive rule typically wins
- Deny rules generally take precedence over allow rules
- Policy order can affect evaluation
- Supplemental policies extend rather than override base policies

### Can I automate WDAC policy management?

Yes, automation is possible through:
- **PowerShell Scripts**: For policy creation, merging, and deployment
- **CI/CD Pipelines**: For automated policy testing and deployment
- **Configuration Management**: Tools like Ansible, Puppet, or Chef
- **Custom Solutions**: Using WDAC APIs for specialized requirements

### What are the limitations of WDAC?

Current WDAC limitations include:
- Requires modern Windows versions
- Learning curve for complex policy creation
- Maintenance overhead for hash-based policies
- Limited support for some legacy application scenarios

## Support Questions

### Where can I get help with WDAC?

Support resources include:
- **Microsoft Documentation**: Official WDAC documentation
- **Tech Community**: Microsoft Tech Community forums
- **Professional Services**: Microsoft Premier Support
- **Community Resources**: GitHub repositories and forums
- **This Repository**: Comprehensive guides and examples

### How do I report issues with this repository?

To report issues:
1. **GitHub Issues**: Create issues in the repository
2. **Pull Requests**: Submit improvements through PRs
3. **Community Forums**: Discuss issues in relevant forums
4. **Contact Maintainers**: Reach out to repository maintainers directly

### How can I contribute to this repository?

Contributions are welcome:
1. **Bug Fixes**: Submit PRs for identified issues
2. **New Features**: Add new policies or scripts
3. **Documentation**: Improve existing documentation
4. **Testing**: Help validate policies in different environments
5. **Examples**: Share real-world policy examples

By understanding these frequently asked questions, you can more effectively implement and manage WDAC in your environment. For additional support, refer to the comprehensive documentation in this repository or seek assistance from the community.