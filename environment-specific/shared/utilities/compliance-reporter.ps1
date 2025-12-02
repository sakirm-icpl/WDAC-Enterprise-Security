# Compliance-Reporter.ps1
# Generates compliance reports for WDAC policy implementations

function Get-WDACComplianceReport {
    <#
    .SYNOPSIS
    Generates a comprehensive compliance report for WDAC policy implementation
    
    .PARAMETER ReportPath
    Path where the compliance report should be saved
    
    .PARAMETER Hours
    Number of hours of event logs to analyze (default: 24)
    
    .EXAMPLE
    Get-WDACComplianceReport -ReportPath "C:\Reports\WDAC_Compliance_Report.html"
    #>
    
    param(
        [Parameter(Mandatory=$false)]
        [string]$ReportPath = "$env:TEMP\WDAC_Compliance_Report.html",
        
        [Parameter(Mandatory=$false)]
        [int]$Hours = 24
    )
    
    try {
        # Get system information
        $ComputerInfo = Get-ComputerInfo
        $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem
        $BIOSInfo = Get-CimInstance -ClassName Win32_BIOS
        
        # Get WDAC status
        $WDACStatus = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
        
        # Get recent WDAC events
        $StartTime = (Get-Date).AddHours(-$Hours)
        $WDADEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
            StartTime = $StartTime
        } -ErrorAction SilentlyContinue
        
        # Categorize events
        $AuditEvents = $WDADEvents | Where-Object { $_.Id -eq 3076 }
        $BlockEvents = $WDADEvents | Where-Object { $_.Id -eq 3077 -or $_.Id -eq 3089 }
        $OtherEvents = $WDADEvents | Where-Object { $_.Id -ne 3076 -and $_.Id -ne 3077 -and $_.Id -ne 3089 }
        
        # Generate HTML report
        $HTMLReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>WDAC Compliance Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1, h2 { color: #2E74B5; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .success { color: green; }
        .warning { color: orange; }
        .error { color: red; }
        .summary-box { border: 1px solid #ccc; padding: 15px; margin-bottom: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>WDAC Compliance Report</h1>
    <p>Generated on: $(Get-Date)</p>
    
    <div class="summary-box">
        <h2>System Information</h2>
        <table>
            <tr><th>Property</th><th>Value</th></tr>
            <tr><td>Computer Name</td><td>$($ComputerInfo.CsName)</td></tr>
            <tr><td>Operating System</td><td>$($OSInfo.Caption) $($OSInfo.Version)</td></tr>
            <tr><td>System Manufacturer</td><td>$($ComputerInfo.CsManufacturer)</td></tr>
            <tr><td>System Model</td><td>$($ComputerInfo.CsModel)</td></tr>
        </table>
    </div>
    
    <div class="summary-box">
        <h2>WDAC Status</h2>
        <table>
            <tr><th>Property</th><th>Value</th></tr>
            <tr><td>Code Integrity Policy Enforcement</td><td>$($WDACStatus.CodeIntegrityPolicyEnforcementStatus)</td></tr>
            <tr><td>User Mode Code Integrity</td><td>$($WDACStatus.UserModeCodeIntegrityPolicyEnforcementStatus)</td></tr>
            <tr><td>Virtualization Based Security</td><td>$($WDACStatus.VirtualizationBasedSecurityStatus)</td></tr>
        </table>
    </div>
    
    <div class="summary-box">
        <h2>Event Summary (Last $Hours Hours)</h2>
        <table>
            <tr><th>Event Type</th><th>Count</th><th>Status</th></tr>
            <tr><td>Audit Events</td><td>$($AuditEvents.Count)</td><td class="warning">Informational</td></tr>
            <tr><td>Block Events</td><td>$($BlockEvents.Count)</td><td class="$(if($BlockEvents.Count -eq 0){'success'}else{'error'})">$($BlockEvents.Count -eq 0 ? "Compliant" : "Non-Compliant")</td></tr>
            <tr><td>Other Events</td><td>$($OtherEvents.Count)</td><td class="warning">Informational</td></tr>
        </table>
    </div>
    
    <h2>Detailed Block Events</h2>
    $(if($BlockEvents.Count -gt 0) {
        "<table>
            <tr><th>Time</th><th>Event ID</th><th>Description</th></tr>" +
        ($BlockEvents | ForEach-Object {
            "<tr><td>$($_.TimeCreated)</td><td>$($_.Id)</td><td>$($_.Message)</td></tr>"
        }) -join "" +
        "</table>"
    } else {
        "<p class='success'>No block events detected. System is compliant.</p>"
    })
</body>
</html>
"@
        
        # Save report
        $HTMLReport | Out-File -FilePath $ReportPath -Encoding UTF8
        Write-Host "Compliance report saved to: $ReportPath" -ForegroundColor Green
        return $ReportPath
    }
    catch {
        Write-Error "Failed to generate compliance report: $($_.Exception.Message)"
        return $null
    }
}

function Send-ComplianceEmail {
    <#
    .SYNOPSIS
    Sends a compliance report via email
    
    .PARAMETER ReportPath
    Path to the compliance report file
    
    .PARAMETER To
    Email recipient
    
    .PARAMETER From
    Email sender
    
    .PARAMETER SMTPServer
    SMTP server address
    
    .EXAMPLE
    Send-ComplianceEmail -ReportPath "C:\Reports\WDAC_Compliance_Report.html" -To "admin@company.com" -From "noreply@company.com" -SMTPServer "smtp.company.com"
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$ReportPath,
        
        [Parameter(Mandatory=$true)]
        [string]$To,
        
        [Parameter(Mandatory=$true)]
        [string]$From,
        
        [Parameter(Mandatory=$true)]
        [string]$SMTPServer
    )
    
    try {
        Send-MailMessage -To $To -From $From -Subject "WDAC Compliance Report" -Body "Please find attached the WDAC compliance report." -Attachments $ReportPath -SmtpServer $SMTPServer
        Write-Host "Compliance report sent to: $To" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to send compliance report: $($_.Exception.Message)"
        return $false
    }
}

# Export functions
Export-ModuleMember -Function *