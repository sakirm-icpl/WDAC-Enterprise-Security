# generate-compliance-report.ps1
# Generates compliance reports from WDAC audit logs
#
# Usage: .\generate-compliance-report.ps1 -LogPath "C:\Windows\System32\CodeIntegrity\AuditLogs" -OutputPath ".\compliance-report.html"

param(
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "C:\Windows\System32\CodeIntegrity\AuditLogs",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\wdac-compliance-report.html",
    
    [Parameter(Mandatory=$false)]
    [int]$DaysBack = 7,
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeEventDetails,
    
    [Parameter(Mandatory=$false)]
    [switch]$ExportToCsv
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

function Test-PowerShellVersionCompatibility {
    # Check PowerShell version
    $PSVersion = $PSVersionTable.PSVersion
    if ($PSVersion.Major -lt 5) {
        throw "PowerShell 5.0 or higher is required. Current version: $PSVersion"
    }
    
    # Check if required modules are available
    try {
        Import-Module ConfigCI -ErrorAction Stop
        return $true
    } catch {
        throw "ConfigCI module not available. This module is required for WDAC policy management."
    }
}

function Get-WDACAuditEvents {
    param(
        [string]$LogPath,
        [int]$DaysBack
    )
    
    try {
        Write-Log "Searching for WDAC audit events in $LogPath" "INFO"
        
        # Calculate the date threshold
        $thresholdDate = (Get-Date).AddDays(-$DaysBack)
        
        # Get all CSV log files
        $logFiles = Get-ChildItem -Path $LogPath -Filter "*.csv" -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.CreationTime -ge $thresholdDate }
        
        if (-not $logFiles) {
            Write-Log "No audit log files found in $LogPath" "WARN"
            return @()
        }
        
        Write-Log "Found $($logFiles.Count) log files to process" "SUCCESS"
        
        $allEvents = @()
        
        foreach ($logFile in $logFiles) {
            Write-Log "Processing log file: $($logFile.Name)" "INFO"
            
            # Import CSV data
            $events = Import-Csv -Path $logFile.FullName -ErrorAction SilentlyContinue
            
            # Filter for relevant events (typically event IDs 3076, 3077, 3099 for WDAC)
            $filteredEvents = $events | Where-Object { 
                $_."Event ID" -in @("3076", "3077", "3099") -or
                $_.EventId -in @("3076", "3077", "3099")
            }
            
            $allEvents += $filteredEvents
        }
        
        Write-Log "Processed $($allEvents.Count) WDAC audit events" "SUCCESS"
        return $allEvents
    } catch {
        Write-Log "Failed to process audit events: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Analyze-WDACEvents {
    param([array]$Events)
    
    try {
        Write-Log "Analyzing WDAC audit events" "INFO"
        
        # Initialize analysis results
        $analysis = @{
            TotalEvents = $Events.Count
            BlockedExecutables = 0
            BlockedScripts = 0
            BlockedByPath = 0
            BlockedByHash = 0
            BlockedByPublisher = 0
            UniqueExecutables = @{}
            TopBlockedPaths = @{}
            EventTimeline = @()
        }
        
        foreach ($event in $Events) {
            # Extract relevant fields (different formats may exist)
            $eventId = $event."Event ID" ?? $event.EventId
            $filePath = $event."File Path" ?? $event.FilePath ?? $event.Path
            $fileName = $event."File Name" ?? $event.FileName ?? if ($filePath) { Split-Path $filePath -Leaf } else { "Unknown" }
            $policyId = $event."Policy ID" ?? $event.PolicyId
            $timestamp = $event.Timestamp ?? $event."TimeCreated"
            
            # Count event types
            switch ($eventId) {
                "3076" { $analysis.BlockedExecutables++ }
                "3077" { $analysis.BlockedScripts++ }
                "3099" { $analysis.BlockedByPublisher++ }
            }
            
            # Track unique executables
            if ($fileName -and -not $analysis.UniqueExecutables.ContainsKey($fileName)) {
                $analysis.UniqueExecutables[$fileName] = 0
            }
            if ($fileName) {
                $analysis.UniqueExecutables[$fileName]++
            }
            
            # Track blocked paths
            if ($filePath) {
                $directory = Split-Path $filePath -Parent
                if (-not $analysis.TopBlockedPaths.ContainsKey($directory)) {
                    $analysis.TopBlockedPaths[$directory] = 0
                }
                $analysis.TopBlockedPaths[$directory]++
            }
            
            # Add to timeline
            if ($timestamp) {
                $analysis.EventTimeline += [PSCustomObject]@{
                    Timestamp = $timestamp
                    EventId = $eventId
                    FileName = $fileName
                    FilePath = $filePath
                }
            }
        }
        
        # Sort and limit top blocked paths
        $analysis.TopBlockedPaths = $analysis.TopBlockedPaths.GetEnumerator() | 
                                    Sort-Object Value -Descending | 
                                    Select-Object -First 10
        
        # Sort and limit unique executables
        $analysis.UniqueExecutables = $analysis.UniqueExecutables.GetEnumerator() | 
                                      Sort-Object Value -Descending | 
                                      Select-Object -First 20
        
        Write-Log "Analysis complete" "SUCCESS"
        return $analysis
    } catch {
        Write-Log "Failed to analyze events: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Generate-HtmlReport {
    param(
        [hashtable]$Analysis,
        [array]$Events,
        [string]$OutputPath,
        [bool]$IncludeEventDetails
    )
    
    try {
        Write-Log "Generating HTML compliance report" "INFO"
        
        $reportDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $daysAnalyzed = (Get-Date).AddDays(-$DaysBack).ToString("yyyy-MM-dd") + " to " + (Get-Date).ToString("yyyy-MM-dd")
        
        $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>WDAC Compliance Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .header { background-color: #2E74B5; color: white; padding: 20px; border-radius: 5px; }
        .container { background-color: white; padding: 20px; margin-top: 20px; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1, h2, h3 { color: #2E74B5; }
        table { border-collapse: collapse; width: 100%; margin-top: 10px; margin-bottom: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .summary-box { background-color: #e9ecef; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .metric { display: inline-block; margin-right: 20px; }
        .metric-value { font-size: 24px; font-weight: bold; color: #2E74B5; }
        .metric-label { font-size: 12px; color: #6c757d; }
        .chart-container { height: 300px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>WDAC Compliance Report</h1>
        <p>Generated on: $reportDate</p>
        <p>Analysis Period: $daysAnalyzed</p>
    </div>
    
    <div class="container">
        <h2>Executive Summary</h2>
        <div class="summary-box">
            <div class="metric">
                <div class="metric-value">$($Analysis.TotalEvents)</div>
                <div class="metric-label">TOTAL EVENTS</div>
            </div>
            <div class="metric">
                <div class="metric-value">$($Analysis.BlockedExecutables)</div>
                <div class="metric-label">BLOCKED EXECUTABLES</div>
            </div>
            <div class="metric">
                <div class="metric-value">$($Analysis.BlockedScripts)</div>
                <div class="metric-label">BLOCKED SCRIPTS</div>
            </div>
            <div class="metric">
                <div class="metric-value">$($Analysis.BlockedByPublisher)</div>
                <div class="metric-label">BLOCKED BY PUBLISHER</div>
            </div>
        </div>
"@
        
        # Top blocked executables
        $htmlContent += @"
        <h3>Top Blocked Executables</h3>
        <table>
            <tr>
                <th>Executable</th>
                <th>Block Count</th>
            </tr>
"@
        
        foreach ($item in $Analysis.UniqueExecutables) {
            $htmlContent += @"
            <tr>
                <td>$($item.Key)</td>
                <td>$($item.Value)</td>
            </tr>
"@
        }
        
        $htmlContent += @"
        </table>
"@
        
        # Top blocked paths
        $htmlContent += @"
        <h3>Top Blocked Paths</h3>
        <table>
            <tr>
                <th>Path</th>
                <th>Block Count</th>
            </tr>
"@
        
        foreach ($item in $Analysis.TopBlockedPaths) {
            $htmlContent += @"
            <tr>
                <td>$($item.Key)</td>
                <td>$($item.Value)</td>
            </tr>
"@
        }
        
        $htmlContent += @"
        </table>
"@
        
        # Event details if requested
        if ($IncludeEventDetails -and $Events.Count -gt 0) {
            $htmlContent += @"
        <h3>Detailed Events</h3>
        <table>
            <tr>
                <th>Timestamp</th>
                <th>Event ID</th>
                <th>File Name</th>
                <th>File Path</th>
            </tr>
"@
            
            # Limit to first 100 events to avoid huge reports
            $displayEvents = $Events | Select-Object -First 100
            
            foreach ($event in $displayEvents) {
                $eventId = $event."Event ID" ?? $event.EventId
                $filePath = $event."File Path" ?? $event.FilePath ?? $event.Path
                $fileName = $event."File Name" ?? $event.FileName ?? if ($filePath) { Split-Path $filePath -Leaf } else { "Unknown" }
                $timestamp = $event.Timestamp ?? $event."TimeCreated" ?? "Unknown"
                
                $htmlContent += @"
            <tr>
                <td>$timestamp</td>
                <td>$eventId</td>
                <td>$fileName</td>
                <td>$filePath</td>
            </tr>
"@
            }
            
            $htmlContent += @"
        </table>
"@
        }
        
        $htmlContent += @"
    </div>
</body>
</html>
"@
        
        $htmlContent | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Log "HTML report generated at: $OutputPath" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to generate HTML report: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Export-ToCsv {
    param(
        [array]$Events,
        [string]$OutputPath
    )
    
    try {
        $csvPath = [System.IO.Path]::ChangeExtension($OutputPath, ".csv")
        $Events | Export-Csv -Path $csvPath -NoTypeInformation
        Write-Log "CSV export saved to: $csvPath" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to export to CSV: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

Write-Log "Starting WDAC Compliance Reporter" "INFO"

# Check prerequisites
try {
    Write-Log "Checking PowerShell version compatibility..." "INFO"
    Test-PowerShellVersionCompatibility | Out-Null
    Write-Log "PowerShell version compatibility check passed" "SUCCESS"
} catch {
    Write-Log "PowerShell compatibility check failed: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Check if log path exists
if (-not (Test-Path $LogPath)) {
    Write-Log "Log path not found at $LogPath" "WARN"
    Write-Log "Note: This tool requires WDAC audit mode to be enabled to generate meaningful reports" "INFO"
}

# Get audit events
$events = Get-WDACAuditEvents -LogPath $LogPath -DaysBack $DaysBack

if ($events.Count -eq 0) {
    Write-Log "No WDAC audit events found for analysis" "WARN"
    Write-Log "Ensure WDAC is in audit mode and has been running for at least $DaysBack days" "INFO"
    exit 0
}

Write-Log "Found $($events.Count) WDAC audit events for analysis" "SUCCESS"

# Analyze events
$analysis = Analyze-WDACEvents -Events $events

if (-not $analysis) {
    Write-Log "Failed to analyze WDAC events" "ERROR"
    exit 1
}

# Generate HTML report
if (Generate-HtmlReport -Analysis $analysis -Events $events -OutputPath $OutputPath -IncludeEventDetails $IncludeEventDetails) {
    Write-Log "Compliance report generated successfully" "SUCCESS"
} else {
    Write-Log "Failed to generate compliance report" "ERROR"
    exit 1
}

# Export to CSV if requested
if ($ExportToCsv) {
    if (Export-ToCsv -Events $events -OutputPath $OutputPath) {
        Write-Log "CSV export completed successfully" "SUCCESS"
    } else {
        Write-Log "Failed to export to CSV" "ERROR"
    }
}

Write-Log "WDAC Compliance Reporter completed successfully" "INFO"
Write-Log "Report saved to: $OutputPath" "INFO"