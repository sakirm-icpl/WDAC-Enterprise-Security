# PowerShell script to merge Base, Deny, and TrustedApp policies
# Usage: .\merge_policies.ps1

param(
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if ($_ -and -not (Test-Path $_)) {
            throw "Base policy file not found at: $_"
        }
        return $true
    })]
    [string]$BasePolicyPath = ".\BasePolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if ($_ -and -not (Test-Path $_)) {
            throw "Deny policy file not found at: $_"
        }
        return $true
    })]
    [string]$DenyPolicyPath = ".\DenyPolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if ($_ -and -not (Test-Path $_)) {
            throw "TrustedApp policy file not found at: $_"
        }
        return $true
    })]
    [string]$TrustedAppPolicyPath = ".\TrustedApp.xml",
    
    [Parameter(Mandatory=$false)]
    [string[]]$AdditionalPolicyPaths = @(),
    
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        $parentDir = Split-Path $_ -Parent
        if ($parentDir -and -not (Test-Path $parentDir)) {
            throw "Output directory does not exist: $parentDir"
        }
        return $true
    })]
    [string]$OutputPath = ".\MergedPolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [switch]$ConvertToBinary,
    
    [Parameter(Mandatory=$false)]
    [switch]$Validate,
    
    [Parameter(Mandatory=$false)]
    [string]$NewVersion
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

function Update-PolicyVersion {
    param(
        [string]$PolicyPath,
        [string]$NewVersion
    )
    
    try {
        [xml]$Policy = Get-Content $PolicyPath
        $Policy.Policy.VersionEx = $NewVersion
        $Policy.Save($PolicyPath)
        Write-Log "Updated policy version to $NewVersion" "SUCCESS"
    } catch {
        Write-Log "Failed to update policy version: $($_.Exception.Message)" "ERROR"
    }
}

Write-Log "Starting WDAC Policy Merge Process" "INFO"

# Check prerequisites
try {
    Write-Log "Checking PowerShell version compatibility..." "INFO"
    Test-PowerShellVersionCompatibility | Out-Null
    Write-Log "PowerShell version compatibility check passed" "SUCCESS"
} catch {
    Write-Log "PowerShell compatibility check failed: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Check if policies exist
if (-not (Test-Path $BasePolicyPath)) {
    Write-Log "Base policy not found at $BasePolicyPath" "ERROR"
    exit 1
} else {
    Write-Log "Base policy found: $BasePolicyPath" "SUCCESS"
}

if ($DenyPolicyPath -and -not (Test-Path $DenyPolicyPath)) {
    Write-Log "Deny policy not found at $DenyPolicyPath. Continuing without it." "WARN"
    $DenyPolicyPath = $null
} elseif ($DenyPolicyPath) {
    Write-Log "Deny policy found: $DenyPolicyPath" "SUCCESS"
}

if ($TrustedAppPolicyPath -and -not (Test-Path $TrustedAppPolicyPath)) {
    Write-Log "TrustedApp policy not found at $TrustedAppPolicyPath. Continuing without it." "WARN"
    $TrustedAppPolicyPath = $null
} elseif ($TrustedAppPolicyPath) {
    Write-Log "TrustedApp policy found: $TrustedAppPolicyPath" "SUCCESS"
}

# Check additional policies
$ValidAdditionalPolicies = @()
foreach ($PolicyPath in $AdditionalPolicyPaths) {
    if (Test-Path $PolicyPath) {
        Write-Log "Additional policy found: $PolicyPath" "SUCCESS"
        $ValidAdditionalPolicies += $PolicyPath
    } else {
        Write-Log "Additional policy not found at $PolicyPath. Skipping." "WARN"
    }
}

Write-Log "Merging WDAC policies..." "INFO"

# Validate policies if requested
if ($Validate) {
    Write-Log "Validating policies before merge..." "INFO"
    
    $AllPoliciesValid = $true
    
    if (-not (Test-PolicySyntax -PolicyPath $BasePolicyPath)) {
        $AllPoliciesValid = $false
    }
    
    if ($DenyPolicyPath -and -not (Test-PolicySyntax -PolicyPath $DenyPolicyPath)) {
        $AllPoliciesValid = $false
    }
    
    if ($TrustedAppPolicyPath -and -not (Test-PolicySyntax -PolicyPath $TrustedAppPolicyPath)) {
        $AllPoliciesValid = $false
    }
    
    foreach ($PolicyPath in $ValidAdditionalPolicies) {
        if (-not (Test-PolicySyntax -PolicyPath $PolicyPath)) {
            $AllPoliciesValid = $false
        }
    }
    
    if (-not $AllPoliciesValid) {
        Write-Log "One or more policies failed validation. Aborting merge." "ERROR"
        exit 1
    }
}

# Create temporary directory for intermediate files
$TempDir = "$env:TEMP\WDACMerge_$(Get-Random)"
if (-not (Test-Path $TempDir)) {
    try {
        New-Item -ItemType Directory -Path $TempDir -ErrorAction Stop | Out-Null
        Write-Log "Created temporary directory: $TempDir" "INFO"
    } catch {
        Write-Log "Failed to create temporary directory: $($_.Exception.Message)" "ERROR"
        exit 1
    }
}

try {
    # Copy base policy to temp directory
    $TempBasePolicy = Join-Path $TempDir "BasePolicy.xml"
    try {
        Copy-Item $BasePolicyPath $TempBasePolicy -Force -ErrorAction Stop
        Write-Log "Copied base policy to temporary location" "INFO"
    } catch {
        Write-Log "Failed to copy base policy: $($_.Exception.Message)" "ERROR"
        exit 1
    }
    
    # Merge deny policy if it exists
    if ($DenyPolicyPath) {
        Write-Log "Merging deny policy..." "INFO"
        $TempMergedPolicy1 = Join-Path $TempDir "MergedPolicy1.xml"
        try {
            Merge-CIPolicy -PolicyPaths $TempBasePolicy, $DenyPolicyPath -OutputFilePath $TempMergedPolicy1 -ErrorAction Stop
            Move-Item $TempMergedPolicy1 $TempBasePolicy -Force -ErrorAction Stop
            Write-Log "Deny policy merged successfully" "SUCCESS"
        } catch {
            Write-Log "Failed to merge deny policy: $($_.Exception.Message)" "ERROR"
            exit 1
        }
    }
    
    # Merge trusted app policy if it exists
    if ($TrustedAppPolicyPath) {
        Write-Log "Merging trusted app policy..." "INFO"
        $TempMergedPolicy2 = Join-Path $TempDir "MergedPolicy2.xml"
        try {
            Merge-CIPolicy -PolicyPaths $TempBasePolicy, $TrustedAppPolicyPath -OutputFilePath $TempMergedPolicy2 -ErrorAction Stop
            Move-Item $TempMergedPolicy2 $TempBasePolicy -Force -ErrorAction Stop
            Write-Log "Trusted app policy merged successfully" "SUCCESS"
        } catch {
            Write-Log "Failed to merge trusted app policy: $($_.Exception.Message)" "ERROR"
            exit 1
        }
    }
    
    # Merge additional policies
    foreach ($PolicyPath in $ValidAdditionalPolicies) {
        Write-Log "Merging additional policy: $PolicyPath" "INFO"
        $TempMergedPolicyN = Join-Path $TempDir "MergedPolicy_$(Get-Random).xml"
        try {
            Merge-CIPolicy -PolicyPaths $TempBasePolicy, $PolicyPath -OutputFilePath $TempMergedPolicyN -ErrorAction Stop
            Move-Item $TempMergedPolicyN $TempBasePolicy -Force -ErrorAction Stop
            Write-Log "Additional policy merged successfully" "SUCCESS"
        } catch {
            Write-Log "Failed to merge additional policy: $($_.Exception.Message)" "ERROR"
            exit 1
        }
    }
    
    # Copy final merged policy to output location
    try {
        Copy-Item $TempBasePolicy $OutputPath -Force -ErrorAction Stop
        Write-Log "Policy merge completed successfully. Output saved to $OutputPath" "SUCCESS"
    } catch {
        Write-Log "Failed to save merged policy: $($_.Exception.Message)" "ERROR"
        exit 1
    }
    
    # Update version if requested
    if ($NewVersion) {
        Update-PolicyVersion -PolicyPath $OutputPath -NewVersion $NewVersion
    }
    
    # Validate merged policy if requested
    if ($Validate) {
        Write-Log "Validating merged policy..." "INFO"
        if (Test-PolicySyntax -PolicyPath $OutputPath) {
            Write-Log "Merged policy validation passed" "SUCCESS"
        } else {
            Write-Log "Merged policy validation failed" "ERROR"
            exit 1
        }
    }
    
    # Convert to binary if requested
    if ($ConvertToBinary) {
        $BinaryOutputPath = [System.IO.Path]::ChangeExtension($OutputPath, ".bin")
        Write-Log "Converting policy to binary format..." "INFO"
        try {
            ConvertFrom-CIPolicy -XmlFilePath $OutputPath -BinaryFilePath $BinaryOutputPath -ErrorAction Stop
            Write-Log "Binary policy saved to $BinaryOutputPath" "SUCCESS"
        } catch {
            Write-Log "Failed to convert policy to binary format: $($_.Exception.Message)" "ERROR"
            exit 1
        }
    }
} catch {
    Write-Log "Unexpected error during policy merge: $($_.Exception.Message)" "ERROR"
    exit 1
} finally {
    # Clean up temporary files
    if (Test-Path $TempDir) {
        try {
            Remove-Item $TempDir -Recurse -Force -ErrorAction Stop
            Write-Log "Cleaned up temporary directory" "INFO"
        } catch {
            Write-Log "Failed to clean up temporary directory: $($_.Exception.Message)" "WARN"
        }
    }
}

Write-Log "Policy merge process completed." "INFO"