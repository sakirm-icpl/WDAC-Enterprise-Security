# Policy-Validator.ps1
# Validates WDAC policy files for syntax and structural correctness

function Test-WDACPolicySyntax {
    <#
    .SYNOPSIS
    Validates the syntax of a WDAC XML policy file
    
    .PARAMETER PolicyPath
    Path to the WDAC XML policy file to validate
    
    .EXAMPLE
    Test-WDACPolicySyntax -PolicyPath "C:\Policies\BasePolicy.xml"
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$PolicyPath
    )
    
    try {
        # Check if file exists
        if (-not (Test-Path $PolicyPath)) {
            Write-Error "Policy file not found: $PolicyPath"
            return $false
        }
        
        # Load XML and validate structure
        [xml]$PolicyXml = Get-Content $PolicyPath
        
        # Check for required elements
        if (-not $PolicyXml.Policy) {
            Write-Error "Invalid policy structure: Missing Policy root element"
            return $false
        }
        
        # Validate PolicyType
        $validPolicyTypes = @("Base Policy", "Supplemental Policy")
        if ($PolicyXml.Policy.PolicyType -notin $validPolicyTypes) {
            Write-Warning "Unexpected PolicyType: $($PolicyXml.Policy.PolicyType). Expected: Base Policy or Supplemental Policy"
        }
        
        # Check for VersionEx
        if (-not $PolicyXml.Policy.VersionEx) {
            Write-Warning "Missing VersionEx element"
        }
        
        # For Base policies, check for PlatformID
        if ($PolicyXml.Policy.PolicyType -eq "Base Policy" -and -not $PolicyXml.Policy.PlatformID) {
            Write-Warning "Missing PlatformID in Base Policy"
        }
        
        # For Supplemental policies, check for BasePolicyID
        if ($PolicyXml.Policy.PolicyType -eq "Supplemental Policy" -and -not $PolicyXml.Policy.BasePolicyID) {
            Write-Warning "Missing BasePolicyID in Supplemental Policy"
        }
        
        Write-Host "Policy syntax validation passed for: $PolicyPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Policy syntax validation failed for $PolicyPath : $($_.Exception.Message)"
        return $false
    }
}

function Test-WDACPolicyRules {
    <#
    .SYNOPSIS
    Validates the rules configuration in a WDAC policy
    
    .PARAMETER PolicyPath
    Path to the WDAC XML policy file to validate
    
    .EXAMPLE
    Test-WDACPolicyRules -PolicyPath "C:\Policies\BasePolicy.xml"
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$PolicyPath
    )
    
    try {
        [xml]$PolicyXml = Get-Content $PolicyPath
        
        # Check for required rules
        $rules = $PolicyXml.Policy.Rules.Rule.Option
        $requiredRules = @(
            "Enabled:Unsigned System Integrity Policy",
            "Enabled:UMCI"
        )
        
        foreach ($requiredRule in $requiredRules) {
            if ($requiredRule -notin $rules) {
                Write-Warning "Missing required rule: $requiredRule"
            }
        }
        
        # Check for audit/enforce mode
        $auditMode = "Enabled:Audit Mode"
        $enforceMode = "Enabled:Enforced Mode"
        
        if ($auditMode -notin $rules -and $enforceMode -notin $rules) {
            Write-Warning "Policy should have either Audit Mode or Enforced Mode enabled"
        }
        
        Write-Host "Policy rules validation completed for: $PolicyPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Policy rules validation failed for $PolicyPath : $($_.Exception.Message)"
        return $false
    }
}

function Convert-WDACPolicyToBinary {
    <#
    .SYNOPSIS
    Converts a WDAC XML policy to binary format
    
    .PARAMETER XmlPath
    Path to the XML policy file
    
    .PARAMETER BinaryPath
    Path where the binary policy should be saved
    
    .EXAMPLE
    Convert-WDACPolicyToBinary -XmlPath "policy.xml" -BinaryPath "policy.bin"
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$XmlPath,
        
        [Parameter(Mandatory=$true)]
        [string]$BinaryPath
    )
    
    try {
        if (-not (Test-Path $XmlPath)) {
            Write-Error "XML policy file not found: $XmlPath"
            return $false
        }
        
        ConvertFrom-CIPolicy -XmlFilePath $XmlPath -BinaryFilePath $BinaryPath
        Write-Host "Successfully converted $XmlPath to $BinaryPath" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to convert policy: $($_.Exception.Message)"
        return $false
    }
}

# Export functions
Export-ModuleMember -Function *