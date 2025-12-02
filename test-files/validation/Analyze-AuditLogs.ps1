# Analyze-AuditLogs.ps1
# Analyzes WDAC audit logs to identify blocked applications and policy effectiveness

param(
    [Parameter(Mandatory=$false)]
    [int]$Hours = 24,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$ExportCSV
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

function Export-ToCSV {
    param(
        [array]$Data,
        [string]$Path
    )
    
    if ($Data.Count -gt 0) {
        $Data | Export-Csv -Path $Path -NoTypeInformation
        Write-Log "Data exported to CSV: $Path" "SUCCESS"
    }
}

Write-Log "Starting WDAC Audit Log Analysis" "INFO"
Write-Log "Analysis period: Last $Hours hours" "INFO"

$StartTime = (Get-Date).AddHours(-$Hours)

try {
    # Get Code Integrity events
    Write-Log "Retrieving Code Integrity events..." "INFO"
    
    $BlockingEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
        StartTime = $StartTime
        Level = 2  # Warning level for blocked applications
        Id = 3076, 3077, 3089  # Common blocking event IDs
    } -ErrorAction SilentlyContinue
    
    $AllEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
        StartTime = $StartTime
    } -ErrorAction SilentlyContinue
    
    Write-Log "Found $($BlockingEvents.Count) blocking events" "INFO"
    Write-Log "Found $($AllEvents.Count) total Code Integrity events" "INFO"
    
    # Analyze blocking events
    if ($BlockingEvents.Count -gt 0) {
        Write-Log "Analyzing blocking events..." "INFO"
        
        $BlockedApplications = @()
        foreach ($Event in $BlockingEvents) {
            $Message = $Event.Message
            # Extract file path from message (this is a simplified approach)
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
        
        Write-Log "Top 10 blocked applications:" "INFO"
        $GroupedApplications | Select-Object -First 10 | ForEach-Object {
            Write-Log "  $($_.Name) - Blocked $($_.Count) times" "INFO"
        }
        
        # Export to CSV if requested
        if ($ExportCSV) {
            $CSVPath = if ($OutputPath) { $OutputPath } else { "$env:TEMP\WDAC_Blocked_Applications.csv" }
            Export-ToCSV -Data $BlockedApplications -Path $CSVPath
        }
    } else {
        Write-Log "No blocking events found in the specified time period" "SUCCESS"
    }
    
    # Check for policy load events
    $PolicyEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
        StartTime = $StartTime
        Id = 3099  # Policy loaded event
    } -ErrorAction SilentlyContinue
    
    Write-Log "Policy load events: $($PolicyEvents.Count)" "INFO"
    
    # Summary statistics
    $Summary = [PSCustomObject]@{
        AnalysisPeriodHours = $Hours
        TotalEvents = $AllEvents.Count
        BlockingEvents = $BlockingEvents.Count
        PolicyLoadEvents = $PolicyEvents.Count
        UniqueBlockedApps = $GroupedApplications.Count
        AnalysisTime = Get-Date
    }
    
    Write-Log "=== ANALYSIS SUMMARY ===" "SUCCESS"
    Write-Log "Total Events: $($Summary.TotalEvents)" "INFO"
    Write-Log "Blocking Events: $($Summary.BlockingEvents)" "INFO"
    Write-Log "Policy Loads: $($Summary.PolicyLoadEvents)" "INFO"
    Write-Log "Unique Blocked Applications: $($Summary.UniqueBlockedApps)" "INFO"
    
    # Export summary if requested
    if ($OutputPath -and -not $ExportCSV) {
        $Summary | Export-Clixml -Path $OutputPath
        Write-Log "Summary exported to: $OutputPath" "SUCCESS"
    }
    
    Write-Log "WDAC Audit Log Analysis Completed" "SUCCESS"
    
} catch {
    Write-Log "Analysis failed: $_" "ERROR"
    exit 1
}