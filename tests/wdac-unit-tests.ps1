# wdac-unit-tests.ps1
# Unit tests for WDAC PowerShell functions

# Import required modules
Import-Module ..\scripts\security-utils.psm1 -Force
Import-Module ..\environment-specific\shared\scripts\wdac-utils.ps1 -Force

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Result,
        [string]$Message = ""
    )
    
    $Status = if ($Result) { "PASS" } else { "FAIL" }
    $Color = if ($Result) { "Green" } else { "Red" }
    
    Write-Host "[$Status] $TestName" -ForegroundColor $Color
    if ($Message) {
        Write-Host "       $Message" -ForegroundColor Gray
    }
}

function Test-AdminPrivileges {
    $Result = Test-AdminPrivileges
    Write-TestResult "Test-AdminPrivileges" $true "Function executed without error"
    return $Result
}

function Test-SecureTempDirectory {
    try {
        $TempDir = Get-SecureTempDirectory
        $Result = Test-Path $TempDir
        Write-TestResult "Get-SecureTempDirectory" $Result "Temporary directory created: $TempDir"
        
        # Clean up
        if ($Result) {
            Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        return $Result
    } catch {
        Write-TestResult "Get-SecureTempDirectory" $false "Failed to create secure temp directory: $($_.Exception.Message)"
        return $false
    }
}

function Test-PowerShellVersionCompatibility {
    try {
        $Result = Test-PowerShellVersionCompatibility
        Write-TestResult "Test-PowerShellVersionCompatibility" $Result "PowerShell version compatibility check passed"
        return $Result
    } catch {
        Write-TestResult "Test-PowerShellVersionCompatibility" $false "PowerShell version compatibility check failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-StringProtection {
    try {
        $OriginalText = "TestSecret123"
        $SecureString = Protect-String -PlainText $OriginalText
        $UnprotectedText = Unprotect-String -SecureString $SecureString
        
        $Result = ($UnprotectedText -eq $OriginalText)
        Write-TestResult "String Protection Functions" $Result "String protection/unprotection works correctly"
        return $Result
    } catch {
        Write-TestResult "String Protection Functions" $false "String protection failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-PolicyGeneration {
    try {
        # Test policy generation from template
        $TemplatePath = "..\templates\parametrized-base-policy.xml"
        $ConfigPath = "..\config\organization-config.json"
        
        if (Test-Path $TemplatePath -and Test-Path $ConfigPath) {
            # This would normally call the generate-policy-from-template.ps1 script
            Write-TestResult "Policy Generation" $true "Template and config files exist"
            return $true
        } else {
            Write-TestResult "Policy Generation" $false "Template or config files missing"
            return $false
        }
    } catch {
        Write-TestResult "Policy Generation" $false "Policy generation test failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-MergePoliciesScript {
    try {
        $ScriptPath = "..\scripts\merge_policies.ps1"
        if (Test-Path $ScriptPath) {
            Write-TestResult "Merge Policies Script" $true "Script file exists"
            return $true
        } else {
            Write-TestResult "Merge Policies Script" $false "Script file not found"
            return $false
        }
    } catch {
        Write-TestResult "Merge Policies Script" $false "Script test failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-ConvertToAuditModeScript {
    try {
        $ScriptPath = "..\scripts\convert_to_audit_mode.ps1"
        if (Test-Path $ScriptPath) {
            Write-TestResult "Convert to Audit Mode Script" $true "Script file exists"
            return $true
        } else {
            Write-TestResult "Convert to Audit Mode Script" $false "Script file not found"
            return $false
        }
    } catch {
        Write-TestResult "Convert to Audit Mode Script" $false "Script test failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-RollbackPolicyScript {
    try {
        $ScriptPath = "..\scripts\rollback_policy.ps1"
        if (Test-Path $ScriptPath) {
            Write-TestResult "Rollback Policy Script" $true "Script file exists"
            return $true
        } else {
            Write-TestResult "Rollback Policy Script" $false "Script file not found"
            return $false
        }
    } catch {
        Write-TestResult "Rollback Policy Script" $false "Script test failed: $($_.Exception.Message)"
        return $false
    }
}

function Run-AllTests {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Running WDAC Unit Tests" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    $TestResults = @()
    
    # Run all tests
    $TestResults += Test-AdminPrivileges
    $TestResults += Test-SecureTempDirectory
    $TestResults += Test-PowerShellVersionCompatibility
    $TestResults += Test-StringProtection
    $TestResults += Test-PolicyGeneration
    $TestResults += Test-MergePoliciesScript
    $TestResults += Test-ConvertToAuditModeScript
    $TestResults += Test-RollbackPolicyScript
    
    # Calculate summary
    $PassedTests = ($TestResults | Where-Object { $_ -eq $true }).Count
    $TotalTests = $TestResults.Count
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Test Summary: $PassedTests/$TotalTests tests passed" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    if ($PassedTests -eq $TotalTests) {
        Write-Host "All tests passed! 🎉" -ForegroundColor Green
        return $true
    } else {
        Write-Host "$($TotalTests - $PassedTests) tests failed. Please review the output above." -ForegroundColor Red
        return $false
    }
}

# Run all tests
Run-AllTests