# Windows Defender Application Control (WDAC) Policy Toolkit

This comprehensive toolkit provides everything needed to implement Windows Defender Application Control (WDAC) across enterprise environments. It includes ready-to-use policies, advanced deployment scripts, monitoring tools, and complete documentation following the Microsoft WDAC Toolkit model with enhanced features.

## Key Features

- **Multi-Environment Support**: Works across Active Directory, Non-AD, and Hybrid environments
- **Powerful CLI Tools**: 10+ command-line tools for policy management, validation, and deployment
- **GUI Policy Wizard**: WIP graphical interface for simplified policy creation (see [WDAC-Policy-Wizard](WDAC-Policy-Wizard/))
- **Ready-to-Use Policies**: Pre-configured policies with common security rules
- **Advanced Automation**: Automated deployment, monitoring, and management scripts
- **Comprehensive Documentation**: End-to-end implementation guides and best practices
- **Testing Framework**: Validation tools and test cases for policy verification
- **Real-World Examples**: Industry-specific use cases and implementation patterns
- **Enhanced Security**: Zero-trust execution model with default-deny approach
- **Migration Tools**: Convert AppLocker policies to WDAC format

## Repository Structure

```
├── ALL-IN-ONE-WDAC-PACKAGE/        # Self-contained WDAC implementation package
├── architecture/                   # Architecture diagrams and design documents
├── config/                         # Configuration files for policy customization
├── docs/                           # Comprehensive documentation
│   ├── contributing/               # Contribution guidelines and processes
│   ├── examples/                   # Detailed usage examples
│   ├── feedback/                   # Feedback mechanisms and issue reporting
│   ├── getting-started/            # Quick start and beginner guides
│   ├── guides/                     # In-depth implementation guides
│   ├── tools/                      # Documentation for CLI tools
│   ├── tutorials/                  # Step-by-step tutorials
│   ├── using/                      # Policy creation and usage guides
│   └── WDAC_Full_Overview.md       # Complete WDAC overview
├── environment-specific/           # Environment-specific policies and scripts
│   ├── active-directory/           # AD environment implementation
│   ├── non-ad/                     # Non-AD environment implementation
│   ├── hybrid/                     # Hybrid environment implementation
│   ├── shared/                     # Shared utilities and components
│   └── implementation-summary.md   # Summary of environment implementations
├── examples/                       # Practical policy examples
├── inventory/                      # Application inventory samples
├── policies/                       # Core WDAC policy files (empty - for user customization)
├── samples/                        # Sample policies for various scenarios
├── scripts/                        # Legacy PowerShell automation scripts
├── templates/                      # Parameterized policy templates
├── test-cases/                     # Comprehensive test cases
├── test-files/                     # Test files for policy validation
├── tests/                          # Automated unit tests
├── tools/                          # Modern CLI tools for policy management
│   ├── cli/                        # Command-line interface tools
│   │   ├── convert-applocker-to-wdac.ps1  # AppLocker to WDAC converter
│   │   ├── convert_to_audit_mode.ps1      # Convert policy to audit mode
│   │   ├── convert_to_enforce_mode.ps1    # Deploy policy in enforce mode
│   │   ├── deploy-policy.ps1              # Advanced policy deployment
│   │   ├── generate-compliance-report.ps1 # Generate compliance reports
│   │   ├── generate-policy-from-template.ps1 # Policy generation from templates
│   │   ├── merge_policies.ps1             # Merge multiple policies
│   │   ├── rollback_policy.ps1            # Rollback deployed policies
│   │   ├── simulate-policy.ps1            # Simulate policy effects
│   │   └── test-xml-validity.ps1          # Validate policy XML syntax
│   └── templates/                  # Tool-specific templates
└── WDAC-Policy-Wizard/             # GUI application for policy creation (WIP)
```

## Quick Start

For the fastest path to implementation:

1. Clone this repository:
   ```powershell
   git clone https://github.com/sakirm-icpl/WDAC-Enterprise-Security.git
   cd WDAC-Enterprise-Security
   ```

2. For a complete self-contained package, use the ALL-IN-ONE-WDAC-PACKAGE:
   ```powershell
   cd ALL-IN-ONE-WDAC-PACKAGE
   ```

3. Review the [Quick Start Guide](docs/getting-started/quick-start.md) for detailed steps

## Prerequisites

- Windows 10/11 Pro, Enterprise, or Education (version 1903 or later)
- Windows Server 2019/2022
- PowerShell 5.1 or later (PowerShell 7.x compatible)
- Administrator privileges for policy deployment

## Implementation Approaches

### Option 1: ALL-IN-ONE Package (Recommended)

Use the self-contained package for easiest deployment:

1. Navigate to `ALL-IN-ONE-WDAC-PACKAGE/`
2. Review the [Package README](ALL-IN-ONE-WDAC-PACKAGE/README.md)
3. Follow the [Quick Start Guide](ALL-IN-ONE-WDAC-PACKAGE/docs/QUICK-START-GUIDE.md)
4. Customize policies in `/policies` for your environment

### Option 2: Modular Implementation

Use the full repository for maximum flexibility:

1. Review the [WDAC Full Overview](docs/WDAC_Full_Overview.md)
2. Identify your environment type (Active Directory, non-AD, or hybrid)
3. Review the appropriate environment-specific guide:
   - [Active Directory Implementation](environment-specific/active-directory/documentation/ad-deployment-guide.md)
   - [Non-AD Implementation](environment-specific/non-ad/documentation/non-ad-environment-guide.md)
   - [Hybrid Implementation](environment-specific/hybrid/documentation/hybrid-environment-guide.md)
4. Customize policies in the [samples/](samples/) directory
5. Use tools in [tools/cli/](tools/cli/) to generate, test, and deploy policies

## Core Components

### Policy Architecture

- **Base Policies**: System-wide protection foundation
- **Supplemental Policies**: Department-specific rules
- **Deny Policies**: Block untrusted locations (Downloads, Temp)
- **Trusted App Policies**: Allow by hash or publisher

### Deployment Workflow

1. **Validate** → [Prerequisites Check](tools/prerequisites-check.ps1)
2. **Test** → Deploy in [Audit Mode](tools/cli/convert_to_audit_mode.ps1)
3. **Deploy** → Deploy in [Enforce Mode](tools/cli/convert_to_enforce_mode.ps1)
4. **Monitor** → [Monitoring Dashboard](scripts/monitoring-dashboard.ps1)
5. **Maintain** → [Rollback Mechanism](tools/cli/rollback_policy.ps1)

## Documentation

### Getting Started
- [Quick Start Guide](docs/getting-started/quick-start.md) - Fastest path to implementation
- [WDAC Full Overview](docs/WDAC_Full_Overview.md) - Complete introduction to WDAC
- [Implementation Guide](ALL-IN-ONE-WDAC-PACKAGE/docs/IMPLEMENTATION-GUIDE.md) - Comprehensive implementation guide

### Environment-Specific Guides
- [Active Directory Implementation](environment-specific/active-directory/documentation/ad-deployment-guide.md)
- [Non-AD Implementation](environment-specific/non-ad/documentation/non-ad-environment-guide.md)
- [Hybrid Implementation](environment-specific/hybrid/documentation/hybrid-environment-guide.md)
- [Environment Implementation Summary](environment-specific/implementation-summary.md)

### Advanced Topics
- [Advanced Policy Configuration](docs/guides/Advanced_Policy_Configuration.md)
- [Policy Rule Comparison](docs/guides/Policy_Rule_Comparison.md)
- [Compliance Mapping](docs/guides/Compliance_Mapping.md)
- [Migration Guide](docs/guides/Migration_Guide.md)

### Real-World Examples
- [Real World Use Cases](real-world-use-cases.md)
- [Policy Examples](docs/examples/Policy_Examples.md)
- [Additional Real World Use Cases](docs/examples/Real_World_Use_Cases.md)

## Command-Line Tools

The toolkit includes powerful CLI tools for policy management:

- [Policy Generator](docs/tools/generate-policy-from-template.md) - Create policies from templates
- [AppLocker Converter](docs/tools/convert-applocker-to-wdac.md) - Convert AppLocker policies to WDAC
- [Policy Validator](docs/tools/test-xml-validity.md) - Validate policy XML syntax
- [Policy Simulator](docs/tools/simulate-policy.md) - Test policy effects before deployment
- [Policy Merger](docs/tools/merge_policies.md) - Combine multiple policies
- [Deployment Assistant](docs/tools/deploy-policy.md) - Deploy policies with validation
- [Compliance Reporter](docs/tools/generate-compliance-report.md) - Generate compliance reports
- [Audit Mode Converter](docs/tools/convert_to_audit_mode.md) - Convert policies to audit mode
- [Enforce Mode Converter](docs/tools/convert_to_enforce_mode.md) - Convert policies to enforce mode
- [Rollback Utility](docs/tools/rollback_policy.md) - Rollback deployed policies

## Testing and Validation

- [Comprehensive Test Cases](test-cases/comprehensive-test-cases.md)
- [Unit Tests](tests/wdac-unit-tests.ps1)
- [Policy Validation Scripts](test-files/validation/)
- [Edge Case Testing](tests/validation/test-edge-cases.ps1)

## Monitoring and Maintenance

- [Monitoring Dashboard](scripts/monitoring-dashboard.ps1)
- [Alerting System](scripts/alerting-system.ps1)
- [Rollback Procedures](docs/Rollback_Instructions.md)
- [Policy Optimization](scripts/ml-policy-optimizer.ps1)

## Contributing

We welcome contributions to improve this repository. Please see our [contribution guidelines](CONTRIBUTING.md) for more information.

## Deployment Guidelines

For detailed guidance on choosing between the full repository and the ALL-IN-ONE package, see our [Deployment Guidelines](DEPLOYMENT_GUIDELINES.md).

## Verification

To verify documentation consistency and check for duplicates, run the [verification script](tools/verify-documentation-consistency.ps1).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.