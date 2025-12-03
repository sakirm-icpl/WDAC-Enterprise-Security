# Getting Started with WDAC Testing

This guide provides a quick path to testing WDAC policies on your systems with minimal setup.

## Prerequisites

1. **System Requirements**:
   - Windows 10/11 Pro, Enterprise, or Education (version 1903 or later)
   - Windows Server 2016 or later
   - PowerShell 5.1 or later
   - Administrator privileges

2. **Test Applications**:
   - Microsoft-signed applications (Calculator, Notepad, etc.)
   - Third-party signed applications (Chrome, Adobe Reader, etc.)
   - Unsigned applications for testing blocking (create simple test executables)

## Quick Start Process

### Step 1: Clone the Repository

```bash
git clone git@github.com:sakirm-icpl/WDAC-Enterprise-Security.git
cd WDAC-Enterprise-Security
```

### Step 2: Identify Your Environment

Determine which environment type you're testing:

- **Non-AD Workstation**: Standalone Windows 10/11 PC
- **AD Workstation**: Domain-joined Windows 10/11 PC
- **Non-AD Server**: Standalone Windows Server
- **AD Server**: Domain-joined Windows Server

### Step 3: Navigate to Environment Directory

```powershell
# For Non-AD systems (workstations or standalone servers)
cd environment-specific\non-ad

# For AD systems (domain-joined workstations or servers)
cd environment-specific\active-directory
```

### Step 4: Review Ready-to-Use Policies

Examine the policies in the `policies/` directory:

- `policies/non-ad-base-policy.xml` (Non-AD) or `policies/enterprise-base-policy.xml` (AD)
- `policies/department-supplemental-policies/` for department-specific allowances
- `policies/exception-policies/` for temporary allowances

### Step 5: Deploy Policies for Testing

#### For Non-AD Systems:
```powershell
# Open PowerShell as Administrator
cd environment-specific\non-ad
.\scripts\deploy-non-ad-policy.ps1
```

#### For AD Systems:
```powershell
# Open PowerShell as Administrator with AD privileges
cd environment-specific\active-directory
.\scripts\deploy-ad-policy.ps1 -Deploy
```

#### For Universal Deployment:
```powershell
# Works on any system, auto-detects environment
cd scripts
.\deploy-unified-policy.ps1 -Environment "NonAD" -Mode "Audit"
```

### Step 6: Test Applications

After deployment and system restart:

1. **Test Microsoft-signed applications**:
   - Run Calculator (`calc.exe`)
   - Run Notepad (`notepad.exe`)
   - These should work normally

2. **Test third-party signed applications**:
   - Run Chrome, Firefox, or other signed applications
   - These should work normally

3. **Test unsigned applications**:
   - Try to run any unsigned executable
   - These should be blocked

### Step 7: Analyze Results

Use the validation tools to analyze policy effectiveness:

```powershell
# Analyze audit logs
cd test-files\validation
.\Analyze-AuditLogs.ps1 -Hours 24

# Generate comprehensive test report
.\Generate-TestReport.ps1 -Hours 24 -IncludeSystemInfo
```

### Step 8: Document Findings

Record your test results:
1. Create a file in `testing-results/` with your environment details
2. Document any applications that were unexpectedly blocked
3. Note any performance impacts
4. Capture screenshots of key validation points

## Environment-Specific Testing Guides

For detailed testing procedures, refer to the environment-specific checklists:
- Non-AD Workstations: `testing-checklists/windows10-nonad-checklist.md`
- AD Workstations: `testing-checklists/windows10-ad-checklist.md`
- Non-AD Servers: `testing-checklists/windows-server-nonad-checklist.md`
- AD Servers: `testing-checklists/windows-server-ad-checklist.md`

## Troubleshooting

### Common Issues

1. **Policies not applying**:
   - Verify system meets WDAC requirements
   - Check event logs for policy loading errors
   - Ensure Virtualization Based Security is enabled

2. **Applications incorrectly blocked**:
   - Review audit logs to identify blocking reasons
   - Check application signatures and paths
   - Update policies as needed

3. **Performance issues**:
   - Monitor CPU and memory usage
   - Verify policy complexity is appropriate

### Rollback Procedure

If issues occur, you can rollback using:
```powershell
cd scripts
.\rollback_policy.ps1
```

Or manually remove the policy file:
```powershell
Remove-Item "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
```

Then restart the system.

## Next Steps

After successful testing:
1. Customize policies for your specific environment
2. Plan production deployment
3. Establish monitoring and maintenance procedures
4. Train administrators on policy management

## Support

For issues with these ready-to-use policies:
1. Review the FAQ in `docs/guides/FAQ.md`
2. Check environment-specific documentation
3. Submit issues to the repository