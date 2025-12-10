# simulate-policy.ps1

This tool simulates WDAC policy enforcement to test policies before deployment.

## Overview

The `simulate-policy.ps1` script allows you to test WDAC policies against actual files on your system without actually enforcing the policy. This helps identify which files would be allowed or blocked by a policy before deployment, reducing the risk of blocking legitimate applications.

## Syntax

```powershell
simulate-policy.ps1
    -PolicyPath <String>
    [-TestPath <String>]
    [-IncludeSubdirectories]
    [-OutputReport <String>]
    [-DetailedLogging]
```

## Parameters

### -PolicyPath
Specifies the path to the WDAC policy file to simulate. This parameter is mandatory.

### -TestPath
Specifies the path to scan for files to test against the policy. Default is the current directory.

### -IncludeSubdirectories
Includes subdirectories when scanning for files to test.

### -OutputReport
Specifies the path where the HTML report will be saved. Default is `.\policy-simulation-report.html`.

### -DetailedLogging
Enables detailed logging to a temporary file.

## Usage Examples

### Basic Policy Simulation
```powershell
# Simulate a policy against files in the current directory
.\simulate-policy.ps1 -PolicyPath "C:\policies\my-policy.xml"
```

### Simulate Against Specific Directory
```powershell
# Simulate a policy against files in a specific directory
.\simulate-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -TestPath "C:\Program Files"
```

### Simulate with Subdirectories
```powershell
# Include subdirectories in the simulation
.\simulate-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -TestPath "C:\Program Files" -IncludeSubdirectories
```

### Custom Output Report
```powershell
# Save the report to a custom location
.\simulate-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -OutputReport "C:\reports\simulation-results.html"
```

### Detailed Logging
```powershell
# Enable detailed logging for troubleshooting
.\simulate-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -DetailedLogging
```

## Simulation Process

The script performs the following steps during simulation:

1. **Policy Loading**: Loads and parses the specified WDAC policy
2. **File Discovery**: Scans the specified path for executable files (*.exe, *.dll, *.sys)
3. **Policy Evaluation**: Tests each discovered file against the policy rules
4. **Result Collection**: Records whether each file would be allowed or denied
5. **Report Generation**: Creates an HTML report with detailed results

## Supported File Types

The simulation tests the following file types:
- **.exe**: Executable files
- **.dll**: Dynamic Link Libraries
- **.sys**: System driver files

## Output

The script generates:

1. Console output showing the simulation progress and summary
2. An HTML report with detailed results at the specified output path
3. Optional detailed logging to a temporary file if `-DetailedLogging` is specified

## Report Contents

The HTML report includes:

### Executive Summary
- Total files tested
- Number of files that would be allowed
- Number of files that would be denied

### Top Blocked Executables
- List of executables that would be blocked
- Block count for each executable

### Top Blocked Paths
- List of directories with the most blocked files
- Block count for each path

### Detailed Results
- File-by-file breakdown of policy decisions
- Reason for each allow/deny decision
- Rule that matched for each decision

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- Administrator privileges (recommended but not required)

## Performance Considerations

### Large Directory Scans
When scanning large directories:
- The simulation may take considerable time
- Consider using specific subdirectories rather than broad scans
- Use `-IncludeSubdirectories` judiciously

### Memory Usage
- The script loads all policy rules into memory
- Large policies may consume significant memory
- Results for all tested files are held in memory during processing

## Best Practices

1. **Test in Controlled Environments**: Run simulations on test systems that mirror production
2. **Focus Scans Appropriately**: Target specific directories rather than scanning entire drives
3. **Review Denied Files**: Carefully examine files that would be denied to ensure they're not legitimate
4. **Use Audit Mode First**: Deploy policies in audit mode to collect real-world data
5. **Combine Approaches**: Use both simulation and audit mode for comprehensive testing
6. **Document Findings**: Keep records of simulation results for policy refinement

## Troubleshooting

### Common Issues

1. **Policy loading failures**: Check policy file validity and path
2. **File access denied**: Run PowerShell as Administrator for better access
3. **Long execution times**: Narrow the test scope or exclude subdirectories
4. **Memory issues**: Reduce the number of files being tested simultaneously

### Diagnostic Information

The script provides detailed logging to help troubleshoot issues:

- Informational messages about the simulation process
- Warning messages for potential issues
- Error messages with specific details
- Progress indicators during file processing

## Security Considerations

### File Access
The script reads file properties but does not execute files:
- Uses `Get-FileHash` to calculate file hashes
- Uses `Get-AuthenticodeSignature` to read certificate information
- Does not execute or modify any files

### Privacy
The script does not transmit any data:
- All processing occurs locally
- Reports are saved locally
- No network communication is initiated

## Related Tools

- [test-xml-validity.ps1](test-xml-validity.md) - Validate policy syntax
- [deploy-policy.ps1](deploy-policy.md) - Deploy policies to systems
- [generate-compliance-report.ps1](generate-compliance-report.md) - Generate compliance reports from audit logs

## See Also

- [WDAC Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/)
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/)