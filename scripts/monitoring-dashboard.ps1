# monitoring-dashboard.ps1
# Real-time dashboard with policy compliance metrics

param(
    [Parameter(Mandatory=$false)]
    [int]$RefreshInterval = 30,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "..\reports\dashboard.html",
    
    [Parameter(Mandatory=$false)]
    [switch]$Continuous
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

function Get-WDACStatus {
    try {
        $WDACStatus = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard -ErrorAction Stop
        return [PSCustomObject]@{
            CodeIntegrityPolicyEnforcement = $WDACStatus.CodeIntegrityPolicyEnforcementStatus
            UserModeCodeIntegrity = $WDACStatus.UserModeCodeIntegrityPolicyEnforcementStatus
            VirtualizationBasedSecurity = $WDACStatus.VirtualizationBasedSecurityStatus
            AvailableSecurityProperties = $WDACStatus.AvailableSecurityProperties
            RequiredSecurityProperties = $WDACStatus.RequiredSecurityProperties
        }
    } catch {
        Write-Log "Failed to retrieve WDAC status: $($_.Exception.Message)" "WARN"
        return $null
    }
}

function Get-RecentAuditEvents {
    param([int]$Hours = 1)
    
    try {
        $StartTime = (Get-Date).AddHours(-$Hours)
        
        # Get Code Integrity events
        $Events = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
            StartTime = $StartTime
        } -ErrorAction SilentlyContinue
        
        # Filter blocking events
        $BlockingEvents = $Events | Where-Object { $_.Level -eq 2 }
        
        return [PSCustomObject]@{
            TotalEvents = $Events.Count
            BlockingEvents = $BlockingEvents.Count
            RecentEvents = $Events | Select-Object -First 10
        }
    } catch {
        Write-Log "Failed to retrieve audit events: $($_.Exception.Message)" "WARN"
        return $null
    }
}

function Get-SystemInformation {
    try {
        $ComputerInfo = Get-ComputerInfo -ErrorAction Stop
        $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $BIOSInfo = Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop
        
        return [PSCustomObject]@{
            ComputerName = $ComputerInfo.CsName
            OperatingSystem = "$($OSInfo.Caption) $($OSInfo.Version)"
            SystemManufacturer = $ComputerInfo.CsManufacturer
            SystemModel = $ComputerInfo.CsModel
            BIOSVersion = $BIOSInfo.SMBIOSBIOSVersion
            LastBootUpTime = $OSInfo.LastBootUpTime
        }
    } catch {
        Write-Log "Failed to retrieve system information: $($_.Exception.Message)" "WARN"
        return $null
    }
}

function Generate-DashboardHtml {
    param(
        [object]$SystemInfo,
        [object]$WDACStatus,
        [object]$AuditEvents
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $HTML = @"
<!DOCTYPE html>
<html>
<head>
    <title>WDAC Monitoring Dashboard</title>
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
        .refresh-info { text-align: right; color: #666; font-size: 0.9em; }
        .status-indicator { display: inline-block; width: 12px; height: 12px; border-radius: 50%; margin-right: 8px; }
        .status-ok { background-color: green; }
        .status-warning { background-color: orange; }
        .status-error { background-color: red; }
    </style>
    <meta http-equiv="refresh" content="30">
</head>
<body>
    <div class="container">
        <h1>WDAC Monitoring Dashboard</h1>
        <div class="refresh-info">Last updated: $Timestamp | Auto-refresh every 30 seconds</div>
        
        <div class="section">
            <h2>System Information</h2>
            <div class="info-box">
"@
    
    if ($SystemInfo) {
        $HTML += @"
                <table>
                    <tr><th>Property</th><th>Value</th></tr>
                    <tr><td>Computer Name</td><td>$($SystemInfo.ComputerName)</td></tr>
                    <tr><td>Operating System</td><td>$($SystemInfo.OperatingSystem)</td></tr>
                    <tr><td>System Manufacturer</td><td>$($SystemInfo.SystemManufacturer)</td></tr>
                    <tr><td>System Model</td><td>$($SystemInfo.SystemModel)</td></tr>
                    <tr><td>BIOS Version</td><td>$($SystemInfo.BIOSVersion)</td></tr>
                    <tr><td>Last Boot Time</td><td>$($SystemInfo.LastBootUpTime)</td></tr>
                </table>
"@
    } else {
        $HTML += "<p class='error'>Failed to retrieve system information</p>"
    }
    
    $HTML += @"
            </div>
        </div>
        
        <div class="section">
            <h2>WDAC Status</h2>
            <div class="info-box">
"@
    
    if ($WDACStatus) {
        # Determine status indicators
        $CIPIndicator = if ($WDACStatus.CodeIntegrityPolicyEnforcement -eq 1) { "status-ok" } else { "status-warning" }
        $UMCIIndicator = if ($WDACStatus.UserModeCodeIntegrity -eq 1) { "status-ok" } else { "status-warning" }
        $VBSIndicator = if ($WDACStatus.VirtualizationBasedSecurity -eq 1) { "status-ok" } else { "status-warning" }
        
        $HTML += @"
                <table>
                    <tr><th>Property</th><th>Value</th><th>Status</th></tr>
                    <tr><td>Code Integrity Policy Enforcement</td><td>$($WDACStatus.CodeIntegrityPolicyEnforcement)</td><td><span class="status-indicator $CIPIndicator"></span></td></tr>
                    <tr><td>User Mode Code Integrity</td><td>$($WDACStatus.UserModeCodeIntegrity)</td><td><span class="status-indicator $UMCIIndicator"></span></td></tr>
                    <tr><td>Virtualization Based Security</td><td>$($WDACStatus.VirtualizationBasedSecurity)</td><td><span class="status-indicator $VBSIndicator"></span></td></tr>
                </table>
"@
    } else {
        $HTML += "<p class='error'>Failed to retrieve WDAC status</p>"
    }
    
    $HTML += @"
            </div>
        </div>
        
        <div class="section">
            <h2>Audit Events (Last Hour)</h2>
            <div class="info-box">
"@
    
    if ($AuditEvents) {
        $HTML += @"
                <table>
                    <tr><th>Metric</th><th>Value</th></tr>
                    <tr><td>Total Events</td><td>$($AuditEvents.TotalEvents)</td></tr>
                    <tr><td>Blocking Events</td><td>$($AuditEvents.BlockingEvents)</td></tr>
                </table>
                
                <h3>Recent Events</h3>
                <table>
                    <tr><th>Time</th><th>Event ID</th><th>Level</th><th>Description</th></tr>
"@
        
        foreach ($Event in $AuditEvents.RecentEvents) {
            $LevelText = switch ($Event.Level) {
                1 { "Critical" }
                2 { "Error" }
                3 { "Warning" }
                4 { "Information" }
                default { "Unknown" }
            }
            
            $HTML += "<tr><td>$($Event.TimeCreated)</td><td>$($Event.Id)</td><td>$LevelText</td><td>$($Event.Message.Substring(0, [Math]::Min(100, $Event.Message.Length)))...</td></tr>"
        }
        
        $HTML += "</table>"
    } else {
        $HTML += "<p class='error'>Failed to retrieve audit events</p>"
    }
    
    $HTML += @"
            </div>
        </div>
        
        <div class="section">
            <h2>Alerts</h2>
            <div class="info-box">
"@
    
    # Generate alerts based on the data
    $Alerts = @()
    
    if ($AuditEvents -and $AuditEvents.BlockingEvents -gt 10) {
        $Alerts += "<p class='warning'>⚠ High number of blocking events detected ($($AuditEvents.BlockingEvents) in the last hour)</p>"
    }
    
    if ($WDACStatus -and $WDACStatus.CodeIntegrityPolicyEnforcement -ne 1) {
        $Alerts += "<p class='error'>❌ Code Integrity Policy Enforcement is not active</p>"
    }
    
    if ($WDACStatus -and $WDACStatus.UserModeCodeIntegrity -ne 1) {
        $Alerts += "<p class='error'>❌ User Mode Code Integrity is not active</p>"
    }
    
    if ($WDACStatus -and $WDACStatus.VirtualizationBasedSecurity -ne 1) {
        $Alerts += "<p class='error'>❌ Virtualization Based Security is not active</p>"
    }
    
    if ($Alerts.Count -eq 0) {
        $HTML += "<p class='success'>✅ No alerts at this time</p>"
    } else {
        foreach ($Alert in $Alerts) {
            $HTML += $Alert
        }
    }
    
    $HTML += @"
            </div>
        </div>
    </div>
</body>
</html>
"@
    
    return $HTML
}

function Update-Dashboard {
    Write-Log "Updating monitoring dashboard..." "INFO"
    
    # Collect data
    $SystemInfo = Get-SystemInformation
    $WDACStatus = Get-WDACStatus
    $AuditEvents = Get-RecentAuditEvents
    
    # Generate dashboard HTML
    $DashboardHtml = Generate-DashboardHtml -SystemInfo $SystemInfo -WDACStatus $WDACStatus -AuditEvents $AuditEvents
    
    # Save dashboard
    try {
        $DashboardHtml | Out-File -FilePath $OutputPath -Encoding UTF8 -ErrorAction Stop
        Write-Log "Dashboard updated successfully: $OutputPath" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to update dashboard: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

Write-Log "Starting WDAC Monitoring Dashboard" "INFO"
Write-Log "Dashboard will be saved to: $OutputPath" "INFO"

if ($Continuous) {
    Write-Log "Continuous monitoring enabled with $RefreshInterval second refresh interval" "INFO"
    
    while ($true) {
        Update-Dashboard
        Write-Log "Waiting $RefreshInterval seconds before next update..." "INFO"
        Start-Sleep -Seconds $RefreshInterval
    }
} else {
    Update-Dashboard
    Write-Log "Dashboard update completed. Exiting." "INFO"
}