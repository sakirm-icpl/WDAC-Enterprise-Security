# Monitor-AuditLogs.ps1
# Simple script to monitor WDAC audit logs

Write-Host "Monitoring WDAC Audit Logs (Press Ctrl+C to stop)" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

while ($true) {
    $events = Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 10 | 
        Where-Object {$_.Id -eq 3076} |
        Sort-Object TimeCreated
    
    if ($events.Count -gt 0) {
        Write-Host "$(Get-Date -Format 'HH:mm:ss') - Found $($events.Count) audit events:" -ForegroundColor Yellow
        foreach ($event in $events) {
            Write-Host "  [$($event.TimeCreated)] $($event.Message)" -ForegroundColor Cyan
        }
        Write-Host ""
    } else {
        Write-Host "$(Get-Date -Format 'HH:mm:ss') - No new audit events" -ForegroundColor Gray
    }
    
    Start-Sleep -Seconds 10
}