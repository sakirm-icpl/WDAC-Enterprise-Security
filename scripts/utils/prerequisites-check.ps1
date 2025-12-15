# prerequisites-check.ps1
# Checks system prerequisites for WDAC policy deployment

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

function Test-AdminPrivileges {
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $WindowsPrincipal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
    return $WindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-WindowsVersion {
    try {
        $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $Version = [Version]$OSInfo.Version
        
        # Check if Windows 10 version 1903 or later, Windows 11, or Windows Server 2016/2019/2022
        if ($OSInfo.Caption -like "*Windows 10*") {
            # Windows 10 version 1903 is 10.0.18362
            if ($Version.Build -ge 18362) {
                return $true
            }
        } elseif ($OSInfo.Caption -like "*Windows 11*") {
            # All Windows 11 versions are supported
            return $true
        } elseif ($OSInfo.Caption -like "*Windows Server*") {
            # Windows Server 2016/2019/2022 are supported
            if ($Version.Major -ge 10 -and $Version.Build -ge 14393) {
                return $true
            }
        }
        
        return $false
    } catch {
        Write-Log "Failed to determine Windows version: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-PowerShellVersion {
    $PSVersion = $PSVersionTable.PSVersion
    if ($PSVersion.Major -ge 5) {
        return $true
    }
    return $false
}

function Test-WDACModule {
    try {
        Import-Module ConfigCI -ErrorAction Stop
        return $true
    } catch {
        Write-Log "ConfigCI module not available: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-CodeIntegrityPolicy {
    try {
        # Check if CodeIntegrity is available
        $CIPath = "C:\Windows\System32\CodeIntegrity"
        if (Test-Path $CIPath) {
            Write-Log "CodeIntegrity directory found: $CIPath" "SUCCESS"
            return $true
        } else {
            Write-Log "CodeIntegrity directory not found: $CIPath" "ERROR"
            return $false
        }
    } catch {
        Write-Log "Failed to check CodeIntegrity availability: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

Write-Log "Starting WDAC Prerequisites Check" "INFO"
Write-Log "================================" "INFO"

# Check 1: Administrator privileges
Write-Log "Checking administrator privileges..." "INFO"
if (Test-AdminPrivileges) {
    Write-Log "✓ Running with administrator privileges" "SUCCESS"
    $AdminCheck = $true
} else {
    Write-Log "✗ Not running with administrator privileges" "ERROR"
    $AdminCheck = $false
}

# Check 2: Windows version
Write-Log "Checking Windows version..." "INFO"
if (Test-WindowsVersion) {
    $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    Write-Log "✓ Supported Windows version: $($OSInfo.Caption) ($($OSInfo.Version))" "SUCCESS"
    $WindowsCheck = $true
} else {
    $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    Write-Log "✗ Unsupported Windows version: $($OSInfo.Caption) ($($OSInfo.Version))" "ERROR"
    Write-Log "  WDAC requires Windows 10 version 1903+, Windows 11, or Windows Server 2016+" "WARN"
    $WindowsCheck = $false
}

# Check 3: PowerShell version
Write-Log "Checking PowerShell version..." "INFO"
$PSVersion = $PSVersionTable.PSVersion
if (Test-PowerShellVersion) {
    Write-Log "✓ Supported PowerShell version: $PSVersion" "SUCCESS"
    $PowerShellCheck = $true
} else {
    Write-Log "✗ Unsupported PowerShell version: $PSVersion" "ERROR"
    Write-Log "  WDAC requires PowerShell 5.1 or later" "WARN"
    $PowerShellCheck = $false
}

# Check 4: WDAC module
Write-Log "Checking WDAC PowerShell module..." "INFO"
if (Test-WDACModule) {
    Write-Log "✓ ConfigCI module is available" "SUCCESS"
    $ModuleCheck = $true
} else {
    Write-Log "✗ ConfigCI module is not available" "ERROR"
    Write-Log "  The ConfigCI PowerShell module is required for WDAC policy management" "WARN"
    $ModuleCheck = $false
}

# Check 5: CodeIntegrity availability
Write-Log "Checking CodeIntegrity availability..." "INFO"
if (Test-CodeIntegrityPolicy) {
    Write-Log "✓ CodeIntegrity is available" "SUCCESS"
    $CIPointCheck = $true
} else {
    Write-Log "✗ CodeIntegrity is not available" "ERROR"
    $CIPointCheck = $false
}

Write-Log "================================" "INFO"
Write-Log "Prerequisites Check Summary" "INFO"
Write-Log "================================" "INFO"

$Checks = @(
    @{Name = "Administrator Privileges"; Result = $AdminCheck},
    @{Name = "Windows Version"; Result = $WindowsCheck},
    @{Name = "PowerShell Version"; Result = $PowerShellCheck},
    @{Name = "WDAC Module"; Result = $ModuleCheck},
    @{Name = "CodeIntegrity Availability"; Result = $CIPointCheck}
)

$PassCount = ($Checks | Where-Object { $_.Result -eq $true }).Count
$TotalCount = $Checks.Count

foreach ($Check in $Checks) {
    $Status = if ($Check.Result) { "PASS" } else { "FAIL" }
    $Color = if ($Check.Result) { "Green" } else { "Red" }
    Write-Host "  [$Status] $($Check.Name)" -ForegroundColor $Color
}

Write-Log "================================" "INFO"
Write-Log "Overall Result: $PassCount/$TotalCount checks passed" "INFO"

if ($PassCount -eq $TotalCount) {
    Write-Log "✅ System is ready for WDAC policy deployment" "SUCCESS"
    exit 0
} else {
    Write-Log "❌ System is not ready for WDAC policy deployment" "ERROR"
    Write-Log "Please address the failed checks before proceeding" "WARN"
    exit 1
}