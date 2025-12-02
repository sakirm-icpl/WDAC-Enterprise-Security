# WDAC Policy Testing Plan

This document outlines the testing procedures for validating WDAC policies.

## Test Environment Setup

### Prerequisites

- Windows 10/11 Pro, Enterprise, or Education (version 1903 or later)
- PowerShell 5.1 or later
- Administrative privileges
- Test applications representing different categories

### Test Environment Configuration

1. Create a dedicated test system or VM
2. Ensure the system is fully updated
3. Install representative applications for testing:
   - Microsoft-signed applications (Office, Edge, etc.)
   - Third-party applications with valid certificates
   - Applications without certificates
   - Scripts (PowerShell, batch files)
   - Legacy applications

## Test Scenarios

### Scenario 1: Base Policy Validation

**Objective**: Verify that the base policy allows trusted applications and blocks untrusted ones.

**Steps**:
1. Deploy base policy in audit mode
2. Launch Microsoft-signed applications (e.g., Notepad, Calculator)
3. Launch third-party signed applications
4. Attempt to run unsigned applications
5. Review audit logs for blocked applications

**Expected Results**:
- Microsoft applications should be allowed
- Third-party signed applications should be allowed
- Unsigned applications should be blocked and logged

### Scenario 2: Deny Policy Validation

**Objective**: Verify that the deny policy blocks applications in specified locations.

**Steps**:
1. Deploy merged policy (base + deny) in audit mode
2. Copy a legitimate application to the Downloads folder
3. Attempt to run the application from the Downloads folder
4. Copy the same application to Program Files
5. Attempt to run the application from Program Files
6. Review audit logs

**Expected Results**:
- Application in Downloads should be blocked
- Application in Program Files should be allowed

### Scenario 3: Trusted Application Validation

**Objective**: Verify that trusted applications are explicitly allowed.

**Steps**:
1. Deploy merged policy (base + deny + trusted) in audit mode
2. Place a trusted application in a normally blocked location
3. Attempt to run the trusted application
4. Review audit logs

**Expected Results**:
- Trusted application should be allowed even from blocked locations

### Scenario 4: Supplemental Policy Validation

**Objective**: Verify that supplemental policies extend base policies correctly.

**Steps**:
1. Deploy base policy in audit mode
2. Attempt to run a third-party application not covered by base policy
3. Note blocking in audit logs
4. Create and deploy supplemental policy for the third-party application
5. Attempt to run the third-party application again
6. Review audit logs

**Expected Results**:
- Third-party application should be blocked initially
- Third-party application should be allowed after supplemental policy deployment

### Scenario 5: Enforce Mode Validation

**Objective**: Verify that policies work correctly in enforce mode.

**Steps**:
1. Deploy policy in enforce mode
2. Attempt to run blocked applications
3. Verify that applications are actually blocked (not just logged)
4. Verify that allowed applications still work

**Expected Results**:
- Blocked applications should fail to launch
- Allowed applications should launch normally

## Validation Scripts

### Policy Syntax Validation

```powershell
# Test-WDACPolicy.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$PolicyPath
)

# Check if policy file exists
if (-not (Test-Path $PolicyPath)) {
    Write-Error "Policy file not found: $PolicyPath"
    exit 1
}

# Validate XML structure
try {
    [xml]$Policy = Get-Content $PolicyPath
    Write-Host "XML structure: VALID" -ForegroundColor Green
} catch {
    Write-Error "Invalid XML structure: $_"
    exit 1
}

# Check required elements
$RequiredElements = @("Policy", "Rules", "FileRules", "SigningScenarios")
foreach ($Element in $RequiredElements) {
    if ($Policy.$Element -or $Policy.Policy.$Element) {
        Write-Host "$Element: FOUND" -ForegroundColor Green
    } else {
        Write-Host "$Element: MISSING" -ForegroundColor Red
    }
}

Write-Host "Policy validation completed." -ForegroundColor Cyan
```

### Audit Log Analysis

```powershell
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
```

## Test Data Organization

### Binary Test Files

Store test binaries in [test-files/binaries/](../test-files/binaries/) with the following organization:

```
test-files/binaries/
├── microsoft/
│   ├── signed/
│   │   ├── calculator.exe
│   │   └── notepad.exe
│   └── unsigned/
│       └── test-app.exe
├── third-party/
│   ├── signed/
│   │   └── vendor-app.exe
│   └── unsigned/
│       └── legacy-app.exe
└── custom/
    ├── trusted/
    │   └── approved-app.exe
    └── malicious/
        └── test-malware.exe
```

### Test Scripts

Store validation scripts in [test-files/validation/](../test-files/validation/):

- Policy syntax validators
- Audit log analyzers
- Automated test runners
- Result reporters

## Test Execution Procedure

### Pre-Test Checklist

- [ ] Test environment prepared
- [ ] Test applications installed
- [ ] Backup policies created
- [ ] Logging enabled
- [ ] Test scripts available

### Test Execution Steps

1. Deploy policy in audit mode
2. Execute test scenarios
3. Collect audit logs
4. Analyze results
5. Document findings
6. Refine policies as needed
7. Repeat with enforce mode

### Post-Test Cleanup

- [ ] Remove test policies
- [ ] Clear test audit logs (if not needed)
- [ ] Document final policy configuration
- [ ] Archive test results

## Expected Test Results

### Pass Criteria

A test is considered passed if:
- All allowed applications execute successfully
- All blocked applications are prevented from executing
- Audit logs accurately reflect policy decisions
- System performance is not significantly impacted
- No unintended side effects occur

### Fail Criteria

A test is considered failed if:
- Allowed applications are incorrectly blocked
- Blocked applications execute successfully
- Audit logs are missing or inaccurate
- System instability occurs
- Performance degradation is observed

## Reporting

### Test Report Template

```
WDAC Policy Test Report
=======================

Test Date: [DATE]
Policy Version: [VERSION]
Test Environment: [ENVIRONMENT DETAILS]

Summary:
[PASS/FAIL] - [BRIEF SUMMARY]

Detailed Results:
[SCENARIO RESULTS]

Issues Found:
[LIST OF ISSUES]

Recommendations:
[IMPROVEMENT RECOMMENDATIONS]

Next Steps:
[ACTION ITEMS]
```

## Automation Opportunities

Consider automating repetitive test tasks:
- Policy deployment scripts
- Application launching scripts
- Log analysis tools
- Report generation utilities

## Continuous Testing

For ongoing policy management:
- Regular audit log reviews
- Periodic policy validation
- Automated testing for policy updates
- Integration with CI/CD pipelines (where applicable)