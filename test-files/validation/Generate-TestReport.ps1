# Generate-TestReport.ps1
# Generates a comprehensive WDAC test report based on audit logs and test results

param(
    [Parameter(Mandatory=$false)]
    [int]$Hours = 24,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "$env:TEMP\WDAC_Test_Report.html",
    
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeSystemInfo
)

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    switch ($Level) {
        "ERROR" { Write-Host $LogMessage -ForegroundColor Red }
        "WARN" { Write-Host $LogMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $LogMessage -ForegroundColor Green }
        default { Write-Host $LogMessage -ForegroundColor White }
    }
}

function Get-SystemInformation {
    try {
        $ComputerInfo = Get-ComputerInfo
        $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem
        $BIOSInfo = Get-CimInstance -ClassName Win32_BIOS
        
        return [PSCustomObject]@{
            ComputerName = $ComputerInfo.CsName
            OperatingSystem = "$($OSInfo.Caption) $($OSInfo.Version)"
            SystemManufacturer = $ComputerInfo.CsManufacturer
            SystemModel = $ComputerInfo.CsModel
            BIOSVersion = $BIOSInfo.SMBIOSBIOSVersion
            LastBootUpTime = $OSInfo.LastBootUpTime
        }
    }
    catch {
        Write-Log "Failed to retrieve system information: $_" "WARN"
        return $null
    }
}

function Get-WDACStatus {
    try {
        $WDACStatus = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
        return [PSCustomObject]@{
            CodeIntegrityPolicyEnforcement = $WDACStatus.CodeIntegrityPolicyEnforcementStatus
            UserModeCodeIntegrity = $WDACStatus.UserModeCodeIntegrityPolicyEnforcementStatus
            VirtualizationBasedSecurity = $WDACStatus.VirtualizationBasedSecurityStatus
        }
    }
    catch {
        Write-Log "Failed to retrieve WDAC status: $_" "WARN"
        return $null
    }
}

function Get-AuditLogSummary {
    param([int]$Hours)
    
    $StartTime = (Get-Date).AddHours(-$Hours)
    
    try {
        # Get Code Integrity events
        $BlockingEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
            StartTime = $StartTime
            Level = 2
            Id = 3076, 3077, 3089
        } -ErrorAction SilentlyContinue
        
        $AllEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
            StartTime = $StartTime
        } -ErrorAction SilentlyContinue
        
        # Analyze blocking events
        $BlockedApplications = @()
        foreach ($Event in $BlockingEvents) {
            $Message = $Event.Message
            if ($Message -match "File name: (.+?)\s") {
                $FileName = $matches[1]
            } else {
                $FileName = "Unknown"
            }
            
            $BlockedApp = [PSCustomObject]@{
                TimeCreated = $Event.TimeCreated
                EventId = $Event.Id
                FileName = $FileName
                Message = $Message
            }
            
            $BlockedApplications += $BlockedApp
        }
        
        # Group by filename
        $GroupedApplications = $BlockedApplications | Group-Object FileName | Sort-Object Count -Descending
        
        return [PSCustomObject]@{
            TotalEvents = $AllEvents.Count
            BlockingEvents = $BlockingEvents.Count
            UniqueBlockedApps = $GroupedApplications.Count
            TopBlockedApps = $GroupedApplications | Select-Object -First 10
            BlockedApplications = $BlockedApplications
        }
    }
    catch {
        Write-Log "Failed to analyze audit logs: $_" "WARN"
        return $null
    }
}

function Get-PolicyInformation {
    param([string]$PolicyPath)
    
    if (-not (Test-Path $PolicyPath)) {
        return $null
    }
    
    try {
        [xml]$Policy = Get-Content $PolicyPath
        
        $RuleCount = ($Policy.Policy.Rules.Rule | Measure-Object).Count
        $FileRuleCount = ($Policy.Policy.FileRules.ChildNodes | Measure-Object).Count
        $SignerCount = ($Policy.Policy.Signers.Signer | Measure-Object).Count
        
        return [PSCustomObject]@{
            PolicyType = $Policy.Policy.PolicyType
            Version = $Policy.Policy.VersionEx
            RuleCount = $RuleCount
            FileRuleCount = $FileRuleCount
            SignerCount = $SignerCount
        }
    }
    catch {
        Write-Log "Failed to analyze policy file: $_" "WARN"
        return $null
    }
}

Write-Log "Generating WDAC Test Report" "INFO"
Write-Log "Analysis period: Last $Hours hours" "INFO"

# Collect data
$SystemInfo = if ($IncludeSystemInfo) { Get-SystemInformation } else { $null }
$WDACStatus = Get-WDACStatus
$AuditSummary = Get-AuditLogSummary -Hours $Hours
$PolicyInfo = if ($PolicyPath) { Get-PolicyInformation -PolicyPath $PolicyPath } else { $null }

# Generate HTML report
$HTMLReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>WDAC Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h1, h2, h3 { color: #2E74B5; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .success { color: green; }
        .warning { color: orange; }
        .error { color: red; }
        .info-box { border: 1px solid #ccc; padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .section { margin-bottom: 30px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>WDAC Test Report</h1>
        <p>Generated on: $(Get-Date)</p>
        <p>Analysis Period: Last $Hours hours</p>
        
        $(if ($SystemInfo) {
            "<div class='section'>
                <h2>System Information</h2>
                <div class='info-box'>
                    <table>
                        <tr><th>Property</th><th>Value</th></tr>
                        <tr><td>Computer Name</td><td>$($SystemInfo.ComputerName)</td></tr>
                        <tr><td>Operating System</td><td>$($SystemInfo.OperatingSystem)</td></tr>
                        <tr><td>System Manufacturer</td><td>$($SystemInfo.SystemManufacturer)</td></tr>
                        <tr><td>System Model</td><td>$($SystemInfo.SystemModel)</td></tr>
                        <tr><td>BIOS Version</td><td>$($SystemInfo.BIOSVersion)</td></tr>
                        <tr><td>Last Boot Time</td><td>$($SystemInfo.LastBootUpTime)</td></tr>
                    </table>
                </div>
            </div>"
        })
        
        <div class='section'>
            <h2>WDAC Status</h2>
            <div class='info-box'>
                <table>
                    <tr><th>Property</th><th>Value</th></tr>
                    <tr><td>Code Integrity Policy Enforcement</td><td>$($WDACStatus.CodeIntegrityPolicyEnforcement)</td></tr>
                    <tr><td>User Mode Code Integrity</td><td>$($WDACStatus.UserModeCodeIntegrity)</td></tr>
                    <tr><td>Virtualization Based Security</td><td>$($WDACStatus.VirtualizationBasedSecurity)</td></tr>
                </table>
            </div>
        </div>
        
        $(if ($PolicyInfo) {
            "<div class='section'>
                <h2>Policy Information</h2>
                <div class='info-box'>
                    <table>
                        <tr><th>Property</th><th>Value</th></tr>
                        <tr><td>Policy Type</td><td>$($PolicyInfo.PolicyType)</td></tr>
                        <tr><td>Version</td><td>$($PolicyInfo.Version)</td></tr>
                        <tr><td>Total Rules</td><td>$($PolicyInfo.RuleCount)</td></tr>
                        <tr><td>File Rules</td><td>$($PolicyInfo.FileRuleCount)</td></tr>
                        <tr><td>Signers</td><td>$($PolicyInfo.SignerCount)</td></tr>
                    </table>
                </div>
            </div>"
        })
        
        <div class='section'>
            <h2>Audit Log Summary</h2>
            <div class='info-box'>
                <table>
                    <tr><th>Metric</th><th>Value</th></tr>
                    <tr><td>Total Events</td><td>$($AuditSummary.TotalEvents)</td></tr>
                    <tr><td>Blocking Events</td><td>$($AuditSummary.BlockingEvents)</td></tr>
                    <tr><td>Unique Blocked Applications</td><td>$($AuditSummary.UniqueBlockedApps)</td></tr>
                </table>
            </div>
        </div>
        
        $(if ($AuditSummary.TopBlockedApps.Count -gt 0) {
            "<div class='section'>
                <h2>Top Blocked Applications</h2>
                <div class='info-box'>
                    <table>
                        <tr><th>Application</th><th>Block Count</th></tr>
                        $($AuditSummary.TopBlockedApps | ForEach-Object {
                            "<tr><td>$($_.Name)</td><td>$($_.Count)</td></tr>"
                        })
                    </table>
                </div>
            </div>"
        } else {
            "<div class='section'>
                <h2>Blocked Applications</h2>
                <div class='info-box'>
                    <p class='success'>No applications were blocked during the analysis period.</p>
                </div>
            </div>"
        })
        
        <div class='section'>
            <h2>Test Recommendations</h2>
            <div class='info-box'>
                <ul>
                    <li>Review any blocked applications to determine if they should be allowed</li>
                    <li>Ensure all business-critical applications are functioning properly</li>
                    <li>Monitor for any performance impact from the policy</li>
                    <li>Document any necessary policy adjustments</li>
                    $(if ($AuditSummary.BlockingEvents -gt 0) {
                        "<li class='warning'>Consider refining the policy to explicitly allow legitimate applications that were blocked</li>"
                    } else {
                        "<li class='success'>Policy appears to be working correctly with no blocking events</li>"
                    })
                </ul>
            </div>
        </div>
    </div>
</body>
</html>
"@

# Save report
try {
    $HTMLReport | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Log "Test report saved to: $OutputPath" "SUCCESS"
    Write-Log "Report generation completed successfully" "SUCCESS"
}
catch {
    Write-Log "Failed to save report: $_" "ERROR"
    exit 1
}