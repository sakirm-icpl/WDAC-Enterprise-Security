# Windows 10 Client - Test Scenarios

## 📋 Overview

This document contains detailed test scenarios for deploying WDAC policies on Windows 10 client systems in non-domain (workgroup) environments.

**Target Systems:**
- Windows 10 Pro/Enterprise
- Version 21H2, 22H2
- Non-domain joined (Workgroup)
- Physical or virtual machines

## 🎯 Test Objectives

1. Validate policy deployment on Windows 10 clients
2. Ensure standard applications continue to work
3. Verify untrusted locations are blocked
4. Test policy update and rollback procedures
5. Measure performance impact

## ⚙️ Test Environment Setup

### Prerequisites
```powershell
# System Information
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber

# Check if domain-joined
(Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain

# Verify administrator access
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
```

### Required Software
- PowerShell 5.1+
- Standard Windows 10 applications
- Microsoft Office (if available)
- Common browsers (Edge, Chrome, Firefox)
- Test applications for validation

## 🧪 Test Scenarios

### TS-W10-001: Initial Policy Deployment

**Objective:** Deploy base WDAC policy to Windows 10 client

**Prerequisites:**
- Fresh Windows 10 installation or clean test system
- Repository cloned to C:\WDAC-Enterprise-Security
- Administrator PowerShell session

**Test Steps:**
```powershell
# Step 1: Navigate to repository
cd C:\WDAC-Enterprise-Security

# Step 2: Run prerequisites check
.\scripts\prerequisites-check.ps1

# Step 3: Validate XML policies
.\test-xml-validity.ps1

# Step 4: Run readiness test
.\test-deployment-readiness.ps1

# Step 5: Navigate to non-AD environment
cd environment-specific\non-ad

# Step 6: Deploy policy
.\scripts\deploy-non-ad-policy.ps1

# Step 7: Restart system
Restart-Computer

# Step 8: After restart, verify policy
Get-CIPolicy

# Step 9: Check event logs
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 10
```

**Expected Results:**
- ✅ Prerequisites check passes
- ✅ XML validation passes
- ✅ Readiness test passes
- ✅ Deployment script completes without errors
- ✅ System restarts successfully
- ✅ Policy shows as active after restart
- ✅ Event ID 3099 (Policy loaded) in CodeIntegrity log

**Pass Criteria:**
- All steps complete without errors
- Policy is active and loaded
- No system instability

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

**Notes:** _______________________________________________

---

### TS-W10-002: Program Files Application Execution

**Objective:** Verify applications in Program Files can execute

**Prerequisites:**
- TS-W10-001 completed successfully
- Policy deployed and active

**Test Steps:**
```powershell
# Test 1: Launch Notepad
Start-Process notepad.exe
Start-Sleep -Seconds 2
Stop-Process -Name notepad -Force

# Test 2: Launch Calculator
Start-Process calc.exe
Start-Sleep -Seconds 2
Stop-Process -Name CalculatorApp -Force

# Test 3: Launch Paint
Start-Process mspaint.exe
Start-Sleep -Seconds 2
Stop-Process -Name mspaint -Force

# Test 4: Launch PowerShell
Start-Process powershell.exe -ArgumentList "-NoProfile -Command 'Write-Host Test; Start-Sleep 2'"

# Test 5: Check event logs for blocks
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 20 |
    Where-Object {$_.Id -eq 3077} |
    Format-Table TimeCreated, Message -AutoSize
```

**Expected Results:**
- ✅ All Windows built-in applications launch successfully
- ✅ No Event ID 3077 (Block) events for these applications
- ✅ Applications function normally

**Pass Criteria:**
- All tested applications launch and run
- No unexpected blocks

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-W10-003: Downloads Folder Block Test

**Objective:** Verify executables in Downloads folder are blocked

**Prerequisites:**
- TS-W10-001 completed successfully
- Policy deployed and active

**Test Steps:**
```powershell
# Step 1: Create test executable in Downloads
$downloadsPath = "$env:USERPROFILE\Downloads"
Copy-Item "C:\Windows\System32\notepad.exe" "$downloadsPath\test-app.exe"

# Step 2: Attempt to run from Downloads
try {
    Start-Process "$downloadsPath\test-app.exe" -ErrorAction Stop
    Write-Host "FAIL: Application was allowed to run" -ForegroundColor Red
} catch {
    Write-Host "PASS: Application was blocked as expected" -ForegroundColor Green
}

# Step 3: Check event logs
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 5 |
    Where-Object {$_.Id -eq 3077 -and $_.Message -like "*Downloads*"} |
    Format-Table TimeCreated, Message -AutoSize

# Step 4: Cleanup
Remove-Item "$downloadsPath\test-app.exe" -Force
```

**Expected Results:**
- ✅ Application blocked from running
- ✅ Event ID 3077 (Block) logged
- ✅ Event message references Downloads folder
- ✅ User receives notification (in Audit Mode, logged only)

**Pass Criteria:**
- Execution blocked or logged (depending on Audit/Enforce mode)
- Event logged correctly

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-W10-004: Temp Folder Block Test

**Objective:** Verify executables in Temp folder are blocked

**Prerequisites:**
- TS-W10-001 completed successfully

**Test Steps:**
```powershell
# Step 1: Create test executable in Temp
$tempPath = "$env:TEMP"
Copy-Item "C:\Windows\System32\notepad.exe" "$tempPath\test-temp-app.exe"

# Step 2: Attempt to run from Temp
try {
    Start-Process "$tempPath\test-temp-app.exe" -ErrorAction Stop
    Write-Host "FAIL: Application was allowed to run" -ForegroundColor Red
} catch {
    Write-Host "PASS: Application was blocked as expected" -ForegroundColor Green
}

# Step 3: Check event logs
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 5 |
    Where-Object {$_.Id -eq 3077 -and $_.Message -like "*Temp*"} |
    Format-Table TimeCreated, Message -AutoSize

# Step 4: Cleanup
Remove-Item "$tempPath\test-temp-app.exe" -Force
```

**Expected Results:**
- ✅ Application blocked from running
- ✅ Event ID 3077 logged
- ✅ Event message references Temp folder

**Pass Criteria:**
- Execution blocked or logged
- Event logged correctly

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-W10-005: Microsoft Edge Browser Test

**Objective:** Verify Microsoft Edge functions correctly

**Prerequisites:**
- TS-W10-001 completed successfully
- Microsoft Edge installed

**Test Steps:**
```powershell
# Step 1: Launch Edge
Start-Process msedge.exe -ArgumentList "https://www.microsoft.com"

# Step 2: Wait for browser to load
Start-Sleep -Seconds 5

# Step 3: Manual verification
# - Navigate to different websites
# - Download a file (should be blocked from running)
# - Test browser extensions
# - Close browser

# Step 4: Check for any blocks
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 20 |
    Where-Object {$_.Id -eq 3077 -and $_.Message -like "*msedge*"} |
    Format-Table TimeCreated, Message -AutoSize
```

**Expected Results:**
- ✅ Edge launches successfully
- ✅ Can browse websites
- ✅ Can download files
- ✅ Downloaded executables blocked from running
- ✅ No unexpected blocks of Edge itself

**Pass Criteria:**
- Browser functions normally
- Only downloads blocked, not browser

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-W10-006: Microsoft Office Applications

**Objective:** Verify Office applications work correctly

**Prerequisites:**
- TS-W10-001 completed successfully
- Microsoft Office installed

**Test Steps:**
```powershell
# Test Word
Start-Process winword.exe
Start-Sleep -Seconds 5
Stop-Process -Name WINWORD -Force -ErrorAction SilentlyContinue

# Test Excel
Start-Process excel.exe
Start-Sleep -Seconds 5
Stop-Process -Name EXCEL -Force -ErrorAction SilentlyContinue

# Test PowerPoint
Start-Process powerpnt.exe
Start-Sleep -Seconds 5
Stop-Process -Name POWERPNT -Force -ErrorAction SilentlyContinue

# Check for blocks
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 20 |
    Where-Object {$_.Id -eq 3077 -and ($_.Message -like "*winword*" -or $_.Message -like "*excel*" -or $_.Message -like "*powerpnt*")} |
    Format-Table TimeCreated, Message -AutoSize
```

**Expected Results:**
- ✅ All Office applications launch
- ✅ Can create/edit documents
- ✅ Can save files
- ✅ Macros work (if enabled)
- ✅ No unexpected blocks

**Pass Criteria:**
- All Office apps function normally

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-W10-007: Third-Party Application Test

**Objective:** Test common third-party applications

**Prerequisites:**
- TS-W10-001 completed successfully
- Test applications installed (e.g., 7-Zip, VLC, etc.)

**Test Applications:**
1. 7-Zip (if installed)
2. VLC Media Player (if installed)
3. Adobe Reader (if installed)
4. Any other common applications

**Test Steps:**
```powershell
# Test 7-Zip
if (Test-Path "C:\Program Files\7-Zip\7zFM.exe") {
    Start-Process "C:\Program Files\7-Zip\7zFM.exe"
    Start-Sleep -Seconds 3
    Stop-Process -Name 7zFM -Force -ErrorAction SilentlyContinue
    Write-Host "7-Zip tested"
}

# Test VLC
if (Test-Path "C:\Program Files\VideoLAN\VLC\vlc.exe") {
    Start-Process "C:\Program Files\VideoLAN\VLC\vlc.exe"
    Start-Sleep -Seconds 3
    Stop-Process -Name vlc -Force -ErrorAction SilentlyContinue
    Write-Host "VLC tested"
}

# Check for blocks
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 20 |
    Where-Object {$_.Id -eq 3077} |
    Format-Table TimeCreated, Message -AutoSize
```

**Expected Results:**
- ✅ Applications from Program Files launch
- ✅ Applications function normally
- ✅ No unexpected blocks

**Pass Criteria:**
- All legitimate applications work

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-W10-008: Policy Update Test

**Objective:** Test updating an existing policy

**Prerequisites:**
- TS-W10-001 completed successfully
- Policy currently deployed

**Test Steps:**
```powershell
# Step 1: Backup current policy
.\scripts\backup-policies.ps1

# Step 2: Modify policy (e.g., add an exception)
# Edit: environment-specific\non-ad\policies\exception-policies\emergency-access-policy.xml

# Step 3: Deploy updated policy
cd environment-specific\non-ad
.\scripts\update-non-ad-policy.ps1

# Step 4: Restart system
Restart-Computer

# Step 5: Verify updated policy
Get-CIPolicy

# Step 6: Test that changes took effect
# [Test specific changes made]
```

**Expected Results:**
- ✅ Policy updates successfully
- ✅ Changes take effect after restart
- ✅ No system instability
- ✅ Previous functionality maintained

**Pass Criteria:**
- Update completes successfully
- Changes work as expected

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-W10-009: Policy Rollback Test

**Objective:** Test rolling back to previous policy

**Prerequisites:**
- TS-W10-008 completed (policy updated)
- Backup of previous policy exists

**Test Steps:**
```powershell
# Step 1: Execute rollback
.\scripts\rollback-policy.ps1

# Step 2: Restart system
Restart-Computer

# Step 3: Verify original policy restored
Get-CIPolicy

# Step 4: Test that original behavior restored
# [Verify changes from TS-W10-008 are reverted]
```

**Expected Results:**
- ✅ Rollback completes successfully
- ✅ Original policy restored
- ✅ System functions normally
- ✅ Previous policy behavior confirmed

**Pass Criteria:**
- Rollback successful
- Original functionality restored

**Actual Results:** [To be filled during testing]

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

### TS-W10-010: Performance Impact Test

**Objective:** Measure performance impact of WDAC policy

**Prerequisites:**
- TS-W10-001 completed successfully

**Test Steps:**
```powershell
# Baseline measurements (before policy or after rollback)
# Boot time: Use Event Viewer or Measure-Command
# CPU usage: Get-Counter '\Processor(_Total)\% Processor Time'
# Memory: Get-Counter '\Memory\Available MBytes'

# Step 1: Measure boot time
$bootTime = (Get-WinEvent -FilterHashtable @{LogName='System'; ID=6005} -MaxEvents 1).TimeCreated
$loginTime = (Get-WinEvent -FilterHashtable @{LogName='System'; ID=7001} -MaxEvents 1).TimeCreated
$bootDuration = ($loginTime - $bootTime).TotalSeconds
Write-Host "Boot time: $bootDuration seconds"

# Step 2: Measure application launch time
Measure-Command { Start-Process notepad.exe; Start-Sleep -Seconds 1; Stop-Process -Name notepad -Force }

# Step 3: Measure CPU usage
$cpu = (Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 10 | 
    Select-Object -ExpandProperty CounterSamples | 
    Measure-Object -Property CookedValue -Average).Average
Write-Host "Average CPU: $cpu%"

# Step 4: Measure memory usage
$memory = Get-Counter '\Memory\Available MBytes' | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
Write-Host "Available Memory: $memory MB"
```

**Expected Results:**
- ✅ Boot time increase <10 seconds
- ✅ Application launch time increase <1 second
- ✅ CPU usage increase <5%
- ✅ Memory usage increase <100MB

**Pass Criteria:**
- Performance impact within acceptable limits

**Actual Results:** [To be filled during testing]

| Metric | Before Policy | After Policy | Change |
|--------|--------------|--------------|--------|
| Boot Time | ___ sec | ___ sec | ___% |
| App Launch | ___ sec | ___ sec | ___% |
| CPU Usage | ___% | ___% | ___% |
| Memory | ___ MB | ___ MB | ___ MB |

**Status:** [ ] Pass [ ] Fail [ ] Blocked

---

## 📊 Test Summary Template

**Test Date:** _______________  
**Tester Name:** _______________  
**System Details:**
- Windows Version: _______________
- Build Number: _______________
- Hardware: _______________

**Test Results:**

| Test ID | Test Name | Status | Notes |
|---------|-----------|--------|-------|
| TS-W10-001 | Initial Deployment | [ ] Pass [ ] Fail | |
| TS-W10-002 | Program Files Apps | [ ] Pass [ ] Fail | |
| TS-W10-003 | Downloads Block | [ ] Pass [ ] Fail | |
| TS-W10-004 | Temp Block | [ ] Pass [ ] Fail | |
| TS-W10-005 | Edge Browser | [ ] Pass [ ] Fail | |
| TS-W10-006 | Office Apps | [ ] Pass [ ] Fail | |
| TS-W10-007 | Third-Party Apps | [ ] Pass [ ] Fail | |
| TS-W10-008 | Policy Update | [ ] Pass [ ] Fail | |
| TS-W10-009 | Policy Rollback | [ ] Pass [ ] Fail | |
| TS-W10-010 | Performance | [ ] Pass [ ] Fail | |

**Overall Result:** [ ] Pass [ ] Fail

**Issues Found:** _______________

**Recommendations:** _______________

**Sign-off:** _______________

---

## 📝 Notes and Best Practices

### Testing Tips
1. Always test on non-production systems first
2. Document all observations, even minor ones
3. Take screenshots of errors
4. Save event logs for analysis
5. Test during different times of day
6. Include different user scenarios

### Common Issues and Solutions

**Issue:** Policy doesn't load after restart
**Solution:** Check Event Viewer for errors, verify policy file location

**Issue:** Legitimate application blocked
**Solution:** Create exception policy, add to supplemental policies

**Issue:** Performance degradation
**Solution:** Review event logs, check for excessive policy evaluations

### Event Log Analysis
```powershell
# View all WDAC events
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 100

# Filter for blocks only
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" |
    Where-Object {$_.Id -eq 3077}

# Export events to CSV
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 1000 |
    Select-Object TimeCreated, Id, Message |
    Export-Csv -Path "C:\WDAC-Events.csv" -NoTypeInformation
```

---

**Document Version:** 2.0  
**Last Updated:** 2025-12-03  
**Next Review:** Before each test execution
