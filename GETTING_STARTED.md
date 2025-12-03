# Getting Started with WDAC Enterprise Security

## ✅ Prerequisites

### System Requirements
- Windows 10 version 1903+ or Windows 11
- Windows Server 2019 or 2022
- PowerShell 5.1+
- Administrator privileges

### Before You Begin
- Back up existing policies
- Identify your environment (AD or non-AD)
- Plan for 2-4 weeks of audit mode testing

## 🚀 Quick Start

### 1. Validate System

```powershell
# Run as Administrator
.\scripts\prerequisites-check.ps1
```

### 2. Validate Policies

```powershell
.\test-xml-validity.ps1
.\test-deployment-readiness.ps1
```

### 3. Deploy

Choose your environment:

**For Non-AD Systems:**
```powershell
cd environment-specific\non-ad
.\scripts\deploy-non-ad-policy.ps1
```

**For Active Directory Systems:**
```powershell
cd environment-specific\active-directory
.\scripts\deploy-ad-policy.ps1
```

## 🧪 Testing and Validation

### Audit Mode Testing

1. Deploy in Audit Mode (default behavior)
2. Monitor event logs for 2-4 weeks
3. Review blocked applications
4. Adjust policies as needed

### Event Log Analysis

```powershell
# View WDAC events
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 100
```

### Custom Policy Testing (NEW)

For advanced testing scenarios with specific requirements:
1. Custom policies for specific folder restrictions
2. Targeted blocking rules for specific directories
3. Advanced audit logging capabilities

See `custom-policies/README.md` for detailed instructions.
## ⚠️ Important Notes

1. **Always backup existing policies** before deployment
2. **Test in audit mode first** for 2-4 weeks
3. **Monitor event logs continuously** after deployment
4. **Have a rollback plan** ready

## 📚 Documentation

- [README.md](README.md) - Main project overview
- [PROJECT_STATUS.md](PROJECT_STATUS.md) - Current validation status
- Environment-specific guides in `environment-specific/*/documentation/`