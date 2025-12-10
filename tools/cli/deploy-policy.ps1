# deploy-policy.ps1
# Comprehensive WDAC policy deployment assistant

param(
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = ".\policy.xml",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Audit", "Enforce", "None")]
    [string]$Mode = "None",
    
    [Parameter(Mandatory=$false)]
    [switch]$Validate,
    
    [Parameter(Mandatory=$false)]
    [switch]$ConvertToBinary,
    
    [Parameter(Mandatory=$false)]
    [switch]$Deploy,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
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

function Test-AdminPrivileges {
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $WindowsPrincipal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
    return $WindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-PowerShellVersionCompatibility {
    # Check PowerShell version
    $PSVersion = $PSVersionTable.PSVersion
    if ($PSVersion.Major -lt 5) {
        throw "PowerShell 5.0 or higher is required. Current version: $PSVersion"
    }
    
    # Check if required modules are available
    try {
        Import-Module ConfigCI -ErrorAction Stop
        return $true
    } catch {
        throw "ConfigCI module not available. This module is required for WDAC policy management."
    }
}

function Test-PolicySyntax {
    param([string]$PolicyPath)
    
    try {
        # Load XML and validate structure
        [xml]$PolicyXml = Get-Content $PolicyPath
        
        # Check for required elements
        if (-not $PolicyXml.Policy) {
            Write-Log "Invalid policy structure: Missing Policy root element" "ERROR"
            return $false
        }
        
        # Validate PolicyType
        $validPolicyTypes = @("Base Policy", "Supplemental Policy")
        if ($PolicyXml.Policy.PolicyType -notin $validPolicyTypes) {
            Write-Log "Unexpected PolicyType: $($PolicyXml.Policy.PolicyType). Expected: Base Policy or Supplemental Policy" "WARN"
        }
        
        # Check for VersionEx
        if (-not $PolicyXml.Policy.VersionEx) {
            Write-Log "Missing VersionEx element" "WARN"
        }
        
        # For Base policies, check for PlatformID
        if ($PolicyXml.Policy.PolicyType -eq "Base Policy" -and -not $PolicyXml.Policy.PlatformID) {
            Write-Log "Missing PlatformID in Base Policy" "ERROR"
            return $false
        }
        
        # For Supplemental policies, check for BasePolicyID
        if ($PolicyXml.Policy.PolicyType -eq "Supplemental Policy" -and -not $PolicyXml.Policy.BasePolicyID) {
            Write-Log "Missing BasePolicyID in Supplemental Policy" "ERROR"
            return $false
        }
        
        Write-Log "Policy syntax validation passed" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Policy syntax validation failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Convert-PolicyMode {
    param(
        [string]$PolicyPath,
        [string]$Mode,
        [string]$OutputPath
    )
    
    try {
        # Load the policy
        [xml]$Policy = Get-Content $PolicyPath
        
        # Find or create the mode rule
        $RulesNode = $Policy.Policy.Rules
        $ModeRule = $RulesNode.Rule | Where-Object { $_.Option -eq "Enabled:Audit Mode" -or $_.Option -eq "Enabled:Enforce Mode" }
        
        # Remove existing mode rules
        if ($ModeRule) {
            $ModeRule | ForEach-Object { $RulesNode.RemoveChild($_) | Out-Null }
        }
        
        # Add new mode rule
        if ($Mode -ne "None") {
            $NewRule = $Policy.CreateElement("Rule")
            $Option = $Policy.CreateElement("Option")
            $OptionInnerText = if ($Mode -eq "Audit") { "Enabled:Audit Mode" } else { "Enabled:Enforce Mode" }
            $Option.InnerText = $OptionInnerText
            $NewRule.AppendChild($Option) | Out-Null
            $RulesNode.AppendChild($NewRule) | Out-Null
            Write-Log "Added $Mode mode rule to policy" "SUCCESS"
        }
        
        # Save the policy
        $Policy.Save($OutputPath)
        Write-Log "Policy mode converted to $Mode" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to convert policy mode: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Deploy-Policy {
    param(
        [string]$BinaryPath
    )
    
    try {
        # Deploy the policy
        $DeployPath = "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
        Copy-Item -Path $BinaryPath -Destination $DeployPath -Force -ErrorAction Stop
        Write-Log "Policy deployed to $DeployPath" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to deploy policy: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

Write-Log "Starting WDAC Policy Deployment Assistant" "INFO"

# Check prerequisites
if (-not (Test-AdminPrivileges)) {
    Write-Log "This script requires administrator privileges. Please run as Administrator." "ERROR"
    exit 1
}

try {
    Write-Log "Checking PowerShell version compatibility..." "INFO"
    Test-PowerShellVersionCompatibility | Out-Null
    Write-Log "PowerShell version compatibility check passed" "SUCCESS"
} catch {
    Write-Log "PowerShell compatibility check failed: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Check if policy file exists
if (-not (Test-Path $PolicyPath)) {
    Write-Log "Policy file not found at $PolicyPath" "ERROR"
    exit 1
}

Write-Log "Policy file found: $PolicyPath" "SUCCESS"

# Validate policy if requested
if ($Validate) {
    Write-Log "Validating policy..." "INFO"
    if (-not (Test-PolicySyntax -PolicyPath $PolicyPath)) {
        Write-Log "Policy validation failed. Aborting deployment." "ERROR"
        exit 1
    }
}

# Convert policy mode if requested
$WorkingPolicyPath = $PolicyPath
if ($Mode -ne "None") {
    Write-Log "Converting policy to $Mode mode..." "INFO"
    $TempDir = "$env:TEMP\WDACDeploy_$(Get-Random)"
    New-Item -ItemType Directory -Path $TempDir -ErrorAction SilentlyContinue | Out-Null
    $WorkingPolicyPath = Join-Path $TempDir "ModeConvertedPolicy.xml"
    
    if (-not (Convert-PolicyMode -PolicyPath $PolicyPath -Mode $Mode -OutputPath $WorkingPolicyPath)) {
        Write-Log "Failed to convert policy mode. Aborting deployment." "ERROR"
        exit 1
    }
}

# Convert to binary if requested
$BinaryPath = $WorkingPolicyPath
if ($ConvertToBinary) {
    Write-Log "Converting policy to binary format..." "INFO"
    $BinaryPath = [System.IO.Path]::ChangeExtension($WorkingPolicyPath, ".bin")
    
    try {
        ConvertFrom-CIPolicy -XmlFilePath $WorkingPolicyPath -BinaryFilePath $BinaryPath -ErrorAction Stop
        Write-Log "Policy converted to binary format: $BinaryPath" "SUCCESS"
    } catch {
        Write-Log "Failed to convert policy to binary format: $($_.Exception.Message)" "ERROR"
        exit 1
    }
}

# Deploy if requested
if ($Deploy) {
    Write-Log "Deploying policy..." "INFO"
    
    # Check if a policy is already deployed
    $ExistingPolicyPath = "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
    if (Test-Path $ExistingPolicyPath -and -not $Force) {
        Write-Log "A policy is already deployed. Use -Force to overwrite." "WARN"
        Write-Log "Exiting without deploying new policy." "INFO"
        exit 0
    }
    
    if (Deploy-Policy -BinaryPath $BinaryPath) {
        Write-Log "Policy deployed successfully!" "SUCCESS"
        Write-Log "IMPORTANT: Restart the computer for changes to take effect" "WARN"
    } else {
        Write-Log "Failed to deploy policy. Aborting." "ERROR"
        exit 1
    }
}

# Clean up temporary files
if ($WorkingPolicyPath -ne $PolicyPath) {
    Remove-Item (Split-Path $WorkingPolicyPath -Parent) -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Log "WDAC Policy Deployment Assistant completed." "INFO"