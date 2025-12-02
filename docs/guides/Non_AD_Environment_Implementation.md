# Non-Active Directory Environment Implementation Guide for WDAC

This guide provides detailed instructions for implementing Windows Defender Application Control (WDAC) in non-Active Directory environments, including workgroup systems, Azure AD-joined devices, and hybrid environments.

## Overview

Non-Active Directory environments present unique challenges for WDAC deployment:
- Decentralized policy management
- Manual or scripted deployment methods
- Limited centralized monitoring capabilities
- Varied system configurations and connectivity

## Environment Types

### 1. Workgroup Systems
- Standalone Windows systems not joined to any domain
- Manual policy deployment required
- Limited centralized management options

### 2. Azure AD-Joined Devices
- Devices joined to Azure Active Directory
- Cloud-based management through Microsoft Intune
- Limited access to traditional Group Policy

### 3. Hybrid Environments
- Mix of domain-joined and non-domain systems
- Multiple management tools required
- Complex policy coordination needed

## Deployment Methods for Non-AD Environments

### 1. Manual Deployment

#### Direct File Copy Method
1. **Prepare Policy File**
   ```powershell
   # Convert policy to binary format
   ConvertFrom-CIPolicy -XmlFilePath "C:\Policies\WDACPolicy.xml" -BinaryFilePath "C:\Policies\WDACPolicy.p7b"
   ```

2. **Copy Policy to Target Systems**
   ```powershell
   # Copy policy to Code Integrity directory
   Copy-Item -Path "C:\Policies\WDACPolicy.p7b" -Destination "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b" -Force
   ```

3. **Restart Systems**
   ```powershell
   # Restart to apply policy
   Restart-Computer -Force
   ```

#### PowerShell Remoting Method
```powershell
# Deploy policy to multiple systems using PowerShell remoting
$Computers = @("Workstation01", "Workstation02", "Workstation03")
$PolicyPath = "\\Server\Share\Policies\WDACPolicy.p7b"

foreach ($Computer in $Computers) {
    Invoke-Command -ComputerName $Computer -ScriptBlock {
        param($PolicyPath)
        Copy-Item -Path $PolicyPath -Destination "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b" -Force
        Restart-Computer -Force
    } -ArgumentList $PolicyPath
}
```

### 2. Script-Based Deployment

#### Deployment Script Example
```powershell
# WDAC_NonAD_Deploy.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$PolicyPath,
    
    [Parameter(Mandatory=$false)]
    [string[]]$TargetComputers,
    
    [Parameter(Mandatory=$false)]
    [switch]$Restart
)

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Timestamp] $Message"
}

Write-Log "Starting WDAC policy deployment"

# Validate policy file
if (-not (Test-Path $PolicyPath)) {
    Write-Error "Policy file not found: $PolicyPath"
    exit 1
}

# Deploy to local system if no targets specified
if (-not $TargetComputers) {
    Write-Log "Deploying to local system"
    try {
        Copy-Item -Path $PolicyPath -Destination "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b" -Force
        Write-Log "Policy deployed successfully"
        
        if ($Restart) {
            Write-Log "Restarting system to apply policy"
            Restart-Computer -Force
        }
    } catch {
        Write-Error "Failed to deploy policy: $_"
        exit 1
    }
} else {
    # Deploy to remote systems
    foreach ($Computer in $TargetComputers) {
        Write-Log "Deploying to $Computer"
        try {
            Invoke-Command -ComputerName $Computer -ScriptBlock {
                param($PolicyPath)
                Copy-Item -Path $PolicyPath -Destination "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b" -Force
            } -ArgumentList $PolicyPath
            
            Write-Log "Policy deployed to $Computer"
            
            if ($Restart) {
                Invoke-Command -ComputerName $Computer -ScriptBlock { Restart-Computer -Force }
                Write-Log "Restart initiated on $Computer"
            }
        } catch {
            Write-Error "Failed to deploy policy to $Computer: $_"
        }
    }
}

Write-Log "WDAC policy deployment completed"
```

### 3. Configuration Management Tools

#### Using Ansible
```yaml
# wdac_deploy.yml
---
- name: Deploy WDAC Policy
  hosts: windows_workstations
  tasks:
    - name: Copy WDAC policy file
      win_copy:
        src: files/WDACPolicy.p7b
        dest: C:\Windows\System32\CodeIntegrity\SIPolicy.p7b
        force: yes
    
    - name: Restart system to apply policy
      win_reboot:
        msg: "Restarting to apply WDAC policy"
        pre_reboot_delay: 15
```

#### Using Puppet
```puppet
# wdac.pp
file { 'C:\Windows\System32\CodeIntegrity\SIPolicy.p7b':
  ensure  => file,
  source  => 'puppet:///modules/wdac/WDACPolicy.p7b',
  owner   => 'SYSTEM',
  group   => 'SYSTEM',
  mode    => '0644',
  notify  => Exec['restart_for_wdac'],
}

exec { 'restart_for_wdac':
  command  => 'shutdown /r /t 0',
  onlyif   => 'if exist C:\Windows\System32\CodeIntegrity\SIPolicy.p7b (exit 0) else (exit 1)',
  provider => powershell,
}
```

## Microsoft Intune for Non-AD Environments

### Azure AD-Joined Device Management

1. **Prepare Policy in Intune**
   - Sign in to Microsoft Endpoint Manager admin center
   - Navigate to Devices > Configuration profiles
   - Create a new profile with platform "Windows 10 and later"
   - Select profile type "Templates" > "Windows Defender Application Control"

2. **Configure Policy Settings**
   - Upload your WDAC policy file
   - Configure enforcement options
   - Assign to appropriate device groups

3. **Monitor Deployment**
   - Use Intune reporting to track policy deployment status
   - Monitor compliance and device health

### Hybrid Azure AD-Joined Devices

For devices that are domain-joined but also registered with Azure AD:

1. **Use Co-Management**
   - Enable co-management in Configuration Manager
   - Configure Intune to manage WDAC policies
   - Use Configuration Manager for other management tasks

2. **Policy Conflict Resolution**
   - Define precedence for conflicting policies
   - Monitor for policy overlap
   - Implement consistent policy naming

## Security Considerations for Non-AD Environments

### 1. Policy Distribution Security

#### Secure File Sharing
```powershell
# Example: Secure policy distribution using encrypted shares
$SecureShare = "\\Server\SecurePolicies$"
$Credential = Get-Credential -Message "Enter credentials for secure share"

# Copy policy using secure credentials
Copy-Item -Path "C:\Policies\WDACPolicy.p7b" -Destination $SecureShare -Credential $Credential
```

#### Policy Signing
```powershell
# Sign policies for non-AD environments
$cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Where-Object {$_.Subject -like "*WDAC*"}
Set-AuthenticodeSignature -FilePath "C:\Policies\WDACPolicy.xml" -Certificate $cert
```

### 2. Access Control

#### Local Administrator Management
```powershell
# Example: Restrict local administrator access
$AdminGroup = Get-LocalGroup -Name "Administrators"
$AdminMembers = Get-LocalGroupMember -Group $AdminGroup

# Remove unnecessary administrators
foreach ($Member in $AdminMembers) {
    if ($Member.Name -notlike "*DOMAIN\Admin*") {
        Remove-LocalGroupMember -Group $AdminGroup -Member $Member.Name
    }
}
```

### 3. Network Security

#### Firewall Configuration
```powershell
# Example: Configure firewall for WDAC management
New-NetFirewallRule -DisplayName "WDAC Management" -Direction Inbound -Protocol TCP -LocalPort 5985 -Profile Domain -Action Allow
```

## Monitoring and Reporting

### 1. Centralized Log Collection

#### Using Windows Event Forwarding
```powershell
# Example: Configure event forwarding for non-AD systems
# This requires manual configuration on each system
wevtutil set-subscription "CodeIntegrityForwarding" /SubscriptionType:CollectorInitiated /TransportName:HTTP /TransportPort:5985
```

#### Using Third-Party Tools
```powershell
# Example: Send logs to SIEM using PowerShell
$Events = Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
    StartTime = (Get-Date).AddHours(-1)
}

# Send to SIEM (example using HTTP POST)
$Events | ConvertTo-Json | Out-File -FilePath "\\Server\Share\WDAC_Events.json"
```

### 2. Compliance Reporting

#### Generate Compliance Reports
```powershell
# Example: Generate compliance report for non-AD systems
$Report = foreach ($Computer in $TargetComputers) {
    Invoke-Command -ComputerName $Computer -ScriptBlock {
        $PolicyStatus = Test-Path "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
        $CIStatus = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
        
        [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            PolicyDeployed = $PolicyStatus
            DeviceGuardStatus = $CIStatus.SecurityServicesConfigured
            LastRestart = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
        }
    }
}

$Report | Export-Csv -Path "C:\Reports\WDAC_Compliance_Report.csv" -NoTypeInformation
```

## Troubleshooting Non-AD Deployments

### 1. Common Issues

#### Policy Not Applying
```powershell
# Check policy status
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard

# Verify policy file
Get-ItemProperty "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"

# Check event logs
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-CodeIntegrity/Operational'; Level=2}
```

#### Connectivity Issues
```powershell
# Test network connectivity to policy source
Test-NetConnection -ComputerName "PolicyServer" -Port 445

# Verify file share access
Get-SmbMapping | Where-Object {$_.RemotePath -like "*Policy*"}
```

### 2. Diagnostic Scripts

#### Policy Validation Script
```powershell
# WDAC_Validate.ps1
function Test-WDACPolicy {
    Write-Host "Validating WDAC Policy Deployment..." -ForegroundColor Cyan
    
    # Check if policy file exists
    $PolicyPath = "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
    if (Test-Path $PolicyPath) {
        Write-Host "✓ Policy file found at $PolicyPath" -ForegroundColor Green
        $PolicyInfo = Get-ItemProperty $PolicyPath
        Write-Host "  Last Modified: $($PolicyInfo.LastWriteTime)" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Policy file not found" -ForegroundColor Red
        return $false
    }
    
    # Check Device Guard status
    try {
        $DGStatus = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard -ErrorAction Stop
        if ($DGStatus.SecurityServicesRunning -band 2) {
            Write-Host "✓ Device Guard with Code Integrity is running" -ForegroundColor Green
        } else {
            Write-Host "✗ Device Guard is not running" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Failed to query Device Guard status: $_" -ForegroundColor Red
        return $false
    }
    
    Write-Host "WDAC Policy Validation Complete" -ForegroundColor Cyan
    return $true
}

Test-WDACPolicy
```

## Best Practices for Non-AD Environments

### 1. Policy Management
- Use version control for policy files
- Implement consistent naming conventions
- Maintain backup copies of working policies
- Document all policy changes

### 2. Deployment Strategy
- Test policies in audit mode first
- Deploy to small groups initially
- Monitor for issues before broad rollout
- Implement rollback procedures

### 3. Security Hygiene
- Keep systems updated with latest patches
- Use signed policies in production
- Restrict administrative access
- Monitor for unauthorized changes

### 4. Monitoring and Maintenance
- Regularly review audit logs
- Update policies for new applications
- Remove outdated rules periodically
- Document policy effectiveness

This guide provides a comprehensive framework for implementing WDAC in non-Active Directory environments. By following these practices, organizations can achieve strong application control even without traditional domain infrastructure.