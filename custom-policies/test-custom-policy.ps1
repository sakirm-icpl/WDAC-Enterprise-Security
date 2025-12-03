# Test-CustomPolicy.ps1
# Tests the custom WDAC policy scenarios

param(
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$env:TEMP\WDAC_Custom_Test_Log.txt"
)

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] $Message"
    Add-Content -Path $LogPath -Value $LogEntry
    Write-Host $LogEntry
}

function Create-TestFiles {
    Write-Log "Creating test files..."
    
    # Create test directory if it doesn't exist
    $testDir = "$env:TEMP\WDAC_Test"
    if (-not (Test-Path $testDir)) {
        New-Item -ItemType Directory -Path $testDir | Out-Null
    }
    
    # Create test files in Downloads
    $downloadsDir = "$env:USERPROFILE\Downloads"
    if (-not (Test-Path $downloadsDir)) {
        New-Item -ItemType Directory -Path $downloadsDir | Out-Null
    }
    
    # Create test batch file in Downloads
    echo "@echo off" > "$downloadsDir\test_wdac.bat"
    echo "echo This is a test batch file from Downloads" >> "$downloadsDir\test_wdac.bat"
    
    # Create test PowerShell script in Downloads
    echo "Write-Host 'This is a test PowerShell script from Downloads'" > "$downloadsDir\test_wdac.ps1"
    
    # Create test executable in Downloads (copy ping.exe)
    Copy-Item "C:\Windows\System32\ping.exe" -Destination "$downloadsDir\test_wdac.exe" -Force
    
    # Create OSSEC test directory and file if it doesn't exist
    $ossecDir = "C:\Program Files (x86)\ossec-agent\active-response\bin"
    if (-not (Test-Path $ossecDir)) {
        New-Item -ItemType Directory -Path $ossecDir -Force | Out-Null
    }
    
    # Create test executable in OSSEC directory
    Copy-Item "C:\Windows\System32\ping.exe" -Destination "$ossecDir\test_ossec.exe" -Force
    
    Write-Log "Test files created successfully"
}

function Test-Scenarios {
    Write-Log "Testing WDAC policy scenarios..."
    
    # Test 1: Microsoft signed applications should work (test with notepad)
    Write-Log "Test 1: Running Microsoft signed application (notepad.exe)"
    try {
        Start-Process -FilePath "notepad.exe" -ArgumentList "/?" -Wait -NoNewWindow
        Write-Log "✓ Microsoft signed application test PASSED"
    } catch {
        Write-Log "✗ Microsoft signed application test FAILED: $($_.Exception.Message)"
    }
    
    # Test 2: Program Files applications should work (test with system utilities)
    Write-Log "Test 2: Running application from Program Files"
    try {
        Start-Process -FilePath "C:\Windows\System32\calc.exe" -ArgumentList "/?" -Wait -NoNewWindow
        Write-Log "✓ Program Files application test PASSED"
    } catch {
        Write-Log "✗ Program Files application test FAILED: $($_.Exception.Message)"
    }
    
    # Test 3: Downloads folder executables should be blocked
    Write-Log "Test 3: Running executable from Downloads folder"
    try {
        Start-Process -FilePath "$env:USERPROFILE\Downloads\test_wdac.exe" -ArgumentList "localhost" -Wait -NoNewWindow
        Write-Log "⚠ Downloads executable test result: Executed (check audit logs for blocking)"
    } catch {
        Write-Log "✓ Downloads executable test result: Blocked as expected"
    }
    
    # Test 4: Downloads folder scripts should be blocked
    Write-Log "Test 4: Running batch file from Downloads folder"
    try {
        Start-Process -FilePath "$env:USERPROFILE\Downloads\test_wdac.bat" -Wait -NoNewWindow
        Write-Log "⚠ Downloads batch file test result: Executed (check audit logs for blocking)"
    } catch {
        Write-Log "✓ Downloads batch file test result: Blocked as expected"
    }
    
    # Test 5: OSSEC folder executables should be blocked
    Write-Log "Test 5: Running executable from OSSEC agent folder"
    try {
        Start-Process -FilePath "C:\Program Files (x86)\ossec-agent\active-response\bin\test_ossec.exe" -ArgumentList "/?" -Wait -NoNewWindow
        Write-Log "⚠ OSSEC executable test result: Executed (check audit logs for blocking)"
    } catch {
        Write-Log "✓ OSSEC executable test result: Blocked as expected"
    }
    
    Write-Log "All test scenarios completed"
}

function Get-AuditLogs {
    Write-Log "Checking WDAC audit logs for recent events..."
    
    # Get recent WDAC audit events
    $recentEvents = Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 50 | 
        Where-Object {$_.TimeCreated -gt (Get-Date).AddMinutes(-30) -and $_.Id -eq 3076} |
        Select-Object TimeCreated, Message
    
    if ($recentEvents.Count -gt 0) {
        Write-Log "Found $($recentEvents.Count) recent WDAC audit events:"
        foreach ($event in $recentEvents) {
            Write-Log "  [$($event.TimeCreated)] $($event.Message)"
        }
    } else {
        Write-Log "No recent WDAC audit events found (this is normal if applications were allowed)"
    }
}

# Main script execution
Write-Log "Starting WDAC custom policy testing"

# Create test files
Create-TestFiles

# Run test scenarios
Test-Scenarios

# Check audit logs
Get-AuditLogs

Write-Log "WDAC custom policy testing completed"
Write-Log "Check audit logs for detailed blocking information"