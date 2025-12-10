# PowerShell script to convert merged policy to Audit mode
# Usage: .\convert_to_audit_mode.ps1 [-PolicyPath "path\to\policy.xml"] [-OutputPath "path\to\output.xml"]

param(
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = "..\policies\MergedPolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "..\policies\MergedPolicy_Audit.xml",
    
    [Parameter(Mandatory=$false)]
    [switch]$Deploy
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

Write-Log "Starting WDAC Policy Conversion to Audit Mode" "INFO"

# Check if policy exists
if (-not (Test-Path $PolicyPath)) {
    Write-Log "Policy file not found at $PolicyPath" "ERROR"
    exit 1
} else {
    Write-Log "Policy file found: $PolicyPath" "SUCCESS"
}

Write-Log "Converting policy to Audit mode..." "INFO"

try {
    # Load the policy
    Write-Log "Loading policy XML..." "INFO"
    [xml]$Policy = Get-Content $PolicyPath -ErrorAction Stop
    
    # Find or create the Audit Mode rule
    $RulesNode = $Policy.Policy.Rules
    $AuditRule = $RulesNode.Rule | Where-Object { $_.Option -eq "Enabled:Audit Mode" }
    
    if (-not $AuditRule) {
        # Create the audit mode rule if it doesn't exist
        Write-Log "Adding Audit Mode rule to policy" "INFO"
        $AuditRule = $Policy.CreateElement("Rule")
        $Option = $Policy.CreateElement("Option")
        $Option.InnerText = "Enabled:Audit Mode"
        $AuditRule.AppendChild($Option) | Out-Null
        $RulesNode.AppendChild($AuditRule) | Out-Null
        Write-Log "Added Audit Mode rule to policy" "SUCCESS"
    } else {
        Write-Log "Audit Mode rule already exists in policy" "WARN"
    }
    
    # Remove Enforce Mode rule if it exists
    $EnforceRule = $RulesNode.Rule | Where-Object { $_.Option -eq "Enabled:Enforce Mode" }
    if ($EnforceRule) {
        Write-Log "Removing Enforce Mode rule from policy" "INFO"
        $RulesNode.RemoveChild($EnforceRule) | Out-Null
        Write-Log "Removed Enforce Mode rule from policy" "SUCCESS"
    }
    
    # Save the audit policy
    Write-Log "Saving audit policy to $OutputPath" "INFO"
    $Policy.Save($OutputPath)
    Write-Log "Audit policy saved to $OutputPath" "SUCCESS"
    
    # Deploy if requested
    if ($Deploy) {
        Write-Log "Deploying audit policy..." "INFO"
        
        # Convert to binary
        $BinaryPath = [System.IO.Path]::ChangeExtension($OutputPath, ".p7b")
        Write-Log "Converting policy to binary format: $BinaryPath" "INFO"
        try {
            ConvertFrom-CIPolicy -XmlFilePath $OutputPath -BinaryFilePath $BinaryPath -ErrorAction Stop
            Write-Log "Policy converted to binary format successfully" "SUCCESS"
        } catch {
            Write-Log "Failed to convert policy to binary format: $($_.Exception.Message)" "ERROR"
            exit 1
        }
        
        # Deploy the policy
        $DeployPath = "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
        Write-Log "Deploying policy to $DeployPath" "INFO"
        try {
            Copy-Item -Path $BinaryPath -Destination $DeployPath -Force -ErrorAction Stop
            Write-Log "Audit policy deployed to $DeployPath" "SUCCESS"
        } catch {
            Write-Log "Failed to deploy policy: $($_.Exception.Message)" "ERROR"
            exit 1
        }
        
        Write-Log "IMPORTANT: Restart the computer for changes to take effect" "WARN"
    }
    
    Write-Log "Conversion to Audit mode completed successfully." "SUCCESS"
} catch {
    Write-Log "Failed to convert policy to Audit mode: $($_.Exception.Message)" "ERROR"
    exit 1
}