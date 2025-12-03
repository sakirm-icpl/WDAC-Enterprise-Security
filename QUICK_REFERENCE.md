# WDAC Enterprise Security - Quick Reference Card

## 🚀 Quick Start (5 Minutes)

```powershell
# 1. Check prerequisites
.\scripts\prerequisites-check.ps1

# 2. Validate policies
.\test-xml-validity.ps1

# 3. Check readiness
.\test-deployment-readiness.ps1

# 4. Deploy (choose your environment)
# Non-AD:
cd environment-specific\non-ad
.\scripts\deploy-non-ad-policy.ps1

# AD:
cd environment-specific\active-directory
.\scripts\deploy-ad-policy.ps1
```

## 📁 Key Files

| File | Purpose |
|------|---------|
| `README.md` | Project overview |
| `GETTING_STARTED.md` | Detailed setup guide |
| `PROJECT_STATUS.md` | Validation status |
| `test-xml-validity.ps1` | Validate XML |
| `test-deployment-readiness.ps1` | Readiness check |
| `scripts/prerequisites-check.ps1` | System check |

## 🎯 Common Tasks

### Validate Policies
```powershell
.\test-xml-validity.ps1
```

### Check System Readiness
```powershell
.\test-deployment-readiness.ps1
```

### Deploy Policy (Non-AD)
```powershell
cd environment-specific\non-ad
.\scripts\deploy-non-ad-policy.ps1
```

### Deploy Policy (AD via GPO)
```powershell
cd environment-specific\active-directory
.\scripts\deploy-ad-policy.ps1
```

### Check Policy Status
```powershell
Get-CIPolicy
```

### View WDAC Events
```powershell
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 50
```

### Rollback Policy
```powershell
.\scripts\rollback-policy.ps1
```

## 🔍 Event IDs

| Event ID | Description | Severity |
|----------|-------------|----------|
| 3099 | Policy loaded successfully | Info |
| 3076 | Audit mode block (logged only) | Warning |
| 3077 | Enforce mode block (prevented) | Warning |
| 3089 | Policy load error | Error |

## 📊 Test Scenarios

| Environment | Test Document |
|-------------|---------------|
| Windows 10 Client | `test-cases/windows-10-client/test-scenarios.md` |
| Windows 11 Client | `test-cases/windows-11-client/test-scenarios.md` |
| Windows Server | `test-cases/windows-server-2022/test-scenarios.md` |
| AD Domain | `test-cases/ad-domain/test-scenarios.md` |
| Non-AD Workgroup | `test-cases/non-ad-workgroup/test-scenarios.md` |

## 🆘 Troubleshooting

### Policy Not Loading
```powershell
# Check policy file exists
Test-Path "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"

# Check event logs
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 10

# Restart system
Restart-Computer
```

### Application Blocked
```powershell
# Find blocked application in events
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" |
    Where-Object {$_.Id -eq 3077} |
    Select-Object -First 5

# Create exception policy (see documentation)
```

### Deployment Failed
```powershell
# Check administrator rights
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Check deployment log
Get-Content "$env:TEMP\WDAC_Deployment_Log.txt"

# Re-run prerequisites check
.\scripts\prerequisites-check.ps1
```

## 📚 Documentation

| Topic | Document |
|-------|----------|
| Getting Started | `GETTING_STARTED.md` |
| Understanding WDAC | `docs/guides/01-understanding-wdac.md` |
| Policy Creation | `docs/guides/02-policy-creation.md` |
| Deployment Methods | `docs/guides/03-deployment-methods.md` |
| Monitoring | `docs/guides/04-monitoring-enforcement.md` |
| Troubleshooting | `docs/guides/05-troubleshooting.md` |
| Testing Guide | `docs/testing-guide.md` |

## ✅ Pre-Deployment Checklist

- [ ] Prerequisites check passed
- [ ] XML validation passed
- [ ] Deployment readiness test passed
- [ ] Backup created
- [ ] Rollback procedure tested
- [ ] Test environment validated
- [ ] Documentation reviewed
- [ ] Support team notified

## 🎯 Deployment Phases

### Phase 1: Lab Testing (1-2 days)
- Set up isolated test environment
- Run all test scenarios
- Document results
- Validate rollback

### Phase 2: Pilot (2-4 weeks)
- Deploy to 5-10 users
- Monitor in Audit Mode
- Collect feedback
- Adjust policies

### Phase 3: Production (4+ weeks)
- Week 1: 10% rollout
- Week 2: 25% rollout
- Week 3: 50% rollout
- Week 4: 100% rollout

## 📞 Support

- **Documentation:** `docs/` folder
- **Test Scenarios:** `test-cases/` folder
- **Event Logs:** CodeIntegrity/Operational
- **Troubleshooting:** `docs/guides/05-troubleshooting.md`

## 🔗 Quick Links

- [README](README.md) - Project overview
- [Getting Started](GETTING_STARTED.md) - Setup guide
- [Project Status](PROJECT_STATUS.md) - Validation status
- [Test Plan](test-cases/TEST_PLAN.md) - Master test plan
- [Deployment Ready](DEPLOYMENT_READY.md) - Deployment guide

---

**Print this page for quick reference during deployment!**

*Version: 2.0 | Updated: December 3, 2025*
