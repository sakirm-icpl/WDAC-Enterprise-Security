# alerting-system.ps1
# Alerting mechanism for policy violations

param(
    [Parameter(Mandatory=$false)]
    [int]$CheckInterval = 60,
    
    [Parameter(Mandatory=$false)]
    [string]$AlertEmail = "",
    
    [Parameter(Mandatory=$false)]
    [string]$WebhookUrl = "",
    
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

function Get-PolicyViolations {
    param([int]$Minutes = 5)
    
    try {
        $StartTime = (Get-Date).AddMinutes(-$Minutes)
        
        # Get Code Integrity blocking events (Level 2 = Warning)
        $Events = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
            StartTime = $StartTime
            Level = 2
            Id = 3076, 3077, 3089
        } -ErrorAction SilentlyContinue
        
        if ($Events) {
            # Extract unique applications
            $BlockedApps = @()
            foreach ($Event in $Events) {
                $Message = $Event.Message
                if ($Message -match "File name: (.+?)\s") {
                    $FileName = $matches[1]
                } else {
                    $FileName = "Unknown"
                }
                
                $BlockedApp = [PSCustomObject]@{
                    TimeCreated = $Event.TimeCreated
                    FileName = $FileName
                    EventId = $Event.Id
                    Message = $Message
                }
                
                $BlockedApps += $BlockedApp
            }
            
            # Group by filename to get unique blocked applications
            $UniqueBlockedApps = $BlockedApps | Group-Object FileName
            
            return [PSCustomObject]@{
                TotalViolations = $Events.Count
                UniqueApplications = $UniqueBlockedApps.Count
                BlockedApplications = $UniqueBlockedApps
                RecentEvents = $Events | Select-Object -First 10
            }
        } else {
            return [PSCustomObject]@{
                TotalViolations = 0
                UniqueApplications = 0
                BlockedApplications = @()
                RecentEvents = @()
            }
        }
    } catch {
        Write-Log "Failed to check policy violations: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Send-EmailAlert {
    param(
        [string]$To,
        [string]$Subject,
        [string]$Body
    )
    
    # This is a simplified implementation
    # In a real environment, you would use Send-MailMessage or a mail relay
    Write-Log "EMAIL ALERT: To=$To, Subject=$Subject" "INFO"
    Write-Log "EMAIL BODY: $Body" "INFO"
    
    # Example implementation:
    # Send-MailMessage -To $To -Subject $Subject -Body $Body -SmtpServer "smtp.company.com"
}

function Send-WebhookAlert {
    param(
        [string]$Url,
        [string]$Message
    )
    
    try {
        $Payload = @{
            text = $Message
        } | ConvertTo-Json
        
        # Example for Slack webhook
        # Invoke-RestMethod -Uri $Url -Method POST -Body $Payload -ContentType "application/json"
        
        Write-Log "WEBHOOK ALERT: Url=$Url" "INFO"
        Write-Log "WEBHOOK PAYLOAD: $Payload" "INFO"
    } catch {
        Write-Log "Failed to send webhook alert: $($_.Exception.Message)" "ERROR"
    }
}

function Generate-AlertMessage {
    param([object]$Violations)
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $Message = @"
WDAC POLICY VIOLATION ALERT
===========================

Time: $Timestamp
Total Violations: $($Violations.TotalViolations)
Unique Blocked Applications: $($Violations.UniqueApplications)

Recent Blocked Applications:
"@
    
    foreach ($App in $Violations.BlockedApplications | Select-Object -First 5) {
        $Message += "- $($App.Name) (blocked $($App.Count) times)`n"
    }
    
    $Message += @"
    
Please investigate these policy violations and take appropriate action.
"@
    
    return $Message
}

function Check-AndAlert {
    Write-Log "Checking for policy violations..." "INFO"
    
    $Violations = Get-PolicyViolations -Minutes 5
    
    if ($Violations -and $Violations.TotalViolations -gt 0) {
        Write-Log "Detected $($Violations.TotalViolations) policy violations" "WARN"
        
        # Generate alert message
        $AlertMessage = Generate-AlertMessage -Violations $Violations
        
        # Send email alert if configured
        if ($AlertEmail) {
            Send-EmailAlert -To $AlertEmail -Subject "WDAC Policy Violation Alert" -Body $AlertMessage
        }
        
        # Send webhook alert if configured
        if ($WebhookUrl) {
            Send-WebhookAlert -Url $WebhookUrl -Message $AlertMessage
        }
        
        # Log to console
        Write-Host $AlertMessage -ForegroundColor Red
    } else {
        Write-Log "No policy violations detected" "SUCCESS"
    }
}

Write-Log "Starting WDAC Alerting System" "INFO"

if ($AlertEmail) {
    Write-Log "Email alerts configured for: $AlertEmail" "INFO"
}

if ($WebhookUrl) {
    Write-Log "Webhook alerts configured for: $WebhookUrl" "INFO"
}

if ($Continuous) {
    Write-Log "Continuous monitoring enabled with $CheckInterval second check interval" "INFO"
    
    while ($true) {
        Check-AndAlert
        Write-Log "Waiting $CheckInterval seconds before next check..." "INFO"
        Start-Sleep -Seconds $CheckInterval
    }
} else {
    Check-AndAlert
    Write-Log "Alert check completed. Exiting." "INFO"
}