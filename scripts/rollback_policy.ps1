# PowerShell script to rollback WDAC policy
# Usage: .\rollback_policy.ps1 [-BackupPath "path\to\backup.xml"] [-Restore]

param(
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b",
    
    [Parameter(Mandatory=$false)]
    [string]$BackupPath = "..\policies\MergedPolicy_Backup.p7b",
    
    [Parameter(Mandatory=$false)]
    [switch]$Restore
)

Write-Host "WDAC Policy Rollback Tool" -ForegroundColor Green

# Check if policy exists
if (Test-Path $PolicyPath) {
    Write-Host "Active policy found at $PolicyPath" -ForegroundColor Yellow
    
    # Backup current policy if backup doesn't exist
    if (-not (Test-Path $BackupPath)) {
        Write-Host "Creating backup of current policy..." -ForegroundColor Yellow
        Copy-Item -Path $PolicyPath -Destination $BackupPath -Force
        Write-Host "Backup saved to $BackupPath" -ForegroundColor Green
    }
    
    if ($Restore) {
        Write-Host "Removing active policy..." -ForegroundColor Yellow
        Remove-Item $PolicyPath -Force
        Write-Host "Policy removed. Rollback completed." -ForegroundColor Green
        Write-Host "IMPORTANT: Restart the computer for changes to take effect" -ForegroundColor Red
    } else {
        Write-Host "Policy file detected. Use -Restore parameter to remove it." -ForegroundColor Yellow
    }
} else {
    Write-Host "No active policy found at $PolicyPath" -ForegroundColor Green
    
    if (Test-Path $BackupPath) {
        Write-Host "Backup policy found at $BackupPath" -ForegroundColor Yellow
        
        if ($Restore) {
            Write-Host "Restoring backup policy..." -ForegroundColor Yellow
            Copy-Item -Path $BackupPath -Destination $PolicyPath -Force
            Write-Host "Backup restored to $PolicyPath" -ForegroundColor Green
            Write-Host "IMPORTANT: Restart the computer for changes to take effect" -ForegroundColor Red
        } else {
            Write-Host "Use -Restore parameter to restore the backup." -ForegroundColor Yellow
        }
    } else {
        Write-Host "No backup policy found." -ForegroundColor Yellow
    }
}

Write-Host "Rollback process completed." -ForegroundColor Green