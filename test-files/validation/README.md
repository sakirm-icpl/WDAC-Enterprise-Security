# WDAC Policy Validation Scripts

This directory contains scripts for validating WDAC policies.

## Available Scripts

### Test-WDACPolicy.ps1

Validates the syntax and structure of WDAC policy XML files.

Usage:
```powershell
.\Test-WDACPolicy.ps1 -PolicyPath "C:\policies\MyPolicy.xml"
```

### Analyze-AuditLogs.ps1

Analyzes WDAC audit logs to identify blocked applications and policy effectiveness.

Usage:
```powershell
.\Analyze-AuditLogs.ps1 -Hours 24
```

### Deploy-TestPolicy.ps1

Deploys a WDAC policy in audit mode for testing.

Usage:
```powershell
.\Deploy-TestPolicy.ps1 -PolicyPath "C:\policies\TestPolicy.xml"
```

### Generate-TestReport.ps1

Generates a comprehensive test report based on audit logs and test results.

Usage:
```powershell
.\Generate-TestReport.ps1 -OutputPath "C:\reports\TestReport.html"
```

## Usage Guidelines

1. Always run validation scripts with appropriate privileges
2. Review script code before execution
3. Test scripts in isolated environments first
4. Document validation results for policy refinement
5. Archive validation results for compliance purposes

## Customization

These scripts can be customized for specific testing requirements:
- Modify thresholds for alerting
- Add custom reporting formats
- Integrate with existing monitoring systems
- Extend validation criteria