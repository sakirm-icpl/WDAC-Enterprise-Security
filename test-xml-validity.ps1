# Test WDAC Policy XML Validity

# Test Non-AD Base Policy
try {
    [xml]$basePolicy = Get-Content "environment-specific/non-ad/policies/non-ad-base-policy.xml"
    Write-Host "✅ Non-AD Base Policy XML is valid" -ForegroundColor Green
} catch {
    Write-Host "❌ Non-AD Base Policy XML is invalid: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Non-AD Department Policies
try {
    [xml]$financePolicy = Get-Content "environment-specific/non-ad/policies/department-supplemental-policies/finance-policy.xml"
    Write-Host "✅ Non-AD Finance Policy XML is valid" -ForegroundColor Green
} catch {
    Write-Host "❌ Non-AD Finance Policy XML is invalid: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    [xml]$hrPolicy = Get-Content "environment-specific/non-ad/policies/department-supplemental-policies/hr-policy.xml"
    Write-Host "✅ Non-AD HR Policy XML is valid" -ForegroundColor Green
} catch {
    Write-Host "❌ Non-AD HR Policy XML is invalid: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    [xml]$itPolicy = Get-Content "environment-specific/non-ad/policies/department-supplemental-policies/it-policy.xml"
    Write-Host "✅ Non-AD IT Policy XML is valid" -ForegroundColor Green
} catch {
    Write-Host "❌ Non-AD IT Policy XML is invalid: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Non-AD Exception Policy
try {
    [xml]$exceptionPolicy = Get-Content "environment-specific/non-ad/policies/exception-policies/emergency-access-policy.xml"
    Write-Host "✅ Non-AD Exception Policy XML is valid" -ForegroundColor Green
} catch {
    Write-Host "❌ Non-AD Exception Policy XML is invalid: $($_.Exception.Message)" -ForegroundColor Red
}

# Test AD Base Policy
try {
    [xml]$adBasePolicy = Get-Content "environment-specific/active-directory/policies/enterprise-base-policy.xml"
    Write-Host "✅ AD Base Policy XML is valid" -ForegroundColor Green
} catch {
    Write-Host "❌ AD Base Policy XML is invalid: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "XML validation complete." -ForegroundColor Cyan