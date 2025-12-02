# Windows Defender Application Control (WDAC) Repository

This repository contains a comprehensive set of Windows Defender Application Control (WDAC) policies, scripts, documentation, and examples for implementing application whitelisting and control in enterprise environments.

## Repository Structure

```
├── architecture/                    # Architecture diagrams and design documents
├── docs/                           # Comprehensive documentation
│   ├── guides/                     # Step-by-step implementation guides
│   ├── examples/                   # Detailed usage examples
│   ├── WDAC_Full_Overview.md       # Complete WDAC overview
│   └── Rollback_Instructions.md    # Policy rollback procedures
├── examples/                       # Practical policy examples
│   ├── templates/                  # Policy templates for common scenarios
│   └── reference/                  # Reference implementations
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
├── test-files/                     # Test files for policy validation
│   ├── binaries/                   # Sample binaries for testing
│   └── validation/                 # Validation scripts and procedures
└── LICENSE                         # License information
```

## Getting Started

1. Review the [WDAC Full Overview](docs/WDAC_Full_Overview.md) to understand WDAC fundamentals
2. Examine the [policy templates](examples/templates/) for common use cases
3. Customize policies in the [policies/](policies/) directory for your environment
4. Use scripts in [scripts/](scripts/) to merge and deploy policies
5. Test in [Audit mode](scripts/convert_to_audit_mode.ps1) before enforcing
6. Deploy [enforce mode](scripts/convert_to_enforce_mode.ps1) policy on target machines
7. Use [rollback procedures](docs/Rollback_Instructions.md) as needed

## Quick Start

For the fastest path to implementation, see our [Quick Start Guide](QUICK_START.md) which provides minimal steps to deploy basic WDAC policies.

## Prerequisites

- Windows 10/11 Pro, Enterprise, or Education (version 1903 or later)
- PowerShell 5.1 or later
- Administrator privileges for policy deployment

## Documentation

### Core Documentation
- [WDAC Full Overview](docs/WDAC_Full_Overview.md) - Complete introduction to WDAC
- [Implementation Guides](docs/guides/) - Step-by-step deployment instructions
- [Usage Examples](docs/examples/) - Practical scenarios and examples
- [Architecture Diagrams](architecture/) - Visual representations of WDAC workflows

### Advanced Guides
- [Policy Deployment Guide](docs/guides/Policy_Deployment_Guide.md) - Detailed deployment procedures
- [Advanced Policy Configuration](docs/guides/Advanced_Policy_Configuration.md) - Complex policy techniques
- [Policy Rule Comparison](docs/guides/Policy_Rule_Comparison.md) - Choosing the right rule types
- [Migration Guide](docs/guides/Migration_Guide.md) - Moving from other solutions
- [Compliance Mapping](docs/guides/Compliance_Mapping.md) - Regulatory framework alignment
- [FAQ](docs/guides/FAQ.md) - Common questions and answers
- [Version Compatibility Matrix](docs/guides/Version_Compatibility_Matrix.md) - Feature support across versions

## Contributing

We welcome contributions to improve this repository. Please see our [contribution guidelines](CONTRIBUTING.md) for more information.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.