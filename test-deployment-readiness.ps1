# Test-DeploymentReadiness.ps1
# Comprehensive test to verify WDAC policies are ready for deployment

param(
    [Parameter(Mandatory=$false)]
    [switch]$DetailedOutput
)

$ErrorActionPreference = "Continue"
$TestsPassed = 0
$TestsFailed = 0

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = ""
    )
    
    if ($Passed) {
        Write-Host "[PASS] $TestName" -ForegroundColor Green
        if ($Message -and $DetailedOutput) {
            Write-Host "  └─ $Message" -ForegroundColor Gray
        }
        $script:TestsPassed++
    } else {
        Write-Host "[FAIL] $TestName" -ForegroundColor Red
        if ($Message) {
            Write-Host "  └─ $Message" -ForegroundColor Yellow
        }
        $script:TestsFailed++
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "     WDAC Policy Deployment Readiness Test Suite" -ForegroundColor Cyan
Write-Host "==================================================`n" -ForegroundColor Cyan

# Test 1: Check PowerShell Version
Write-Host "[1/10] Checking PowerShell Version..." -ForegroundColor Yellow
$psVersion = $PSVersionTable.PSVersion.Major
Write-TestResult "PowerShell Version >= 5" ($psVersion -ge 5) "Found version $psVersion"

# Test 2: Check Administrator Privileges
Write-Host "`n[2/10] Checking Administrator Privileges..." -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-TestResult "Running as Administrator" $isAdmin "Required for policy deployment"

# Test 3: Check WDAC Module Availability
Write-Host "`n[3/10] Checking WDAC PowerShell Module..." -ForegroundColor Yellow
$wdacModule = Get-Command ConvertFrom-CIPolicy -ErrorAction SilentlyContinue
Write-TestResult "ConvertFrom-CIPolicy cmdlet available" ($null -ne $wdacModule) "Required for policy conversion"

# Test 4: Validate XML Files
Write-Host "`n[4/10] Validating XML Policy Files..." -ForegroundColor Yellow
$policyFiles = @(
    ".\policies\BasePolicy.xml",
    ".\policies\DenyPolicy.xml",
    ".\policies\TrustedApp.xml",
    ".\policies\MergedPolicy.xml",
    ".\environment-specific\non-ad\policies\non-ad-base-policy.xml",
    ".\environment-specific\active-directory\policies\enterprise-base-policy.xml"
)

$allXmlValid = $true
foreach ($file in $policyFiles) {
    if (Test-Path $file) {
        try {
            [xml]$xml = Get-Content $file -ErrorAction Stop
            if ($xml.DocumentElement.LocalName -ne "SiPolicy") {
                $allXmlValid = $false
                if ($DetailedOutput) { Write-Host "  └─ $file has incorrect root element" -ForegroundColor Red }
            }
        } catch {
            $allXmlValid = $false
            if ($DetailedOutput) { Write-Host "  └─ $file is not valid XML" -ForegroundColor Red }
        }
    } else {
        $allXmlValid = $false
        if ($DetailedOutput) { Write-Host "  └─ $file not found" -ForegroundColor Red }
    }
}
Write-TestResult "All XML policies are valid" $allXmlValid "Checked $($policyFiles.Count) policy files"

# Test 5: Check Root Element
Write-Host "`n[5/10] Verifying Root Element Structure..." -ForegroundColor Yellow
$rootElementCorrect = $true
foreach ($file in $policyFiles) {
    if (Test-Path $file) {
        try {
            [xml]$xml = Get-Content $file
            if ($xml.DocumentElement.LocalName -ne "SiPolicy") {
                $rootElementCorrect = $false
                break
            }
        } catch {
            $rootElementCorrect = $false
            break
        }
    }
}
Write-TestResult "Root element is 'SiPolicy'" $rootElementCorrect "Must be SiPolicy, not Policy"

# Test 6: Check Version Format
Write-Host "`n[6/10] Checking Policy Version Format..." -ForegroundColor Yellow
$versionCorrect = $true
foreach ($file in $policyFiles) {
    if (Test-Path $file) {
        try {
            [xml]$xml = Get-Content $file
            $version = $xml.SiPolicy.VersionEx
            if ($version -notmatch '^\d+\.\d+\.\d+\.\d+$') {
                $versionCorrect = $false
                break
            }
        } catch {
            $versionCorrect = $false
            break
        }
    }
}
Write-TestResult "Version format is correct" $versionCorrect "Format: X.X.X.X (e.g., 10.0.0.0)"

# Test 7: Check Required Elements
Write-Host "`n[7/10] Verifying Required Policy Elements..." -ForegroundColor Yellow
$requiredElements = @("VersionEx", "PlatformID", "Rules", "SigningScenarios", "HvciOptions")
$elementsPresent = $true
foreach ($file in $policyFiles) {
    if (Test-Path $file) {
        try {
            [xml]$xml = Get-Content $file
            foreach ($element in $requiredElements) {
                if ($null -eq $xml.SiPolicy.$element) {
                    $elementsPresent = $false
                    if ($DetailedOutput) { Write-Host "  └─ $file missing $element" -ForegroundColor Red }
                    break
                }
            }
        } catch {
            $elementsPresent = $false
            break
        }
    }
}
Write-TestResult "All required elements present" $elementsPresent "Checked: $($requiredElements -join ', ')"

# Test 8: Check Supplemental Policy Structure
Write-Host "`n[8/10] Validating Supplemental Policy Structure..." -ForegroundColor Yellow
$supplementalCorrect = $true
$supplementalPolicies = @(".\policies\DenyPolicy.xml", ".\policies\TrustedApp.xml")
foreach ($file in $supplementalPolicies) {
    if (Test-Path $file) {
        try {
            [xml]$xml = Get-Content $file
            if ($null -eq $xml.SiPolicy.PolicyTypeID) {
                $supplementalCorrect = $false
                if ($DetailedOutput) { Write-Host "  └─ $file missing PolicyTypeID" -ForegroundColor Red }
            }
        } catch {
            $supplementalCorrect = $false
        }
    }
}
Write-TestResult "Supplemental policies have PolicyTypeID" $supplementalCorrect "Required for supplemental policies"

# Test 9: Test Binary Conversion
Write-Host "`n[9/10] Testing Policy Binary Conversion..." -ForegroundColor Yellow
$conversionWorks = $false
$testPolicy = ".\environment-specific\non-ad\policies\non-ad-base-policy.xml"
$testBinary = "$env:TEMP\wdac-test-policy.bin"

if (Test-Path $testPolicy) {
    try {
        ConvertFrom-CIPolicy -XmlFilePath $testPolicy -BinaryFilePath $testBinary -ErrorAction Stop
        if (Test-Path $testBinary) {
            $conversionWorks = $true
            Remove-Item $testBinary -Force -ErrorAction SilentlyContinue
        }
    } catch {
        if ($DetailedOutput) { Write-Host "  └─ Conversion error: $($_.Exception.Message)" -ForegroundColor Red }
    }
}
Write-TestResult "Policy converts to binary format" $conversionWorks "Critical for deployment"

# Test 10: Check Deployment Scripts
Write-Host "`n[10/10] Verifying Deployment Scripts..." -ForegroundColor Yellow
$deployScripts = @(
    ".\environment-specific\non-ad\scripts\deploy-non-ad-policy.ps1",
    ".\environment-specific\active-directory\scripts\deploy-ad-policy.ps1"
)
$scriptsExist = $true
foreach ($script in $deployScripts) {
    if (-not (Test-Path $script)) {
        $scriptsExist = $false
        if ($DetailedOutput) { Write-Host "  └─ $script not found" -ForegroundColor Red }
    }
}
Write-TestResult "Deployment scripts present" $scriptsExist "Required for automated deployment"

# Summary
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "                    TEST SUMMARY" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$totalTests = $TestsPassed + $TestsFailed
$passRate = [math]::Round(($TestsPassed / $totalTests) * 100, 1)

Write-Host "`nTotal Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $TestsPassed" -ForegroundColor Green
Write-Host "Failed: $TestsFailed" -ForegroundColor $(if ($TestsFailed -eq 0) { "Green" } else { "Red" })
Write-Host "Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -eq 100) { "Green" } elseif ($passRate -ge 80) { "Yellow" } else { "Red" })

if ($TestsFailed -eq 0) {
    Write-Host "`n[PASS] ALL TESTS PASSED - Policies are ready for deployment!" -ForegroundColor Green
    Write-Host "`nNext Steps:" -ForegroundColor Cyan
    Write-Host "  1. Review the deployment guide in the documentation folder" -ForegroundColor White
    Write-Host "  2. Test in a non-production environment first" -ForegroundColor White
    Write-Host "  3. Run deployment script as Administrator:" -ForegroundColor White
    Write-Host "     cd environment-specific\non-ad" -ForegroundColor Gray
    Write-Host "     .\scripts\deploy-non-ad-policy.ps1" -ForegroundColor Gray
    exit 0
} else {
    Write-Host "`n[FAIL] SOME TESTS FAILED - Please fix issues before deployment" -ForegroundColor Red
    Write-Host "`nRecommended Actions:" -ForegroundColor Cyan
    Write-Host "  1. Review the XML_FIXES_SUMMARY.md document" -ForegroundColor White
    Write-Host "  2. Run with -DetailedOutput flag for detailed error information" -ForegroundColor White
    Write-Host "  3. Ensure you're running PowerShell as Administrator" -ForegroundColor White
    exit 1
}