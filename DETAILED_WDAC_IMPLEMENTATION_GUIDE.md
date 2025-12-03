# Complete WDAC Policy Implementation Guide for Your Machine

This guide provides detailed steps to implement Windows Defender Application Control (WDAC) policies on your Windows machine, covering everything from policy design to deployment and testing.

## Table of Contents
1. [Understanding WDAC Policies](#understanding-wdac-policies)
2. [Policy Design Principles](#policy-design-principles)
3. [Step-by-Step Implementation](#step-by-step-implementation)
4. [Folder Restriction Policies](#folder-restriction-policies)
5. [Testing and Validation](#testing-and-validation)
6. [Deployment and Management](#deployment-and-management)

## Understanding WDAC Policies

WDAC policies control which applications can run on Windows systems. The policies consist of:

1. **Base Policies** - Define fundamental rules and trusted publishers
2. **Supplemental Policies** - Extend base policies with additional allowances or restrictions
3. **Exception Policies** - Handle special cases or temporary exceptions

## Policy Design Principles

### 1. Trust Model
- Allow signed applications from trusted publishers (Microsoft, known vendors)
- Block unsigned applications by default
- Permit specific folders for trusted applications
- Deny execution from high-risk locations (Downloads, Temp folders)

### 2. Rule Types
- **Publisher Rules** - Based on certificate information
- **Path Rules** - Based on file system paths
- **Hash Rules** - Based on file cryptographic hashes
- **File Attribute Rules** - Based on file metadata

## Step-by-Step Implementation

### Step 1: Environment Assessment
1. Identify critical applications that must run
2. Determine trusted publishers and software sources
3. Catalog applications by folder locations
4. Identify high-risk folders that should be restricted

### Step 2: Base Policy Creation
Create a base policy that:
- Allows Windows components and Microsoft-signed applications
- Permits applications in trusted folders (%PROGRAMFILES%, %WINDIR%)
- Blocks execution from user profile folders
- Enables audit mode initially for testing

### Step 3: Supplemental Policy Creation
Create supplemental policies for:
- Department-specific applications
- Third-party software with valid signatures
- Legacy applications that require special handling

### Step 4: Exception Policy Creation
Create exception policies for:
- Temporary access during migrations
- Emergency troubleshooting scenarios
- Vendor software installations

## Folder Restriction Policies

### High-Risk Folder Restrictions
1. **Downloads Folder** - Block all executable files
2. **Temp Folders** - Block all executable files
3. **Public Folders** - Block all executable files
4. **Removable Drives** - Block all executable files (optional)

### Trusted Folder Allowances
1. **Program Files** - Allow all applications
2. **Windows Folder** - Allow system components
3. **Department-Specific Folders** - Allow department applications

## Testing and Validation

### Phase 1: Audit Mode Testing
1. Deploy base policy in audit mode
2. Monitor Code Integrity events
3. Identify blocked applications
4. Create supplemental policies for legitimate applications

### Phase 2: Enforce Mode Testing
1. Switch policy to enforce mode
2. Validate critical applications still work
3. Test blocked applications are prevented
4. Verify folder restrictions are effective

### Phase 3: Production Deployment
1. Deploy to test systems
2. Monitor for policy violations
3. Refine policies based on findings
4. Deploy broadly with rollback plan

## Deployment and Management

### Deployment Methods
1. **Group Policy** - For domain-joined systems
2. **PowerShell Scripts** - For standalone systems
3. **Microsoft Endpoint Manager** - For managed environments

### Policy Updates
1. Regular review of allowed applications
2. Update policies for new software deployments
3. Remove outdated allowances
4. Maintain policy version control

### Monitoring and Reporting
1. Monitor Code Integrity event logs
2. Generate compliance reports
3. Track policy violations
4. Maintain audit trails

## Ready-to-Use Policies in This Repository

This repository contains pre-built policies ready for deployment:

### Base Policies
- `policies/BasePolicy.xml` - Generic base policy for any environment
- `environment-specific/non-ad/policies/non-ad-base-policy.xml` - Non-AD environment base policy

### Supplemental Policies
- `policies/TrustedApp.xml` - Sample trusted application policy
- `environment-specific/non-ad/policies/department-supplemental-policies/` - Department-specific policies

### Deny Policies
- `policies/DenyPolicy.xml` - Sample deny policy for high-risk folders
- `environment-specific/non-ad/policies/exception-policies/emergency-access-policy.xml` - Emergency access policy

## Implementation Commands

### Merge Policies
```powershell
.\scripts\merge_policies.ps1
```

### Convert to Audit Mode
```powershell
.\scripts\convert_to_audit_mode.ps1
```

### Deploy Policy
```powershell
.\scripts\convert_to_enforce_mode.ps1 -Deploy
```

### Rollback Policy
```powershell
.\scripts\rollback_policy.ps1 -Restore
```

## Next Steps

1. Review the sample policies in the `policies` directory
2. Customize policies for your specific environment
3. Test in audit mode first
4. Deploy in enforce mode after validation