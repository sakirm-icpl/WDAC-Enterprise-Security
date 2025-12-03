# Windows 10/11 AD Environment Testing Checklist

## Prerequisites
- [ ] Domain-joined Windows 10/11 device
- [ ] Domain administrator credentials
- [ ] Access to Group Policy Management Console
- [ ] Test applications (signed and unsigned)
- [ ] Repository cloned to local system

## Environment Preparation
- [ ] Verify domain connectivity
- [ ] Confirm device is in correct OU for testing
- [ ] Ensure no conflicting GPOs are linked to test OU
- [ ] Backup existing WDAC policies if present
- [ ] Verify PowerShell execution policy allows script execution

## Policy Deployment
- [ ] Navigate to repository directory
- [ ] Open `environment-specific/active-directory/documentation/deployment-guide.md`
- [ ] Follow steps 1-3 to prepare GPO
- [ ] Copy policy files from `environment-specific/active-directory/policies/` to SYSVOL
- [ ] Link GPO to test OU
- [ ] Force Group Policy update on test client
- [ ] Verify policy deployment through Code Integrity logs

## Testing Procedures
- [ ] Restart test client
- [ ] Attempt to run Microsoft-signed applications (e.g., Calculator, Notepad)
- [ ] Attempt to run third-party signed applications (e.g., Chrome, Adobe Reader)
- [ ] Attempt to run unsigned applications
- [ ] Test department-specific policies (Finance, HR, IT)
- [ ] Test exception policies (emergency access)
- [ ] Verify folder restriction policies

## Validation Criteria
- [ ] Microsoft-signed applications execute normally
- [ ] Third-party signed applications execute normally
- [ ] Unsigned applications are blocked with appropriate event logs
- [ ] Department-specific applications execute per policy
- [ ] Exception policies work as intended
- [ ] Folder restrictions are enforced
- [ ] No system stability issues observed

## Monitoring and Analysis
- [ ] Run `test-files/validation/Analyze-AuditLogs.ps1` to review audit logs
- [ ] Generate test report using `test-files/validation/Generate-TestReport.ps1`
- [ ] Check Code Integrity event logs for any unexpected blocks
- [ ] Verify performance impact is minimal

## Troubleshooting
- [ ] If policies aren't applying, check GPO replication status
- [ ] Verify policy files were copied correctly to SYSVOL
- [ ] Confirm GPO is linked to correct OU
- [ ] Check for WMI filters blocking GPO application
- [ ] Review Group Policy processing logs

## Documentation
- [ ] Record test results in `testing-results/windows10-ad-results.md`
- [ ] Capture screenshots of key validation points
- [ ] Document any deviations from expected behavior
- [ ] Note performance observations