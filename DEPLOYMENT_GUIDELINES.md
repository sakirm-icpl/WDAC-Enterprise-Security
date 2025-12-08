# WDAC Enterprise Security Deployment Guidelines

This document provides clear guidance on how to deploy WDAC policies using either the full repository structure or the ALL-IN-ONE package.

## Repository Structure Overview

### Option 1: Full Repository (Recommended for Learning and Customization)
Located at the root of this repository, this structure provides:
- Complete documentation suite
- Environment-specific implementations
- Advanced policy configurations
- Comprehensive testing framework
- Detailed examples and use cases

Best for: Organizations wanting to understand WDAC deeply and customize extensively.

### Option 2: ALL-IN-ONE Package (Recommended for Quick Deployment)
Located in the [ALL-IN-ONE-WDAC-PACKAGE](ALL-IN-ONE-WDAC-PACKAGE/) directory, this structure provides:
- Self-contained implementation with minimal dependencies
- Pre-configured policies for immediate use
- Simplified deployment scripts
- Essential documentation

Best for: Organizations wanting quick deployment with minimal customization.

## Eliminating Duplicate Content

To avoid confusion between similar files in different locations:

1. **Scripts**: The main repository contains more feature-rich scripts with enhanced error handling, while the ALL-IN-ONE package contains simplified versions.

2. **Documentation**: The main repository contains comprehensive documentation, while the ALL-IN-ONE package contains essential guides.

3. **Policies**: Both locations contain functional policies, but the main repository has more variations and examples.

## Deployment Recommendations

### For New Users
Start with the ALL-IN-ONE package to understand basic concepts, then explore the full repository for advanced features.

### For Production Environments
Choose based on your needs:
- Use ALL-IN-ONE package for standardized deployments
- Use full repository for customized enterprise deployments

## Getting Started

1. **Assess Your Environment**:
   - Active Directory: Use AD-specific policies and deployment scripts
   - Non-AD: Use standalone deployment scripts
   - Hybrid: Combine both approaches

2. **Choose Your Path**:
   - Quick Start: Navigate to [ALL-IN-ONE-WDAC-PACKAGE](ALL-IN-ONE-WDAC-PACKAGE/)
   - Full Implementation: Use the root repository structure

3. **Review Documentation**:
   - Main Repository: See [docs/](docs/) directory
   - ALL-IN-ONE Package: See [ALL-IN-ONE-WDAC-PACKAGE/docs/](ALL-IN-ONE-WDAC-PACKAGE/docs/)

## Support and Maintenance

Both structures are maintained together but serve different purposes. Updates to core concepts in one will be reflected in the other, though implementation details may vary.

For issues, questions, or contributions, please refer to the [CONTRIBUTING.md](CONTRIBUTING.md) file.