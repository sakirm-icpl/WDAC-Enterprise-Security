# PowerShell script to deploy policy in Enforce mode
# Usage: .\convert_to_enforce_mode.ps1 [-PolicyPath "path\to\policy.xml"] [-OutputPath "path\to/output.xml"] [-Deploy]

param(
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = "..\policies\MergedPolicy.xml",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "..\policies\MergedPolicy_Enforce.xml",
    
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

Write-Log "Starting WDAC Policy Conversion to Enforce Mode" "INFO"

# Check if policy exists
if (-not (Test-Path $PolicyPath)) {
    Write-Log "Policy file not found at $PolicyPath" "ERROR"
    exit 1
} else {
    Write-Log "Policy file found: $PolicyPath" "SUCCESS"
}

Write-Log "Converting policy to Enforce mode..." "INFO"

try {
    # Load the policy
    Write-Log "Loading policy XML..." "INFO"
    [xml]$Policy = Get-Content $PolicyPath -ErrorAction Stop
    
    # Find or create the Enforce Mode rule
    $RulesNode = $Policy.Policy.Rules
    $EnforceRule = $RulesNode.Rule | Where-Object { $_.Option -eq "Enabled:Enforce Mode" }
    
    if (-not $EnforceRule) {
        # Create the enforce mode rule if it doesn't exist
        Write-Log "Adding Enforce Mode rule to policy" "INFO"
        $EnforceRule = $Policy.CreateElement("Rule")
        $Option = $Policy.CreateElement("Option")
        $Option.InnerText = "Enabled:Enforce Mode"
        $EnforceRule.AppendChild($Option) | Out-Null
        $RulesNode.AppendChild($EnforceRule) | Out-Null
        Write-Log "Added Enforce Mode rule to policy" "SUCCESS"
    } else {
        Write-Log "Enforce Mode rule already exists in policy" "WARN"
    }
    
    # Remove Audit Mode rule if it exists
    $AuditRule = $RulesNode.Rule | Where-Object { $_.Option -eq "Enabled:Audit Mode" }
    if ($AuditRule) {
        Write-Log "Removing Audit Mode rule from policy" "INFO"
        $RulesNode.RemoveChild($AuditRule) | Out-Null
        Write-Log "Removed Audit Mode rule from policy" "SUCCESS"
    }
    
    # Save the enforce policy
    Write-Log "Saving enforce policy to $OutputPath" "INFO"
    $Policy.Save($OutputPath)
    Write-Log "Enforce policy saved to $OutputPath" "SUCCESS"
    
    # Deploy if requested
    if ($Deploy) {
        Write-Log "Deploying enforce policy..." "INFO"
        
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
            Write-Log "Enforce policy deployed to $DeployPath" "SUCCESS"
        } catch {
            Write-Log "Failed to deploy policy: $($_.Exception.Message)" "ERROR"
            exit 1
        }
        
        Write-Log "IMPORTANT: Restart the computer for changes to take effect" "WARN"
    }
    
    Write-Log "Conversion to Enforce mode completed successfully." "SUCCESS"
} catch {
    Write-Log "Failed to convert policy to Enforce mode: $($_.Exception.Message)" "ERROR"
    exit 1
}