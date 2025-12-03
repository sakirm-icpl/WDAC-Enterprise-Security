# Ready-to-Use WDAC Policies

This directory contains pre-configured WDAC policies ready for immediate deployment and testing. Each policy is designed for specific use cases and environments.

## Policy Organization

### Base Policies
- `non-ad-base-policy.xml` - Foundation policy for non-Active Directory environments
- `enterprise-base-policy.xml` - Foundation policy for Active Directory environments (in AD directory)

### Department Supplemental Policies
These policies extend the base policy to allow department-specific applications:

1. **Finance Department Policy** (`finance-policy.xml`)
   - Microsoft Office applications (Excel, Word, PowerPoint)
   - Financial software (QuickBooks, SAP GUI)
   - Analysis tools (MATLAB)

2. **Human Resources Policy** (`hr-policy.xml`)
   - HR management systems
   - Payroll software
   - Background check tools
   - Document management applications

3. **IT Department Policy** (`it-policy.xml`)
   - Remote management tools
   - System monitoring software
   - Development tools
   - PowerShell access

### Exception Policies
These policies provide temporary allowances for special circumstances:

1. **Emergency Access Policy** (`emergency-access-policy.xml`)
   - Diagnostic tools
   - Temporary vendor software
   - Backup and recovery tools
   - Network analysis tools

## Getting Started

1. **Clone the repository**:
   ```bash
   git clone git@github.com:sakirm-icpl/WDAC-Enterprise-Security.git
   ```

2. **Navigate to the appropriate environment directory**:
   - For non-AD environments: `environment-specific/non-ad/policies/`
   - For AD environments: `environment-specific/active-directory/policies/`

3. **Review the policies** to understand what applications they allow/block

4. **Deploy using the environment-specific scripts**

## Testing Instructions

Each policy comes with detailed testing instructions in the respective environment documentation:
- Non-AD: `environment-specific/non-ad/documentation/testing-guide.md`
- AD: `environment-specific/active-directory/documentation/testing-guide.md`

## Customization

While these policies are ready to use, you may need to customize them for your specific environment:
- Update file paths to match your installation directories
- Modify signer certificates to match your applications
- Adjust version requirements for specific software

See the customization guide in each environment's documentation directory for detailed instructions.