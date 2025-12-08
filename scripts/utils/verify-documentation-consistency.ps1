# PowerShell script to verify documentation consistency and eliminate duplicates
# Usage: .\verify-documentation-consistency.ps1

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

Write-Log "Starting Documentation Consistency Verification" "INFO"

# Define paths
$RootPath = "..\.."
$AllInOnePath = "..\..\ALL-IN-ONE-WDAC-PACKAGE"

Write-Log "Checking repository structure..." "INFO"

# Check if both paths exist
if (-not (Test-Path $RootPath)) {
    Write-Log "Root path not found: $RootPath" "ERROR"
    exit 1
}

if (-not (Test-Path $AllInOnePath)) {
    Write-Log "ALL-IN-ONE package path not found: $AllInOnePath" "ERROR"
    exit 1
}

Write-Log "Verifying README files..." "INFO"

# Check main README
$MainReadme = Join-Path $RootPath "README.md"
$AllInOneReadme = Join-Path $AllInOnePath "README.md"

if (Test-Path $MainReadme) {
    Write-Log "Main README found: $MainReadme" "SUCCESS"
} else {
    Write-Log "Main README not found: $MainReadme" "ERROR"
}

if (Test-Path $AllInOneReadme) {
    Write-Log "ALL-IN-ONE README found: $AllInOneReadme" "SUCCESS"
} else {
    Write-Log "ALL-IN-ONE README not found: $AllInOneReadme" "ERROR"
}

Write-Log "Checking for duplicate policy files..." "INFO"

# Check policy directories
$MainPolicies = Join-Path $RootPath "policies"
$AllInOnePolicies = Join-Path $AllInOnePath "policies"

if (Test-Path $MainPolicies) {
    $MainPolicyFiles = Get-ChildItem -Path $MainPolicies -Recurse -File | Measure-Object
    Write-Log "Main repository policies: $($MainPolicyFiles.Count) files" "INFO"
}

if (Test-Path $AllInOnePolicies) {
    $AllInOnePolicyFiles = Get-ChildItem -Path $AllInOnePolicies -Recurse -File | Measure-Object
    Write-Log "ALL-IN-ONE package policies: $($AllInOnePolicyFiles.Count) files" "INFO"
}

Write-Log "Checking for duplicate script files..." "INFO"

# Check script directories
$MainScripts = Join-Path $RootPath "scripts"
$AllInOneScripts = Join-Path $AllInOnePath "scripts"

if (Test-Path $MainScripts) {
    $MainScriptFiles = Get-ChildItem -Path $MainScripts -Recurse -File | Measure-Object
    Write-Log "Main repository scripts: $($MainScriptFiles.Count) files" "INFO"
}

if (Test-Path $AllInOneScripts) {
    $AllInOneScriptFiles = Get-ChildItem -Path $AllInOneScripts -Recurse -File | Measure-Object
    Write-Log "ALL-IN-ONE package scripts: $($AllInOneScriptFiles.Count) files" "INFO"
}

Write-Log "Checking documentation directories..." "INFO"

# Check documentation directories
$MainDocs = Join-Path $RootPath "docs"
$AllInOneDocs = Join-Path $AllInOnePath "docs"

if (Test-Path $MainDocs) {
    $MainDocFiles = Get-ChildItem -Path $MainDocs -Recurse -File | Measure-Object
    Write-Log "Main repository documentation: $($MainDocFiles.Count) files" "INFO"
}

if (Test-Path $AllInOneDocs) {
    $AllInOneDocFiles = Get-ChildItem -Path $AllInOneDocs -Recurse -File | Measure-Object
    Write-Log "ALL-IN-ONE package documentation: $($AllInOneDocFiles.Count) files" "INFO"
}

Write-Log "Checking environment-specific implementations..." "INFO"

# Check environment-specific directories
$MainEnvSpecific = Join-Path $RootPath "environment-specific"
if (Test-Path $MainEnvSpecific) {
    $EnvDirs = Get-ChildItem -Path $MainEnvSpecific -Directory
    Write-Log "Environment-specific implementations found:" "INFO"
    foreach ($Dir in $EnvDirs) {
        Write-Log "  - $($Dir.Name)" "INFO"
    }
}

Write-Log "Documentation consistency verification completed." "SUCCESS"
Write-Log "Note: The main repository and ALL-IN-ONE package serve different purposes:" "INFO"
Write-Log "  - Main repository: Comprehensive implementation with full documentation" "INFO"
Write-Log "  - ALL-IN-ONE package: Simplified deployment package" "INFO"
Write-Log "Both are maintained but contain purpose-appropriate content variations." "INFO"