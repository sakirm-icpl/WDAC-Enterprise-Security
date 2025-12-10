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

Write-Log "Starting WDAC Policy Rollback Tool" "INFO"

try {
    # Check if policy exists
    if (Test-Path $PolicyPath) {
        Write-Log "Active policy found at $PolicyPath" "WARN"
        
        # Backup current policy if backup doesn't exist
        if (-not (Test-Path $BackupPath)) {
            Write-Log "Creating backup of current policy..." "INFO"
            try {
                Copy-Item -Path $PolicyPath -Destination $BackupPath -Force -ErrorAction Stop
                Write-Log "Backup saved to $BackupPath" "SUCCESS"
            } catch {
                Write-Log "Failed to create backup: $($_.Exception.Message)" "ERROR"
                exit 1
            }
        } else {
            Write-Log "Backup already exists at $BackupPath" "INFO"
        }
        
        if ($Restore) {
            Write-Log "Removing active policy..." "INFO"
            try {
                Remove-Item $PolicyPath -Force -ErrorAction Stop
                Write-Log "Policy removed. Rollback completed." "SUCCESS"
                Write-Log "IMPORTANT: Restart the computer for changes to take effect" "WARN"
            } catch {
                Write-Log "Failed to remove policy: $($_.Exception.Message)" "ERROR"
                exit 1
            }
        } else {
            Write-Log "Policy file detected. Use -Restore parameter to remove it." "INFO"
        }
    } else {
        Write-Log "No active policy found at $PolicyPath" "INFO"
        
        if (Test-Path $BackupPath) {
            Write-Log "Backup policy found at $BackupPath" "WARN"
            
            if ($Restore) {
                Write-Log "Restoring backup policy..." "INFO"
                try {
                    Copy-Item -Path $BackupPath -Destination $PolicyPath -Force -ErrorAction Stop
                    Write-Log "Backup restored to $PolicyPath" "SUCCESS"
                    Write-Log "IMPORTANT: Restart the computer for changes to take effect" "WARN"
                } catch {
                    Write-Log "Failed to restore backup: $($_.Exception.Message)" "ERROR"
                    exit 1
                }
            } else {
                Write-Log "Use -Restore parameter to restore the backup." "INFO"
            }
        } else {
            Write-Log "No backup policy found." "WARN"
        }
    }
} catch {
    Write-Log "Unexpected error in rollback process: $($_.Exception.Message)" "ERROR"
    exit 1
}

Write-Log "Rollback process completed." "INFO"