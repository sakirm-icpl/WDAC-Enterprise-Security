# generate-policy-from-template.ps1
# Generates WDAC policy files from templates using organization configuration

param(
    [Parameter(Mandatory=$false)]
    [string]$TemplatePath = "..\templates\parametrized-base-policy.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigPath = "..\config\organization-config.json",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "..\policies\generated-base-policy.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$Mode = "Enabled:Audit Mode",
    
    [Parameter(Mandatory=$false)]
    [string]$Version = "1.0.0.0"
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

Write-Log "Starting WDAC Policy Generation from Template" "INFO"

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
    $PolicyContent = $PolicyContent -replace "{{MODE}}", $Mode
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
    
} catch {
    Write-Log "Failed to generate policy: $($_.Exception.Message)" "ERROR"
    exit 1
}