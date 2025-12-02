# Windows Defender Application Control (WDAC) Repository - Complete Structure

This document provides an overview of the complete repository structure and its components.

## Repository Overview

This repository provides a comprehensive set of resources for implementing Windows Defender Application Control (WDAC) policies in enterprise environments. It includes policy templates, deployment scripts, documentation, and testing tools.

## Complete Directory Structure

```
.
├── architecture/                    # Architecture diagrams and design documents
│   ├── WDAC_Architecture.md        # High-level WDAC architecture diagram
│   ├── WDAC_Policy_Lifecycle.md    # Policy lifecycle flow chart
│   └── WDAC_Deployment_Process.md  # Deployment process flow chart
├── docs/                           # Comprehensive documentation
│   ├── WDAC_Full_Overview.md       # Complete WDAC overview
│   ├── Rollback_Instructions.md    # Policy rollback procedures
│   ├── guides/                     # Step-by-step implementation guides
│   │   ├── Policy_Deployment_Guide.md        # Deployment guide
│   │   └── Advanced_Policy_Configuration.md  # Advanced configuration guide
│   └── examples/                   # Detailed usage examples
│       └── Policy_Examples.md      # Practical policy examples
├── examples/                       # Practical policy examples
│   ├── templates/                  # Policy templates for common scenarios
│   │   ├── BasePolicy_Template.xml         # Base policy template
│   │   ├── DenyPolicy_Template.xml         # Deny policy template
│   │   └── TrustedAppPolicy_Template.xml   # Trusted application policy template
│   └── reference/                  # Reference implementations
│       └── MergedPolicy_Reference.xml      # Complete merged policy example
├── policies/                       # Core WDAC policy files
│   ├── BasePolicy.xml              # Base policy allowing trusted and Microsoft apps
│   ├── DenyPolicy.xml              # Policy denying untrusted locations
│   ├── TrustedApp.xml              # Explicitly trusted applications
│   └── MergedPolicy.xml            # Final merged policy
├── scripts/                        # PowerShell automation scripts
│   ├── convert_to_audit_mode.ps1   # Convert policy to audit mode
│   ├── convert_to_enforce_mode.ps1 # Deploy policy in enforce mode
│   ├── merge_policies.ps1          # Merge multiple policies
│   ├── rollback_policy.ps1         # Rollback deployed policies
│   └── utils/                      # Utility functions and helpers
│       └── WDAC-Utils.psm1         # Utility module with helper functions
├── test-files/                     # Test files for policy validation
│   ├── README.md                   # Test files directory overview
│   ├── Test_Plan.md                # Comprehensive test plan
│   ├── binaries/                   # Sample binaries for testing
│   │   ├── microsoft/             # Microsoft-signed applications
│   │   ├── third-party/          # Third-party applications
│   │   └── custom/               # Custom test applications
│   └── validation/               # Validation scripts and procedures
│       ├── README.md             # Validation scripts overview
│       ├── Test-WDACPolicy.ps1   # Policy syntax validator
│       ├── Analyze-AuditLogs.ps1 # Audit log analyzer
│       └── Deploy-TestPolicy.ps1 # Test policy deployment script
├── CONTRIBUTING.md                 # Contribution guidelines
├── LICENSE                         # License information
└── README.md                       # Main repository documentation
```

## Getting Started

### 1. Understand WDAC

Begin by reading the [WDAC Full Overview](docs/WDAC_Full_Overview.md) to understand the fundamentals of Windows Defender Application Control.

### 2. Review Policy Examples

Examine the [policy templates](examples/templates/) and [reference implementations](examples/reference/) to understand different policy approaches.

### 3. Customize Policies

Modify the policies in the [policies/](policies/) directory to match your environment's requirements.

### 4. Test Thoroughly

Use the [test plan](test-files/Test_Plan.md) and [validation scripts](test-files/validation/) to test your policies in audit mode.

### 5. Deploy Securely

Follow the [deployment guide](docs/guides/Policy_Deployment_Guide.md) to deploy policies in enforce mode.

## Key Components

### Policy Files

The [policies/](policies/) directory contains ready-to-use policy files:
- [BasePolicy.xml](policies/BasePolicy.xml): Core policy allowing trusted applications
- [DenyPolicy.xml](policies/DenyPolicy.xml): Policy blocking untrusted locations
- [TrustedApp.xml](policies/TrustedApp.xml): Policy for explicitly trusted applications
- [MergedPolicy.xml](policies/MergedPolicy.xml): Combined policy ready for deployment

### Scripts

The [scripts/](scripts/) directory contains PowerShell scripts for policy management:
- [merge_policies.ps1](scripts/merge_policies.ps1): Merges multiple policy files
- [convert_to_audit_mode.ps1](scripts/convert_to_audit_mode.ps1): Converts policies to audit mode
- [convert_to_enforce_mode.ps1](scripts/convert_to_enforce_mode.ps1): Converts policies to enforce mode
- [rollback_policy.ps1](scripts/rollback_policy.ps1): Rolls back deployed policies

### Documentation

The [docs/](docs/) directory contains comprehensive documentation:
- [WDAC Full Overview](docs/WDAC_Full_Overview.md): Complete introduction to WDAC
- [Policy Deployment Guide](docs/guides/Policy_Deployment_Guide.md): Step-by-step deployment instructions
- [Advanced Policy Configuration](docs/guides/Advanced_Policy_Configuration.md): Advanced configuration techniques
- [Policy Examples](docs/examples/Policy_Examples.md): Practical policy examples

### Testing

The [test-files/](test-files/) directory contains resources for policy testing:
- [Test Plan](test-files/Test_Plan.md): Comprehensive testing procedures
- [Validation Scripts](test-files/validation/): Tools for policy validation
- [Test Binaries](test-files/binaries/): Sample applications for testing

## Best Practices

1. **Always test in audit mode first** - Never deploy policies in enforce mode without thorough testing
2. **Start with permissive policies** - Begin with broader policies and gradually tighten restrictions
3. **Maintain detailed documentation** - Document all policy changes and their rationale
4. **Regular policy reviews** - Periodically review and update policies to reflect changing requirements
5. **Backup policies** - Always maintain backups of working policies before making changes
6. **Monitor audit logs** - Regularly review audit logs to identify legitimate applications that may be blocked

## Contributing

We welcome contributions to improve this repository. Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Support

For issues with this repository, please file GitHub issues. For WDAC-specific questions, consult Microsoft documentation or support channels.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.