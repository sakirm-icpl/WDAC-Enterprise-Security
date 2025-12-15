# PowerShell script to deploy policy in Audit mode
# Usage: .\convert_to_audit_mode.ps1 [-PolicyPath "path\to\policy.xml"] [-OutputPath "path\to/output.xml"] [-Deploy]

param(
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = "..\policies\MergedPolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "..\policies\MergedPolicy_Audit.xml",
    
    [Parameter(Mandatory=$false)]
    [switch]$Deploy
)

# Check if policy exists
if (-not (Test-Path $PolicyPath)) {
    Write-Error "Policy file not found at $PolicyPath"
    exit 1
}

Write-Host "Converting policy to Audit mode..." -ForegroundColor Green

try {
    # Load the policy
    [xml]$Policy = Get-Content $PolicyPath
    
    # Find or create the Audit Mode rule
    $RulesNode = $Policy.Policy.Rules
    $AuditRule = $RulesNode.Rule | Where-Object { $_.Option -eq "Enabled:Audit Mode" }
    
    if (-not $AuditRule) {
        # Create the audit mode rule if it doesn't exist
        $AuditRule = $Policy.CreateElement("Rule")
        $Option = $Policy.CreateElement("Option")
        $Option.InnerText = "Enabled:Audit Mode"
        $AuditRule.AppendChild($Option) | Out-Null
        $RulesNode.AppendChild($AuditRule) | Out-Null
        Write-Host "Added Audit Mode rule to policy" -ForegroundColor Yellow
    } else {
        Write-Host "Audit Mode rule already exists in policy" -ForegroundColor Yellow
    }
    
    # Remove Enforce Mode rule if it exists
    $EnforceRule = $RulesNode.Rule | Where-Object { $_.Option -eq "Enabled:Enforce Mode" }
    if ($EnforceRule) {
        $RulesNode.RemoveChild($EnforceRule) | Out-Null
        Write-Host "Removed Enforce Mode rule from policy" -ForegroundColor Yellow
    }
    
    # Save the audit policy
    $Policy.Save($OutputPath)
    Write-Host "Audit policy saved to $OutputPath" -ForegroundColor Green
    
    # Deploy if requested
    if ($Deploy) {
        Write-Host "Deploying audit policy..." -ForegroundColor Yellow
        
        # Convert to binary
        $BinaryPath = [System.IO.Path]::ChangeExtension($OutputPath, ".p7b")
        ConvertFrom-CIPolicy -XmlFilePath $OutputPath -BinaryFilePath $BinaryPath
        
        # Deploy the policy
        $DeployPath = "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
        Copy-Item -Path $BinaryPath -Destination $DeployPath -Force
        Write-Host "Audit policy deployed to $DeployPath" -ForegroundColor Green
        
        Write-Host "IMPORTANT: Restart the computer for changes to take effect" -ForegroundColor Red
    }
    
    Write-Host "Conversion to Audit mode completed successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to convert policy to Audit mode: $_"
    exit 1
}