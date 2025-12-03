# Windows Defender Application Control (WDAC) Enterprise Security Repository

This repository contains a comprehensive set of Windows Defender Application Control (WDAC) policies, scripts, documentation, and examples for implementing application whitelisting and control in enterprise environments. It's designed for immediate use with ready-to-deploy policies and testing procedures.

## Repository Structure

```
├── architecture/                    # Architecture diagrams and design documents
├── docs/                           # Comprehensive documentation
│   ├── guides/                     # Step-by-step implementation guides
│   ├── examples/                   # Detailed usage examples
│   ├── WDAC_Full_Overview.md       # Complete WDAC overview
│   └── Rollback_Instructions.md    # Policy rollback procedures
├── environment-specific/           # Environment-specific policies and scripts
│   ├── active-directory/           # AD environment implementation
│   ├── non-ad/                     # Non-AD environment implementation
│   ├── hybrid/                     # Hybrid environment implementation
│   ├── shared/                     # Shared utilities and components
│   └── implementation-summary.md   # Summary of environment implementations
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
│   ├── deploy-unified-policy.ps1   # Unified deployment script for all environments
│   └── utils/                      # Utility functions and helpers
├── test-cases/                     # Comprehensive test cases
│   └── comprehensive-test-cases.md # Detailed testing procedures
├── test-files/                     # Test files for policy validation
│   ├── binaries/                   # Sample binaries for testing
│   └── validation/                 # Validation scripts and procedures
├── testing-checklists/             # Environment-specific testing checklists
├── testing-results/                # Directory for test result documentation
├── GETTING_STARTED.md              # Quick start guide for testing
├── QUICK_START.md                  # Minimal steps for immediate deployment
├── DEMO_SCRIPT.md                  # Demonstration walkthrough
├── PRESENTATION.md                 # Presentation materials
└── LICENSE                         # License information
```

## Quick Start for Testing

1. **Clone the repository**:
   ```bash
   git clone git@github.com:sakirm-icpl/WDAC-Enterprise-Security.git
   ```

2. **Identify your environment**:
   - Non-AD Windows 10/11 workstations: Navigate to `environment-specific/non-ad/`
   - AD domain-joined systems: Navigate to `environment-specific/active-directory/`
   - Windows Server systems: Navigate to `environment-specific/non-ad/` (for standalone) or `environment-specific/active-directory/` (for domain-joined)

3. **Review ready-to-use policies**:
   - Base policies provide foundational application control
   - Department-specific policies allow finance, HR, and IT applications
   - Exception policies provide temporary allowances

4. **Deploy for testing**:
   - Non-AD: Run `environment-specific/non-ad/scripts/deploy-non-ad-policy.ps1`
   - AD: Run `environment-specific/active-directory/scripts/deploy-ad-policy.ps1`
   - Universal: Run `scripts/deploy-unified-policy.ps1` with appropriate parameters

5. **Test with the checklists**:
   - Use checklists in `testing-checklists/` for step-by-step testing procedures
   - Run validation scripts in `test-files/validation/` to analyze results

6. **Analyze results**:
   - Generate reports with `test-files/validation/Generate-TestReport.ps1`
   - Review audit logs with `test-files/validation/Analyze-AuditLogs.ps1`

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

### Environment-Specific Guides
- [Active Directory Implementation](environment-specific/active-directory/documentation/ad-deployment-guide.md) - AD deployment strategies
- [Non-AD Implementation](environment-specific/non-ad/documentation/non-ad-environment-guide.md) - Non-AD deployment strategies
- [Hybrid Implementation](environment-specific/hybrid/documentation/hybrid-environment-guide.md) - Hybrid environment strategies
- [Environment Implementation Summary](environment-specific/implementation-summary.md) - Comprehensive environment comparison

### Additional Resources
- [Getting Started Guide](GETTING_STARTED.md) - Comprehensive testing walkthrough
- [Testing Guide](docs/testing-guide.md) - Detailed testing procedures
- [Real-World Use Cases](docs/real-world-use-cases.md) - Practical implementation examples
- [Demo Script](DEMO_SCRIPT.md) - Repository demonstration guide
- [Presentation Materials](PRESENTATION.md) - Slides for team presentations
- [Final Implementation Summary](FINAL_IMPLEMENTATION_SUMMARY.md) - Complete project overview

## Contributing

We welcome contributions to improve this repository. Please see our [contribution guidelines](CONTRIBUTING.md) for more information.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.