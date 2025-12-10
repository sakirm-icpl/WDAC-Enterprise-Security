# generate-compliance-report.ps1

This tool generates compliance reports from WDAC audit logs.

## Overview

The `generate-compliance-report.ps1` script analyzes WDAC audit logs to generate comprehensive compliance reports. These reports help administrators understand policy effectiveness, identify blocked applications, and demonstrate compliance with security requirements.

## Syntax

```powershell
generate-compliance-report.ps1
    [-LogPath <String>]
    [-OutputPath <String>]
    [-DaysBack <Int32>]
    [-IncludeEventDetails]
    [-ExportToCsv]
```

## Parameters

### -LogPath
Specifies the path to the WDAC audit log directory. Default is `C:\Windows\System32\CodeIntegrity\AuditLogs`.

### -OutputPath
Specifies the path where the HTML report will be saved. Default is `.\wdac-compliance-report.html`.

### -DaysBack
Specifies how many days of audit logs to analyze. Default is 7 days.

### -IncludeEventDetails
Includes detailed event information in the report.

### -ExportToCsv
Exports the raw event data to a CSV file.

## Usage Examples

### Basic Compliance Report
```powershell
# Generate a compliance report using default settings
.\generate-compliance-report.ps1
```

### Custom Log Path
```powershell
# Generate a report from a custom log path
.\generate-compliance-report.ps1 -LogPath "C:\CustomLogs\WDAC"
```

### Extended Analysis Period
```powershell
# Analyze 30 days of audit logs
.\generate-compliance-report.ps1 -DaysBack 30
```

### Include Event Details
```powershell
# Include detailed event information in the report
.\generate-compliance-report.ps1 -IncludeEventDetails
```

### Export to CSV
```powershell
# Export raw event data to CSV format
.\generate-compliance-report.ps1 -ExportToCsv
```

### Custom Output Path
```powershell
# Save the report to a custom location
.\generate-compliance-report.ps1 -OutputPath "C:\Reports\wdac-compliance.html"
```

## Report Generation Process

The script performs the following steps to generate compliance reports:

1. **Log Discovery**: Locates and identifies relevant audit log files
2. **Event Extraction**: Parses CSV log files to extract WDAC events
3. **Data Analysis**: Analyzes events to identify patterns and trends
4. **Report Compilation**: Organizes findings into a structured report
5. **Output Generation**: Creates HTML report and optional CSV export

## Supported Event Types

The script analyzes the following WDAC audit event types:

| Event ID | Description | Purpose |
|----------|-------------|---------|
| 3076 | Executable file was not allowed | Tracks blocked executables |
| 3077 | Script file was not allowed | Tracks blocked scripts |
| 3099 | File was not allowed by publisher rule | Tracks publisher rule violations |

## Report Contents

The HTML report includes:

### Executive Summary
- Total number of audit events
- Breakdown by event type
- Key metrics and trends

### Top Blocked Executables
- List of most frequently blocked executables
- Block count for each executable

### Top Blocked Paths
- List of directories with the most blocked files
- Block count for each path

### Detailed Events (Optional)
- Timestamp, event ID, file name, and file path for each event
- Limited to first 100 events to avoid overly large reports

## Output Formats

The script can generate reports in the following formats:

1. **HTML Report**: Richly formatted report with charts and tables
2. **CSV Export**: Raw event data for further analysis (when `-ExportToCsv` is specified)

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- WDAC policies deployed in audit mode

## WDAC Audit Mode Requirements

For meaningful compliance reports, WDAC must be configured in audit mode:

### Enabling Audit Mode
```powershell
# Add audit mode rule to your policy
<Rule>
    <Option>Enabled:Audit Mode</Option>
</Rule>
```

### Deploying Audit Policy
- Deploy the policy with audit mode enabled
- Allow sufficient time for events to accumulate
- Regularly review and analyze audit logs

## Performance Considerations

### Large Log Files
When processing large volumes of audit data:
- The script may take considerable time to process
- Memory usage increases with the number of events
- Consider reducing the analysis period with `-DaysBack`

### Network Locations
When logs are stored on network shares:
- Network latency may impact performance
- Ensure adequate bandwidth for log transfer
- Consider copying logs locally before processing

## Best Practices

1. **Regular Analysis**: Generate compliance reports on a regular schedule
2. **Trend Monitoring**: Track changes in blocked applications over time
3. **Policy Refinement**: Use report findings to refine WDAC policies
4. **Stakeholder Communication**: Share reports with security teams and management
5. **Retention Policies**: Implement log retention policies to manage storage
6. **Automated Reporting**: Schedule regular report generation using Task Scheduler

## Troubleshooting

### Common Issues

1. **No audit logs found**: Verify WDAC is in audit mode and running
2. **Permission denied**: Run PowerShell as Administrator
3. **Invalid log format**: Check log file integrity and format
4. **Performance issues**: Reduce analysis period or log volume

### Diagnostic Information

The script provides detailed logging to help troubleshoot issues:

- Informational messages about the analysis process
- Warning messages for potential issues
- Error messages with specific details
- Progress indicators during log processing

## Security Considerations

### Log Access
The script reads audit log files but does not modify them:
- Requires read access to log directories
- Does not alter or delete log files
- Processes logs in a read-only manner

### Data Privacy
The script handles sensitive security data:
- Report files contain information about blocked applications
- Store reports securely to prevent unauthorized access
- Consider encryption for report files containing sensitive data

## Related Tools

- [simulate-policy.ps1](simulate-policy.md) - Simulate policy enforcement
- [deploy-policy.ps1](deploy-policy.md) - Deploy policies to systems
- [test-xml-validity.ps1](test-xml-validity.md) - Validate policy syntax

## See Also

- [WDAC Audit Mode Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/audit-windows-defender-application-control-policies)
- [Event Log Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/event-id-explanations)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)