# Getting Started with WDAC

This tutorial provides a comprehensive introduction to Windows Defender Application Control (WDAC) and guides you through setting up your first policies using the WDAC Enterprise Security Toolkit.

## What is WDAC?

Windows Defender Application Control (WDAC) is a Windows security feature that allows administrators to control which applications are allowed to run on Windows clients and servers. WDAC helps protect against malware and other unauthorized applications by enforcing a "zero-trust" execution model.

### Key Benefits

- **Zero-Trust Security**: Only explicitly allowed applications can run
- **Malware Prevention**: Blocks unknown and malicious executables
- **Application Whitelisting**: Granular control over permitted applications
- **Kernel Protection**: Protects against vulnerable driver installations
- **Compliance**: Helps meet regulatory and security requirements

## Prerequisites

Before starting with WDAC, ensure you have:

- Windows 10 version 1903 or later, or Windows 11
- Windows Server 2019 or later
- PowerShell 5.1 or later
- Administrator privileges on target systems
- Basic understanding of Windows security concepts

## Understanding WDAC Policy Types

### Base Policies

Base policies form the foundation of your WDAC implementation. They define the core rules that apply to all systems.

**Characteristics:**
- Has a unique PlatformID
- Can have supplemental policies
- Cannot be supplemental to another policy
- Usually deployed via Group Policy or Intune

### Supplemental Policies

Supplemental policies extend base policies with additional rules for specific departments, applications, or scenarios.

**Characteristics:**
- References a BasePolicyID
- Adds rules to an existing base policy
- Cannot exist independently
- Useful for department-specific exceptions

### Deny Policies

Deny policies explicitly block known malicious or unwanted applications.

**Characteristics:**
- Typically deployed as supplemental policies
- Contains only deny rules
- Takes precedence over allow rules
- Useful for blocking known malware

## Setting Up Your First WDAC Policy

### Step 1: Choose a Deployment Approach

Decide on your deployment approach based on your environment:

- **Group Policy**: For Active Directory environments
- **Intune**: For cloud-managed devices
- **Script Deployment**: For standalone or hybrid environments
- **Manual Deployment**: For testing and small-scale deployments

### Step 2: Select a Policy Template

The WDAC Enterprise Security Toolkit provides several templates:

1. **Base Policy Template**: A balanced policy allowing Microsoft-signed applications
2. **Allow All Template**: Permissive policy for transitioning to stricter controls
3. **Deny All Template**: Restrictive policy blocking everything by default
4. **Industry-Specific Templates**: Pre-configured for healthcare, finance, education

### Step 3: Generate Your Policy

Use the `generate-policy-from-template.ps1` script to create your policy:

```powershell
# Navigate to the tools directory
cd tools\cli

# Generate a policy from the base template
.\generate-policy-from-template.ps1 -TemplatePath "..\templates\BasePolicy_Template.xml" -Mode Audit -OutputPath "..\..\policies\my-first-policy.xml"
```

### Step 4: Customize Your Policy

Edit the generated policy to match your environment:

1. Update the PlatformID with a unique GUID for your organization
2. Review and adjust allowed publishers and file paths
3. Add any additional trusted publishers
4. Save your changes

### Step 5: Validate Your Policy

Before deployment, validate your policy:

```powershell
# Validate the policy syntax
.\test-xml-validity.ps1 -PolicyPath "..\..\policies\my-first-policy.xml"
```

### Step 6: Test in Audit Mode

Deploy in audit mode to see what would be blocked:

```powershell
# Deploy in audit mode
.\deploy-policy.ps1 -PolicyPath "..\..\policies\my-first-policy.xml" -Mode Audit -Deploy
```

### Step 7: Monitor and Analyze

Monitor audit logs to understand policy impact:

```powershell
# Generate a compliance report from audit logs
.\generate-compliance-report.ps1 -DaysBack 7 -OutputPath "..\..\reports\audit-report.html"
```

### Step 8: Transition to Enforce Mode

After validating in audit mode, transition to enforce mode:

```powershell
# Deploy in enforce mode
.\deploy-policy.ps1 -PolicyPath "..\..\policies\my-first-policy.xml" -Mode Enforce -Deploy
```

## Best Practices

### Policy Design

1. **Start with Audit Mode**: Always test policies in audit mode first
2. **Use Base and Supplemental Policies**: Create a base policy for core rules and supplemental policies for exceptions
3. **Regular Updates**: Review and update policies regularly to accommodate new applications
4. **Version Control**: Keep policies in version control to track changes and roll back if needed
5. **Documentation**: Document policy decisions and the rationale behind rules

### Deployment

1. **Phased Rollout**: Deploy to test groups first
2. **Monitor Closely**: Watch for blocked legitimate applications
3. **Have Rollback Plans**: Prepare rollback procedures before deployment
4. **Communicate Changes**: Inform users about policy changes
5. **Emergency Access**: Plan for emergency access procedures

### Maintenance

1. **Regular Reviews**: Schedule periodic policy reviews
2. **Update Certificates**: Keep certificate information current
3. **Remove Obsolete Rules**: Clean up unused rules periodically
4. **Track Exceptions**: Maintain an exception log
5. **Stay Informed**: Keep up with new threats and security recommendations

## Common Scenarios

### Developer Workstations

For developer workstations, you might need to:

1. Allow development tools (Visual Studio, VS Code, etc.)
2. Permit build tools and package managers (npm, NuGet, pip)
3. Allow containerization tools (Docker, Kubernetes)
4. Permit debugging and profiling tools

### Healthcare Environments

Healthcare environments require:

1. Electronic Health Record (EHR) systems
2. Medical imaging software
3. Laboratory information systems
4. Telemedicine platforms
5. Medical device interfaces

### Financial Services

Financial services environments need:

1. Trading platforms and analytical tools
2. Risk management software
3. Financial data providers
4. Compliance monitoring tools
5. Secure communication platforms

## Troubleshooting

### Common Issues

1. **Blocked Legitimate Applications**: Review audit logs and add exceptions
2. **Policy Deployment Failures**: Check policy syntax and system compatibility
3. **Performance Impact**: Optimize policy rules and file paths
4. **User Complaints**: Investigate blocked applications and adjust policies
5. **Emergency Access**: Use emergency policies or disable procedures

### Diagnostic Tools

1. **Event Viewer**: Check CodeIntegrity logs
2. **Audit Logs**: Analyze WDAC audit events
3. **Policy Simulator**: Test policies before deployment
4. **Compliance Reports**: Monitor policy effectiveness
5. **System Information**: Verify system compatibility

## Next Steps

After completing this tutorial:

1. Explore the [sample policies library](../../samples/README.md) for more examples
2. Review the [best practices guide](best-practices.md) for advanced techniques
3. Learn about [policy merging](policy-merging.md) for complex deployments
4. Understand [migration from AppLocker](applocker-migration.md) if applicable
5. Check out the [GUI Policy Wizard](../../WDAC-Policy-Wizard/README.md) for a visual interface

## Resources

- [Microsoft WDAC Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/)
- [WDAC Enterprise Security Toolkit](https://github.com/your-org/WDAC-Enterprise-Security)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)
- [Windows Security Documentation](https://learn.microsoft.com/en-us/windows/security/)