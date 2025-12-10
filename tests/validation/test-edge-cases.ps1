# test-edge-cases.ps1
# Tests for edge cases and error conditions

param(
    [string]$TestRoot = $PSScriptRoot
)

# Import required modules
try {
    Import-Module ConfigCI -ErrorAction Stop
} catch {
    Write-Host "SKIP: ConfigCI module not available. Skipping edge case tests." -ForegroundColor Yellow
    return $true
}

# Test results array
$testResults = @()

function Test-InvalidPolicyHandling {
    Write-Host "Testing invalid policy handling..." -ForegroundColor Cyan
    
    # Create temporary directory for test files
    $tempDir = "$env:TEMP\WDAC_Test_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    try {
        # Test 1: Invalid XML
        $invalidXmlPath = "$tempDir\invalid.xml"
        Set-Content -Path $invalidXmlPath -Value "<?xml version='1.0'?><Policy><Invalid>"
        
        # This should fail gracefully
        try {
            [xml]$policy = Get-Content $invalidXmlPath -ErrorAction Stop
            Write-Host "FAIL: Invalid XML was parsed successfully" -ForegroundColor Red
            $result1 = $false
        } catch {
            Write-Host "PASS: Invalid XML correctly rejected" -ForegroundColor Green
            $result1 = $true
        }
        
        # Test 2: Missing required elements
        $missingElementsPath = "$tempDir\missing-elements.xml"
        Set-Content -Path $missingElementsPath -Value @"
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy">
</Policy>
"@
        
        try {
            [xml]$policy = Get-Content $missingElementsPath -ErrorAction Stop
            if (-not $policy.Policy.VersionEx) {
                Write-Host "PASS: Missing VersionEx correctly detected" -ForegroundColor Green
                $result2 = $true
            } else {
                Write-Host "FAIL: Missing VersionEx not detected" -ForegroundColor Red
                $result2 = $false
            }
        } catch {
            Write-Host "PASS: Missing elements correctly caused error" -ForegroundColor Green
            $result2 = $true
        }
        
        # Test 3: Invalid PolicyType
        $invalidPolicyTypePath = "$tempDir\invalid-policy-type.xml"
        Set-Content -Path $invalidPolicyTypePath -Value @"
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Invalid Policy">
  <VersionEx>1.0.0.0</VersionEx>
</Policy>
"@
        
        try {
            [xml]$policy = Get-Content $invalidPolicyTypePath -ErrorAction Stop
            if ($policy.Policy.PolicyType -ne "Invalid Policy") {
                Write-Host "FAIL: PolicyType not parsed correctly" -ForegroundColor Red
                $result3 = $false
            } else {
                Write-Host "PASS: Invalid PolicyType accepted (warning expected)" -ForegroundColor Green
                $result3 = $true
            }
        } catch {
            Write-Host "FAIL: Invalid PolicyType caused unexpected error" -ForegroundColor Red
            $result3 = $false
        }
        
        return ($result1 -and $result2 -and $result3)
    }
    finally {
        # Clean up temporary files
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Test-EmptyAndWhitespaceHandling {
    Write-Host "Testing empty and whitespace handling..." -ForegroundColor Cyan
    
    # Create temporary directory for test files
    $tempDir = "$env:TEMP\WDAC_Test_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    try {
        # Test 1: Empty file
        $emptyPath = "$tempDir\empty.xml"
        Set-Content -Path $emptyPath -Value ""
        
        try {
            [xml]$policy = Get-Content $emptyPath -ErrorAction Stop
            Write-Host "FAIL: Empty file was parsed successfully" -ForegroundColor Red
            $result1 = $false
        } catch {
            Write-Host "PASS: Empty file correctly rejected" -ForegroundColor Green
            $result1 = $true
        }
        
        # Test 2: Whitespace only
        $whitespacePath = "$tempDir\whitespace.xml"
        Set-Content -Path $whitespacePath -Value "   `t`n   "
        
        try {
            [xml]$policy = Get-Content $whitespacePath -ErrorAction Stop
            Write-Host "FAIL: Whitespace-only file was parsed successfully" -ForegroundColor Red
            $result2 = $false
        } catch {
            Write-Host "PASS: Whitespace-only file correctly rejected" -ForegroundColor Green
            $result2 = $true
        }
        
        return ($result1 -and $result2)
    }
    finally {
        # Clean up temporary files
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Test-UnicodeAndSpecialCharacters {
    Write-Host "Testing Unicode and special characters..." -ForegroundColor Cyan
    
    # Create temporary directory for test files
    $tempDir = "$env:TEMP\WDAC_Test_$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    try {
        # Test 1: Unicode characters in policy
        $unicodePath = "$tempDir\unicode.xml"
        Set-Content -Path $unicodePath -Value @"
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>{12345678-1234-1234-1234-123456789012}</PlatformID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
  </Rules>
  <!-- Unicode test: café, naïve, résumé -->
  <FileRules>
    <Allow ID="ID_ALLOW_UNICODE" FriendlyName="Unicode Test Café" FileName="*" FilePath="%PROGRAMFILES%\TestApp\*" />
  </FileRules>
</Policy>
"@
        
        try {
            [xml]$policy = Get-Content $unicodePath -ErrorAction Stop
            if ($policy.Policy.FileRules.Allow.FriendlyName -eq "Unicode Test Café") {
                Write-Host "PASS: Unicode characters handled correctly" -ForegroundColor Green
                $result1 = $true
            } else {
                Write-Host "FAIL: Unicode characters not handled correctly" -ForegroundColor Red
                $result1 = $false
            }
        } catch {
            Write-Host "FAIL: Unicode characters caused parsing error: $($_.Exception.Message)" -ForegroundColor Red
            $result1 = $false
        }
        
        return $result1
    }
    finally {
        # Clean up temporary files
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# Run tests
Write-Host "Running edge case validation tests..." -ForegroundColor Cyan

$testResults += Test-InvalidPolicyHandling
$testResults += Test-EmptyAndWhitespaceHandling
$testResults += Test-UnicodeAndSpecialCharacters

# Return results
if ($testResults -notcontains $false) {
    Write-Host "All edge case validation tests passed" -ForegroundColor Green
    return $true
} else {
    Write-Host "Some edge case validation tests failed" -ForegroundColor Red
    return $false
}