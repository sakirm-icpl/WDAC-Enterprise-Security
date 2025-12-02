# Monitor-NonADSystems.ps1
# Monitors WDAC policy status on non-Active Directory systems

param(
    [Parameter(Mandatory=$false)]
    [int]$Hours = 24,
    
    [Parameter(Mandatory=$false)]
    [string]$ReportPath = "$env:TEMP\WDAC_Monitoring_Report.csv",
    
    [Parameter(Mandatory=$false)]
    [switch]$AlertOnViolations,
    
    [Parameter(Mandatory=$false)]
    [string]$AlertEmail = "admin@company.com"
)

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] $Message"
    Write-Host $LogEntry
}

function Get-WDACStatus {
    try {
        # Check if WDAC is enabled
        $CIState = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
        $WdacStatus = @{
            "BootStatus" = $CIState.CodeIntegrityPolicyEnforcementStatus
            "UserModeStatus" = $CIState.UserModeCodeIntegrityPolicyEnforcementStatus
            "VirtualizationBasedSecurity" = $CIState.VirtualizationBasedSecurityStatus
            "AvailableSecurityProperties" = $CIState.AvailableSecurityProperties
            "RequiredSecurityProperties" = $CIState.RequiredSecurityProperties
            "SecurityServicesConfigured" = $CIState.SecurityServicesConfigured
            "SecurityServicesRunning" = $CIState.SecurityServicesRunning
        }
        return $WdacStatus
    }
    catch {
        Write-Log "Error retrieving WDAC status: $($_.Exception.Message)"
        return $null
    }
}

function Get-WDACEvents {
    param([int]$Hours)
    
    try {
        $StartTime = (Get-Date).AddHours(-$Hours)
        $Events = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
            StartTime = $StartTime
            ID = 3076, 3077, 3089
        } -ErrorAction SilentlyContinue
        
        return $Events
    }
    catch {
        Write-Log "Error retrieving WDAC events: $($_.Exception.Message)"
        return @()
    }
}

function Send-Alert {
    param(
        [string]$Subject,
        [string]$Body
    )
    
    try {
        # Simple email sending (requires configured SMTP)
        # In a real environment, you would integrate with your email system
        Write-Log "ALERT: $Subject"
        Write-Log "Details: $Body"
        Write-Log "Would send alert to: $AlertEmail"
    }
    catch {
        Write-Log "Failed to send alert: $($_.Exception.Message)"
    }
}

# Main script execution
Write-Log "Starting WDAC monitoring for non-AD systems"

# Get current WDAC status
$WdacStatus = Get-WDACStatus
if ($null -eq $WdacStatus) {
    Write-Log "Failed to retrieve WDAC status"
    exit 1
}

Write-Log "WDAC Status:"
Write-Log "  Boot Status: $($WdacStatus.BootStatus)"
Write-Log "  User Mode Status: $($WdacStatus.UserModeStatus)"
Write-Log "  VBS Status: $($WdacStatus.VirtualizationBasedSecurity)"

# Get recent WDAC events
$Events = Get-WDACEvents -Hours $Hours
Write-Log "Found $($Events.Count) WDAC events in the last $Hours hours"

# Process events for violations
$ViolationEvents = $Events | Where-Object { $_.Id -eq 3077 -or $_.Id -eq 3089 }
if ($ViolationEvents.Count -gt 0) {
    Write-Log "Found $($ViolationEvents.Count) policy violation events"
    
    if ($AlertOnViolations) {
        $AlertSubject = "WDAC Policy Violation Alert - $(Get-Date -Format 'yyyy-MM-dd')"
        $AlertBody = "Detected $($ViolationEvents.Count) WDAC policy violations in the last $Hours hours.`n`nReview the CodeIntegrity operational log for details."
        Send-Alert -Subject $AlertSubject -Body $AlertBody
    }
}

# Generate report
$ReportData = @()
foreach ($Event in $Events) {
    $ReportData += [PSCustomObject]@{
        TimeCreated = $Event.TimeCreated
        EventID = $Event.Id
        Level = $Event.LevelDisplayName
        Message = $Event.Message
    }
}

# Export to CSV
try {
    $ReportData | Export-Csv -Path $ReportPath -NoTypeInformation
    Write-Log "Report exported to: $ReportPath"
} catch {
    Write-Log "Failed to export report: $($_.Exception.Message)"
}

Write-Log "WDAC monitoring completed"