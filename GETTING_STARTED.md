# Getting Started with WDAC Enterprise Security

This guide will walk you through setting up and deploying Windows Defender Application Control (WDAC) policies in your environment.

## 📋 Prerequisites

### System Requirements
- Windows 10 version 1903+ or Windows 11
- Windows Server 2019 or 2022
- PowerShell 5.1 or later (PowerShell 7.x recommended)
- Administrator privileges
- 100 MB free disk space

### Knowledge Requirements
- Basic understanding of Windows security
- PowerShell scripting knowledge
- Understanding of your organization's application landscape
- Familiarity with Group Policy (for AD deployments)

## 🎯 Step-by-Step Setup

### Step 1: Clone or Download Repository

```powershell
# Clone the repository
git clone https://github.com/your-org/WDAC-Enterprise-Security.git
cd WDAC-Enterprise-Security

# Or download and extract ZIP file
```

### Step 2: Run Prerequisites Check

```powershell
# Open PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# Run prerequisites check
.\scripts\prerequisites-check.ps1
```

**Expected Output:**
```
✓ Windows Version: Compatible
✓ PowerShell Version: 5.1 or higher
✓ Administrator Rights: Confirmed
✓ WDAC Module: Available
✓ Disk Space: Sufficient
```

### Step 3: Validate Policies

```powershell
# Validate all XML policies
.\test-xml-validity.ps1
```

**Expected Output:**
```
Testing WDAC Policy XML Files...
=================================

Testing: .\policies\BasePolicy.xml
  ✓ XML is well-formed
  ✓ Root element is 'SiPolicy'
  ✓ All required elements present
  ✓ Policy structure validated

...

All XML files are valid!
```

### Step 4: Run Deployment Readiness Test

```powershell
# Comprehensive readiness check
.\test-deployment-readiness.ps1
```

**Expected Output:**
```
╔════════════════════════════════════════════════════════════╗
║     WDAC Policy Deployment Readiness Test Suite           ║
╚════════════════════════════════════════════════════════════╝

[1/10] Checking PowerShell Version... ✓ PASS
[2/10] Checking Administrator Privileges... ✓ PASS
[3/10] Checking WDAC PowerShell Module... ✓ PASS
...
[10/10] Verifying Deployment Scripts... ✓ PASS

Pass Rate: 100%
✓ ALL TESTS PASSED - Policies are ready for deployment!
```

## 🎯 Choose Your Deployment Scenario

### Scenario A: Non-AD Environment (Standalone/Workgroup)

**Best for:**
- Small offices
- Standalone workstations
- Remote workers
- Non-domain systems

**Steps:**
1. Read the guide:
   ```powershell
   # Open documentation
   notepad environment-specific\non-ad\documentation\non-ad-environment-guide.md
   ```

2. Review test scenarios:
   ```powershell
   notepad test-cases\non-ad-workgroup\test-scenarios.md
   ```

3. Deploy policy:
   ```powershell
   cd environment-specific\non-ad
   .\scripts\deploy-non-ad-policy.ps1
   ```

### Scenario B: Active Directory Environment

**Best for:**
- Enterprise networks
- Centralized management
- Large organizations
- Domain-joined systems

**Steps:**
1. Read the guide:
   ```powershell
   notepad environment-specific\active-directory\documentation\ad-deployment-guide.md
   ```

2. Review test scenarios:
   ```powershell
   notepad test-cases\ad-domain\test-scenarios.md
   ```

3. Deploy policy:
   ```powershell
   cd environment-specific\active-directory
   .\scripts\deploy-ad-policy.ps1
   ```

### Scenario C: Windows Server

**Best for:**
- Server infrastructure
- Application servers
- Database servers
- Web servers

**Steps:**
1. Review server-specific scenarios:
   ```powershell
   notepad test-cases\windows-server-2022\test-scenarios.md
   ```

2. Customize policies for server workloads

3. Deploy using appropriate script

## 🧪 Testing Workflow

### Phase 1: Lab Testing (Week 1)

1. **Set up test environment:**
   - 1-2 test machines
   - Isolated from production
   - Representative of production systems

2. **Deploy in Audit Mode:**
   ```powershell
   # Policies are already in Audit Mode by default
   # This logs violations without blocking
   ```

3. **Run test scenarios:**
   ```powershell
   # Follow test cases in test-cases/ folder
   # Document results in testing-results/
   ```

4. **Monitor event logs:**
   ```powershell
   # View WDAC events
   Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 100 | 
       Where-Object {$_.Id -eq 3076 -or $_.Id -eq 3077} |
       Format-Table TimeCreated, Id, Message -AutoSize
   ```

### Phase 2: Pilot Deployment (Weeks 2-5)

1. **Select pilot group:**
   - 5-10 representative users
   - Mix of departments
   - Power users and standard users

2. **Deploy to pilot:**
   ```powershell
   # Deploy policy to pilot systems
   # Keep in Audit Mode
   ```

3. **Monitor for 2-4 weeks:**
   - Review event logs daily
   - Collect user feedback
   - Identify blocked applications
   - Create exception policies

4. **Adjust policies:**
   ```powershell
   # Add exceptions as needed
   # Update supplemental policies
   ```

### Phase 3: Production Rollout (Weeks 6+)

1. **Phased deployment:**
   - Week 6: 10% of systems
   - Week 7: 25% of systems
   - Week 8: 50% of systems
   - Week 9: 100% of systems

2. **Switch to Enforce Mode (Optional):**
   ```powershell
   # Only after thorough testing
   # Update policy to remove Audit Mode option
   ```

3. **Continuous monitoring:**
   - Daily event log review
   - Weekly policy updates
   - Monthly policy review

## 📊 Validation Checklist

Before each deployment phase:

### Pre-Deployment
- [ ] Prerequisites check passed
- [ ] XML validation passed
- [ ] Deployment readiness test passed
- [ ] Backup of existing policies created
- [ ] Rollback procedure documented
- [ ] Support team notified

### During Deployment
- [ ] Deployment script executed successfully
- [ ] No errors in deployment log
- [ ] Policy file copied to correct location
- [ ] System restarted (if required)

### Post-Deployment
- [ ] Policy active and loaded
- [ ] Event logs monitored
- [ ] No unexpected blocks (in Audit Mode)
- [ ] User feedback collected
- [ ] Documentation updated

## 🔍 Monitoring and Maintenance

### Daily Tasks
```powershell
# Check for policy violations
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 50 |
    Where-Object {$_.Id -eq 3076} |
    Format-Table TimeCreated, Message -AutoSize
```

### Weekly Tasks
```powershell
# Generate policy report
.\scripts\generate-policy-report.ps1

# Review exception requests
# Update supplemental policies as needed
```

### Monthly Tasks
- Review policy effectiveness
- Update policies for new applications
- Remove obsolete exceptions
- Update documentation

## 🆘 Troubleshooting

### Issue: Policy Not Loading

**Symptoms:**
- Policy file exists but not active
- No events in CodeIntegrity log

**Solution:**
```powershell
# Check policy status
Get-CIPolicy

# Verify file location
Test-Path "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"

# Restart system
Restart-Computer
```

### Issue: Application Blocked Unexpectedly

**Symptoms:**
- Event ID 3077 in CodeIntegrity log
- Application won't run

**Solution:**
```powershell
# Find the blocked file
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" |
    Where-Object {$_.Id -eq 3077} |
    Select-Object -First 1 -ExpandProperty Message

# Create exception policy
# See docs/guides/02-policy-creation.md
```

### Issue: Deployment Script Fails

**Symptoms:**
- Script errors
- Policy not deployed

**Solution:**
```powershell
# Check administrator rights
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Check execution policy
Get-ExecutionPolicy

# Set execution policy if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# Review deployment log
Get-Content "$env:TEMP\WDAC_Deployment_Log.txt"
```

## 📚 Next Steps

### Learn More
1. **Understanding WDAC:**
   - Read `docs/guides/01-understanding-wdac.md`
   - Review `architecture/WDAC_Architecture.md`

2. **Policy Creation:**
   - Read `docs/guides/02-policy-creation.md`
   - Review examples in `docs/examples/`

3. **Advanced Topics:**
   - Multiple base policies
   - Signed policies
   - Managed installer
   - Intelligent Security Graph (ISG)

### Customize for Your Environment
1. **Identify applications:**
   - Audit current application usage
   - Create inventory of approved applications
   - Document line-of-business applications

2. **Create custom policies:**
   - Use WDAC Policy Wizard
   - Follow examples in `docs/examples/`
   - Test thoroughly before deployment

3. **Establish processes:**
   - Exception request workflow
   - Policy update schedule
   - Incident response procedures

## 🎓 Training Resources

### Internal Documentation
- `docs/guides/` - Comprehensive guides
- `test-cases/` - Real-world scenarios
- `examples/` - Working examples

### External Resources
- [Microsoft WDAC Documentation](https://docs.microsoft.com/windows/security/threat-protection/windows-defender-application-control)
- [WDAC Policy Wizard](https://webapp-wdac-wizard.azurewebsites.net/)
- [Windows Security Blog](https://techcommunity.microsoft.com/t5/windows-security/bg-p/Windows-Security)

## ✅ Success Criteria

You're ready for production when:

- [ ] All validation tests pass
- [ ] Lab testing completed (1 week)
- [ ] Pilot deployment successful (2-4 weeks)
- [ ] No critical issues identified
- [ ] Rollback procedure tested
- [ ] Support team trained
- [ ] Documentation complete
- [ ] Monitoring configured
- [ ] Exception process established

## 🎯 Quick Reference

### Essential Commands
```powershell
# Validate policies
.\test-xml-validity.ps1

# Check readiness
.\test-deployment-readiness.ps1

# Deploy (Non-AD)
cd environment-specific\non-ad
.\scripts\deploy-non-ad-policy.ps1

# Deploy (AD)
cd environment-specific\active-directory
.\scripts\deploy-ad-policy.ps1

# Check policy status
Get-CIPolicy

# View events
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 50

# Rollback
.\scripts\rollback-policy.ps1
```

### Important Files
- `README.md` - Project overview
- `test-xml-validity.ps1` - XML validation
- `test-deployment-readiness.ps1` - Readiness check
- `scripts/prerequisites-check.ps1` - System check
- `scripts/rollback-policy.ps1` - Rollback procedure

### Support
- Documentation: `docs/guides/05-troubleshooting.md`
- Test scenarios: `test-cases/`
- Examples: `docs/examples/`

---

**Ready to deploy?** Choose your scenario above and follow the steps!

**Need help?** Check `docs/guides/05-troubleshooting.md` or review test scenarios in `test-cases/`
