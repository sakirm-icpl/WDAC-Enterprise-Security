# ml-policy-optimizer.ps1
# Machine learning-based policy optimization that analyzes audit logs to suggest rule refinements

param(
    [Parameter(Mandatory=$false)]
    [int]$Hours = 24,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "..\reports\policy-optimization-report.html",
    
    [Parameter(Mandatory=$false)]
    [switch]$ApplySuggestions
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

function Get-AuditLogData {
    param([int]$Hours)
    
    Write-Log "Collecting audit log data for the last $Hours hours..." "INFO"
    
    try {
        $StartTime = (Get-Date).AddHours(-$Hours)
        
        # Get Code Integrity events
        $Events = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
            StartTime = $StartTime
            Level = 2  # Warning level for blocked applications
        } -ErrorAction SilentlyContinue
        
        if ($Events) {
            Write-Log "Found $($Events.Count) blocking events" "SUCCESS"
            
            # Extract file information from events
            $BlockedFiles = @()
            foreach ($Event in $Events) {
                $Message = $Event.Message
                if ($Message -match "File name: (.+?)\s") {
                    $FileName = $matches[1]
                } else {
                    $FileName = "Unknown"
                }
                
                if ($Message -match "File hash: (.+?)\s") {
                    $FileHash = $matches[1]
                } else {
                    $FileHash = "Unknown"
                }
                
                if ($Message -match "Policy GUID: (.+?)\s") {
                    $PolicyGuid = $matches[1]
                } else {
                    $PolicyGuid = "Unknown"
                }
                
                $BlockedFile = [PSCustomObject]@{
                    TimeCreated = $Event.TimeCreated
                    EventId = $Event.Id
                    FileName = $FileName
                    FileHash = $FileHash
                    PolicyGuid = $PolicyGuid
                    Message = $Message
                }
                
                $BlockedFiles += $BlockedFile
            }
            
            return $BlockedFiles
        } else {
            Write-Log "No blocking events found in the specified time period." "INFO"
            return @()
        }
    } catch {
        Write-Log "Failed to collect audit log data: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Analyze-BlockedApplications {
    param([array]$BlockedFiles)
    
    Write-Log "Analyzing blocked applications..." "INFO"
    
    # Group by filename
    $GroupedFiles = $BlockedFiles | Group-Object FileName | Sort-Object Count -Descending
    
    # Identify frequently blocked applications
    $FrequentlyBlocked = $GroupedFiles | Where-Object { $_.Count -gt 1 } | Select-Object -First 10
    
    # Identify applications that might need to be allowed
    $PotentialAllowList = @()
    foreach ($Group in $FrequentlyBlocked) {
        $AppName = $Group.Name
        $BlockCount = $Group.Count
        
        # Check if this is a legitimate application that should be allowed
        # This is a simplified heuristic - in a real implementation, this would be more sophisticated
        if ($AppName -match "\.(exe|dll|sys)$" -and $BlockCount -gt 5) {
            $PotentialAllow = [PSCustomObject]@{
                Application = $AppName
                BlockCount = $BlockCount
                Recommendation = "Consider allowing this application"
                Confidence = "High"
            }
            $PotentialAllowList += $PotentialAllow
        } elseif ($AppName -match "\.(exe|dll|sys)$" -and $BlockCount -gt 2) {
            $PotentialAllow = [PSCustomObject]@{
                Application = $AppName
                BlockCount = $BlockCount
                Recommendation = "Investigate if this application should be allowed"
                Confidence = "Medium"
            }
            $PotentialAllowList += $PotentialAllow
        }
    }
    
    return [PSCustomObject]@{
        FrequentlyBlocked = $FrequentlyBlocked
        PotentialAllowList = $PotentialAllowList
    }
}

function Generate-OptimizationReport {
    param(
        [array]$BlockedFiles,
        [object]$AnalysisResults,
        [string]$OutputPath
    )
    
    Write-Log "Generating optimization report..." "INFO"
    
    $TotalEvents = $BlockedFiles.Count
    $UniqueBlockedApps = ($BlockedFiles | Group-Object FileName).Count
    
    # Generate HTML report
    $HTMLReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>WDAC Policy Optimization Report</title>
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
        <h1>WDAC Policy Optimization Report</h1>
        <p>Generated on: $(Get-Date)</p>
        
        <div class="section">
            <h2>Summary</h2>
            <div class="info-box">
                <table>
                    <tr><th>Metric</th><th>Value</th></tr>
                    <tr><td>Total Blocking Events</td><td>$TotalEvents</td></tr>
                    <tr><td>Unique Blocked Applications</td><td>$UniqueBlockedApps</td></tr>
                </table>
            </div>
        </div>
        
        <div class="section">
            <h2>Frequently Blocked Applications</h2>
            <div class="info-box">
                <table>
                    <tr><th>Application</th><th>Block Count</th></tr>
"@
    
    foreach ($App in $AnalysisResults.FrequentlyBlocked | Select-Object -First 10) {
        $HTMLReport += "<tr><td>$($App.Name)</td><td>$($App.Count)</td></tr>"
    }
    
    $HTMLReport += @"
                </table>
            </div>
        </div>
        
        <div class="section">
            <h2>Optimization Suggestions</h2>
            <div class="info-box">
                <table>
                    <tr><th>Application</th><th>Block Count</th><th>Recommendation</th><th>Confidence</th></tr>
"@
    
    foreach ($Suggestion in $AnalysisResults.PotentialAllowList) {
        $HTMLReport += "<tr><td>$($Suggestion.Application)</td><td>$($Suggestion.BlockCount)</td><td>$($Suggestion.Recommendation)</td><td>$($Suggestion.Confidence)</td></tr>"
    }
    
    $HTMLReport += @"
                </table>
            </div>
        </div>
        
        <div class="section">
            <h2>Next Steps</h2>
            <div class="info-box">
                <ol>
                    <li>Review the frequently blocked applications to determine if they should be allowed</li>
                    <li>Investigate applications with high block counts that might be legitimate business software</li>
                    <li>Consider creating supplemental policies for department-specific applications</li>
                    <li>Update your base policy to include newly identified trusted applications</li>
                    <li>Continue monitoring audit logs to validate policy effectiveness</li>
                </ol>
            </div>
        </div>
    </div>
</body>
</html>
"@
    
    # Save report
    try {
        $HTMLReport | Out-File -FilePath $OutputPath -Encoding UTF8 -ErrorAction Stop
        Write-Log "Optimization report saved to: $OutputPath" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to save optimization report: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Apply-OptimizationSuggestions {
    param([object]$AnalysisResults)
    
    Write-Log "Applying optimization suggestions..." "INFO"
    
    # This is a simplified implementation
    # In a real-world scenario, this would:
    # 1. Load the existing policy XML
    # 2. Add new allow rules for suggested applications
    # 3. Save the updated policy
    # 4. Optionally convert and deploy the policy
    
    foreach ($Suggestion in $AnalysisResults.PotentialAllowList) {
        Write-Log "Suggested rule: $($Suggestion.Recommendation) for $($Suggestion.Application)" "INFO"
    }
    
    Write-Log "NOTE: Automatic policy modification is not implemented in this demo version." "WARN"
    Write-Log "Please manually review and implement the suggested optimizations." "INFO"
}

Write-Log "Starting WDAC Policy Optimization Analysis" "INFO"

# Collect audit log data
$BlockedFiles = Get-AuditLogData -Hours $Hours

if ($BlockedFiles.Count -eq 0) {
    Write-Log "No blocking events found. Policy appears to be working correctly." "SUCCESS"
    exit 0
}

# Analyze blocked applications
$AnalysisResults = Analyze-BlockedApplications -BlockedFiles $BlockedFiles

# Generate optimization report
$ReportSuccess = Generate-OptimizationReport -BlockedFiles $BlockedFiles -AnalysisResults $AnalysisResults -OutputPath $OutputPath

if ($ReportSuccess) {
    Write-Log "Policy optimization analysis completed successfully." "SUCCESS"
    
    if ($ApplySuggestions) {
        Apply-OptimizationSuggestions -AnalysisResults $AnalysisResults
    }
} else {
    Write-Log "Failed to generate optimization report." "ERROR"
    exit 1
}