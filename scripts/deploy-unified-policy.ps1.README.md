# Unified WDAC Policy Deployment Script

This script provides a unified interface for deploying WDAC policies across different environments:
- Non-Active Directory Windows systems
- Active Directory domain-joined systems
- Windows Server systems (both AD and non-AD)

## Features
- Automatic environment detection
- Support for both audit and enforce modes
- Comprehensive logging
- Policy validation
- Rollback capabilities

## Usage

### For Non-AD Environments:
```powershell
# Deploy policies in audit mode
.\deploy-unified-policy.ps1 -Environment "NonAD" -Mode "Audit"

# Deploy policies in enforce mode
.\deploy-unified-policy.ps1 -Environment "NonAD" -Mode "Enforce"
```

### For AD Environments:
```powershell
# Deploy policies through Group Policy
.\deploy-unified-policy.ps1 -Environment "AD" -Mode "Enforce" -TargetOU "OU=Workstations,DC=company,DC=com"
```

### For Server Environments:
```powershell
# Deploy policies on Windows Server
.\deploy-unified-policy.ps1 -Environment "Server" -Mode "Audit"
```

## Parameters

- `-Environment`: Target environment ("NonAD", "AD", or "Server")
- `-Mode`: Deployment mode ("Audit" or "Enforce")
- `-TargetOU`: Target OU for AD deployments
- `-PolicyPath`: Path to policy files (default: environment-specific policies)
- `-LogPath`: Path to log file (default: TEMP directory)
- `-Force`: Skip confirmation prompts

## Examples

```powershell
# Deploy to non-AD workstation in audit mode
.\deploy-unified-policy.ps1 -Environment "NonAD" -Mode "Audit"

# Deploy to AD domain with specific OU
.\deploy-unified-policy.ps1 -Environment "AD" -Mode "Enforce" -TargetOU "OU=Computers,DC=corp,DC=company,DC=com"

# Deploy to Windows Server in enforce mode
.\deploy-unified-policy.ps1 -Environment "Server" -Mode "Enforce" -Force
```