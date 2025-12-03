# Folder Restriction Implementation Guide

This guide shows how to implement folder restrictions in WDAC policies and test them effectively.

## Understanding Folder Restrictions

Folder restrictions in WDAC policies work by:
1. Using Path Rules to allow or deny execution based on file location
2. Specifying wildcards (*) to match multiple files in a directory
3. Applying rules at different levels of the file system hierarchy

## Implementing Folder Restrictions

### 1. Deny Rules for High-Risk Folders

```xml
<!-- Deny executables in user downloads folder -->
<Deny ID="ID_DENY_DOWNLOADS_FOLDER" FriendlyName="Deny Downloads Folder Executables" FileName="*" FilePath="%OSDRIVE%\Users\*\Downloads\*" />

<!-- Deny executables in user temp folder -->
<Deny ID="ID_DENY_TEMP_FOLDER" FriendlyName="Deny Temp Folder Executables" FileName="*" FilePath="%OSDRIVE%\Users\*\AppData\Local\Temp\*" />

<!-- Deny executables in public folders -->
<Deny ID="ID_DENY_PUBLIC_FOLDERS" FriendlyName="Deny Public Folder Executables" FileName="*" FilePath="%OSDRIVE%\Users\Public\*" />
```

### 2. Allow Rules for Trusted Folders

```xml
<!-- Allow applications in Program Files -->
<Allow ID="ID_ALLOW_PROGRAM_FILES" FriendlyName="Allow Program Files" FileName="*" FilePath="%PROGRAMFILES%\*" />
<Allow ID="ID_ALLOW_PROGRAM_FILES_X86" FriendlyName="Allow Program Files x86" FileName="*" FilePath="%PROGRAMFILES(X86)%\*" />

<!-- Allow Windows folder -->
<Allow ID="ID_ALLOW_WINDOWS_FOLDER" FriendlyName="Allow Windows Folder" FileName="*" FilePath="%WINDIR%\*" />
```

### 3. Custom Folder Restrictions

```xml
<!-- Allow specific applications in a custom folder -->
<Allow ID="ID_ALLOW_CUSTOM_APPS" FriendlyName="Allow Custom Applications" FileName="*" FilePath="%PROGRAMFILES%\MyCompany\Apps\*" />

<!-- Deny specific file types in a folder -->
<Deny ID="ID_DENY_EXE_IN_DOCUMENTS" FriendlyName="Deny EXE files in Documents" FileName="*.exe" FilePath="%USERPROFILE%\Documents\*" />
```

## Testing Folder Restrictions

### Test Script for Folder Restrictions

```powershell
# Test-FolderRestrictions.ps1
# Script to test folder restriction policies

param(
    [Parameter(Mandatory=$false)]
    [string]$TestBasePath = "C:\temp\wdac_folder_tests"
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "WARN") { "Yellow" } elseif ($Level -eq "SUCCESS") { "Green" } else { "White" })
}

function Create-TestStructure {
    param([string]$BasePath)
    
    Write-Log "Creating test folder structure at $BasePath"
    
    # Create test directories
    $directories = @(
        "$BasePath\Downloads",
        "$BasePath\Temp",
        "$BasePath\Documents",
        "$BasePath\ProgramFiles\MyApp",
        "$BasePath\Public"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Log "Created directory: $dir"
        }
    }
}

function Create-TestExecutables {
    param([string]$BasePath)
    
    Write-Log "Creating test executables"
    
    # Create a simple executable in each test location
    $testLocations = @(
        "$BasePath\Downloads",
        "$BasePath\Temp",
        "$BasePath\Documents",
        "$BasePath\ProgramFiles\MyApp",
        "$BasePath\Public"
    )
    
    foreach ($location in $testLocations) {
        $exePath = Join-Path $location "testapp.exe"
        # Create a minimal executable by copying cmd.exe
        Copy-Item "$env:SystemRoot\System32\cmd.exe" -Destination $exePath -Force
        Write-Log "Created test executable: $exePath"
    }
}

function Test-Execution {
    param([string]$BasePath)
    
    Write-Log "Testing execution in different folders"
    
    $testApps = @(
        @{ Path = "$BasePath\Downloads\testapp.exe"; Expected = "Blocked" },
        @{ Path = "$BasePath\Temp\testapp.exe"; Expected = "Blocked" },
        @{ Path = "$BasePath\Documents\testapp.exe"; Expected = "Blocked" },
        @{ Path = "$BasePath\ProgramFiles\MyApp\testapp.exe"; Expected = "Allowed" },
        @{ Path = "$BasePath\Public\testapp.exe"; Expected = "Blocked" }
    )
    
    foreach ($app in $testApps) {
        Write-Log "Testing: $($app.Path) (Expected: $($app.Expected))"
        
        if (Test-Path $app.Path) {
            try {
                # Attempt to run the executable silently
                $process = Start-Process -FilePath $app.Path -ArgumentList "/c exit" -PassThru -Wait -WindowStyle Hidden -ErrorAction Stop
                if ($process.ExitCode -eq 0) {
                    Write-Log "  Result: Executed successfully" -Level "SUCCESS"
                    if ($app.Expected -eq "Blocked") {
                        Write-Log "  WARNING: This should have been blocked!" -Level "WARN"
                    }
                } else {
                    Write-Log "  Result: Execution failed (Exit code: $($process.ExitCode))" -Level "ERROR"
                    if ($app.Expected -eq "Allowed") {
                        Write-Log "  WARNING: This should have been allowed!" -Level "WARN"
                    }
                }
            } catch {
                Write-Log "  Result: Execution blocked - $_" -Level "ERROR"
                if ($app.Expected -eq "Allowed") {
                    Write-Log "  WARNING: This should have been allowed!" -Level "WARN"
                } else {
                    Write-Log "  SUCCESS: Correctly blocked as expected" -Level "SUCCESS"
                }
            }
        } else {
            Write-Log "  Result: Test executable not found" -Level "WARN"
        }
    }
}

function Monitor-CodeIntegrity {
    Write-Log "Monitoring Code Integrity events"
    
    try {
        # Get recent Code Integrity events
        $events = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
            StartTime = (Get-Date).AddMinutes(-10)
        } -MaxEvents 20 -ErrorAction SilentlyContinue
        
        if ($events) {
            Write-Log "Recent Code Integrity events:"
            $events | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-List
        } else {
            Write-Log "No recent Code Integrity events found"
        }
    } catch {
        Write-Log "Failed to retrieve Code Integrity events: $_" -Level "ERROR"
    }
}

# Main execution
Write-Log "Starting Folder Restriction Tests"

# Create test structure
Create-TestStructure -BasePath $TestBasePath

# Create test executables
Create-TestExecutables -BasePath $TestBasePath

# Test execution
Test-Execution -BasePath $TestBasePath

# Monitor Code Integrity
Monitor-CodeIntegrity

Write-Log "Folder Restriction Tests Completed"