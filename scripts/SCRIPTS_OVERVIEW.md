# PowerShell Scripts Overview

## Core Deployment Scripts

### 1. deploy-unified-policy.ps1
**Purpose**: Unified deployment script for all environments
**Location**: `scripts/deploy-unified-policy.ps1`

#### Usage:
```powershell
# Non-AD deployment
.\deploy-unified-policy.ps1 -Environment "NonAD" -Mode "Audit"

# AD deployment
.\deploy-unified-policy.ps1 -Environment "AD" -Mode "Enforce" -TargetOU "OU=Workstations,DC=company,DC=com"

# Server deployment
.\deploy-unified-policy.ps1 -Environment "Server" -Mode "Enforce"
```

#### Parameters:
- `-Environment`: "NonAD", "AD", or "Server"
- `-Mode`: "Audit" or "Enforce"
- `-TargetOU`: AD Organizational Unit (AD only)
- `-PolicyPath`: Custom policy path
- `-LogPath`: Custom log file path
- `-Force`: Skip confirmation prompts

### 2. prerequisites-check.ps1
**Purpose**: Validate system requirements before deployment
**Location**: `scripts/prerequisites-check.ps1`

#### Usage:
```powershell
# Basic check
.\prerequisites-check.ps1

# Detailed output
.\prerequisites-check.ps1 -Detailed
```

#### Checks Performed:
- Windows version compatibility
- PowerShell version
- Administrator privileges
- WDAC module availability
- Disk space
- Execution policy
- Domain status
- Secure Boot status
- TPM status
- Windows Defender status
- Existing WDAC policy
- Event Log service
- Code Integrity log
- Network connectivity

## Policy Management Scripts

### 1. convert_to_audit_mode.ps1
**Purpose**: Convert policy to audit mode for testing
**Location**: `scripts/convert_to_audit_mode.ps1`

#### Usage:
```powershell
# Convert default policy
.\convert_to_audit_mode.ps1

# Convert specific policy
.\convert_to_audit_mode.ps1 -PolicyPath "custom-policy.xml" -OutputPath "audit-policy.xml"
```

### 2. convert_to_enforce_mode.ps1
**Purpose**: Convert policy to enforce mode for production
**Location**: `scripts/convert_to_enforce_mode.ps1`

#### Usage:
```powershell
# Convert default policy
.\convert_to_enforce_mode.ps1

# Convert specific policy
.\convert_to_enforce_mode.ps1 -PolicyPath "audit-policy.xml" -OutputPath "enforce-policy.xml"
```

### 3. merge_policies.ps1
**Purpose**: Combine multiple policies into a single policy
**Location**: `scripts/merge_policies.ps1`

#### Usage:
```powershell
# Merge default policies
.\merge_policies.ps1

# Merge custom policies
.\merge_policies.ps1 -BasePolicy "base.xml" -SupplementalPolicy "supplemental.xml" -OutputPath "merged.xml"
```

### 4. rollback_policy.ps1
**Purpose**: Revert to previous policy version
**Location**: `scripts/rollback_policy.ps1`

#### Usage:
```powershell
# Rollback to previous policy
.\rollback_policy.ps1
```

## Utility Scripts

### 1. test-xml-validity.ps1
**Purpose**: Validate XML policy files
**Location**: `test-xml-validity.ps1` (root directory)

#### Usage:
```powershell
# Validate all policies
.\test-xml-validity.ps1

# Validate specific policy
.\test-xml-validity.ps1 -PolicyPath "custom-policy.xml"
```

### 2. test-deployment-readiness.ps1
**Purpose**: Comprehensive deployment readiness test
**Location**: `test-deployment-readiness.ps1` (root directory)

#### Usage:
```powershell
# Run basic tests
.\test-deployment-readiness.ps1

# Detailed output
.\test-deployment-readiness.ps1 -DetailedOutput
```

## Environment-Specific Scripts

### Non-AD Environment
**Location**: `environment-specific/non-ad/scripts/`

- `deploy-non-ad-policy.ps1` - Deploy policies to non-AD systems
- `update-non-ad-policy.ps1` - Update existing non-AD policies
- `monitor-non-ad-systems.ps1` - Monitor non-AD systems

### Active Directory Environment
**Location**: `environment-specific/active-directory/scripts/`

- `deploy-ad-policy.ps1` - Deploy policies via Group Policy
- `update-ad-policy.ps1` - Update existing AD policies
- `monitor-ad-systems.ps1` - Monitor AD systems

## Best Practices

1. **Always run as Administrator** for deployment scripts
2. **Test with prerequisites-check.ps1** first
3. **Validate policies with test-xml-validity.ps1**
4. **Deploy in Audit Mode initially** for testing
5. **Use rollback_policy.ps1** if issues occur
6. **Check logs** in `%TEMP%` directory for troubleshooting

## Troubleshooting

### Common Issues:

**"Access Denied" Errors**
```powershell
# Run PowerShell as Administrator
Start-Process powershell -Verb RunAs
```

**Policy Not Taking Effect**
```powershell
# Check deployed policies
Get-CIPolicy

# Restart system
Restart-Computer
```

**XML Validation Errors**
```powershell
# Validate policy structure
.\test-xml-validity.ps1
```