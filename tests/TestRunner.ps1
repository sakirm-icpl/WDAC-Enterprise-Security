# TestRunner.ps1
# Main test runner for WDAC Toolkit testing framework

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("All", "Unit", "Integration", "Validation")]
    [string]$TestType = "All",
    
    [Parameter(Mandatory=$false)]
    [string]$TestPath = $PSScriptRoot,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

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

function Invoke-TestSuite {
    param(
        [string]$SuitePath,
        [string]$SuiteName
    )
    
    Write-Log "Running $SuiteName tests..." "INFO"
    
    # Get all test files in the suite
    $testFiles = Get-ChildItem -Path $SuitePath -Filter "test-*.ps1" -File -Recurse
    
    if ($testFiles.Count -eq 0) {
        Write-Log "No test files found in $SuitePath" "WARN"
        return @{ Passed = 0; Failed = 0; Total = 0 }
    }
    
    Write-Log "Found $($testFiles.Count) test files" "INFO"
    
    $passed = 0
    $failed = 0
    $total = 0
    
    foreach ($testFile in $testFiles) {
        $total++
        Write-Log "Running test: $($testFile.Name)" "INFO"
        
        try {
            # Execute the test file
            $result = & $testFile.FullName -TestRoot $TestPath
            
            if ($result -eq $true) {
                $passed++
                Write-Log "PASS: $($testFile.Name)" "SUCCESS"
            } else {
                $failed++
                Write-Log "FAIL: $($testFile.Name)" "ERROR"
            }
        } catch {
            $failed++
            Write-Log "ERROR: $($testFile.Name) - $($_.Exception.Message)" "ERROR"
        }
    }
    
    return @{ Passed = $passed; Failed = $failed; Total = $total }
}

Write-Log "Starting WDAC Toolkit Test Runner" "INFO"
Write-Log "Test Type: $TestType" "INFO"
Write-Log "Test Path: $TestPath" "INFO"

# Initialize results
$totalPassed = 0
$totalFailed = 0
$totalTests = 0

# Run tests based on type
switch ($TestType) {
    "All" {
        # Run all test suites
        $suiteResults = @()
        
        # Unit tests
        if (Test-Path "$TestPath\unit") {
            $result = Invoke-TestSuite -SuitePath "$TestPath\unit" -SuiteName "Unit"
            $suiteResults += $result
        }
        
        # Integration tests
        if (Test-Path "$TestPath\integration") {
            $result = Invoke-TestSuite -SuitePath "$TestPath\integration" -SuiteName "Integration"
            $suiteResults += $result
        }
        
        # Validation tests
        if (Test-Path "$TestPath\validation") {
            $result = Invoke-TestSuite -SuitePath "$TestPath\validation" -SuiteName "Validation"
            $suiteResults += $result
        }
        
        # Aggregate results
        foreach ($result in $suiteResults) {
            $totalPassed += $result.Passed
            $totalFailed += $result.Failed
            $totalTests += $result.Total
        }
    }
    
    "Unit" {
        if (Test-Path "$TestPath\unit") {
            $result = Invoke-TestSuite -SuitePath "$TestPath\unit" -SuiteName "Unit"
            $totalPassed = $result.Passed
            $totalFailed = $result.Failed
            $totalTests = $result.Total
        } else {
            Write-Log "Unit test directory not found" "WARN"
        }
    }
    
    "Integration" {
        if (Test-Path "$TestPath\integration") {
            $result = Invoke-TestSuite -SuitePath "$TestPath\integration" -SuiteName "Integration"
            $totalPassed = $result.Passed
            $totalFailed = $result.Failed
            $totalTests = $result.Total
        } else {
            Write-Log "Integration test directory not found" "WARN"
        }
    }
    
    "Validation" {
        if (Test-Path "$TestPath\validation") {
            $result = Invoke-TestSuite -SuitePath "$TestPath\validation" -SuiteName "Validation"
            $totalPassed = $result.Passed
            $totalFailed = $result.Failed
            $totalTests = $result.Total
        } else {
            Write-Log "Validation test directory not found" "WARN"
        }
    }
}

# Display results
Write-Log "===== TEST RESULTS =====" "INFO"
Write-Log "Total Tests: $totalTests" "INFO"
Write-Log "Passed: $totalPassed" "SUCCESS"
Write-Log "Failed: $totalFailed" $(if ($totalFailed -gt 0) { "ERROR" } else { "INFO" })
Write-Log "========================" "INFO"

# Exit with appropriate code
if ($totalFailed -gt 0) {
    Write-Log "Some tests failed. Exiting with code 1." "ERROR"
    exit 1
} elseif ($totalTests -eq 0) {
    Write-Log "No tests were run. Exiting with code 2." "WARN"
    exit 2
} else {
    Write-Log "All tests passed. Exiting with code 0." "SUCCESS"
    exit 0
}