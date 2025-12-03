# Complete WDAC Implementation Workflow

This document provides a step-by-step workflow for implementing WDAC policies on your machine using the components in this repository.

## Prerequisites

Before starting, ensure you have:
1. Windows 10/11 Pro, Enterprise, or Education (version 1903 or later)
2. PowerShell 5.1 or later
3. Administrator privileges
4. This repository cloned to your local system

## Phase 1: Environment Assessment

### 1.1 Identify Your Environment
Determine which environment type you're working with:
- **Non-AD Workstation**: Standalone Windows 10/11 PC
- **AD Workstation**: Domain-joined Windows 10/11 PC
- **Non-AD Server**: Standalone Windows Server
- **AD Server**: Domain-joined Windows Server

### 1.2 Inventory Applications
Catalog the applications that need to run:
- Microsoft-signed applications (should be allowed by default)
- Third-party signed applications
- Legacy unsigned applications (require special handling)
- Applications in specific folders

### 1.3 Identify High-Risk Folders
Document folders that should be restricted:
- User Downloads folders
- User Temp folders
- Public folders
- Removable drives

## Phase 2: Policy Design

### 2.1 Select Base Policy
Choose the appropriate base policy:
- **Non-AD Environment**: `environment-specific/non-ad/policies/non-ad-base-policy.xml`
- **AD Environment**: `environment-specific/active-directory/policies/enterprise-base-policy.xml`
- **Generic Environment**: `policies/BasePolicy.xml`

### 2.2 Customize Supplemental Policies
Create or modify supplemental policies for:
- Department-specific applications
- Third-party software
- Legacy applications

### 2.3 Configure Deny Policies
Implement folder restrictions using:
- `policies/DenyPolicy.xml` (generic)
- Custom deny policies for specific folders

## Phase 3: Testing in Audit Mode

### 3.1 Deploy Base Policy in Audit Mode
```powershell
# Convert to audit mode
.\scripts\convert_to_audit_mode.ps1 -PolicyPath "path\to\base-policy.xml"

# Deploy for testing
.\scripts\convert_to_audit_mode.ps1 -PolicyPath "path\to\base-policy.xml" -Deploy
```

### 3.2 Run Application Tests
Use the test scripts to validate policy behavior:
```powershell
# Create test files
.\test-files\validation\Test-WDACPolicy.ps1 -CreateTestFiles

# Run tests
.\test-files\validation\Test-WDACPolicy.ps1 -RunTests

# Check logs
.\test-files\validation\Test-WDACPolicy.ps1 -CheckLogs
```

### 3.3 Analyze Code Integrity Events
Review audit logs to identify blocked applications:
```powershell
.\test-files\validation\Analyze-AuditLogs.ps1
```

### 3.4 Create Supplemental Policies
Based on audit results, create supplemental policies for legitimately blocked applications.

## Phase 4: Policy Merging

### 4.1 Merge Policies
Combine base, supplemental, and deny policies:
```powershell
.\scripts\merge_policies.ps1 -BasePolicyPath "path\to\base-policy.xml" -DenyPolicyPath "path\to\deny-policy.xml" -TrustedAppPolicyPath "path\to\trusted-app-policy.xml"
```

### 4.2 Validate Merged Policy
Check that the merged policy is syntactically correct:
```powershell
[xml]$policy = Get-Content "path\to\merged-policy.xml"
```

## Phase 5: Production Deployment

### 5.1 Convert to Enforce Mode
Switch the merged policy to enforce mode:
```powershell
.\scripts\convert_to_enforce_mode.ps1 -PolicyPath "path\to\merged-policy.xml" -Deploy
```

### 5.2 Restart System
Restart the system for policy changes to take effect:
```powershell
Restart-Computer
```

### 5.3 Validate Deployment
Verify that the policy is active:
```powershell
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
```

## Phase 6: Ongoing Management

### 6.1 Monitor Policy Violations
Regularly check Code Integrity logs:
```powershell
.\test-files\validation\Analyze-AuditLogs.ps1 -Days 7
```

### 6.2 Update Policies as Needed
Modify policies when:
- New applications need to be allowed
- Applications are deprecated
- Security requirements change

### 6.3 Generate Compliance Reports
Create regular reports on policy effectiveness:
```powershell
.\test-files\validation\Generate-TestReport.ps1 -OutputPath "C:\Reports\MonthlyWDACReport.html"
```

## Troubleshooting

### Common Issues and Solutions

1. **Applications Blocked Unexpectedly**
   - Check Code Integrity logs (Event ID 3076/3077)
   - Create appropriate allowances in supplemental policies
   - Test in audit mode before redeploying

2. **Policy Not Taking Effect**
   - Verify system restart after deployment
   - Check policy file placement (`C:\Windows\System32\CodeIntegrity\SIPolicy.p7b`)
   - Confirm policy is correctly formatted

3. **Performance Issues**
   - Simplify policies by removing unnecessary rules
   - Use broader path rules instead of many specific file rules
   - Review and consolidate duplicate allowances

### Emergency Procedures

1. **Immediate Rollback**
   ```powershell
   .\scripts\rollback_policy.ps1 -Restore
   Restart-Computer
   ```

2. **Temporary Exception**
   Deploy an exception policy for temporary access:
   ```powershell
   .\scripts\convert_to_enforce_mode.ps1 -PolicyPath "path\to\exception-policy.xml" -Deploy
   ```

## Best Practices

### Policy Design
- Start with restrictive base policies
- Use publisher rules when possible (more flexible than hash rules)
- Regularly review and clean up policies
- Maintain policy version control

### Deployment
- Always test in audit mode first
- Deploy during maintenance windows
- Have rollback plans ready
- Communicate changes to users

### Monitoring
- Set up alerts for policy violations
- Regularly review audit logs
- Generate compliance reports
- Track policy effectiveness metrics

## Conclusion

This repository provides a complete framework for implementing WDAC policies on any Windows system. By following this workflow, you can:
1. Assess your environment and requirements
2. Design appropriate policies
3. Test thoroughly in audit mode
4. Deploy securely in enforce mode
5. Manage and maintain policies ongoing

The ready-to-use policies, scripts, and documentation make it easy to implement robust application control that protects against unauthorized software while allowing legitimate applications to function.