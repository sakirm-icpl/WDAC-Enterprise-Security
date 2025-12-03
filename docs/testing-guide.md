# Testing Guide for Ready-to-Use WDAC Policies

This guide provides step-by-step instructions for testing the ready-to-use WDAC policies included in this repository.

## Prerequisites

Before beginning testing, ensure you have:

1. A clean Windows system (Windows 10/11 or Windows Server 2016/2019/2022)
2. Administrator privileges on the test system
3. The repository cloned to your local system
4. Test applications (both signed and unsigned) for validation
5. PowerShell execution policy set to allow script execution

## Environment Identification

First, identify which environment type you're testing:

- **Non-AD Environment**: Standalone Windows system not joined to a domain
- **AD Environment**: Windows system joined to an Active Directory domain

## Testing Process

### Phase 1: Environment Preparation

#### For Non-AD Environments:
1. Navigate to `environment-specific/non-ad/`
2. Review the documentation in `documentation/` directory
3. Ensure Device Guard feature is enabled:
   ```powershell
   Enable-WindowsOptionalFeature -Online -FeatureName DeviceGuard -All
   ```

#### For AD Environments:
1. Navigate to `environment-specific/active-directory/`
2. Review the documentation in `documentation/` directory
3. Ensure you have access to Group Policy Management

### Phase 2: Policy Deployment

#### For Non-AD Environments:
1. Open PowerShell as Administrator
2. Navigate to the repository directory
3. Execute the deployment script:
   ```powershell
   .\environment-specific\non-ad\scripts\deploy-non-ad-policy.ps1
   ```
4. Restart the system when prompted

#### For AD Environments:
1. Copy policy files to SYSVOL share
2. Create and link Group Policy Objects
3. Force Group Policy update on test clients
4. Restart test clients

### Phase 3: Testing Execution

#### Test Microsoft-signed Applications
1. Attempt to run Calculator (`calc.exe`)
2. Attempt to run Notepad (`notepad.exe`)
3. Attempt to run Command Prompt (`cmd.exe`)
4. All should execute normally

#### Test Third-party Signed Applications
1. Attempt to run Chrome, Firefox, or other signed browsers
2. Attempt to run Adobe Reader or other signed productivity tools
3. All should execute normally

#### Test Unsigned Applications
1. Attempt to run any unsigned executable
2. Observe that execution is blocked
3. Check event logs for blocking events

#### Test Department-specific Policies
1. For Finance policy:
   - Attempt to run Excel, QuickBooks
   - Verify these applications execute
2. For HR policy:
   - Attempt to run HR management software
   - Verify these applications execute
3. For IT policy:
   - Attempt to run PowerShell
   - Attempt to run remote management tools
   - Verify these applications execute

#### Test Exception Policies
1. Deploy emergency access policy
2. Attempt to run diagnostic tools
3. Verify these applications execute during the exception window

### Phase 4: Validation and Analysis

#### Run Audit Log Analysis
```powershell
.\test-files\validation\Analyze-AuditLogs.ps1 -Hours 24
```

#### Generate Test Report
```powershell
.\test-files\validation\Generate-TestReport.ps1 -Hours 24 -IncludeSystemInfo
```

#### Validate Policy Syntax
```powershell
.\environment-specific\shared\utilities\policy-validator.ps1
```

### Phase 5: Documentation

Record your findings in the testing results directory:
- Create a new file in `testing-results/` with your environment details
- Document any issues or unexpected behavior
- Capture screenshots of key validation points
- Note performance observations

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
   - Consider policy optimization

### Rollback Procedure

If issues occur, you can rollback using:
```powershell
.\scripts\rollback_policy.ps1
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

For issues with these ready-to-use policies, please:
1. Review the FAQ in `docs/faq.md`
2. Check the troubleshooting guide in environment-specific documentation
3. Submit issues to the repository