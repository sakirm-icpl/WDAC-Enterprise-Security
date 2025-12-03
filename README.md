# WDAC Enterprise Security - Production Ready

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Windows](https://img.shields.io/badge/Windows-10%2F11%2C%20Server%202019%2B-blue.svg)](https://www.microsoft.com/windows)

Production-ready Windows Defender Application Control (WDAC) implementation with validated policies and deployment scripts for enterprise environments.

## 🎯 Quick Start

```powershell
# 1. Check system requirements (run as Administrator)
.\scripts\prerequisites-check.ps1

# 2. Validate policies
.\test-xml-validity.ps1
.\test-deployment-readiness.ps1

# 3. Deploy (choose your environment)
cd environment-specific\non-ad  # or active-directory
.\scripts\deploy-non-ad-policy.ps1  # or deploy-ad-policy.ps1

# 4. Custom Policy Testing (NEW)
# For custom testing scenarios, see custom-policies directory
cd custom-policies
.\deploy-custom-policy.ps1  # Deploy custom policy
.\test-custom-policy.ps1    # Test custom scenarios
```
## 📊 Project Status

✅ **All XML policies validated and tested**  
✅ **Binary conversion successful**  
✅ **Deployment scripts functional**  
✅ **Ready for production testing**

## 📋 Contents

- [System Requirements](#-system-requirements)
- [Deployment Guide](#-deployment-guide)
- [Documentation](#-documentation)
- [Troubleshooting](#-troubleshooting)

## 🚀 Quick Start

### Prerequisites Check
```powershell
# Run as Administrator
.\scripts\prerequisites-check.ps1
```

### Validate Policies
```powershell
# Validate all XML policies
.\test-xml-validity.ps1

# Run comprehensive readiness test
.\test-deployment-readiness.ps1
```

### Deploy (Choose Your Environment)

**Non-AD Environment:**
```powershell
cd environment-specific\non-ad
.\scripts\deploy-non-ad-policy.ps1
```

**Active Directory Environment:**
```powershell
cd environment-specific\active-directory
.\scripts\deploy-ad-policy.ps1
```

## ✨ Key Features

### Policy Types
- ✅ **Base Policies** - Foundation policies for system-wide protection
- ✅ **Supplemental Policies** - Department-specific and exception policies
- ✅ **Deny Policies** - Block untrusted locations (Downloads, Temp folders)
- ✅ **Trusted App Policies** - Allow specific applications by hash or publisher

### Environments Supported
- ✅ **Windows 10/11 Pro/Enterprise** (1903+)
- ✅ **Windows Server 2019/2022**
- ✅ **Active Directory Domain**
- ✅ **Non-Domain (Workgroup)**
- ✅ **Hybrid (Azure AD Join)**

## 💻 System Requirements

### Minimum
- Windows 10 version 1903 or later / Windows Server 2019+
- PowerShell 5.1 or later
- Administrator privileges

### Recommended
- Windows 11 / Windows Server 2022
- PowerShell 7.x

## 🚀 Deployment Guide

### 1. Environment Detection

The repository automatically detects your environment:
- **Non-AD**: Standalone Windows 10/11 workstations
- **Active Directory**: Domain-joined systems

### 2. Quick Deployment

```powershell
# Run as Administrator

# For Non-AD environments:
cd environment-specific\non-ad
.\scripts\deploy-non-ad-policy.ps1

# For Active Directory environments:
cd environment-specific\active-directory
.\scripts\deploy-ad-policy.ps1
```

### 3. Custom Deployment

1. Review environment-specific documentation:
   - Non-AD: `environment-specific/non-ad/documentation/non-ad-environment-guide.md`
   - AD: `environment-specific/active-directory/documentation/ad-deployment-guide.md`

2. Customize policies in the `policies/` directory

3. Test with `test-deployment-readiness.ps1`

4. Deploy using environment-specific scripts



## 🧪 Testing

### Pre-Deployment Validation
```powershell
# Run as Administrator
.\scripts\prerequisites-check.ps1
.\test-xml-validity.ps1
.\test-deployment-readiness.ps1
```

### Best Practices
- Always test in **Audit Mode** first
- Monitor event logs for 2-4 weeks
- Document exceptions in `testing-results/`
- Review [test-cases/](test-cases/) for detailed scenarios

## 📚 Documentation

### Essential Guides
- [GETTING_STARTED.md](GETTING_STARTED.md) - Complete setup guide
- [Non-AD Guide](environment-specific/non-ad/documentation/non-ad-environment-guide.md)
- [Active Directory Guide](environment-specific/active-directory/documentation/ad-deployment-guide.md)

### Reference
- [Architecture Docs](architecture/)
- [Policy Examples](docs/examples/)
- [Test Cases](test-cases/TEST_PLAN.md)
- [Troubleshooting](docs/guides/05-troubleshooting.md)

## 🔧 Troubleshooting

### Common Issues

**XML Errors**
```powershell
.\test-xml-validity.ps1  # Validate policy files
```

**Access Denied**
```powershell
Start-Process powershell -Verb RunAs  # Run as Administrator
```

**Policy Not Taking Effect**
```powershell
Get-CIPolicy  # Check deployed policies
Restart-Computer  # Restart to apply changes
```

### Monitoring
```powershell
# View WDAC events
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 50
```

### Rollback
```powershell
.\scripts\rollback-policy.ps1  # Revert to previous policy
```

## ✅ Pre-Deployment Checklist

- [ ] Validate XML policies: `test-xml-validity.ps1`
- [ ] Run readiness test: `test-deployment-readiness.ps1`
- [ ] Test in Audit Mode for 2-4 weeks
- [ ] Document exceptions
- [ ] Test rollback procedure

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

## ⚠️ Important Notes

1. **Always test in Audit Mode first** before enforcing policies
2. **Backup existing policies** before deployment
3. **Monitor event logs** continuously after deployment
4. **Have a rollback plan** ready

## 🎉 Ready for Production

✅ **All policies validated** | ✅ **All tests passing** | ✅ **Documentation complete**

See [PROJECT_STATUS.md](PROJECT_STATUS.md) for complete validation results.

## 🧪 Custom Policy Testing (NEW)

### Custom Policy Features
- **Allow Microsoft-signed applications** - All Microsoft signed files are permitted
- **Allow Program Files** - All files in %PROGRAMFILES% and %PROGRAMFILES(X86)% are permitted
- **Block Downloads folder** - All files in user Downloads folders are denied
- **Block OSSEC agent folder** - All files in C:\Program Files (x86)\ossec-agent\active-response\bin are denied
- **Audit Mode** - Policy runs in audit mode to log without blocking

See [CUSTOM_POLICIES_SUMMARY.md](CUSTOM_POLICIES_SUMMARY.md) for detailed information and usage instructions.
