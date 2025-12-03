# Custom WDAC Policies Summary

## Overview

This repository now includes custom WDAC policies designed for specific testing scenarios with targeted allow/deny rules.

## New Features

### 1. Custom Policy Directory
- Located at `custom-policies/`
- Contains all files needed for custom testing scenarios

### 2. Policy Capabilities
- **Allow Microsoft-signed applications** - All Microsoft signed files are permitted
- **Allow Program Files** - All files in `%PROGRAMFILES%` and `%PROGRAMFILES(X86)%` are permitted
- **Block Downloads folder** - All files in user Downloads folders are denied
- **Block OSSEC agent folder** - All files in `C:\Program Files (x86)\ossec-agent\active-response\bin` are denied
- **Audit Mode** - Policy runs in audit mode to log without blocking

### 3. Testing Scenarios
1. Microsoft signed applications should work normally
2. Program Files applications should work normally
3. Downloads folder files should generate audit logs
4. OSSEC agent folder files should generate audit logs

## Files Included

### Main Policy Files
- `custom-base-policy.xml` - Main WDAC policy with custom rules
- `deploy-custom-policy.ps1` - Script to deploy the custom policy
- `test-custom-policy.ps1` - Script to test the custom policy scenarios

### Supporting Files
- `monitor-audit-logs.ps1` - Real-time audit log monitoring script
- `README.md` - Documentation for custom policies
- `DEPLOY_INSTRUCTIONS.txt` - Step-by-step deployment guide
- `DIRECTORY_STRUCTURE.md` - Custom policies directory structure

## Usage Instructions

### Deployment
1. Open PowerShell as Administrator
2. Navigate to repository root: `cd C:\WADC\WDAC-Enterprise-Security`
3. Deploy policy: `.\custom-policies\deploy-custom-policy.ps1`
4. Restart computer

### Testing
1. After restart, open PowerShell as Administrator
2. Navigate to repository root: `cd C:\WADC\WDAC-Enterprise-Security`
3. Run tests: `.\custom-policies\test-custom-policy.ps1`

### Monitoring
1. Real-time monitoring: `.\custom-policies\monitor-audit-logs.ps1`
2. Manual log checking: 
   ```powershell
   Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 100 | Where-Object {$_.Id -eq 3076}
   ```

## Expected Results

### Allowed Operations (No Audit Events)
- ✅ Microsoft applications (notepad, calc, etc.)
- ✅ Program Files applications

### Audited Operations (Generates Audit Logs)
- ⚠️ Downloads folder executables
- ⚠️ Downloads folder scripts
- ⚠️ OSSEC agent folder executables

## Log Locations

- **Deployment logs**: `$env:TEMP\WDAC_Custom_Deployment_Log.txt`
- **Test logs**: `$env:TEMP\WDAC_Custom_Test_Log.txt`
- **System audit logs**: `Microsoft-Windows-CodeIntegrity/Operational` event log

## Customization

To modify the policy rules:
1. Edit `custom-policies\custom-base-policy.xml`
2. Redeploy using the deployment script
3. Restart the system