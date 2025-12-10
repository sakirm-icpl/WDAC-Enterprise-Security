# WDAC Sample Policies Library

This directory contains a collection of sample Windows Defender Application Control (WDAC) policies for various scenarios and use cases. These policies can be used as starting points for your own deployments or as references for best practices.

## Policy Categories

### Base Policies

Base policies form the foundation of your WDAC implementation. They define the core rules that apply to all systems.

- **[base-allow-microsoft.xml](base-policies/base-allow-microsoft.xml)** - Allows all Microsoft-signed applications and Windows Store apps
- **[base-allow-all.xml](base-policies/base-allow-all.xml)** - Allows all applications (useful for transitioning to stricter policies)
- **[base-deny-all.xml](base-policies/base-deny-all.xml)** - Denies all applications by default (most restrictive)

### Supplemental Policies

Supplemental policies extend base policies with additional rules for specific departments, applications, or scenarios.

- **[supplemental-developer-tools.xml](supplemental-policies/supplemental-developer-tools.xml)** - Allows common developer tools and IDEs
- **[supplemental-office-applications.xml](supplemental-policies/supplemental-office-applications.xml)** - Allows Microsoft Office and common productivity tools
- **[supplemental-third-party-vendors.xml](supplemental-policies/supplemental-third-party-vendors.xml)** - Allows applications from specific third-party vendors

### Deny Policies

Deny policies explicitly block known malicious or unwanted applications.

- **[deny-known-malware.xml](deny-policies/deny-known-malware.xml)** - Blocks known malware signatures
- **[deny-unwanted-applications.xml](deny-policies/deny-unwanted-applications.xml)** - Blocks common unwanted applications
- **[deny-legacy-applications.xml](deny-policies/deny-legacy-applications.xml)** - Blocks outdated and potentially insecure legacy applications

### Industry-Specific Policies

Policies tailored for specific industries with their unique requirements.

- **[healthcare-clinical-apps.xml](industry/healthcare/healthcare-clinical-apps.xml)** - Allows clinical applications commonly used in healthcare
- **[finance-trading-platforms.xml](industry/finance/finance-trading-platforms.xml)** - Allows financial trading platforms and related tools
- **[education-learning-tools.xml](industry/education/education-learning-tools.xml)** - Allows educational software and learning platforms

### Environment-Specific Policies

Policies designed for specific computing environments.

- **[server-admin-tools.xml](environments/server/server-admin-tools.xml)** - Allows server administration tools
- **[kiosk-mode-apps.xml](environments/kiosk/kiosk-mode-apps.xml)** - Restricts systems to run only specific kiosk applications
- **[remote-worker-tools.xml](environments/remote/remote-worker-tools.xml)** - Allows remote collaboration and communication tools

## Usage Guidelines

### Testing Policies

Before deploying any policy in enforcement mode, always:

1. Deploy in audit mode first
2. Monitor audit logs for blocked applications
3. Adjust policies as needed
4. Test thoroughly in a representative environment

### Merging Policies

Multiple policies can be merged using the `merge_policies.ps1` tool:

```powershell
# Merge base policy with supplemental policies
.\tools\cli\merge_policies.ps1 -BasePolicyPath .\samples\base-policies\base-allow-microsoft.xml -AdditionalPolicyPaths .\samples\supplemental-policies\supplemental-developer-tools.xml, .\samples\supplemental-policies\supplemental-office-applications.xml
```

### Customizing Policies

To customize a sample policy for your environment:

1. Copy the policy to your working directory
2. Modify the PlatformID to a unique GUID for your organization
3. Adjust file paths and rules as needed
4. Validate the policy using `test-xml-validity.ps1`
5. Test in audit mode before enforcement

## Best Practices

1. **Start with Audit Mode**: Always test policies in audit mode before enforcing them
2. **Use Base and Supplemental Policies**: Create a base policy for core rules and supplemental policies for exceptions
3. **Regular Updates**: Review and update policies regularly to accommodate new applications
4. **Version Control**: Keep policies in version control to track changes and roll back if needed
5. **Documentation**: Document policy decisions and the rationale behind rules

## Contributing

To contribute new sample policies:

1. Fork the repository
2. Create a new branch for your policy
3. Place the policy in the appropriate subdirectory
4. Add documentation explaining the policy's purpose and usage
5. Submit a pull request with your changes

## Policy Validation

All sample policies in this library have been validated for:

- XML syntax correctness
- WDAC policy structure compliance
- Common configuration best practices
- Compatibility with Windows 10/11