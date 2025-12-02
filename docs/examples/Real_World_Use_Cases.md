# Real-World WDAC Use Cases and Examples

This document provides practical, real-world use cases for Windows Defender Application Control (WDAC) implementation, complete with detailed examples, policies, and implementation guidance.

## Use Case 1: Financial Services Organization

### Scenario
A financial services company needs to implement strict application control to comply with SOX and PCI-DSS regulations while maintaining operational efficiency for trading applications.

### Requirements
- Block all unauthorized applications
- Allow only approved trading software
- Permit Microsoft Office suite
- Block USB-based malware execution
- Maintain audit trail for compliance

### Implementation Approach

#### 1. Policy Design
```xml
<!-- Financial_Services_Policy.xml -->
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>{2E07F7E4-194C-4D20-B7C9-6F44A6C5A234}</PlatformID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Enforce Mode</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Advanced Boot Options Menu</Option>
    </Rule>
    <Rule>
      <Option>Required:Enforce Store Applications</Option>
    </Rule>
    <Rule>
      <Option>Enabled:UMCI</Option>
    </Rule>
    <Rule>
      <Option>Disabled:Script Enforcement</Option>
    </Rule>
  </Rules>
  
  <!-- Allow Microsoft Applications -->
  <FileRules>
    <Allow ID="ID_ALLOW_MS_PUBLISHER" FriendlyName="Microsoft Applications" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_MS">
        <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
        <CertPublisher Value="Microsoft Corporation" />
      </Signer>
    </Allow>
    
    <!-- Allow Trading Applications -->
    <Allow ID="ID_ALLOW_TRADING_APP1" FriendlyName="Trading Application 1" FileName="tradingapp1.exe" FilePath="%PROGRAMFILES%\TradingSuite\*" />
    <Allow ID="ID_ALLOW_TRADING_APP2" FriendlyName="Trading Application 2" FileName="tradingapp2.exe" FilePath="%PROGRAMFILES%\TradingSuite\*" />
    
    <!-- Allow Office Suite -->
    <Allow ID="ID_ALLOW_OFFICE" FriendlyName="Microsoft Office" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_OFFICE">
        <CertRoot Type="TBS" Value="8A334509347B877279E2C55B8D3E94D8B0E3E2D7A2C5F8A0B1C2D3E4F5A6B7C8" />
        <CertPublisher Value="Microsoft Corporation" />
      </Signer>
    </Allow>
    
    <!-- Deny High-Risk Locations -->
    <Deny ID="ID_DENY_DOWNLOADS" FriendlyName="Downloads Folder" FileName="*" FilePath="%OSDRIVE%\Users\*\Downloads\*" />
    <Deny ID="ID_DENY_TEMP" FriendlyName="Temp Folder" FileName="*" FilePath="%OSDRIVE%\Users\*\AppData\Local\Temp\*" />
    <Deny ID="ID_DENY_REMOVABLE" FriendlyName="Removable Drives" FileName="*" FilePath="%OSDRIVE%\*" />
  </FileRules>
  
  <Signers>
    <Signer Name="Microsoft Publisher" ID="ID_SIGNER_MS">
      <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
      <CertPublisher Value="Microsoft Corporation" />
    </Signer>
    <Signer Name="Microsoft Office" ID="ID_SIGNER_OFFICE">
      <CertRoot Type="TBS" Value="8A334509347B877279E2C55B8D3E94D8B0E3E2D7A2C5F8A0B1C2D3E4F5A6B7C8" />
      <CertPublisher Value="Microsoft Corporation" />
    </Signer>
  </Signers>
  
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_TRADING_APP1" />
          <FileRuleRef RuleID="ID_ALLOW_TRADING_APP2" />
          <FileRuleRef RuleID="ID_DENY_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_TEMP" />
          <FileRuleRef RuleID="ID_DENY_REMOVABLE" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS">
      <ProductSigners>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_MS" />
          <AllowedSigner SignerId="ID_SIGNER_OFFICE" />
        </AllowedSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_TRADING_APP1" />
          <FileRuleRef RuleID="ID_ALLOW_TRADING_APP2" />
          <FileRuleRef RuleID="ID_DENY_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_TEMP" />
          <FileRuleRef RuleID="ID_DENY_REMOVABLE" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

#### 2. Deployment Script
```powershell
# Deploy-FinancialPolicy.ps1
param(
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = "C:\Policies\Financial_Services_Policy.xml",
    
    [Parameter(Mandatory=$false)]
    [string[]]$TargetServers = @("TradingServer01", "TradingServer02", "TradingServer03")
)

Write-Host "Deploying Financial Services WDAC Policy..." -ForegroundColor Green

# Convert to binary
$BinaryPath = [System.IO.Path]::ChangeExtension($PolicyPath, ".p7b")
ConvertFrom-CIPolicy -XmlFilePath $PolicyPath -BinaryFilePath $BinaryPath

# Deploy to trading servers
foreach ($Server in $TargetServers) {
    Write-Host "Deploying to $Server..." -ForegroundColor Yellow
    
    try {
        Copy-Item -Path $BinaryPath -Destination "\\$Server\C$\Windows\System32\CodeIntegrity\SIPolicy.p7b" -Force
        Invoke-Command -ComputerName $Server -ScriptBlock { Restart-Computer -Force }
        Write-Host "Successfully deployed to $Server" -ForegroundColor Green
    } catch {
        Write-Error "Failed to deploy to $Server: $_"
    }
}

Write-Host "Financial Services WDAC Policy Deployment Complete" -ForegroundColor Green
```

### Compliance Benefits
- SOX compliance through strict application control
- PCI-DSS compliance by preventing unauthorized software
- Audit trail through Code Integrity event logging
- Reduced attack surface for financial systems

## Use Case 2: Healthcare Organization

### Scenario
A healthcare organization needs to implement WDAC to comply with HIPAA regulations while ensuring medical devices and applications continue to function properly.

### Requirements
- Protect patient data through application control
- Allow medical device software to operate
- Block malware that could compromise patient data
- Maintain system uptime for critical medical applications

### Implementation Approach

#### 1. Policy Design
```xml
<!-- Healthcare_Policy.xml -->
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>{3F18F9A5-2A4D-4E3C-B8D7-5F2A6E7B8C9D}</PlatformID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Enforce Mode</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Advanced Boot Options Menu</Option>
    </Rule>
    <Rule>
      <Option>Required:Enforce Store Applications</Option>
    </Rule>
    <Rule>
      <Option>Enabled:UMCI</Option>
    </Rule>
  </Rules>
  
  <FileRules>
    <!-- Allow Microsoft Applications -->
    <Allow ID="ID_ALLOW_MS_HEALTHCARE" FriendlyName="Microsoft Applications" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_MS_HEALTHCARE">
        <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
        <CertPublisher Value="Microsoft Corporation" />
      </Signer>
    </Allow>
    
    <!-- Allow Medical Device Software -->
    <Allow ID="ID_ALLOW_MEDICAL_DEVICE1" FriendlyName="Medical Device Software 1" Hash="A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2" />
    <Allow ID="ID_ALLOW_MEDICAL_DEVICE2" FriendlyName="Medical Device Software 2" Hash="B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3" />
    
    <!-- Allow Healthcare Applications -->
    <Allow ID="ID_ALLOW_EHR" FriendlyName="Electronic Health Records" FileName="ehr.exe" FilePath="%PROGRAMFILES%\Healthcare\EHR\*" />
    <Allow ID="ID_ALLOW_IMAGING" FriendlyName="Medical Imaging Software" FileName="imaging.exe" FilePath="%PROGRAMFILES%\Healthcare\Imaging\*" />
    
    <!-- Deny High-Risk Locations -->
    <Deny ID="ID_DENY_HEALTHCARE_DOWNLOADS" FriendlyName="Downloads Folder" FileName="*" FilePath="%OSDRIVE%\Users\*\Downloads\*" />
    <Deny ID="ID_DENY_HEALTHCARE_TEMP" FriendlyName="Temp Folder" FileName="*" FilePath="%OSDRIVE%\Users\*\AppData\Local\Temp\*" />
  </FileRules>
  
  <Signers>
    <Signer Name="Microsoft Healthcare" ID="ID_SIGNER_MS_HEALTHCARE">
      <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
      <CertPublisher Value="Microsoft Corporation" />
    </Signer>
  </Signers>
  
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1_HEALTHCARE">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_MEDICAL_DEVICE1" />
          <FileRuleRef RuleID="ID_ALLOW_MEDICAL_DEVICE2" />
          <FileRuleRef RuleID="ID_ALLOW_EHR" />
          <FileRuleRef RuleID="ID_ALLOW_IMAGING" />
          <FileRuleRef RuleID="ID_DENY_HEALTHCARE_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_HEALTHCARE_TEMP" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS_HEALTHCARE">
      <ProductSigners>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_MS_HEALTHCARE" />
        </AllowedSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_MEDICAL_DEVICE1" />
          <FileRuleRef RuleID="ID_ALLOW_MEDICAL_DEVICE2" />
          <FileRuleRef RuleID="ID_ALLOW_EHR" />
          <FileRuleRef RuleID="ID_ALLOW_IMAGING" />
          <FileRuleRef RuleID="ID_DENY_HEALTHCARE_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_HEALTHCARE_TEMP" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

#### 2. Monitoring Script
```powershell
# Monitor-HealthcareWDAC.ps1
param(
    [Parameter(Mandatory=$false)]
    [int]$Hours = 24,
    
    [Parameter(Mandatory=$false)]
    [string]$ReportPath = "C:\Reports\Healthcare_WDAC_Report.csv"
)

Write-Host "Monitoring Healthcare WDAC Policy..." -ForegroundColor Green

$StartTime = (Get-Date).AddHours(-$Hours)

# Get Code Integrity events from healthcare systems
$HealthcareSystems = @("EHR-Server01", "Imaging-Server01", "MedicalDevice01", "MedicalDevice02")
$AllEvents = @()

foreach ($System in $HealthcareSystems) {
    Write-Host "Collecting events from $System..." -ForegroundColor Yellow
    
    try {
        $Events = Invoke-Command -ComputerName $System -ScriptBlock {
            param($StartTime)
            Get-WinEvent -FilterHashtable @{
                LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
                StartTime = $StartTime
                Level = 2, 3
            } -ErrorAction SilentlyContinue
        } -ArgumentList $StartTime
        
        $AllEvents += $Events
        Write-Host "Collected $($Events.Count) events from $System" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to collect events from $System: $_"
    }
}

# Process events for report
$ReportData = $AllEvents | ForEach-Object {
    [PSCustomObject]@{
        TimeCreated = $_.TimeCreated
        ComputerName = $_.MachineName
        EventId = $_.Id
        Message = $_.Message
        Level = $_.LevelDisplayName
    }
}

# Export report
$ReportData | Export-Csv -Path $ReportPath -NoTypeInformation
Write-Host "Report exported to $ReportPath" -ForegroundColor Green
Write-Host "Total events processed: $($AllEvents.Count)" -ForegroundColor Cyan
```

### Compliance Benefits
- HIPAA compliance through strict application control
- Protection of patient data from unauthorized access
- Audit trail for compliance reporting
- Reduced risk of ransomware affecting medical systems

## Use Case 3: Educational Institution

### Scenario
A university needs to implement WDAC to protect student and research data while allowing flexibility for academic software and research applications.

### Requirements
- Protect sensitive student and research data
- Allow legitimate academic software
- Permit research applications with proper approval
- Block malware that could compromise systems
- Support diverse computing environments

### Implementation Approach

#### 1. Multi-Policy Architecture
```xml
<!-- Base_Education_Policy.xml -->
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>{4A29F0B6-3B5E-4F7D-A9C8-6F3A7D8E9F0A}</PlatformID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Enforce Mode</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Advanced Boot Options Menu</Option>
    </Rule>
    <Rule>
      <Option>Required:Enforce Store Applications</Option>
    </Rule>
    <Rule>
      <Option>Enabled:UMCI</Option>
    </Rule>
  </Rules>
  
  <FileRules>
    <!-- Allow Microsoft Applications -->
    <Allow ID="ID_ALLOW_MS_EDUCATION" FriendlyName="Microsoft Applications" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_MS_EDUCATION">
        <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
        <CertPublisher Value="Microsoft Corporation" />
      </Signer>
    </Allow>
    
    <!-- Allow Educational Software -->
    <Allow ID="ID_ALLOW_OFFICE365" FriendlyName="Office 365" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_OFFICE365">
        <CertRoot Type="TBS" Value="8A334509347B877279E2C55B8D3E94D8B0E3E2D7A2C5F8A0B1C2D3E4F5A6B7C8" />
        <CertPublisher Value="Microsoft Corporation" />
      </Signer>
    </Allow>
    
    <!-- Allow Common Academic Software -->
    <Allow ID="ID_ALLOW_MATLAB" FriendlyName="MATLAB" FileName="matlab.exe" FilePath="%PROGRAMFILES%\MATLAB\*" />
    <Allow ID="ID_ALLOW_SPSS" FriendlyName="SPSS" FileName="spss.exe" FilePath="%PROGRAMFILES%\IBM\SPSS\*" />
    <Allow ID="ID_ALLOW_R" FriendlyName="R Programming" FileName="rscript.exe" FilePath="%PROGRAMFILES%\R\*" />
    
    <!-- Deny High-Risk Locations -->
    <Deny ID="ID_DENY_EDUCATION_DOWNLOADS" FriendlyName="Downloads Folder" FileName="*" FilePath="%OSDRIVE%\Users\*\Downloads\*" />
    <Deny ID="ID_DENY_EDUCATION_TEMP" FriendlyName="Temp Folder" FileName="*" FilePath="%OSDRIVE%\Users\*\AppData\Local\Temp\*" />
  </FileRules>
  
  <Signers>
    <Signer Name="Microsoft Education" ID="ID_SIGNER_MS_EDUCATION">
      <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
      <CertPublisher Value="Microsoft Corporation" />
    </Signer>
    <Signer Name="Microsoft Office 365" ID="ID_SIGNER_OFFICE365">
      <CertRoot Type="TBS" Value="8A334509347B877279E2C55B8D3E94D8B0E3E2D7A2C5F8A0B1C2D3E4F5A6B7C8" />
      <CertPublisher Value="Microsoft Corporation" />
    </Signer>
  </Signers>
  
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1_EDUCATION">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_MATLAB" />
          <FileRuleRef RuleID="ID_ALLOW_SPSS" />
          <FileRuleRef RuleID="ID_ALLOW_R" />
          <FileRuleRef RuleID="ID_DENY_EDUCATION_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_EDUCATION_TEMP" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS_EDUCATION">
      <ProductSigners>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_MS_EDUCATION" />
          <AllowedSigner SignerId="ID_SIGNER_OFFICE365" />
        </AllowedSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_MATLAB" />
          <FileRuleRef RuleID="ID_ALLOW_SPSS" />
          <FileRuleRef RuleID="ID_ALLOW_R" />
          <FileRuleRef RuleID="ID_DENY_EDUCATION_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_EDUCATION_TEMP" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

```xml
<!-- Research_Supplemental_Policy.xml -->
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Supplemental Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <BasePolicyID>{4A29F0B6-3B5E-4F7D-A9C8-6F3A7D8E9F0A}</BasePolicyID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
  </Rules>
  
  <FileRules>
    <!-- Allow Research Applications (Approved by Research Committee) -->
    <Allow ID="ID_ALLOW_RESEARCH_APP1" FriendlyName="Research Application 1" Hash="C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4" />
    <Allow ID="ID_ALLOW_RESEARCH_APP2" FriendlyName="Research Application 2" Hash="D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5" />
    
    <!-- Allow Department-Specific Software -->
    <Allow ID="ID_ALLOW_ENGINEERING_SW" FriendlyName="Engineering Software" FileName="*" FilePath="%PROGRAMFILES%\Engineering\*" />
    <Allow ID="ID_ALLOW_BIOLOGY_SW" FriendlyName="Biology Software" FileName="*" FilePath="%PROGRAMFILES%\Biology\*" />
  </FileRules>
  
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1_RESEARCH">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_RESEARCH_APP1" />
          <FileRuleRef RuleID="ID_ALLOW_RESEARCH_APP2" />
          <FileRuleRef RuleID="ID_ALLOW_ENGINEERING_SW" />
          <FileRuleRef RuleID="ID_ALLOW_BIOLOGY_SW" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS_RESEARCH">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_RESEARCH_APP1" />
          <FileRuleRef RuleID="ID_ALLOW_RESEARCH_APP2" />
          <FileRuleRef RuleID="ID_ALLOW_ENGINEERING_SW" />
          <FileRuleRef RuleID="ID_ALLOW_BIOLOGY_SW" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

#### 2. Approval Workflow Script
```powershell
# Request-ResearchSoftwareApproval.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$SoftwareName,
    
    [Parameter(Mandatory=$true)]
    [string]$Requester,
    
    [Parameter(Mandatory=$true)]
    [string]$Department,
    
    [Parameter(Mandatory=$true)]
    [string]$Justification,
    
    [Parameter(Mandatory=$false)]
    [string]$FilePath
)

# Create approval request
$Request = [PSCustomObject]@{
    RequestID = (New-Guid).Guid
    SoftwareName = $SoftwareName
    Requester = $Requester
    Department = $Department
    Justification = $Justification
    FilePath = $FilePath
    RequestDate = Get-Date
    Status = "Pending"
    ApprovedBy = $null
    ApprovalDate = $null
}

# Save request to approval queue
$RequestPath = "C:\WDAC\Requests\Pending\$($Request.RequestID).json"
$Request | ConvertTo-Json | Out-File -FilePath $RequestPath

# Send notification to research committee
$EmailBody = @"
New Software Approval Request

Software Name: $SoftwareName
Requester: $Requester
Department: $Department
Justification: $Justification
Request Date: $($Request.RequestDate)

Please review this request and approve or deny as appropriate.
"@

# In a real environment, this would send an email
Write-Host "Approval request submitted for $SoftwareName" -ForegroundColor Green
Write-Host "Request ID: $($Request.RequestID)" -ForegroundColor Yellow
Write-Host "Request saved to: $RequestPath" -ForegroundColor Cyan
```

### Compliance Benefits
- Protection of student and research data
- Compliance with educational privacy regulations
- Audit trail for software usage
- Flexible policy structure for academic needs

## Use Case 4: Government Agency

### Scenario
A government agency needs to implement WDAC to meet federal security requirements while maintaining operational capabilities for mission-critical applications.

### Requirements
- Comply with federal security standards
- Protect classified and sensitive information
- Allow only approved government software
- Implement zero-trust execution model
- Maintain detailed audit trails

### Implementation Approach

#### 1. Strict Hash-Based Policy
```xml
<!-- Government_Security_Policy.xml -->
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>{5B3AF1C7-4C6F-4G8H-B0D9-7G4A8E9F0B1C}</PlatformID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Enforce Mode</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Advanced Boot Options Menu</Option>
    </Rule>
    <Rule>
      <Option>Required:Enforce Store Applications</Option>
    </Rule>
    <Rule>
      <Option>Enabled:UMCI</Option>
    </Rule>
    <Rule>
      <Option>Enabled:HVCI</Option>
    </Rule>
    <Rule>
      <Option>Disabled:Script Enforcement</Option>
    </Rule>
  </Rules>
  
  <FileRules>
    <!-- Allow Only Specific Hashes -->
    <Allow ID="ID_ALLOW_WINDOWS_DEFENDER" FriendlyName="Windows Defender" Hash="E1F2A3B4C5D6E7F8A9B0C1D2E3F4A5B6C7D8E9F0A1B2C3D4E5F6A7B8C9D0E1F2" />
    <Allow ID="ID_ALLOW_NOTEPAD" FriendlyName="Notepad" Hash="F2A3B4C5D6E7F8A9B0C1D2E3F4A5B6C7D8E9F0A1B2C3D4E5F6A7B8C9D0E1F2A3" />
    <Allow ID="ID_ALLOW_CALCULATOR" FriendlyName="Calculator" Hash="A3B4C5D6E7F8A9B0C1D2E3F4A5B6C7D8E9F0A1B2C3D4E5F6A7B8C9D0E1F2A3B4" />
    
    <!-- Allow Government Applications -->
    <Allow ID="ID_ALLOW_GOV_APP1" FriendlyName="Government Application 1" Hash="B4C5D6E7F8A9B0C1D2E3F4A5B6C7D8E9F0A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5" />
    <Allow ID="ID_ALLOW_GOV_APP2" FriendlyName="Government Application 2" Hash="C5D6E7F8A9B0C1D2E3F4A5B6C7D8E9F0A1B2C3D4E5F6A7B8C9D0E1F2A3B4C5D6" />
    
    <!-- Deny Everything Else -->
    <Deny ID="ID_DENY_ALL" FriendlyName="Deny All Other Applications" FileName="*" />
  </FileRules>
  
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1_GOV">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_WINDOWS_DEFENDER" />
          <FileRuleRef RuleID="ID_ALLOW_NOTEPAD" />
          <FileRuleRef RuleID="ID_ALLOW_CALCULATOR" />
          <FileRuleRef RuleID="ID_ALLOW_GOV_APP1" />
          <FileRuleRef RuleID="ID_ALLOW_GOV_APP2" />
          <FileRuleRef RuleID="ID_DENY_ALL" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS_GOV">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_WINDOWS_DEFENDER" />
          <FileRuleRef RuleID="ID_ALLOW_NOTEPAD" />
          <FileRuleRef RuleID="ID_ALLOW_CALCULATOR" />
          <FileRuleRef RuleID="ID_ALLOW_GOV_APP1" />
          <FileRuleRef RuleID="ID_ALLOW_GOV_APP2" />
          <FileRuleRef RuleID="ID_DENY_ALL" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
  
  <HvciOptions>1</HvciOptions>
</Policy>
```

#### 2. Compliance Reporting Script
```powershell
# Generate-GovernmentComplianceReport.ps1
param(
    [Parameter(Mandatory=$false)]
    [int]$Days = 30,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "C:\Reports\Government_WDAC_Compliance_Report.html"
)

Write-Host "Generating Government WDAC Compliance Report..." -ForegroundColor Green

$StartTime = (Get-Date).AddDays(-$Days)
$GovernmentSystems = Get-ADComputer -Filter {OperatingSystem -like "*Windows*" -and Name -like "GOV-*"}

# Collect compliance data
$ComplianceData = foreach ($System in $GovernmentSystems) {
    try {
        $PolicyStatus = Invoke-Command -ComputerName $System.Name -ScriptBlock {
            Test-Path "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
        }
        
        $Events = Invoke-Command -ComputerName $System.Name -ScriptBlock {
            param($StartTime)
            Get-WinEvent -FilterHashtable @{
                LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
                StartTime = $StartTime
                Level = 2
            } -ErrorAction SilentlyContinue | Measure-Object
        } -ArgumentList $StartTime
        
        [PSCustomObject]@{
            SystemName = $System.Name
            PolicyDeployed = $PolicyStatus
            Violations = $Events.Count
            LastChecked = Get-Date
            ComplianceStatus = if ($PolicyStatus -and $Events.Count -eq 0) { "Compliant" } else { "Non-Compliant" }
        }
    } catch {
        [PSCustomObject]@{
            SystemName = $System.Name
            PolicyDeployed = $false
            Violations = "Error"
            LastChecked = Get-Date
            ComplianceStatus = "Error"
        }
    }
}

# Generate HTML report
$HTMLReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Government WDAC Compliance Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .compliant { background-color: #d4edda; }
        .noncompliant { background-color: #f8d7da; }
        .error { background-color: #fff3cd; }
    </style>
</head>
<body>
    <h1>Government WDAC Compliance Report</h1>
    <p>Report Generated: $(Get-Date)</p>
    <p>Reporting Period: Last $Days days</p>
    
    <table>
        <tr>
            <th>System Name</th>
            <th>Policy Deployed</th>
            <th>Violations</th>
            <th>Last Checked</th>
            <th>Compliance Status</th>
        </tr>
"@

foreach ($Item in $ComplianceData) {
    $RowClass = switch ($Item.ComplianceStatus) {
        "Compliant" { "compliant" }
        "Non-Compliant" { "noncompliant" }
        default { "error" }
    }
    
    $HTMLReport += @"
        <tr class="$RowClass">
            <td>$($Item.SystemName)</td>
            <td>$($Item.PolicyDeployed)</td>
            <td>$($Item.Violations)</td>
            <td>$($Item.LastChecked)</td>
            <td>$($Item.ComplianceStatus)</td>
        </tr>
"@
}

$HTMLReport += @"
    </table>
    
    <h2>Summary</h2>
    <p>Total Systems: $($ComplianceData.Count)</p>
    <p>Compliant Systems: $(($ComplianceData | Where-Object {$_.ComplianceStatus -eq "Compliant"}).Count)</p>
    <p>Non-Compliant Systems: $(($ComplianceData | Where-Object {$_.ComplianceStatus -eq "Non-Compliant"}).Count)</p>
    <p>Systems with Errors: $(($ComplianceData | Where-Object {$_.ComplianceStatus -eq "Error"}).Count)</p>
</body>
</html>
"@

$HTMLReport | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host "Compliance report generated at $OutputPath" -ForegroundColor Green
```

### Compliance Benefits
- Meeting federal security requirements
- Zero-trust execution model implementation
- Detailed audit trails for compliance
- Protection of classified information

## Use Case 5: Small Business

### Scenario
A small business wants to implement WDAC to protect against malware while maintaining ease of use for employees.

### Requirements
- Simple deployment and management
- Protection against common malware threats
- Allow legitimate business applications
- Minimal impact on user productivity
- Cost-effective solution

### Implementation Approach

#### 1. Simple Publisher-Based Policy
```xml
<!-- Small_Business_Policy.xml -->
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>{6C4BG2D8-5D7G-4H9J-B1E0-8F5G6H7J8K9L}</PlatformID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Enforce Mode</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Advanced Boot Options Menu</Option>
    </Rule>
    <Rule>
      <Option>Required:Enforce Store Applications</Option>
    </Rule>
    <Rule>
      <Option>Enabled:UMCI</Option>
    </Rule>
  </Rules>
  
  <FileRules>
    <!-- Allow Common Business Applications -->
    <Allow ID="ID_ALLOW_MS_BUSINESS" FriendlyName="Microsoft Business Applications" FileName="*" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_MS_BUSINESS">
        <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
        <CertPublisher Value="Microsoft Corporation" />
      </Signer>
    </Allow>
    
    <Allow ID="ID_ALLOW_GOOGLE_CHROME" FriendlyName="Google Chrome" FileName="chrome.exe" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_CHROME">
        <CertRoot Type="TBS" Value="A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2" />
        <CertPublisher Value="Google LLC" />
      </Signer>
    </Allow>
    
    <Allow ID="ID_ALLOW_ADOBE_READER" FriendlyName="Adobe Reader" FileName="AcroRd*.exe" MinimumFileVersion="0.0.0.0">
      <Signer Id="ID_SIGNER_ADOBE">
        <CertRoot Type="TBS" Value="B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3" />
        <CertPublisher Value="Adobe Inc." />
      </Signer>
    </Allow>
    
    <!-- Allow Business Software -->
    <Allow ID="ID_ALLOW_QUICKBOOKS" FriendlyName="QuickBooks" FileName="qb*.exe" FilePath="%PROGRAMFILES%\Intuit\*" />
    <Allow ID="ID_ALLOW_OFFICE_SUITE" FriendlyName="Office Suite" FileName="*" FilePath="%PROGRAMFILES%\OfficeSuite\*" />
    
    <!-- Deny High-Risk Locations -->
    <Deny ID="ID_DENY_SMALL_BUSINESS_DOWNLOADS" FriendlyName="Downloads Folder" FileName="*" FilePath="%OSDRIVE%\Users\*\Downloads\*" />
    <Deny ID="ID_DENY_SMALL_BUSINESS_TEMP" FriendlyName="Temp Folder" FileName="*" FilePath="%OSDRIVE%\Users\*\AppData\Local\Temp\*" />
  </FileRules>
  
  <Signers>
    <Signer Name="Microsoft Business" ID="ID_SIGNER_MS_BUSINESS">
      <CertRoot Type="TBS" Value="F6F74D185A25E4928881FC0DB33C9FB7F57956D51661DD8063F7F700BA8A548B" />
      <CertPublisher Value="Microsoft Corporation" />
    </Signer>
    <Signer Name="Google Chrome" ID="ID_SIGNER_CHROME">
      <CertRoot Type="TBS" Value="A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2" />
      <CertPublisher Value="Google LLC" />
    </Signer>
    <Signer Name="Adobe Reader" ID="ID_SIGNER_ADOBE">
      <CertRoot Type="TBS" Value="B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3D4E5F6A1B2C3" />
      <CertPublisher Value="Adobe Inc." />
    </Signer>
  </Signers>
  
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1_BUSINESS">
      <ProductSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_QUICKBOOKS" />
          <FileRuleRef RuleID="ID_ALLOW_OFFICE_SUITE" />
          <FileRuleRef RuleID="ID_DENY_SMALL_BUSINESS_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_SMALL_BUSINESS_TEMP" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS_BUSINESS">
      <ProductSigners>
        <AllowedSigners>
          <AllowedSigner SignerId="ID_SIGNER_MS_BUSINESS" />
          <AllowedSigner SignerId="ID_SIGNER_CHROME" />
          <AllowedSigner SignerId="ID_SIGNER_ADOBE" />
        </AllowedSigners>
        <FileRulesRef>
          <FileRuleRef RuleID="ID_ALLOW_QUICKBOOKS" />
          <FileRuleRef RuleID="ID_ALLOW_OFFICE_SUITE" />
          <FileRuleRef RuleID="ID_DENY_SMALL_BUSINESS_DOWNLOADS" />
          <FileRuleRef RuleID="ID_DENY_SMALL_BUSINESS_TEMP" />
        </FileRulesRef>
      </ProductSigners>
    </SigningScenario>
  </SigningScenarios>
</Policy>
```

#### 2. Simple Deployment Script
```powershell
# Deploy-SmallBusinessWDAC.ps1
param(
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = "C:\Policies\Small_Business_Policy.xml"
)

Write-Host "Deploying Small Business WDAC Policy..." -ForegroundColor Green

# Check if running as administrator
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

# Convert policy to binary
Write-Host "Converting policy to binary format..." -ForegroundColor Yellow
$BinaryPath = [System.IO.Path]::ChangeExtension($PolicyPath, ".p7b")
ConvertFrom-CIPolicy -XmlFilePath $PolicyPath -BinaryFilePath $BinaryPath

# Deploy policy
Write-Host "Deploying policy..." -ForegroundColor Yellow
Copy-Item -Path $BinaryPath -Destination "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b" -Force

# Restart computer
Write-Host "Restarting computer to apply policy..." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to cancel restart, or wait 10 seconds..." -ForegroundColor Red
Start-Sleep -Seconds 10
Restart-Computer -Force
```

### Benefits for Small Business
- Simple deployment process
- Protection against common malware
- Minimal impact on user productivity
- Cost-effective security solution
- Easy maintenance and updates

## Implementation Best Practices

### 1. Testing Strategy
- Always test in audit mode first
- Use representative systems for testing
- Monitor for false positives
- Validate all business-critical applications

### 2. Deployment Approach
- Start with less critical systems
- Gradually expand to production systems
- Maintain rollback procedures
- Document all deployment steps

### 3. Monitoring and Maintenance
- Regularly review audit logs
- Update policies for new applications
- Remove outdated rules
- Maintain policy documentation

### 4. User Communication
- Communicate policy changes to users
- Provide guidance for blocked applications
- Establish support procedures
- Train users on security best practices

These real-world use cases demonstrate how WDAC can be implemented across different organization types and environments, providing strong security while meeting specific business requirements.