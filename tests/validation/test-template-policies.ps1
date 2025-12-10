# test-template-policies.ps1
# Validation tests for template policies

param(
    [string]$TestRoot = $PSScriptRoot
)

# Import required modules
try {
    Import-Module ConfigCI -ErrorAction Stop
} catch {
    Write-Host "SKIP: ConfigCI module not available. Skipping template policy tests." -ForegroundColor Yellow
    return $true
}

# Test results array
$testResults = @()

function Test-TemplateSyntax {
    param([string]$TemplatePath)
    
    try {
        # Load XML and validate structure
        [xml]$TemplateXml = Get-Content $TemplatePath -ErrorAction Stop
        
        # Check for required elements
        if (-not $TemplateXml.Policy) {
            Write-Host "FAIL: Invalid template structure: Missing Policy root element in $TemplatePath" -ForegroundColor Red
            return $false
        }
        
        # Validate PolicyType
        $validPolicyTypes = @("Base Policy", "Supplemental Policy")
        if ($TemplateXml.Policy.PolicyType -notin $validPolicyTypes) {
            Write-Host "WARN: Unexpected PolicyType in $TemplatePath. Expected: Base Policy or Supplemental Policy" -ForegroundColor Yellow
        }
        
        # Check for template placeholders
        $templateContent = Get-Content $TemplatePath -Raw
        $placeholders = @{
            "VERSION" = "{{VERSION}}"
            "MODE" = "{{MODE}}"
            "PLATFORM_ID" = "{{PLATFORM_ID}}"
            "GENERATION_DATE" = "{{GENERATION_DATE}}"
        }
        
        $missingPlaceholders = @()
        foreach ($placeholder in $placeholders.Values) {
            if ($templateContent -notmatch [regex]::Escape($placeholder)) {
                $missingPlaceholders += $placeholder
            }
        }
        
        if ($missingPlaceholders.Count -gt 0) {
            Write-Host "WARN: Missing placeholders in $TemplatePath : $($missingPlaceholders -join ', ')" -ForegroundColor Yellow
        }
        
        Write-Host "PASS: Template syntax validation passed for $TemplatePath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "FAIL: Template syntax validation failed for $TemplatePath : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-ParametrizedTemplates {
    Write-Host "Testing parametrized templates..." -ForegroundColor Cyan
    
    $templatePath = "$TestRoot\..\..\tools\templates"
    
    if (-not (Test-Path $templatePath)) {
        Write-Host "SKIP: Templates directory not found" -ForegroundColor Yellow
        return $true
    }
    
    $templates = Get-ChildItem -Path $templatePath -Filter "*.xml" -File
    
    if ($templates.Count -eq 0) {
        Write-Host "SKIP: No templates found" -ForegroundColor Yellow
        return $true
    }
    
    $result = $true
    foreach ($template in $templates) {
        $result = Test-TemplateSyntax -TemplatePath $template.FullName -and $result
    }
    
    return $result
}

function Test-SamplePolicyTemplates {
    Write-Host "Testing sample policy templates..." -ForegroundColor Cyan
    
    $sampleTemplatePath = "$TestRoot\..\..\samples"
    
    if (-not (Test-Path $sampleTemplatePath)) {
        Write-Host "SKIP: Sample templates directory not found" -ForegroundColor Yellow
        return $true
    }
    
    $templates = Get-ChildItem -Path $sampleTemplatePath -Filter "*.xml" -File -Recurse
    
    if ($templates.Count -eq 0) {
        Write-Host "SKIP: No sample templates found" -ForegroundColor Yellow
        return $true
    }
    
    $result = $true
    foreach ($template in $templates) {
        # Skip non-template files (actual policies)
        $content = Get-Content $template.FullName -Raw
        if ($content -match "{{.*}}") {
            $result = Test-TemplateSyntax -TemplatePath $template.FullName -and $result
        }
    }
    
    return $result
}

# Run tests
Write-Host "Running template policy validation tests..." -ForegroundColor Cyan

$testResults += Test-ParametrizedTemplates
$testResults += Test-SamplePolicyTemplates

# Return results
if ($testResults -notcontains $false) {
    Write-Host "All template policy validation tests passed" -ForegroundColor Green
    return $true
} else {
    Write-Host "Some template policy validation tests failed" -ForegroundColor Red
    return $false
}