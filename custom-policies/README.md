# Custom WDAC Policy for Testing

This directory contains custom WDAC policies designed for specific testing scenarios.

## Policy Features

1. **Allows all Microsoft-signed applications** to run normally
2. **Allows all applications in Program Files directories** to run normally
3. **Blocks all executables, scripts, and files in user Downloads folders**
4. **Blocks all executables in OSSEC agent active-response bin folder**
5. **Runs in Audit Mode** to log blocking attempts without actually blocking

## Files Included

- `custom-base-policy.xml` - The main WDAC policy XML file
- `deploy-custom-policy.ps1` - Script to deploy the custom policy
- `test-custom-policy.ps1` - Script to test the policy scenarios
- `README.md` - This documentation file

## Deployment Instructions

1. Open PowerShell as Administrator
2. Navigate to the repository root directory
3. Run the deployment script:
   ```powershell
   .\custom-policies\deploy-custom-policy.ps1
   ```
4. Restart your computer when prompted

## Testing Instructions

1. After deployment and restart, open PowerShell as Administrator
2. Navigate to the repository root directory
3. Run the test script:
   ```powershell
   .\custom-policies\test-custom-policy.ps1
   ```
4. Check the audit logs for blocking events

## Audit Log Monitoring

To monitor WDAC audit events in real-time:
```powershell
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 100 | Where-Object {$_.Id -eq 3076} | Select-Object TimeCreated, Message
```

## Policy Details

The policy implements the following rules:
- **ALLOW**: All files in `%PROGRAMFILES%` and `%PROGRAMFILES(X86)%` directories
- **ALLOW**: All Microsoft-signed files
- **DENY**: All files in `%OSDRIVE%\Users\*\Downloads\*` paths
- **DENY**: All files in `C:\Program Files (x86)\ossec-agent\active-response\bin\*` path

All DENY actions are logged as audit events (not actual blocks) since the policy is in Audit Mode.

## Customization

To modify the policy:
1. Edit `custom-base-policy.xml`
2. Redeploy using the deployment script
3. Restart the system