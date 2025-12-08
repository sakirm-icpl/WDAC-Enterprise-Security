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
    [string]$BasePolicyPath = "..\policies\BasePolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if ($_ -and -not (Test-Path $_)) {
            throw "Deny policy file not found at: $_"
        }
        return $true
    })]
    [string]$DenyPolicyPath = "..\policies\DenyPolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if ($_ -and -not (Test-Path $_)) {
            throw "TrustedApp policy file not found at: $_"
        }
        return $true
    })]
    [string]$TrustedAppPolicyPath = "..\policies\TrustedApp.xml",
    
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        $parentDir = Split-Path $_ -Parent
        if ($parentDir -and -not (Test-Path $parentDir)) {
            throw "Output directory does not exist: $parentDir"
        }
        return $true
    })]
    [string]$OutputPath = "..\policies\MergedPolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [switch]$ConvertToBinary
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

Write-Log "Starting WDAC Policy Merge Process" "INFO"

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

Write-Log "Merging WDAC policies..." "INFO"

# Create temporary directory for intermediate files
$TempDir = "$env:TEMP\WDACMerge"
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
    
    # Copy final merged policy to output location
    try {
        Copy-Item $TempBasePolicy $OutputPath -Force -ErrorAction Stop
        Write-Log "Policy merge completed successfully. Output saved to $OutputPath" "SUCCESS"
    } catch {
        Write-Log "Failed to save merged policy: $($_.Exception.Message)" "ERROR"
        exit 1
    }
    
    # Convert to binary if requested
    if ($ConvertToBinary) {
        $BinaryOutputPath = [System.IO.Path]::ChangeExtension($OutputPath, ".p7b")
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