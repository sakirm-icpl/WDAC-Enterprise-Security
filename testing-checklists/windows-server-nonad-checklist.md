# Windows Server Non-AD Environment Testing Checklist

## Prerequisites
- [ ] Standalone Windows Server (2016/2019/2022)
- [ ] Local administrator credentials
- [ ] Test applications (signed and unsigned)
- [ ] Repository cloned to local system

## Environment Preparation
- [ ] Verify system meets WDAC requirements
- [ ] Enable required Windows features (Device Guard)
- [ ] Backup existing WDAC policies if present
- [ ] Verify PowerShell execution policy allows script execution
- [ ] Ensure Server Manager and required roles are installed

## Policy Deployment
- [ ] Navigate to repository directory
- [ ] Open `environment-specific/non-ad/documentation/server-deployment-guide.md`
- [ ] Review the base policy at `environment-specific/non-ad/policies/non-ad-base-policy.xml`
- [ ] Run deployment script: `environment-specific/non-ad/scripts/deploy-non-ad-policy.ps1`
- [ ] Confirm script executes without errors
- [ ] Verify policy file is placed at `C:\Windows\System32\CodeIntegrity\SIPolicy.p7b`

## Testing Procedures
- [ ] Restart system to apply policy
- [ ] Attempt to run Microsoft-signed server applications
- [ ] Attempt to run third-party signed server applications
- [ ] Attempt to run unsigned server applications
- [ ] Test server role-specific policies (if applicable)
- [ ] Test department-specific policies:
  - [ ] Finance policy: `environment-specific/non-ad/policies/department-supplemental-policies/finance-policy.xml`
  - [ ] HR policy: `environment-specific/non-ad/policies/department-supplemental-policies/hr-policy.xml`
  - [ ] IT policy: `environment-specific/non-ad/policies/department-supplemental-policies/it-policy.xml`
- [ ] Test exception policies: `environment-specific/non-ad/policies/exception-policies/emergency-access-policy.xml`
- [ ] Verify folder restriction policies

## Validation Criteria
- [ ] Microsoft-signed server applications execute normally
- [ ] Third-party signed server applications execute normally
- [ ] Unsigned server applications are blocked with appropriate event logs
- [ ] Server roles function correctly with policy applied
- [ ] Department-specific applications execute per policy
- [ ] Exception policies work as intended
- [ ] Folder restrictions are enforced
- [ ] No system stability issues observed

## Monitoring and Analysis
- [ ] Run `test-files/validation/Analyze-AuditLogs.ps1` to review audit logs
- [ ] Generate test report using `test-files/validation/Generate-TestReport.ps1`
- [ ] Check Code Integrity event logs for any unexpected blocks
- [ ] Verify performance impact is minimal
- [ ] Monitor server-specific event logs

## Troubleshooting
- [ ] If policies aren't applying, check event logs for errors
- [ ] Verify policy file is correctly formatted using `policy-validator.ps1`
- [ ] Confirm policy file permissions are correct
- [ ] Check if Virtualization Based Security is enabled
- [ ] Review WDAC status using `Get-CimInstance -ClassName Win32_DeviceGuard`
- [ ] Verify server-specific compatibility issues

## Documentation
- [ ] Record test results in `testing-results/windows-server-nonad-results.md`
- [ ] Capture screenshots of key validation points
- [ ] Document any deviations from expected behavior
- [ ] Note performance observations
- [ ] Record any server-specific considerations