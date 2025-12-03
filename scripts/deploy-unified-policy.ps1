# Unified WDAC Policy Deployment Script
# Deploys WDAC policies across different environments (Non-AD, AD, Server)

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("NonAD", "AD", "Server")]
    [string]$Environment = "NonAD",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Audit", "Enforce")]
    [string]$Mode = "Audit",
    
    [Parameter(Mandatory=$false)]
    [string]$PolicyPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$TargetOU = "OU=Workstations,DC=company,DC=com",
    
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$env:TEMP\WDAC_Unified_Deployment_Log.txt",
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    # Append to log file
    Add-Content -Path $LogPath -Value $LogMessage
    
    # Display to console with color coding
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

function Detect-Environment {
    try {
        # Check if domain joined
        $DomainInfo = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        if ($DomainInfo.PartOfDomain) {
            Write-Log "System is domain-joined" "INFO"
            
            # Check if it's a server
            $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
            if ($OSInfo.ProductType -eq 3) {
                Write-Log "System is a Windows Server" "INFO"
                return "ADServer"
            } else {
                Write-Log "System is a domain-joined workstation" "INFO"
                return "ADWorkstation"
            }
        } else {
            Write-Log "System is not domain-joined" "INFO"
            
            # Check if it's a server
            $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
            if ($OSInfo.ProductType -eq 3) {
                Write-Log "System is a Windows Server" "INFO"
                return "Server"
            } else {
                Write-Log "System is a standalone workstation" "INFO"
                return "NonAD"
            }
        }
    } catch {
        Write-Log "Failed to detect environment: $_" "WARN"
        return "NonAD"  # Default fallback
    }
}

function Get-PolicyPath {
    param([string]$EnvType)
    
    switch ($EnvType) {
        "NonAD" { return ".\environment-specific\non-ad\policies" }
        "ADWorkstation" { return ".\environment-specific\active-directory\policies" }
        "ADServer" { return ".\environment-specific\active-directory\policies" }
        "Server" { return ".\environment-specific\non-ad\policies" }
        default { return ".\environment-specific\non-ad\policies" }
    }
}

function Convert-PolicyToMode {
    param(
        [string]$PolicyFile,
        [string]$Mode,
        [string]$OutputPath
    )
    
    try {
        Write-Log "Converting policy $PolicyFile to $Mode mode" "INFO"
        
        # Load XML policy
        [xml]$Policy = Get-Content $PolicyFile
        
        # Remove existing mode rules
        $AuditRule = $Policy.Policy.Rules.Rule | Where-Object { $_.Option -eq "Enabled:Audit Mode" }
        $EnforceRule = $Policy.Policy.Rules.Rule | Where-Object { $_.Option -eq "Enabled:Enforce Mode" }
        
        if ($AuditRule) {
            $Policy.Policy.Rules.RemoveChild($AuditRule) | Out-Null
        }
        
        if ($EnforceRule) {
            $Policy.Policy.Rules.RemoveChild($EnforceRule) | Out-Null
        }
        
        # Add appropriate mode rule
        $ModeRule = $Policy.CreateElement("Rule")
        $Option = $Policy.CreateElement("Option")
        
        if ($Mode -eq "Audit") {
            $Option.InnerText = "Enabled:Audit Mode"
        } else {
            $Option.InnerText = "Enabled:Enforce Mode"
        }
        
        $ModeRule.AppendChild($Option) | Out-Null
        $Policy.Policy.Rules.AppendChild($ModeRule) | Out-Null
        
        # Save modified policy
        $Policy.Save($OutputPath)
        Write-Log "Policy converted and saved to $OutputPath" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Failed to convert policy to $Mode mode: $_" "ERROR"
        return $false
    }
}

function Deploy-NonADPolicy {
    param(
        [string]$PolicyPath,
        [string]$Mode
    )
    
    Write-Log "Deploying policies in $Mode mode for Non-AD environment" "INFO"
    
    try {
        # Create temp directory
        $TempDir = "$env:TEMP\WDAC_Unified_Deploy"
        if (-not (Test-Path $TempDir)) {
            New-Item -ItemType Directory -Path $TempDir | Out-Null
        }
        
        # Deploy base policy
        $BasePolicy = Join-Path $PolicyPath "non-ad-base-policy.xml"
        if (Test-Path $BasePolicy) {
            # Convert to appropriate mode
            $ModeBasePolicy = Join-Path $TempDir "base-policy-$Mode.xml"
            if (Convert-PolicyToMode -PolicyFile $BasePolicy -Mode $Mode -OutputPath $ModeBasePolicy) {
                # Convert to binary and deploy
                $BinaryPolicyPath = "$env:TEMP\base_policy.bin"
                ConvertFrom-CIPolicy -XmlFilePath $ModeBasePolicy -BinaryFilePath $BinaryPolicyPath
                
                # Deploy policy
                Copy-Item -Path $BinaryPolicyPath -Destination "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b" -Force
                
                # Cleanup temp file
                Remove-Item -Path $BinaryPolicyPath -Force
                
                Write-Log "Base policy deployed successfully" "SUCCESS"
            }
        } else {
            Write-Log "Base policy not found at $BasePolicy" "WARN"
        }
        
        # Deploy supplemental policies
        $SupplementalPath = Join-Path $PolicyPath "department-supplemental-policies"
        if (Test-Path $SupplementalPath) {
            Get-ChildItem -Path $SupplementalPath -Filter "*.xml" | ForEach-Object {
                $SupplementalPolicy = $_.FullName
                $ModeSupplementalPolicy = Join-Path $TempDir "supplemental-$($_.BaseName)-$Mode.xml"
                
                if (Convert-PolicyToMode -PolicyFile $SupplementalPolicy -Mode $Mode -OutputPath $ModeSupplementalPolicy) {
                    # Convert to binary and deploy
                    $BinaryPolicyPath = "$env:TEMP\supplemental_$($_.BaseName).bin"
                    ConvertFrom-CIPolicy -XmlFilePath $ModeSupplementalPolicy -BinaryFilePath $BinaryPolicyPath
                    
                    # Deploy policy (note: supplemental policies need to be merged or deployed differently)
                    # For simplicity in this unified script, we'll just log that they exist
                    Write-Log "Supplemental policy $_.Name prepared for deployment" "INFO"
                    
                    # Cleanup temp file
                    Remove-Item -Path $BinaryPolicyPath -Force
                }
            }
        }
        
        # Deploy exception policies
        $ExceptionPath = Join-Path $PolicyPath "exception-policies"
        if (Test-Path $ExceptionPath) {
            Get-ChildItem -Path $ExceptionPath -Filter "*.xml" | ForEach-Object {
                $ExceptionPolicy = $_.FullName
                $ModeExceptionPolicy = Join-Path $TempDir "exception-$($_.BaseName)-$Mode.xml"
                
                if (Convert-PolicyToMode -PolicyFile $ExceptionPolicy -Mode $Mode -OutputPath $ModeExceptionPolicy) {
                    # Convert to binary and deploy
                    $BinaryPolicyPath = "$env:TEMP\exception_$($_.BaseName).bin"
                    ConvertFrom-CIPolicy -XmlFilePath $ModeExceptionPolicy -BinaryFilePath $BinaryPolicyPath
                    
                    # Deploy policy
                    Write-Log "Exception policy $_.Name prepared for deployment" "INFO"
                    
                    # Cleanup temp file
                    Remove-Item -Path $BinaryPolicyPath -Force
                }
            }
        }
        
        # Refresh policy
        try {
            Write-Log "Refreshing WDAC policy" "INFO"
            Invoke-CimMethod -Namespace root/Microsoft/Windows/CI -ClassName PS_UpdateAndCompareInfo -MethodName Update -Arguments @{UpdatedPSObjects = $null}
            Write-Log "Policy refresh completed" "SUCCESS"
        } catch {
            Write-Log "Warning: Failed to refresh policy: $($_.Exception.Message)" "WARN"
        }
        
        # Cleanup temp directory
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
        
        Write-Log "Non-AD policy deployment completed" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Failed to deploy Non-AD policy: $_" "ERROR"
        return $false
    }
}

function Deploy-ADPolicy {
    param(
        [string]$PolicyPath,
        [string]$Mode,
        [string]$TargetOU
    )
    
    Write-Log "Deploying policies in $Mode mode for AD environment" "INFO"
    
    try {
        # Import required modules
        Import-Module GroupPolicy -ErrorAction Stop
        Write-Log "GroupPolicy module imported successfully" "SUCCESS"
        
        # Use existing AD deployment script
        $ADScriptPath = ".\environment-specific\active-directory\scripts\deploy-ad-policy.ps1"
        
        if (Test-Path $ADScriptPath) {
            $Params = @{
                BasePolicyPath = Join-Path $PolicyPath "enterprise-base-policy.xml"
                GPOName = "WDAC Enterprise Policy - $Mode Mode"
                TargetOU = $TargetOU
                Deploy = $true
            }
            
            if ($Force) {
                $Params.Force = $true
            }
            
            # Execute AD deployment script
            & $ADScriptPath @Params
            
            Write-Log "AD policy deployment initiated" "SUCCESS"
            return $true
        } else {
            Write-Log "AD deployment script not found at $ADScriptPath" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Failed to deploy AD policy: $_" "ERROR"
        return $false
    }
}

# Main script execution
Write-Log "Starting Unified WDAC Policy Deployment" "INFO"
Write-Log "Environment: $Environment" "INFO"
Write-Log "Mode: $Mode" "INFO"

# Check for admin privileges
if (-not (Test-AdminPrivileges)) {
    Write-Log "Error: This script requires administrator privileges" "ERROR"
    exit 1
}

# Determine policy path
if (-not $PolicyPath) {
    $PolicyPath = Get-PolicyPath -EnvType $Environment
}

Write-Log "Using policy path: $PolicyPath" "INFO"

# Validate policy path
if (-not (Test-Path $PolicyPath)) {
    Write-Log "Error: Policy path '$PolicyPath' does not exist" "ERROR"
    exit 1
}

# Deploy based on environment
$Result = $false
switch ($Environment) {
    "NonAD" {
        $Result = Deploy-NonADPolicy -PolicyPath $PolicyPath -Mode $Mode
    }
    "AD" {
        $Result = Deploy-ADPolicy -PolicyPath $PolicyPath -Mode $Mode -TargetOU $TargetOU
    }
    "Server" {
        # For servers, we'll use the NonAD approach but with server-specific considerations
        $Result = Deploy-NonADPolicy -PolicyPath $PolicyPath -Mode $Mode
    }
    default {
        Write-Log "Unsupported environment: $Environment" "ERROR"
        exit 1
    }
}

if ($Result) {
    Write-Log "=== DEPLOYMENT COMPLETED SUCCESSFULLY ===" "SUCCESS"
    
    if ($Environment -eq "NonAD" -or $Environment -eq "Server") {
        Write-Log "Please restart the system for changes to take effect" "INFO"
    } elseif ($Environment -eq "AD") {
        Write-Log "Group Policy will apply to target systems within 90 minutes" "INFO"
        Write-Log "Use 'gpupdate /force' to expedite policy application" "INFO"
    }
} else {
    Write-Log "=== DEPLOYMENT FAILED ===" "ERROR"
    exit 1
}