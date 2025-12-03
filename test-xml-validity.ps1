# Test-XMLValidity.ps1
# Tests the validity of WDAC policy XML files

$ErrorActionPreference = "Stop"

Write-Host "Testing WDAC Policy XML Files..." -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Define policy files to test
$PolicyFiles = @(
    ".\policies\BasePolicy.xml",
    ".\policies\DenyPolicy.xml",
    ".\policies\MergedPolicy.xml",
    ".\policies\TrustedApp.xml",
    ".\environment-specific\non-ad\policies\non-ad-base-policy.xml",
    ".\environment-specific\active-directory\policies\enterprise-base-policy.xml"
)

$AllValid = $true

foreach ($PolicyFile in $PolicyFiles) {
    Write-Host "`nTesting: $PolicyFile" -ForegroundColor Yellow
    
    if (-not (Test-Path $PolicyFile)) {
        Write-Host "  ERROR: File not found!" -ForegroundColor Red
        $AllValid = $false
        continue
    }
    
    try {
        # Test XML parsing
        [xml]$XmlContent = Get-Content $PolicyFile -ErrorAction Stop
        Write-Host "  [OK] XML is well-formed" -ForegroundColor Green
        
        # Validate root element (should be SiPolicy, not Policy)
        if ($XmlContent.DocumentElement.LocalName -ne "SiPolicy") {
            Write-Host "  ERROR: Root element must be 'SiPolicy', found '$($XmlContent.DocumentElement.LocalName)'" -ForegroundColor Red
            $AllValid = $false
            continue
        }
        Write-Host "  [OK] Root element is 'SiPolicy'" -ForegroundColor Green
        
        # Check for required elements
        $RequiredElements = @("VersionEx", "PlatformID", "Rules", "SigningScenarios", "HvciOptions")
        foreach ($Element in $RequiredElements) {
            if ($null -eq $XmlContent.SiPolicy.$Element) {
                Write-Host "  ERROR: Missing required element: $Element" -ForegroundColor Red
                $AllValid = $false
            } else {
                Write-Host "  [OK] Found required element: $Element" -ForegroundColor Green
            }
        }
        
        # Check version format (should be 10.0.0.0 or higher)
        $version = $XmlContent.SiPolicy.VersionEx
        if ($version -and $version -match '^\d+\.\d+\.\d+\.\d+$') {
            Write-Host "  [OK] Version format valid: $version" -ForegroundColor Green
        } else {
            Write-Host "  WARNING: Version format may be incorrect: $version" -ForegroundColor Yellow
        }
        
        # Check if supplemental policy has PolicyTypeID
        if ($PolicyFile -match "(Deny|Trusted|Supplemental)") {
            if ($null -eq $XmlContent.SiPolicy.PolicyTypeID) {
                Write-Host "  WARNING: Supplemental policy should have PolicyTypeID" -ForegroundColor Yellow
            } else {
                Write-Host "  [OK] PolicyTypeID present for supplemental policy" -ForegroundColor Green
            }
        }
        
        Write-Host "  [OK] Policy structure validated" -ForegroundColor Green
        
    } catch {
        Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $AllValid = $false
    }
}

Write-Host "`n=================================" -ForegroundColor Cyan
if ($AllValid) {
    Write-Host "All XML files are valid!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Some XML files have errors!" -ForegroundColor Red
    exit 1
}