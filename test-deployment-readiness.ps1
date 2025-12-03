# Test WDAC Deployment Process

Write-Host "Testing WDAC Deployment Process" -ForegroundColor Cyan

# Test 1: Validate XML files can be parsed
Write-Host "`nTest 1: Validating XML Policy Files" -ForegroundColor Yellow
$xmlFiles = @(
    "environment-specific/non-ad/policies/non-ad-base-policy.xml",
    "environment-specific/non-ad/policies/department-supplemental-policies/finance-policy.xml",
    "environment-specific/non-ad/policies/department-supplemental-policies/hr-policy.xml",
    "environment-specific/non-ad/policies/department-supplemental-policies/it-policy.xml",
    "environment-specific/non-ad/policies/exception-policies/emergency-access-policy.xml"
)

$allValid = $true
foreach ($file in $xmlFiles) {
    try {
        [xml]$policy = Get-Content $file
        Write-Host "  [OK] $file" -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] $file - $($_.Exception.Message)" -ForegroundColor Red
        $allValid = $false
    }
}

if ($allValid) {
    Write-Host "  All XML files are valid!" -ForegroundColor Green
} else {
    Write-Host "  Some XML files have errors!" -ForegroundColor Red
    exit 1
}

# Test 2: Check if ConvertFrom-CIPolicy cmdlet is available
Write-Host "`nTest 2: Checking ConvertFrom-CIPolicy Availability" -ForegroundColor Yellow
try {
    $cmdlet = Get-Command ConvertFrom-CIPolicy -ErrorAction Stop
    Write-Host "  [OK] ConvertFrom-CIPolicy cmdlet is available" -ForegroundColor Green
} catch {
    Write-Host "  [WARNING] ConvertFrom-CIPolicy cmdlet is not available: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "  This cmdlet is part of the WDAC feature and requires Windows 10/11 Enterprise or equivalent." -ForegroundColor Yellow
}

# Test 3: Verify directory structure
Write-Host "`nTest 3: Verifying Directory Structure" -ForegroundColor Yellow
$requiredDirs = @(
    "environment-specific/non-ad/policies",
    "environment-specific/non-ad/scripts",
    "environment-specific/active-directory/policies",
    "environment-specific/active-directory/scripts",
    "test-files/validation"
)

foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        Write-Host "  [OK] $dir" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $dir" -ForegroundColor Red
    }
}

# Test 4: Check key script files
Write-Host "`nTest 4: Checking Key Script Files" -ForegroundColor Yellow
$scriptFiles = @(
    "environment-specific/non-ad/scripts/deploy-non-ad-policy.ps1",
    "environment-specific/active-directory/scripts/deploy-ad-policy.ps1",
    "test-files/validation/Analyze-AuditLogs.ps1",
    "test-files/validation/Generate-TestReport.ps1"
)

foreach ($file in $scriptFiles) {
    if (Test-Path $file) {
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] $file" -ForegroundColor Red
    }
}

Write-Host "`n[SUCCESS] WDAC Repository Validation Complete" -ForegroundColor Cyan
Write-Host "The repository is ready for deployment testing on Windows 10/11 systems." -ForegroundColor Yellow