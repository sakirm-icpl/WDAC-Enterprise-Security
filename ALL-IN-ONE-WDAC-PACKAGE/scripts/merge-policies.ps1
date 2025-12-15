# PowerShell script to merge Base, Deny, and TrustedApp policies
# Usage: .\merge_policies.ps1

param(
    [Parameter(Mandatory=$false)]
    [string]$BasePolicyPath = "..\policies\BasePolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$DenyPolicyPath = "..\policies\DenyPolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$TrustedAppPolicyPath = "..\policies\TrustedApp.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "..\policies\MergedPolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [switch]$ConvertToBinary
)

# Check if policies exist
if (-not (Test-Path $BasePolicyPath)) {
    Write-Error "Base policy not found at $BasePolicyPath"
    exit 1
}

if (-not (Test-Path $DenyPolicyPath)) {
    Write-Warning "Deny policy not found at $DenyPolicyPath. Continuing without it."
    $DenyPolicyPath = $null
}

if (-not (Test-Path $TrustedAppPolicyPath)) {
    Write-Warning "TrustedApp policy not found at $TrustedAppPolicyPath. Continuing without it."
    $TrustedAppPolicyPath = $null
}

Write-Host "Merging WDAC policies..." -ForegroundColor Green

# Create temporary directory for intermediate files
$TempDir = "$env:TEMP\WDACMerge"
if (-not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir | Out-Null
}

try {
    # Copy base policy to temp directory
    $TempBasePolicy = Join-Path $TempDir "BasePolicy.xml"
    Copy-Item $BasePolicyPath $TempBasePolicy -Force
    
    # Merge deny policy if it exists
    if ($DenyPolicyPath) {
        Write-Host "Merging deny policy..." -ForegroundColor Yellow
        $TempMergedPolicy1 = Join-Path $TempDir "MergedPolicy1.xml"
        Merge-CIPolicy -PolicyPaths $TempBasePolicy, $DenyPolicyPath -OutputFilePath $TempMergedPolicy1
        Move-Item $TempMergedPolicy1 $TempBasePolicy -Force
    }
    
    # Merge trusted app policy if it exists
    if ($TrustedAppPolicyPath) {
        Write-Host "Merging trusted app policy..." -ForegroundColor Yellow
        $TempMergedPolicy2 = Join-Path $TempDir "MergedPolicy2.xml"
        Merge-CIPolicy -PolicyPaths $TempBasePolicy, $TrustedAppPolicyPath -OutputFilePath $TempMergedPolicy2
        Move-Item $TempMergedPolicy2 $TempBasePolicy -Force
    }
    
    # Copy final merged policy to output location
    Copy-Item $TempBasePolicy $OutputPath -Force
    Write-Host "Policy merge completed successfully. Output saved to $OutputPath" -ForegroundColor Green
    
    # Convert to binary if requested
    if ($ConvertToBinary) {
        $BinaryOutputPath = [System.IO.Path]::ChangeExtension($OutputPath, ".p7b")
        Write-Host "Converting policy to binary format..." -ForegroundColor Yellow
        ConvertFrom-CIPolicy -XmlFilePath $OutputPath -BinaryFilePath $BinaryOutputPath
        Write-Host "Binary policy saved to $BinaryOutputPath" -ForegroundColor Green
    }
} catch {
    Write-Error "Failed to merge policies: $_"
    exit 1
} finally {
    # Clean up temporary files
    if (Test-Path $TempDir) {
        Remove-Item $TempDir -Recurse -Force
    }
}

Write-Host "Policy merge process completed." -ForegroundColor Green