# WDAC Deployment Overview

## Quick Deployment

### Non-AD Systems
```powershell
# Navigate to non-AD directory
cd environment-specific\non-ad

# Deploy policies
.\scripts\deploy-non-ad-policy.ps1
```

### Active Directory Systems
```powershell
# Navigate to AD directory
cd environment-specific\active-directory

# Deploy policies via Group Policy
.\scripts\deploy-ad-policy.ps1
```

## Deployment Process

### 1. Pre-Deployment
```powershell
# Check system requirements
.\scripts\prerequisites-check.ps1

# Validate policies
.\test-xml-validity.ps1
.\test-deployment-readiness.ps1
```

### 2. Test Deployment (Audit Mode)
```powershell
# Deploy in audit mode
# Non-AD:
.\scripts\deploy-non-ad-policy.ps1 -Mode Audit

# AD:
.\scripts\deploy-ad-policy.ps1 -Mode Audit
```

### 3. Monitor (2-4 weeks)
```powershell
# Check blocked applications
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" | Where-Object {$_.Id -eq 3076}
```

### 4. Production Deployment (Enforce Mode)
```powershell
# Deploy in enforce mode
# Non-AD:
.\scripts\deploy-non-ad-policy.ps1 -Mode Enforce

# AD:
.\scripts\deploy-ad-policy.ps1 -Mode Enforce
```

## Environment-Specific Deployment

### Non-Active Directory
**Best for:** Small offices, remote workers, standalone systems

**Process:**
1. Review: `environment-specific/non-ad/documentation/non-ad-environment-guide.md`
2. Customize policies in `environment-specific/non-ad/policies/`
3. Deploy using: `environment-specific/non-ad/scripts/deploy-non-ad-policy.ps1`

### Active Directory
**Best for:** Enterprise networks, centralized management

**Process:**
1. Review: `environment-specific/active-directory/documentation/ad-deployment-guide.md`
2. Customize policies in `environment-specific/active-directory/policies/`
3. Deploy using: `environment-specific/active-directory/scripts/deploy-ad-policy.ps1`

## Policy Management

### Updating Policies
```powershell
# Non-AD update
cd environment-specific\non-ad
.\scripts\update-non-ad-policy.ps1

# AD update
cd environment-specific\active-directory
.\scripts\update-ad-policy.ps1
```

### Rolling Back
```powershell
# Rollback to previous policy
.\scripts\rollback_policy.ps1
```

## Monitoring and Maintenance

### Daily Monitoring
```powershell
# Check recent WDAC events
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 50
```

### Weekly Reports
Use the compliance reporter utility:
```powershell
# Generate compliance report
.\environment-specific\shared\utilities\compliance-reporter.ps1
```

## Best Practices

1. **Always deploy in Audit Mode first** for 2-4 weeks
2. **Backup existing policies** before deployment
3. **Monitor event logs** continuously after deployment
4. **Document all changes** in version control
5. **Test rollback procedures** regularly
6. **Update policies quarterly** or as needed

## Troubleshooting

### Common Issues

**"Access Denied" During Deployment**
```powershell
# Run PowerShell as Administrator
Start-Process powershell -Verb RunAs
```

**Policy Not Taking Effect**
```powershell
# Check deployed policies
Get-CIPolicy

# Restart system
Restart-Computer
```

**GPO Distribution Delays (AD)**
```powershell
# Force Group Policy update
gpupdate /force
```

## Post-Deployment

### 1. Verify Deployment
```powershell
# Check policy status
Get-CIPolicy
```

### 2. Monitor Performance
- CPU usage
- Memory consumption
- System responsiveness

### 3. Document Configuration
- Policy versions deployed
- Deployment date
- Systems affected
- Any customizations made

## Next Steps

After successful deployment:
1. Establish exception management process
2. Train support staff
3. Schedule regular policy reviews
4. Plan for quarterly updates
5. Monitor compliance reports