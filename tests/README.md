# WDAC Toolkit Testing Framework

This directory contains the testing framework for the WDAC Toolkit, including unit tests, integration tests, and validation suites.

## Testing Structure

```
tests/
├── unit/                       # Unit tests for individual functions
│   ├── test-cli-tools.ps1      # Tests for CLI tools
│   ├── test-policy-validation.ps1 # Tests for policy validation functions
│   └── test-utilities.ps1      # Tests for utility functions
├── integration/                # Integration tests for complete workflows
│   ├── test-policy-generation.ps1 # Tests for policy generation workflows
│   ├── test-policy-deployment.ps1 # Tests for policy deployment workflows
│   └── test-conversion-tools.ps1 # Tests for conversion tools
├── validation/                 # Policy validation test suites
│   ├── test-sample-policies.ps1 # Tests for sample policies
│   ├── test-template-policies.ps1 # Tests for template policies
│   └── test-edge-cases.ps1     # Tests for edge cases and error conditions
├── fixtures/                   # Test data and sample files
│   ├── policies/               # Sample policy files for testing
│   ├── applocker/             # Sample AppLocker policies for conversion testing
│   └── config/                # Configuration files for testing
├── TestRunner.ps1              # Main test runner script
└── README.md                   # This file
```

## Running Tests

### Prerequisites

- PowerShell 5.1 or later
- Windows 10/11 with WDAC features enabled
- Administrator privileges for some tests

### Running All Tests

```powershell
# From the repository root
.\tests\TestRunner.ps1
```

### Running Specific Test Suites

```powershell
# Run unit tests only
.\tests\TestRunner.ps1 -TestType Unit

# Run integration tests only
.\tests\TestRunner.ps1 -TestType Integration

# Run validation tests only
.\tests\TestRunner.ps1 -TestType Validation
```

### Running Individual Test Files

```powershell
# Run a specific test file
.\tests\unit\test-cli-tools.ps1
```

## Test Categories

### Unit Tests

Unit tests verify the functionality of individual functions and components in isolation. These tests should:

- Run quickly (typically under 1 second per test)
- Not require external dependencies
- Not modify system state
- Cover edge cases and error conditions
- Have clear assertions and failure messages

### Integration Tests

Integration tests verify that multiple components work together correctly. These tests may:

- Take longer to run (several seconds to minutes)
- Require temporary file creation
- Simulate real-world usage scenarios
- Test complete workflows from start to finish
- Validate interactions between different tools

### Validation Tests

Validation tests ensure that policies and tools meet quality standards. These tests:

- Verify policy syntax and structure
- Check for common configuration errors
- Validate against best practices
- Ensure compatibility with different Windows versions
- Test policy effectiveness in simulated environments

## Writing Tests

### Test Structure

Tests should follow this structure:

```powershell
# test-example.ps1
param(
    [string]$TestRoot = $PSScriptRoot
)

# Import the module or script being tested
Import-Module "$TestRoot\..\tools\cli\some-tool.ps1"

# Define test functions
function Test-SomeFunction {
    # Arrange
    $input = "test input"
    $expected = "expected output"
    
    # Act
    $result = Some-Function -Input $input
    
    # Assert
    if ($result -eq $expected) {
        Write-Host "PASS: Some-Function works correctly" -ForegroundColor Green
        return $true
    } else {
        Write-Host "FAIL: Some-Function returned '$result', expected '$expected'" -ForegroundColor Red
        return $false
    }
}

# Run tests
$testResults = @()
$testResults += Test-SomeFunction

# Return results
return ($testResults -notcontains $false)
```

### Best Practices

1. **Use Descriptive Names**: Test function names should clearly indicate what is being tested
2. **Follow AAA Pattern**: Arrange, Act, Assert
3. **Test One Thing**: Each test should verify a single behavior
4. **Use Clear Assertions**: Failure messages should explain what went wrong
5. **Clean Up Resources**: Remove temporary files and reset state after tests
6. **Handle Errors Gracefully**: Tests should fail gracefully and provide useful information

## Continuous Integration

The testing framework is designed to work with continuous integration systems. The TestRunner.ps1 script returns appropriate exit codes:

- Exit code 0: All tests passed
- Exit code 1: One or more tests failed
- Exit code 2: Test framework error

## Contributing Tests

To contribute tests to the WDAC Toolkit:

1. Fork the repository
2. Create a new branch for your tests
3. Add your test files to the appropriate directory
4. Ensure your tests follow the established patterns
5. Run all tests to verify they pass
6. Submit a pull request with your changes

## Test Data

Sample policies and test data are provided in the `fixtures/` directory. These files are used by various tests and should not be modified without updating the corresponding tests.