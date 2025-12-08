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