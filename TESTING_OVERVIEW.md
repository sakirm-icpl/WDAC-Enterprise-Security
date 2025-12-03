# WDAC Testing Overview

## Testing Phases

### 1. Pre-Deployment Validation
**Scripts to run:**
```powershell
# Check system requirements
.\scripts\prerequisites-check.ps1

# Validate policy XML files
.\test-xml-validity.ps1

# Run deployment readiness test
.\test-deployment-readiness.ps1
```

### 2. Audit Mode Testing (2-4 weeks)
**Process:**
1. Deploy policies in Audit Mode
2. Monitor event logs daily
3. Document blocked applications
4. Adjust policies as needed

**Monitoring Commands:**
```powershell
# View WDAC events
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 100

# Filter for blocked applications
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" | Where-Object {$_.Id -eq 3076}
```

### 3. Enforce Mode Testing
**Process:**
1. Convert policies to Enforce Mode
2. Deploy to test systems
3. Verify applications work as expected
4. Test rollback procedures

## Environment-Specific Testing

### Windows 10/11 Non-AD
**Checklist Location:** `testing-checklists/windows10-nonad-checklist.md`

**Key Tests:**
- Local policy deployment
- Application allowance/denial
- System performance impact
- Rollback functionality

### Windows 10/11 AD
**Checklist Location:** `testing-checklists/windows10-ad-checklist.md`

**Key Tests:**
- Group Policy deployment
- Policy distribution timing
- Multi-system consistency
- AD integration

### Windows Server
**Checklists:**
- AD: `testing-checklists/windows-server-ad-checklist.md`
- Non-AD: `testing-checklists/windows-server-nonad-checklist.md`

**Key Tests:**
- Server workload compatibility
- Service/application restrictions
- Performance monitoring
- Role-specific policies

## Test Applications

### Required Test Apps:
1. **Microsoft-signed applications** (Calculator, Notepad, Edge)
2. **Third-party signed applications** (Chrome, Adobe Reader)
3. **Unsigned applications** (Test executables)
4. **Department-specific applications** (based on your environment)

## Test Results Documentation

**Template Location:** `testing-results/RESULTS_TEMPLATE.md`

**Required Information:**
- Environment details
- Test applications used
- Results for each application
- Issues encountered
- Performance observations
- Recommendations

## Key Metrics to Track

### Success Criteria:
- ✅ 100% of trusted applications run
- ✅ 100% of untrusted applications blocked
- ✅ Minimal performance impact (<5% CPU)
- ✅ Successful rollback capability
- ✅ Consistent policy enforcement

### Warning Signs:
- ⚠️ Unexpected application blocks
- ⚠️ System instability
- ⚠️ Performance degradation
- ⚠️ Policy deployment failures

## Troubleshooting Common Issues

### Policy Not Taking Effect
```powershell
# Check deployed policies
Get-CIPolicy

# Force policy refresh
Invoke-CimMethod -Namespace root/CIMv2/Policy -ClassName PS_UpdatePolicy -MethodName UpdatePolicy

# Restart system
Restart-Computer
```

### False Positives (Blocking Good Apps)
1. Check event logs for blocked applications
2. Add application to supplemental policy
3. Redeploy updated policy
4. Test again

### Performance Issues
1. Monitor CPU/memory usage
2. Check for excessive logging
3. Optimize policy rules
4. Consider HVCI settings

## Best Practices

1. **Always test in Audit Mode first** for 2-4 weeks
2. **Document all test results** in `testing-results/`
3. **Test with real applications** from your environment
4. **Monitor system performance** during testing
5. **Verify rollback procedures** before production deployment
6. **Train support staff** on WDAC concepts and troubleshooting