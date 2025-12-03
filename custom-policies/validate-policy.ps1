# Validate-Policy.ps1
# Simple validation script for custom WDAC policy

Write-Host "Validating custom WDAC policy..." -ForegroundColor Yellow

# Load the policy
[xml]$policy = Get-Content "C:\WADC\WDAC-Enterprise-Security\custom-policies\custom-base-policy.xml"

# Check 1: Program Files allow rules
$programFilesRules = $policy.SiPolicy.FileRules.ChildNodes | Where-Object { 
    ($_.FriendlyName -like "*Program Files*" -or $_.ID -like "*ALLOW_PROGRAM_FILES*") -and $_.Name -eq "Allow"
}
if ($programFilesRules.Count -ge 2) {
    Write-Host "✅ Allows Program Files applications" -ForegroundColor Green
} else {
    Write-Host "❌ Missing Program Files allow rules" -ForegroundColor Red
}

# Check 2: Downloads folder deny rules
$downloadsRules = $policy.SiPolicy.FileRules.ChildNodes | Where-Object { 
    ($_.FriendlyName -like "*Downloads*" -or $_.ID -like "*DENY_DOWNLOADS*") -and $_.Name -eq "Deny"
}
if ($downloadsRules.Count -ge 1) {
    Write-Host "✅ Blocks Downloads folder content" -ForegroundColor Green
} else {
    Write-Host "❌ Missing Downloads folder deny rules" -ForegroundColor Red
}

# Check 3: OSSEC folder deny rules
$ossecRules = $policy.SiPolicy.FileRules.ChildNodes | Where-Object { 
    ($_.FriendlyName -like "*OSSEC*" -or $_.ID -like "*DENY_OSSEC*") -and $_.Name -eq "Deny"
}
if ($ossecRules.Count -ge 1) {
    Write-Host "✅ Blocks OSSEC agent folder content" -ForegroundColor Green
} else {
    Write-Host "❌ Missing OSSEC agent folder deny rules" -ForegroundColor Red
}

# Check 4: Audit mode
$auditMode = $policy.SiPolicy.Rules.Rule | Where-Object { $_.Option -eq "Enabled:Audit Mode" }
if ($auditMode) {
    Write-Host "✅ Policy is in Audit Mode" -ForegroundColor Green
} else {
    Write-Host "❌ Policy is not in Audit Mode" -ForegroundColor Red
}

# Check 5: Policy conversion
try {
    ConvertFrom-CIPolicy -XmlFilePath "C:\WADC\WDAC-Enterprise-Security\custom-policies\custom-base-policy.xml" -BinaryFilePath "$env:TEMP\test_policy.bin" -ErrorAction Stop
    Remove-Item "$env:TEMP\test_policy.bin" -ErrorAction SilentlyContinue
    Write-Host "✅ Policy converts to binary format" -ForegroundColor Green
} catch {
    Write-Host "❌ Policy conversion failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Validation complete!" -ForegroundColor Yellow