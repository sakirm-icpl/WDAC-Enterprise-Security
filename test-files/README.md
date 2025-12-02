# Test Files Directory

This directory contains test files and validation procedures for WDAC policies.

## Directory Structure

```
test-files/
├── binaries/                   # Test binary files organized by category
│   ├── microsoft/             # Microsoft-signed applications
│   │   ├── signed/           # Properly signed Microsoft applications
│   │   └── unsigned/         # Unsigned Microsoft test applications
│   ├── third-party/          # Third-party applications
│   │   ├── signed/           # Properly signed third-party applications
│   │   └── unsigned/         # Unsigned third-party applications
│   └── custom/               # Custom test applications
│       ├── trusted/          # Applications that should be allowed
│       └── malicious/        # Applications that should be blocked
├── validation/               # Validation scripts and tools
└── Test_Plan.md             # Comprehensive test plan
```

## Usage

1. Review the [Test Plan](Test_Plan.md) for detailed testing procedures
2. Use the binaries in this directory to test policy effectiveness
3. Run validation scripts to analyze policy behavior
4. Document test results and refine policies as needed

## Important Notes

- These test files are for validation purposes only
- Do not use malicious binaries in production environments
- Always test policies in audit mode before enforcing
- Keep backups of working policies before testing
- Follow your organization's security policies when handling test files

## Adding Test Files

When adding new test files:

1. Place them in the appropriate subdirectory based on their characteristics
2. Document the file's purpose and expected behavior
3. Update the test plan if new test scenarios are needed
4. Ensure files are properly licensed for testing use