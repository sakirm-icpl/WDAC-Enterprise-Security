# Analyze-AuditLogs.ps1
param(
    [Parameter(Mandatory=$false)]
    [int]$Hours = 24
)

$StartTime = (Get-Date).AddHours(-$Hours)

Write-Host "Analyzing WDAC audit logs for the last $Hours hours..." -ForegroundColor Cyan

# Get Code Integrity events
$Events = Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
    StartTime = $StartTime
    Level = 2  # Warning level for blocked applications
} -ErrorAction SilentlyContinue

if ($Events) {
    Write-Host "Found $($Events.Count) blocking events:" -ForegroundColor Yellow
    $Events | Format-Table TimeCreated, Id, Message -AutoSize
} else {
    Write-Host "No blocking events found in the specified time period." -ForegroundColor Green
}

# Summary statistics
$TotalEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
    StartTime = $StartTime
} -ErrorAction SilentlyContinue | Measure-Object

Write-Host "Total Code Integrity events: $($TotalEvents.Count)" -ForegroundColor Cyan