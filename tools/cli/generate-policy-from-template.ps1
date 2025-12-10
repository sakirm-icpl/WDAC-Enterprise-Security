# generate-policy-from-template.ps1
# Generates WDAC policy files from templates using organization configuration

param(
    [Parameter(Mandatory=$false)]
    [string]$TemplatePath = "..\templates\parametrized-base-policy.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = "..\config\organization-config.json",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\generated-policy.xml",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Audit", "Enforce")]
    [string]$Mode = "Audit",
    
    [Parameter(Mandatory=$false)]
    [string]$Version = "1.0.0.0",
    
    [Parameter(Mandatory=$false)]
    [switch]$ConvertToBinary,
    
    [Parameter(Mandatory=$false)]
    [switch]$Validate
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

Write-Log "Starting WDAC Policy Generation from Template" "INFO"

# Check prerequisites
try {
    Write-Log "Checking PowerShell version compatibility..." "INFO"
    Test-PowerShellVersionCompatibility | Out-Null
    Write-Log "PowerShell version compatibility check passed" "SUCCESS"
} catch {
    Write-Log "PowerShell compatibility check failed: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Check if template exists
if (-not (Test-Path $TemplatePath)) {
    Write-Log "Template file not found at $TemplatePath" "ERROR"
    exit 1
}

# Check if config exists
if (-not (Test-Path $ConfigPath)) {
    Write-Log "Configuration file not found at $ConfigPath" "ERROR"
    exit 1
}

try {
    # Load template
    Write-Log "Loading policy template from $TemplatePath" "INFO"
    $TemplateContent = Get-Content $TemplatePath -Raw
    
    # Load configuration
    Write-Log "Loading organization configuration from $ConfigPath" "INFO"
    $Config = Get-Content $ConfigPath | ConvertFrom-Json
    
    # Replace placeholders with actual values
    Write-Log "Replacing template placeholders with configuration values" "INFO"
    
    # Basic replacements
    $PolicyContent = $TemplateContent
    $PolicyContent = $PolicyContent -replace "{{VERSION}}", $Version
    
    # Set mode
    $ModeValue = if ($Mode -eq "Audit") { "Enabled:Audit Mode" } else { "Enabled:Enforce Mode" }
    $PolicyContent = $PolicyContent -replace "{{MODE}}", $ModeValue
    
    $PolicyContent = $PolicyContent -replace "{{PLATFORM_ID}}", $Config.organization.platformId
    $PolicyContent = $PolicyContent -replace "{{GENERATION_DATE}}", (Get-Date -Format "MM-dd-yyyy")
    
    # Certificate replacements
    $PolicyContent = $PolicyContent -replace "{{WINDOWS_STORE_EKU}}", $Config.certificates.windowsStoreEKU
    $PolicyContent = $PolicyContent -replace "{{MICROSOFT_PRODUCT_SIGNING_ROOT}}", $Config.certificates.microsoftProductSigning
    $PolicyContent = $PolicyContent -replace "{{MICROSOFT_CODE_SIGNING_ROOT}}", $Config.certificates.microsoftCodeSigningPCA2011
    
    # Path replacements
    $PolicyContent = $PolicyContent -replace "{{PROGRAM_FILES_PATH}}", $Config.paths.programFiles
    $PolicyContent = $PolicyContent -replace "{{PROGRAM_FILES_X86_PATH}}", $Config.paths.programFilesX86
    $PolicyContent = $PolicyContent -replace "{{WINDOWS_FOLDER_PATH}}", $Config.paths.windowsFolder
    $PolicyContent = $PolicyContent -replace "{{DOWNLOADS_PATH}}", $Config.paths.downloads
    $PolicyContent = $PolicyContent -replace "{{TEMP_PATH}}", $Config.paths.temp
    $PolicyContent = $PolicyContent -replace "{{PUBLIC_PATH}}", $Config.paths.public
    
    # Save the generated policy
    Write-Log "Saving generated policy to $OutputPath" "INFO"
    $PolicyContent | Out-File -FilePath $OutputPath -Encoding UTF8
    
    Write-Log "Policy generation completed successfully" "SUCCESS"
    Write-Log "Generated policy saved to: $OutputPath" "INFO"
    
    # Validate if requested
    if ($Validate) {
        Write-Log "Validating generated policy..." "INFO"
        if (Test-PolicySyntax -PolicyPath $OutputPath) {
            Write-Log "Policy validation passed" "SUCCESS"
        } else {
            Write-Log "Policy validation failed" "ERROR"
            exit 1
        }
    }
    
    # Convert to binary if requested
    if ($ConvertToBinary) {
        Write-Log "Converting policy to binary format..." "INFO"
        try {
            $BinaryPath = [System.IO.Path]::ChangeExtension($OutputPath, ".bin")
            ConvertFrom-CIPolicy -XmlFilePath $OutputPath -BinaryFilePath $BinaryPath
            Write-Log "Policy converted to binary format: $BinaryPath" "SUCCESS"
        } catch {
            Write-Log "Failed to convert policy to binary format: $($_.Exception.Message)" "ERROR"
            exit 1
        }
    }
    
} catch {
    Write-Log "Failed to generate policy: $($_.Exception.Message)" "ERROR"
    exit 1
}