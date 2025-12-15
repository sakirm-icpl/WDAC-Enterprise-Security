# generate-policy-from-inventory.ps1
# Automatically generates WDAC policies from application inventory scans

param(
    [Parameter(Mandatory=$false)]
    [string]$InventoryPath = "..\inventory\application-inventory.csv",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "..\policies\generated-inventory-policy.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$PolicyName = "Inventory-Based Policy",
    
    [Parameter(Mandatory=$false)]
    [string]$PolicyId = [guid]::NewGuid().ToString(),
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeUnsigned
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

function Get-ApplicationInventory {
    param([string]$InventoryPath)
    
    Write-Log "Loading application inventory from $InventoryPath" "INFO"
    
    try {
        if (-not (Test-Path $InventoryPath)) {
            throw "Inventory file not found: $InventoryPath"
        }
        
        $Inventory = Import-Csv $InventoryPath -ErrorAction Stop
        Write-Log "Loaded $($Inventory.Count) applications from inventory" "SUCCESS"
        return $Inventory
    } catch {
        throw "Failed to load application inventory: $($_.Exception.Message)"
    }
}

function Group-ApplicationsByPublisher {
    param([array]$Applications)
    
    Write-Log "Grouping applications by publisher..." "INFO"
    
    # Group applications by publisher
    $PublisherGroups = $Applications | Group-Object Publisher | Sort-Object Count -Descending
    
    # Filter out unknown publishers
    $ValidPublisherGroups = $PublisherGroups | Where-Object { $_.Name -and $_.Name -ne "Unknown" }
    
    Write-Log "Found $($ValidPublisherGroups.Count) valid publisher groups" "SUCCESS"
    return $ValidPublisherGroups
}

function Generate-PolicyXml {
    param(
        [array]$Applications,
        [array]$PublisherGroups,
        [string]$PolicyName,
        [string]$PolicyId,
        [bool]$IncludeUnsigned
    )
    
    Write-Log "Generating policy XML..." "INFO"
    
    # Start building the policy XML
    $PolicyXml = @"
<?xml version="1.0" encoding="utf-8"?>
<Policy xmlns="urn:schemas-microsoft-com:sipolicy" PolicyType="Base Policy">
  <VersionEx>1.0.0.0</VersionEx>
  <PlatformID>{$PolicyId}</PlatformID>
  <Rules>
    <Rule>
      <Option>Enabled:Unsigned System Integrity Policy</Option>
    </Rule>
    <Rule>
      <Option>Enabled:Audit Mode</Option>
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
      <Option>Enabled:Inherit Default Policy</Option>
    </Rule>
  </Rules>
  <!--EKUS-->
  <EKUs>
    <Eku Id="ID_EKU_STORE" Value="010A2B0601040182370A0301" FriendlyName="Windows Store EKU - 1.3.6.1.4.1.311.76.3.1 Windows Store" />
  </EKUs>
  <!--File Rules-->
  <FileRules>
"@
    
    # Add publisher-based rules
    $RuleId = 1000
    foreach ($Group in $PublisherGroups) {
        $Publisher = $Group.Name
        $ApplicationsInGroup = $Group.Group
        
        # Skip Microsoft applications as they're covered by default rules
        if ($Publisher -like "*Microsoft*") {
            continue
        }
        
        # Create a signer rule for this publisher
        $SignerId = "ID_SIGNER_$RuleId"
        $RuleId++
        
        $PolicyXml += @"
    <!--Allow applications from publisher: $Publisher-->
    <Allow ID="ID_ALLOW_PUBLISHER_$RuleId" FriendlyName="Allow Publisher - $Publisher" FileName="*">
      <Signer Id="$SignerId">
        <CertPublisher Value="$Publisher" />
      </Signer>
    </Allow>
"@
    }
    
    # Add path-based rules for applications without publishers
    $PathBasedApps = $Applications | Where-Object { 
        (-not $_.Publisher -or $_.Publisher -eq "Unknown") -and 
        $_.Path -and 
        $_.Path -ne "Unknown" 
    }
    
    foreach ($App in $PathBasedApps) {
        $RuleId++
        $AppPath = $App.Path
        $AppName = $App.Name
        
        $PolicyXml += @"
    <!--Allow application by path: $AppName-->
    <Allow ID="ID_ALLOW_PATH_$RuleId" FriendlyName="Allow Application - $AppName" FileName="*" FilePath="$AppPath" />
"@
    }
    
    # Add hash-based rules for unsigned applications if requested
    if ($IncludeUnsigned) {
        $UnsignedApps = $Applications | Where-Object { 
            $_.Signed -eq "False" -and 
            $_.Hash -and 
            $_.Hash -ne "Unknown" 
        }
        
        foreach ($App in $UnsignedApps) {
            $RuleId++
            $AppHash = $App.Hash
            $AppName = $App.Name
            
            $PolicyXml += @"
    <!--Allow unsigned application by hash: $AppName-->
    <Allow ID="ID_ALLOW_HASH_$RuleId" FriendlyName="Allow Unsigned Application - $AppName" Hash="$AppHash" />
"@
        }
    }
    
    # Close FileRules section and add Signers section
    $PolicyXml += @"
  </FileRules>
  <!--Signers-->
  <Signers>
"@
    
    # Add signer definitions
    $SignerId = 1000
    foreach ($Group in $PublisherGroups) {
        $Publisher = $Group.Name
        $ApplicationsInGroup = $Group.Group
        
        # Skip Microsoft applications as they're covered by default rules
        if ($Publisher -like "*Microsoft*") {
            continue
        }
        
        # Create a signer definition for this publisher
        $CurrentSignerId = "ID_SIGNER_$SignerId"
        $SignerId++
        
        $PolicyXml += @"
    <Signer Name="$Publisher" ID="$CurrentSignerId">
      <CertPublisher Value="$Publisher" />
    </Signer>
"@
    }
    
    # Close Signers section and add SigningScenarios
    $PolicyXml += @"
  </Signers>
  <!--Driver Signing Scenarios-->
  <SigningScenarios>
    <SigningScenario Value="131" ID="ID_SIGNINGSCENARIO_DRIVERS_1" FriendlyName="Auto generated policy on $(Get-Date -Format 'MM-dd-yyyy')">
      <ProductSigners />
    </SigningScenario>
    <SigningScenario Value="12" ID="ID_SIGNINGSCENARIO_WINDOWS" FriendlyName="Windows">
      <ProductSigners />
    </SigningScenario>
  </SigningScenarios>
  <UpdatePolicySigners>
  </UpdatePolicySigners>
  <CiSigners>
  </CiSigners>
  <HvciOptions>0</HvciOptions>
</Policy>
"@
    
    return $PolicyXml
}

Write-Log "Starting WDAC Policy Generation from Application Inventory" "INFO"

try {
    # Load application inventory
    $Applications = Get-ApplicationInventory -InventoryPath $InventoryPath
    
    # Group applications by publisher
    $PublisherGroups = Group-ApplicationsByPublisher -Applications $Applications
    
    # Generate policy XML
    $PolicyXml = Generate-PolicyXml -Applications $Applications -PublisherGroups $PublisherGroups -PolicyName $PolicyName -PolicyId $PolicyId -IncludeUnsigned $IncludeUnsigned
    
    # Save the policy
    Write-Log "Saving generated policy to $OutputPath" "INFO"
    $PolicyXml | Out-File -FilePath $OutputPath -Encoding UTF8 -ErrorAction Stop
    
    Write-Log "Policy generation completed successfully!" "SUCCESS"
    Write-Log "Generated policy saved to: $OutputPath" "INFO"
    Write-Log "Please review the policy before deployment and test in audit mode first." "WARN"
    
} catch {
    Write-Log "Failed to generate policy: $($_.Exception.Message)" "ERROR"
    exit 1
}