# Quick Start Guide

This guide provides the fastest path to creating and deploying your first WDAC policy using the WDAC Policy Toolkit.

## Prerequisites

Ensure you've completed the [installation process](install-process.md) and verified that your system meets all requirements.

## Creating Your First Policy

### Option 1: Using Pre-built Templates

1. Navigate to the samples directory:
   ```powershell
   cd samples
   ```

2. Select a base policy template that matches your security requirements:
   - `BasePolicy.xml` - Standard base policy allowing Microsoft-signed applications
   - Review other sample policies for different security postures

3. Copy the selected policy to your working directory:
   ```powershell
   Copy-Item BasePolicy.xml MyFirstPolicy.xml
   ```

### Option 2: Using Command-Line Tools

1. Navigate to the tools directory:
   ```powershell
   cd tools
   ```

2. Generate a new policy from a template:
   ```powershell
   .\cli\generate-policy-from-template.ps1 -TemplatePath templates\BasePolicy_Template.xml -OutputPath ..\MyFirstPolicy.xml
   ```

## Testing Your Policy in Audit Mode

Before enforcing your policy, test it in audit mode to identify any legitimate applications that might be blocked:

1. Convert your policy to audit mode:
   ```powershell
   .\cli\convert_to_audit_mode.ps1 -PolicyPath ..\MyFirstPolicy.xml -OutputPath ..\MyFirstPolicy_Audit.xml -Deploy
   ```

2. Monitor audit logs for blocked applications:
   ```powershell
   .\analyze-audit-logs.ps1
   ```

## Deploying Your Policy in Enforcement Mode

Once you've verified your policy in audit mode:

1. Convert your policy to enforcement mode:
   ```powershell
   .\cli\convert_to_enforce_mode.ps1 -PolicyPath ..\MyFirstPolicy.xml -OutputPath ..\MyFirstPolicy_Enforce.xml -Deploy
   ```

2. Restart your computer to activate the policy

## Managing Your Policy

### Adding Exceptions

To add exceptions to your policy:

1. Edit your policy XML file to add allow rules for specific applications
2. Or use the merge utility to combine policies:
   ```powershell
   .\cli\merge_policies.ps1 -BasePolicyPath ..\MyFirstPolicy.xml -SupplementalPolicyPath ..\ExceptionPolicy.xml -OutputPath ..\MyUpdatedPolicy.xml
   ```

### Rolling Back Changes

If you need to rollback your policy:

```powershell
.\cli\rollback_policy.ps1 -Restore
```

Then restart your computer.

## Next Steps

- Review the [Policy Creation Guide](../using/base-policy.md) for detailed instructions on creating custom policies
- Explore [Advanced Policy Configuration](../guides/Advanced_Policy_Configuration.md) for complex scenarios
- Learn about [Policy Deployment Methods](../guides/Policy_Deployment_Guide.md) for enterprise environments

## Getting Help

For issues or questions:

1. Check the [FAQ](../guides/FAQ.md)
2. Review existing [GitHub issues](../../CONTRIBUTING.md#reporting-issues)
3. [Open a new issue](../../CONTRIBUTING.md#reporting-issues) if needed