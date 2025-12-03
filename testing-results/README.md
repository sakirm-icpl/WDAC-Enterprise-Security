# Testing Results Directory

This directory is intended for storing test results and findings when testing WDAC policies.

## Usage

Create a new file for each test environment with the following naming convention:
- `windows10-nonad-[date].md` for non-AD Windows 10 workstations
- `windows10-ad-[date].md` for AD Windows 10 workstations
- `windows-server-nonad-[date].md` for non-AD Windows Servers
- `windows-server-ad-[date].md` for AD Windows Servers

## Template

Use the following template for your test results:

```markdown
# Test Results: [Environment Type] - [Date]

## Environment Details
- OS Version:
- WDAC Version:
- Test Applications Used:

## Test Results
### Microsoft-signed Applications
- Calculator: ✅ Pass / ❌ Fail
- Notepad: ✅ Pass / ❌ Fail
- Command Prompt: ✅ Pass / ❌ Fail

### Third-party Signed Applications
- Chrome: ✅ Pass / ❌ Fail
- Adobe Reader: ✅ Pass / ❌ Fail

### Unsigned Applications
- TestApp1: ✅ Blocked / ❌ Not Blocked
- TestApp2: ✅ Blocked / ❌ Not Blocked

## Issues Encountered
- [List any issues or unexpected behavior]

## Performance Observations
- [Note any performance impacts]

## Screenshots
- [List any screenshots captured during testing]

## Recommendations
- [Any recommendations for policy adjustments]
```