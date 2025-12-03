# Custom Policies Directory Structure

## Files

- `custom-base-policy.xml` - Main WDAC policy with custom rules
- `deploy-custom-policy.ps1` - Script to deploy the custom policy
- `test-custom-policy.ps1` - Script to test the custom policy scenarios
- `monitor-audit-logs.ps1` - Real-time audit log monitoring script
- `README.md` - Documentation for custom policies
- `DEPLOY_INSTRUCTIONS.txt` - Step-by-step deployment guide
- `DIRECTORY_STRUCTURE.md` - This file

## Policy Features

1. **Allow Microsoft-signed applications** - All Microsoft signed files are permitted
2. **Allow Program Files** - All files in %PROGRAMFILES% and %PROGRAMFILES(X86)% are permitted
3. **Block Downloads folder** - All files in user Downloads folders are denied
4. **Block OSSEC agent folder** - All files in C:\Program Files (x86)\ossec-agent\active-response\bin are denied
5. **Audit Mode** - Policy runs in audit mode to log without blocking

## Usage

1. Deploy the policy using `deploy-custom-policy.ps1`
2. Test scenarios using `test-custom-policy.ps1`
3. Monitor audit logs using `monitor-audit-logs.ps1`
4. Check detailed logs in %TEMP% directory