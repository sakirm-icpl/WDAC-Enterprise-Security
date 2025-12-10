# test-sample-policies.ps1
# Validation tests for sample policies

param(
    [string]$TestRoot = $PSScriptRoot
)

# Import required modules
try {
    Import-Module ConfigCI -ErrorAction Stop
} catch {
    Write-Host "SKIP: ConfigCI module not available. Skipping sample policy tests." -ForegroundColor Yellow
    return $true
}

# Test results array
$testResults = @()

function Test-PolicySyntax {
    param([string]$PolicyPath)
    
    try {
        # Load XML and validate structure
        [xml]$PolicyXml = Get-Content $PolicyPath -ErrorAction Stop
        
        # Check for required elements
        if (-not $PolicyXml.Policy) {
            Write-Host "FAIL: Invalid policy structure: Missing Policy root element in $PolicyPath" -ForegroundColor Red
            return $false
        }
        
        # Validate PolicyType
        $validPolicyTypes = @("Base Policy", "Supplemental Policy")
        if ($PolicyXml.Policy.PolicyType -notin $validPolicyTypes) {
            Write-Host "WARN: Unexpected PolicyType in $PolicyPath. Expected: Base Policy or Supplemental Policy" -ForegroundColor Yellow
        }
        
        # Check for VersionEx
        if (-not $PolicyXml.Policy.VersionEx) {
            Write-Host "FAIL: Missing VersionEx element in $PolicyPath" -ForegroundColor Red
            return $false
        }
        
        # For Base policies, check for PlatformID
        if ($PolicyXml.Policy.PolicyType -eq "Base Policy" -and -not $PolicyXml.Policy.PlatformID) {
            Write-Host "FAIL: Missing PlatformID in Base Policy $PolicyPath" -ForegroundColor Red
            return $false
        }
        
        # For Supplemental policies, check for BasePolicyID
        if ($PolicyXml.Policy.PolicyType -eq "Supplemental Policy" -and -not $PolicyXml.Policy.BasePolicyID) {
            Write-Host "FAIL: Missing BasePolicyID in Supplemental Policy $PolicyPath" -ForegroundColor Red
            return $false
        }
        
        Write-Host "PASS: Policy syntax validation passed for $PolicyPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "FAIL: Policy syntax validation failed for $PolicyPath : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-SampleBasePolicies {
    Write-Host "Testing base policies..." -ForegroundColor Cyan
    
    $basePolicyPath = "$TestRoot\..\..\samples\base-policies"
    
    if (-not (Test-Path $basePolicyPath)) {
        Write-Host "SKIP: Base policies directory not found" -ForegroundColor Yellow
        return $true
    }
    
    $policies = Get-ChildItem -Path $basePolicyPath -Filter "*.xml" -File
    
    if ($policies.Count -eq 0) {
        Write-Host "SKIP: No base policies found" -ForegroundColor Yellow
        return $true
    }
    
    $result = $true
    foreach ($policy in $policies) {
        $result = Test-PolicySyntax -PolicyPath $policy.FullName -and $result
    }
    
    return $result
}

function Test-SampleSupplementalPolicies {
    Write-Host "Testing supplemental policies..." -ForegroundColor Cyan
    
    $supplementalPolicyPath = "$TestRoot\..\..\samples\supplemental-policies"
    
    if (-not (Test-Path $supplementalPolicyPath)) {
        Write-Host "SKIP: Supplemental policies directory not found" -ForegroundColor Yellow
        return $true
    }
    
    $policies = Get-ChildItem -Path $supplementalPolicyPath -Filter "*.xml" -File
    
    if ($policies.Count -eq 0) {
        Write-Host "SKIP: No supplemental policies found" -ForegroundColor Yellow
        return $true
    }
    
    $result = $true
    foreach ($policy in $policies) {
        $result = Test-PolicySyntax -PolicyPath $policy.FullName -and $result
    }
    
    return $result
}

function Test-SampleDenyPolicies {
    Write-Host "Testing deny policies..." -ForegroundColor Cyan
    
    $denyPolicyPath = "$TestRoot\..\..\samples\deny-policies"
    
    if (-not (Test-Path $denyPolicyPath)) {
        Write-Host "SKIP: Deny policies directory not found" -ForegroundColor Yellow
        return $true
    }
    
    $policies = Get-ChildItem -Path $denyPolicyPath -Filter "*.xml" -File
    
    if ($policies.Count -eq 0) {
        Write-Host "SKIP: No deny policies found" -ForegroundColor Yellow
        return $true
    }
    
    $result = $true
    foreach ($policy in $policies) {
        $result = Test-PolicySyntax -PolicyPath $policy.FullName -and $result
    }
    
    return $result
}

function Test-SampleIndustryPolicies {
    Write-Host "Testing industry-specific policies..." -ForegroundColor Cyan
    
    $industryPolicyPath = "$TestRoot\..\..\samples\industry"
    
    if (-not (Test-Path $industryPolicyPath)) {
        Write-Host "SKIP: Industry policies directory not found" -ForegroundColor Yellow
        return $true
    }
    
    $policies = Get-ChildItem -Path $industryPolicyPath -Filter "*.xml" -File -Recurse
    
    if ($policies.Count -eq 0) {
        Write-Host "SKIP: No industry policies found" -ForegroundColor Yellow
        return $true
    }
    
    $result = $true
    foreach ($policy in $policies) {
        $result = Test-PolicySyntax -PolicyPath $policy.FullName -and $result
    }
    
    return $result
}

# Run tests
Write-Host "Running sample policy validation tests..." -ForegroundColor Cyan

$testResults += Test-SampleBasePolicies
$testResults += Test-SampleSupplementalPolicies
$testResults += Test-SampleDenyPolicies
$testResults += Test-SampleIndustryPolicies

# Return results
if ($testResults -notcontains $false) {
    Write-Host "All sample policy validation tests passed" -ForegroundColor Green
    return $true
} else {
    Write-Host "Some sample policy validation tests failed" -ForegroundColor Red
    return $false
}