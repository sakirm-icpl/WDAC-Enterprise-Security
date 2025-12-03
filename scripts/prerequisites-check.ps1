# Prerequisites Check Script for WDAC Deployment
# Validates system requirements before policy deployment

param(
    [Parameter(Mandatory=$false)]
    [switch]$Detailed
)

$ErrorActionPreference = "Continue"
$script:PassCount = 0
$script:FailCount = 0
$script:WarnCount = 0

function Write-CheckResult {
    param(
        [string]$CheckName,
        [string]$Status,  # Pass, Fail, Warn
        [string]$Message,
        [string]$Details = ""
    )
    
    $iconChar = ""
    $iconColor = "White"
    switch ($Status) {
        "Pass" { $iconChar = "[PASS]"; $script:PassCount++; $iconColor = "Green" }
        "Fail" { $iconChar = "[FAIL]"; $script:FailCount++; $iconColor = "Red" }
        "Warn" { $iconChar = "[WARN]"; $script:WarnCount++; $iconColor = "Yellow" }
    }
    
    Write-Host "$iconChar $CheckName" -ForegroundColor $iconColor
    Write-Host "    $Message" -ForegroundColor Gray
    
    if ($Detailed -and $Details) {
        Write-Host "    Details: $Details" -ForegroundColor DarkGray
    }
    Write-Host ""
}

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     WDAC Deployment Prerequisites Check                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Check 1: Windows Version
Write-Host "[1/15] Checking Windows Version..." -ForegroundColor Yellow
try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $version = [System.Environment]::OSVersion.Version
    $build = $os.BuildNumber
    
    $minBuild = 18362  # Windows 10 1903
    
    if ($build -ge $minBuild) {
        Write-CheckResult "Windows Version" "Pass" `
            "Windows $($os.Caption) Build $build" `
            "Minimum build $minBuild required"
    } else {
        Write-CheckResult "Windows Version" "Fail" `
            "Build $build is below minimum required ($minBuild)" `
            "Please upgrade to Windows 10 1903 or later"
    }
} catch {
    Write-CheckResult "Windows Version" "Fail" "Unable to determine Windows version" $_.Exception.Message
}

# Check 2: Windows Edition
Write-Host "[2/15] Checking Windows Edition..." -ForegroundColor Yellow
try {
    $edition = (Get-WindowsEdition -Online).Edition
    $supportedEditions = @("Professional", "Enterprise", "Education", "ServerStandard", "ServerDatacenter")
    
    if ($supportedEditions -contains $edition) {
        Write-CheckResult "Windows Edition" "Pass" `
            "Edition: $edition" `
            "WDAC supported on this edition"
    } else {
        Write-CheckResult "Windows Edition" "Warn" `
            "Edition: $edition may have limited WDAC support" `
            "Pro, Enterprise, or Server editions recommended"
    }
} catch {
    Write-CheckResult "Windows Edition" "Warn" "Unable to determine Windows edition" $_.Exception.Message
}

# Check 3: PowerShell Version
Write-Host "[3/15] Checking PowerShell Version..." -ForegroundColor Yellow
try {
    $psVersion = $PSVersionTable.PSVersion
    
    if ($psVersion.Major -ge 5) {
        Write-CheckResult "PowerShell Version" "Pass" `
            "Version $($psVersion.Major).$($psVersion.Minor)" `
            "PowerShell 5.1 or later required"
    } else {
        Write-CheckResult "PowerShell Version" "Fail" `
            "Version $($psVersion.Major).$($psVersion.Minor) is too old" `
            "Please upgrade to PowerShell 5.1 or later"
    }
} catch {
    Write-CheckResult "PowerShell Version" "Fail" "Unable to determine PowerShell version" $_.Exception.Message
}

# Check 4: Administrator Privileges
Write-Host "[4/15] Checking Administrator Privileges..." -ForegroundColor Yellow
try {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if ($isAdmin) {
        Write-CheckResult "Administrator Rights" "Pass" `
            "Running with administrator privileges" `
            "Required for policy deployment"
    } else {
        Write-CheckResult "Administrator Rights" "Fail" `
            "Not running as administrator" `
            "Please run PowerShell as Administrator"
    }
} catch {
    Write-CheckResult "Administrator Rights" "Fail" "Unable to check administrator status" $_.Exception.Message
}

# Check 5: WDAC PowerShell Module
Write-Host "[5/15] Checking WDAC PowerShell Module..." -ForegroundColor Yellow
try {
    $wdacCmdlets = @("ConvertFrom-CIPolicy", "Get-CIPolicy", "New-CIPolicy")
    $allPresent = $true
    
    foreach ($cmdlet in $wdacCmdlets) {
        if (-not (Get-Command $cmdlet -ErrorAction SilentlyContinue)) {
            $allPresent = $false
            break
        }
    }
    
    if ($allPresent) {
        Write-CheckResult "WDAC Module" "Pass" `
            "All required WDAC cmdlets available" `
            "ConvertFrom-CIPolicy, Get-CIPolicy, New-CIPolicy"
    } else {
        Write-CheckResult "WDAC Module" "Fail" `
            "WDAC cmdlets not available" `
            "May need to install Windows SDK or update Windows"
    }
} catch {
    Write-CheckResult "WDAC Module" "Fail" "Unable to check WDAC module" $_.Exception.Message
}

# Check 6: Disk Space
Write-Host "[6/15] Checking Disk Space..." -ForegroundColor Yellow
try {
    $systemDrive = $env:SystemDrive
    $disk = Get-PSDrive -Name $systemDrive.TrimEnd(':')
    $freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)
    
    if ($freeSpaceGB -ge 0.1) {
        Write-CheckResult "Disk Space" "Pass" `
            "$freeSpaceGB GB free on $systemDrive" `
            "Minimum 100 MB required"
    } else {
        Write-CheckResult "Disk Space" "Fail" `
            "Only $freeSpaceGB GB free on $systemDrive" `
            "At least 100 MB required"
    }
} catch {
    Write-CheckResult "Disk Space" "Warn" "Unable to check disk space" $_.Exception.Message
}

# Check 7: Execution Policy
Write-Host "[7/15] Checking Execution Policy..." -ForegroundColor Yellow
try {
    $execPolicy = Get-ExecutionPolicy
    $allowedPolicies = @("RemoteSigned", "Unrestricted", "Bypass")
    
    if ($allowedPolicies -contains $execPolicy) {
        Write-CheckResult "Execution Policy" "Pass" `
            "Current policy: $execPolicy" `
            "Scripts can execute"
    } else {
        Write-CheckResult "Execution Policy" "Warn" `
            "Current policy: $execPolicy may block scripts" `
            "Consider: Set-ExecutionPolicy RemoteSigned"
    }
} catch {
    Write-CheckResult "Execution Policy" "Warn" "Unable to check execution policy" $_.Exception.Message
}

# Check 8: Domain Status
Write-Host "[8/15] Checking Domain Status..." -ForegroundColor Yellow
try {
    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    $isDomain = $computerSystem.PartOfDomain
    
    if ($isDomain) {
        Write-CheckResult "Domain Status" "Pass" `
            "Computer is domain-joined: $($computerSystem.Domain)" `
            "Use AD deployment scripts"
    } else {
        Write-CheckResult "Domain Status" "Pass" `
            "Computer is in workgroup: $($computerSystem.Workgroup)" `
            "Use non-AD deployment scripts"
    }
} catch {
    Write-CheckResult "Domain Status" "Warn" "Unable to determine domain status" $_.Exception.Message
}

# Check 9: Secure Boot Status
Write-Host "[9/15] Checking Secure Boot Status..." -ForegroundColor Yellow
try {
    $secureBoot = Confirm-SecureBootUEFI
    
    if ($secureBoot) {
        Write-CheckResult "Secure Boot" "Pass" `
            "Secure Boot is enabled" `
            "Enhanced security for WDAC"
    } else {
        Write-CheckResult "Secure Boot" "Warn" `
            "Secure Boot is disabled" `
            "Consider enabling for enhanced security"
    }
} catch {
    Write-CheckResult "Secure Boot" "Warn" `
        "Unable to check Secure Boot status" `
        "May not be supported on this system"
}

# Check 10: TPM Status
Write-Host "[10/15] Checking TPM Status..." -ForegroundColor Yellow
try {
    $tpm = Get-Tpm
    
    if ($tpm.TpmPresent -and $tpm.TpmReady) {
        Write-CheckResult "TPM" "Pass" `
            "TPM is present and ready" `
            "Can be used for signed policies"
    } else {
        Write-CheckResult "TPM" "Warn" `
            "TPM not available or not ready" `
            "Signed policies may not be supported"
    }
} catch {
    Write-CheckResult "TPM" "Warn" "Unable to check TPM status" $_.Exception.Message
}

# Check 11: Windows Defender Status
Write-Host "[11/15] Checking Windows Defender Status..." -ForegroundColor Yellow
try {
    $defender = Get-MpComputerStatus
    
    if ($defender.AntivirusEnabled) {
        Write-CheckResult "Windows Defender" "Pass" `
            "Windows Defender is active" `
            "Complements WDAC protection"
    } else {
        Write-CheckResult "Windows Defender" "Warn" `
            "Windows Defender is not active" `
            "Consider enabling for layered security"
    }
} catch {
    Write-CheckResult "Windows Defender" "Warn" "Unable to check Windows Defender status" $_.Exception.Message
}

# Check 12: Existing WDAC Policy
Write-Host "[12/15] Checking for Existing WDAC Policy..." -ForegroundColor Yellow
try {
    $policyPath = "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
    
    if (Test-Path $policyPath) {
        Write-CheckResult "Existing Policy" "Warn" `
            "WDAC policy already exists" `
            "Will be backed up before deployment"
    } else {
        Write-CheckResult "Existing Policy" "Pass" `
            "No existing WDAC policy found" `
            "Clean deployment possible"
    }
} catch {
    Write-CheckResult "Existing Policy" "Warn" "Unable to check for existing policy" $_.Exception.Message
}

# Check 13: Event Log Service
Write-Host "[13/15] Checking Event Log Service..." -ForegroundColor Yellow
try {
    $eventLog = Get-Service -Name EventLog
    
    if ($eventLog.Status -eq "Running") {
        Write-CheckResult "Event Log Service" "Pass" `
            "Event Log service is running" `
            "Required for policy monitoring"
    } else {
        Write-CheckResult "Event Log Service" "Fail" `
            "Event Log service is not running" `
            "Start the service before deployment"
    }
} catch {
    Write-CheckResult "Event Log Service" "Fail" "Unable to check Event Log service" $_.Exception.Message
}

# Check 14: Code Integrity Log
Write-Host "[14/15] Checking Code Integrity Event Log..." -ForegroundColor Yellow
try {
    $ciLog = Get-WinEvent -ListLog "Microsoft-Windows-CodeIntegrity/Operational" -ErrorAction Stop
    
    if ($ciLog.IsEnabled) {
        Write-CheckResult "CodeIntegrity Log" "Pass" `
            "CodeIntegrity event log is enabled" `
            "Policy events will be logged"
    } else {
        Write-CheckResult "CodeIntegrity Log" "Warn" `
            "CodeIntegrity event log is disabled" `
            "Enable for policy monitoring"
    }
} catch {
    Write-CheckResult "CodeIntegrity Log" "Warn" "Unable to check CodeIntegrity log" $_.Exception.Message
}

# Check 15: Network Connectivity
Write-Host "[15/15] Checking Network Connectivity..." -ForegroundColor Yellow
try {
    $ping = Test-Connection -ComputerName "microsoft.com" -Count 1 -Quiet
    
    if ($ping) {
        Write-CheckResult "Network Connectivity" "Pass" `
            "Internet connectivity available" `
            "Can download updates if needed"
    } else {
        Write-CheckResult "Network Connectivity" "Warn" `
            "No internet connectivity" `
            "May limit some features"
    }
} catch {
    Write-CheckResult "Network Connectivity" "Warn" "Unable to check network connectivity" $_.Exception.Message
}

# Summary
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    CHECK SUMMARY                           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$totalChecks = $PassCount + $FailCount + $WarnCount
$passRate = [math]::Round(($PassCount / $totalChecks) * 100, 1)

Write-Host "`nTotal Checks: $totalChecks" -ForegroundColor White
Write-Host "Passed: $PassCount" -ForegroundColor Green
Write-Host "Failed: $FailCount" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })
Write-Host "Warnings: $WarnCount" -ForegroundColor $(if ($WarnCount -eq 0) { "Green" } else { "Yellow" })
Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -eq 100) { "Green" } elseif ($passRate -ge 80) { "Yellow" } else { "Red" })

# Recommendations
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    RECOMMENDATIONS                         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

if ($FailCount -eq 0 -and $WarnCount -eq 0) {
    Write-Host "[PASS] All checks passed! System is ready for WDAC deployment." -ForegroundColor Green
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  1. Run: .\test-xml-validity.ps1" -ForegroundColor White
    Write-Host "  2. Run: .\test-deployment-readiness.ps1" -ForegroundColor White
    Write-Host "  3. Review: GETTING_STARTED.md" -ForegroundColor White
    Write-Host "  4. Deploy: Follow deployment guide for your environment" -ForegroundColor White
    exit 0
} elseif ($FailCount -eq 0) {
    Write-Host "[WARN] All critical checks passed, but some warnings present." -ForegroundColor Yellow
    Write-Host "`nRecommendations:" -ForegroundColor Cyan
    Write-Host "  1. Review warnings above" -ForegroundColor White
    Write-Host "  2. Address warnings if possible" -ForegroundColor White
    Write-Host "  3. Proceed with caution" -ForegroundColor White
    Write-Host "  4. Monitor closely after deployment" -ForegroundColor White
    exit 0
} else {
    Write-Host "[FAIL] Some critical checks failed. Please address before deployment." -ForegroundColor Red
    Write-Host "`nRequired Actions:" -ForegroundColor Cyan
    Write-Host "  1. Review failed checks above" -ForegroundColor White
    Write-Host "  2. Address all failures" -ForegroundColor White
    Write-Host "  3. Re-run this script" -ForegroundColor White
    Write-Host "  4. Do not proceed with deployment until all checks pass" -ForegroundColor White
    exit 1
}
