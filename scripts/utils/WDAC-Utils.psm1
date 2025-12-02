# Utility functions for WDAC operations
# Import this module in other scripts: Import-Module .\scripts\utils\WDAC-Utils.psm1

function Get-WDACStatus {
    <#
    .SYNOPSIS
        Gets the current WDAC policy status
    .DESCRIPTION
        Retrieves information about the currently deployed WDAC policy
    .EXAMPLE
        Get-WDACStatus
    #>
    
    [CmdletBinding()]
    param()
    
    try {
        Write-Host "Checking WDAC policy status..." -ForegroundColor Green
        
        # Check if policy file exists
        $PolicyPath = "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
        if (Test-Path $PolicyPath) {
            $PolicyInfo = Get-ItemProperty $PolicyPath
            Write-Host "Policy Status: ACTIVE" -ForegroundColor Green
            Write-Host "Policy Location: $PolicyPath" -ForegroundColor Yellow
            Write-Host "Last Modified: $($PolicyInfo.LastWriteTime)" -ForegroundColor Yellow
            Write-Host "Size: $($PolicyInfo.Length) bytes" -ForegroundColor Yellow
        } else {
            Write-Host "Policy Status: INACTIVE" -ForegroundColor Red
            Write-Host "No policy file found at $PolicyPath" -ForegroundColor Yellow
        }
        
        # Check Code Integrity events
        Write-Host "`nRecent Code Integrity Events:" -ForegroundColor Cyan
        $Events = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-CodeIntegrity/Operational'; Level=2} -MaxEvents 5 -ErrorAction SilentlyContinue
        if ($Events) {
            $Events | Format-Table TimeCreated, Id, LevelDisplayName, Message -AutoSize
        } else {
            Write-Host "No recent Code Integrity events found" -ForegroundColor Yellow
        }
    } catch {
        Write-Error "Failed to get WDAC status: $_"
    }
}

function New-WDACPolicyFromLogs {
    <#
    .SYNOPSIS
        Creates a WDAC policy based on audit logs
    .DESCRIPTION
        Generates a WDAC policy from Code Integrity audit events
    .PARAMETER LogPath
        Path to save the audit log file
    .PARAMETER OutputPath
        Path to save the generated policy
    .EXAMPLE
        New-WDACPolicyFromLogs -LogPath "C:\temp\auditlogs.evtx" -OutputPath "C:\temp\newpolicy.xml"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$LogPath = "$env:TEMP\WDACAuditLogs.evtx",
        
        [Parameter(Mandatory=$false)]
        [string]$OutputPath = "$env:TEMP\WDACPolicyFromLogs.xml"
    )
    
    try {
        Write-Host "Creating WDAC policy from audit logs..." -ForegroundColor Green
        
        # Export audit logs
        Write-Host "Exporting Code Integrity audit logs..." -ForegroundColor Yellow
        wevtutil epl "Microsoft-Windows-CodeIntegrity/Operational" $LogPath
        
        if (Test-Path $LogPath) {
            Write-Host "Audit logs exported to $LogPath" -ForegroundColor Green
            
            # Create policy from logs
            Write-Host "Generating WDAC policy from logs..." -ForegroundColor Yellow
            New-CIPolicy -Audit -Path $OutputPath -Level FilePublisher -UserPEs
            
            if (Test-Path $OutputPath) {
                Write-Host "Policy created successfully at $OutputPath" -ForegroundColor Green
            } else {
                Write-Warning "Failed to create policy from logs"
            }
        } else {
            Write-Warning "Failed to export audit logs"
        }
    } catch {
        Write-Error "Failed to create policy from logs: $_"
    }
}

function Test-WDACPolicy {
    <#
    .SYNOPSIS
        Tests a WDAC policy for validity
    .DESCRIPTION
        Validates a WDAC policy XML file for syntax and structure
    .PARAMETER PolicyPath
        Path to the policy file to test
    .EXAMPLE
        Test-WDACPolicy -PolicyPath "C:\policies\MyPolicy.xml"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$PolicyPath
    )
    
    if (-not (Test-Path $PolicyPath)) {
        Write-Error "Policy file not found at $PolicyPath"
        return $false
    }
    
    try {
        Write-Host "Testing WDAC policy at $PolicyPath..." -ForegroundColor Green
        
        # Load and validate XML structure
        [xml]$Policy = Get-Content $PolicyPath
        if ($Policy.Policy) {
            Write-Host "XML structure: VALID" -ForegroundColor Green
            
            # Check required elements
            $RequiredElements = @("Rules", "FileRules", "Signers", "SigningScenarios")
            foreach ($Element in $RequiredElements) {
                if ($Policy.Policy.$Element) {
                    Write-Host "$Element: FOUND" -ForegroundColor Green
                } else {
                    Write-Host "$Element: MISSING" -ForegroundColor Red
                }
            }
            
            # Validate policy type
            $PolicyType = $Policy.Policy.PolicyType
            if ($PolicyType) {
                Write-Host "Policy Type: $PolicyType" -ForegroundColor Yellow
            } else {
                Write-Host "Policy Type: UNKNOWN" -ForegroundColor Red
            }
            
            Write-Host "Policy test completed." -ForegroundColor Green
            return $true
        } else {
            Write-Error "Invalid policy XML structure"
            return $false
        }
    } catch {
        Write-Error "Failed to test policy: $_"
        return $false
    }
}

Export-ModuleMember -Function Get-WDACStatus, New-WDACPolicyFromLogs, Test-WDACPolicy