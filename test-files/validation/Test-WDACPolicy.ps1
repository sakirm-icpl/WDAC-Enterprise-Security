# WDAC Policy Testing and Validation Script

This script helps you test and validate your WDAC policies on your machine.

```powershell
# Test-WDACPolicy.ps1
# Script to test and validate WDAC policies

param(
    [Parameter(Mandatory=$false)]
    [string]$TestDirectory = "C:\temp\wdac_test",
    
    [Parameter(Mandatory=$false)]
    [switch]$CreateTestFiles,
    
    [Parameter(Mandatory=$false)]
    [switch]$RunTests,
    
    [Parameter(Mandatory=$false)]
    [switch]$CheckLogs
)

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "WARN") { "Yellow" } else { "Green" })
}

function Create-TestFiles {
    param(
        [string]$Directory
    )
    
    Write-Log "Creating test files in $Directory"
    
    # Create test directory if it doesn't exist
    if (-not (Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
        Write-Log "Created test directory: $Directory"
    }
    
    # Create a simple batch file (unsigned)
    $batchContent = @"
@echo off
echo This is a test batch file
echo Current date: %date%
echo Current time: %time%
"@
    
    $batchPath = Join-Path $Directory "test.bat"
    Set-Content -Path $batchPath -Value $batchContent
    Write-Log "Created test batch file: $batchPath"
    
    # Create a simple PowerShell script (unsigned)
    $psContent = @"
Write-Host "This is a test PowerShell script"
Get-Date | Write-Host
"@
    
    $psPath = Join-Path $Directory "test.ps1"
    Set-Content -Path $psPath -Value $psContent
    Write-Log "Created test PowerShell script: $psPath"
    
    # Create a simple executable (using PowerShell to create a dummy exe)
    $exePath = Join-Path $Directory "test.exe"
    # We'll create a simple executable using a one-liner that creates a minimal PE file
    # For testing purposes, we'll just copy cmd.exe and rename it
    Copy-Item "$env:SystemRoot\System32\cmd.exe" -Destination $exePath -Force
    Write-Log "Created test executable: $exePath"
    
    Write-Log "Test files created successfully"
}

function Run-PolicyTests {
    param(
        [string]$Directory
    )
    
    Write-Log "Running WDAC policy tests"
    
    # Check if test directory exists
    if (-not (Test-Path $Directory)) {
        Write-Log "Test directory does not exist: $Directory" -Level "ERROR"
        return
    }
    
    # Test running batch file
    $batchPath = Join-Path $Directory "test.bat"
    if (Test-Path $batchPath) {
        Write-Log "Testing batch file execution: $batchPath"
        try {
            & $batchPath
            Write-Log "Batch file executed successfully" -Level "INFO"
        } catch {
            Write-Log "Batch file execution failed: $_" -Level "WARN"
        }
    } else {
        Write-Log "Batch file not found: $batchPath" -Level "WARN"
    }
    
    # Test running PowerShell script
    $psPath = Join-Path $Directory "test.ps1"
    if (Test-Path $psPath) {
        Write-Log "Testing PowerShell script execution: $psPath"
        try {
            & "powershell.exe" -ExecutionPolicy Bypass -File $psPath
            Write-Log "PowerShell script executed successfully" -Level "INFO"
        } catch {
            Write-Log "PowerShell script execution failed: $_" -Level "WARN"
        }
    } else {
        Write-Log "PowerShell script not found: $psPath" -Level "WARN"
    }
    
    # Test running executable
    $exePath = Join-Path $Directory "test.exe"
    if (Test-Path $exePath) {
        Write-Log "Testing executable execution: $exePath"
        try {
            & $exePath /c "echo Test execution successful & pause"
            Write-Log "Executable ran successfully" -Level "INFO"
        } catch {
            Write-Log "Executable execution failed: $_" -Level "WARN"
        }
    } else {
        Write-Log "Executable not found: $exePath" -Level "WARN"
    }
    
    Write-Log "Policy tests completed"
}

function Check-CodeIntegrityLogs {
    Write-Log "Checking Code Integrity logs"
    
    # Check for recent Code Integrity events
    try {
        $events = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-CodeIntegrity/Operational'; StartTime=(Get-Date).AddDays(-1)} -MaxEvents 50 -ErrorAction SilentlyContinue
        
        if ($events) {
            Write-Log "Found $($events.Count) Code Integrity events in the last 24 hours"
            
            # Filter for blocked applications (event ID 3076 or 3077)
            $blockedEvents = $events | Where-Object { $_.Id -eq 3076 -or $_.Id -eq 3077 }
            
            if ($blockedEvents) {
                Write-Log "Found $($blockedEvents.Count) blocked application events:" -Level "WARN"
                $blockedEvents | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-List
            } else {
                Write-Log "No blocked application events found"
            }
        } else {
            Write-Log "No Code Integrity events found in the last 24 hours"
        }
    } catch {
        Write-Log "Failed to check Code Integrity logs: $_" -Level "ERROR"
    }
    
    # Check current policy status
    try {
        $policyStatus = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard -ErrorAction SilentlyContinue
        if ($policyStatus) {
            Write-Log "Device Guard Status:"
            Write-Log "  Code Integrity Policy Status: $($policyStatus.CodeIntegrityPolicyStatus)"
            Write-Log "  User Mode Code Integrity Policy Status: $($policyStatus.UserModeCodeIntegrityPolicyStatus)"
            Write-Log "  Virtualization Based Security Status: $($policyStatus.VirtualizationBasedSecurityStatus)"
        }
    } catch {
        Write-Log "Failed to get Device Guard status: $_" -Level "ERROR"
    }
    
    Write-Log "Code Integrity log check completed"
}

function Show-Usage {
    Write-Host "WDAC Policy Testing Script" -ForegroundColor Cyan
    Write-Host "Usage: .\Test-WDACPolicy.ps1 [-TestDirectory <path>] [-CreateTestFiles] [-RunTests] [-CheckLogs]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Cyan
    Write-Host "  -TestDirectory    Path to test directory (default: C:\temp\wdac_test)" -ForegroundColor White
    Write-Host "  -CreateTestFiles  Create test files (batch, ps1, exe)" -ForegroundColor White
    Write-Host "  -RunTests         Run policy tests" -ForegroundColor White
    Write-Host "  -CheckLogs        Check Code Integrity logs" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\Test-WDACPolicy.ps1 -CreateTestFiles" -ForegroundColor White
    Write-Host "  .\Test-WDACPolicy.ps1 -RunTests" -ForegroundColor White
    Write-Host "  .\Test-WDACPolicy.ps1 -CheckLogs" -ForegroundColor White
    Write-Host "  .\Test-WDACPolicy.ps1 -TestDirectory C:\MyTests -CreateTestFiles -RunTests -CheckLogs" -ForegroundColor White
}

# Main script execution
Write-Log "Starting WDAC Policy Testing Script"

if (-not $CreateTestFiles -and -not $RunTests -and -not $CheckLogs) {
    Show-Usage
    exit 0
}

if ($CreateTestFiles) {
    Create-TestFiles -Directory $TestDirectory
}

if ($RunTests) {
    Run-PolicyTests -Directory $TestDirectory
}

if ($CheckLogs) {
    Check-CodeIntegrityLogs
}

Write-Log "WDAC Policy Testing Script completed"