# simulate-policy.ps1

This tool simulates WDAC policy enforcement to test policies before deployment.

## Overview

The `simulate-policy.ps1` script provides a safe way to test WDAC policies against actual files without deploying them to the system. It analyzes how a policy would treat files in a specified directory, helping you validate policy effectiveness before enforcement.

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
Specifies the path to the directory containing files to test against the policy. Default is the current directory.

### -IncludeSubdirectories
Includes subdirectories when scanning for files to test.

### -OutputReport
Specifies the path where the HTML simulation report will be saved. Default is `.\policy-simulation-report.html`.

### -DetailedLogging
Enables detailed logging to a temporary file for troubleshooting.

## Usage Examples

### Basic Policy Simulation

```powershell
# Simulate a policy against files in the current directory
.\simulate-policy.ps1 -PolicyPath "C:\policies\my-policy.xml"
```

### Simulate Against Specific Directory

```powershell
# Simulate against a specific directory
.\simulate-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -TestPath "C:\Program Files"
```

### Include Subdirectories

```powershell
# Include subdirectories in the simulation
.\simulate-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -TestPath "C:\Program Files" -IncludeSubdirectories
```

### Custom Report Output

```powershell
# Save report to a custom location
.\simulate-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -OutputReport "C:\reports\simulation.html"
```

### Detailed Logging

```powershell
# Enable detailed logging
.\simulate-policy.ps1 -PolicyPath "C:\policies\my-policy.xml" -DetailedLogging
```

## Simulation Process

The script performs the following steps during simulation:

1. **Policy Loading**: Loads and parses the WDAC policy file
2. **File Discovery**: Scans the specified directory for executable files
3. **Policy Evaluation**: Tests each file against the policy rules
4. **Result Analysis**: Determines if each file would be allowed or denied
5. **Report Generation**: Creates a detailed HTML report of findings

### File Types Tested

The simulation tests the following file types:

- `.exe` - Executable files
- `.dll` - Dynamic link libraries
- `.sys` - System driver files
- Other executable types as identified by the system

## Output

The script generates:

1. **Console Output**: Real-time progress and summary information
2. **HTML Report**: Detailed analysis of policy simulation results
3. **Detailed Log**: If enabled, a temporary log file with verbose information

### Report Contents

The HTML report includes:

- **Summary Statistics**: Total files tested, allowed, and denied
- **Detailed Results**: File-by-file analysis with rule matching
- **Policy Information**: Details about the policy tested
- **Test Parameters**: Information about the simulation parameters

## Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- ConfigCI PowerShell module
- Read access to the policy file and test directories

## Performance Considerations

### Large Directory Scans

When scanning large directories:

- The process may take considerable time
- Consider using specific subdirectories
- Use `-IncludeSubdirectories` judiciously
- Monitor system resource usage

### Memory Usage

For large simulations:

- Results are stored in memory during processing
- Very large simulations may require significant RAM
- Consider breaking large simulations into smaller chunks

## Best Practices

1. **Test Representative Samples**: Use directories that represent typical system usage
2. **Compare Audit Logs**: Cross-reference with actual audit mode results
3. **Iterate and Refine**: Use simulation to fine-tune policies before deployment
4. **Document Findings**: Keep records of simulation results for policy reviews
5. **Test Critical Applications**: Focus on business-critical applications first

## Troubleshooting

### Common Issues

1. **Access Denied**: Ensure read permissions on policy files and test directories
2. **Invalid Policy**: Verify policy file syntax and structure
3. **No Files Found**: Check test directory and file type filters
4. **Performance Issues**: Reduce scope or run during low-usage periods

### Diagnostic Information

With detailed logging enabled, the script writes additional information to:
`$env:TEMP\WDAC_Simulation_Log.txt`

This log includes:
- Timestamped entries
- Detailed file processing information
- Rule matching details
- Error conditions

## Integration Examples

### Batch Simulation Script

```powershell
# Simulate multiple policies against different directories
$policies = @("C:\policies\base.xml", "C:\policies\strict.xml")
$directories = @("C:\Program Files", "C:\Windows")

foreach ($policy in $policies) {
    foreach ($dir in $directories) {
        $reportName = "simulation_$(Split-Path $policy -Leaf)_$(Split-Path $dir -Leaf).html"
        .\simulate-policy.ps1 -PolicyPath $policy -TestPath $dir -OutputReport $reportName
    }
}
```

### Automated Testing Workflow

```powershell
# Integrate simulation into a testing workflow
.\simulate-policy.ps1 -PolicyPath "C:\policies\new-policy.xml" -TestPath "C:\TestApplications" -OutputReport "C:\Reports\test-results.html"

# Check results
$deniedCount = (Select-String -Path "C:\Reports\test-results.html" -Pattern "DENIED").Count
if ($deniedCount -gt 5) {
    Write-Warning "Too many files would be denied. Review policy."
} else {
    Write-Host "Policy simulation acceptable. Proceeding with deployment testing."
}
```

## Related Tools

- [generate-policy-from-template.ps1](generate-policy-from-template.md) - Generate policies from templates
- [test-xml-validity.ps1](test-xml-validity.md) - Validate policy syntax
- [deploy-policy.ps1](deploy-policy.md) - Deploy policies to systems
- [generate-compliance-report.ps1](generate-compliance-report.md) - Analyze audit logs

## See Also

- [WDAC Policy Testing Documentation](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-control/test-windows-defender-application-control-policies)
- [PowerShell File System Cmdlets](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/?view=powershell-7.3#filesystem)