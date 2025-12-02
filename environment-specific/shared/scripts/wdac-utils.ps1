# WDAC-Utils.ps1
# Shared utility functions for WDAC policy management across all environments

function Test-AdminPrivileges {
    <#
    .SYNOPSIS
    Tests if the current session has administrator privileges
    
    .DESCRIPTION
    Checks if the current user has administrative rights required for WDAC policy management
    
    .EXAMPLE
    Test-AdminPrivileges
    #>
    
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $WindowsPrincipal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
    return $WindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-Log {
    <#
    .SYNOPSIS
    Writes a timestamped log entry to a file and console
    
    .PARAMETER Message
    The message to log
    
    .PARAMETER LogPath
    Path to the log file (defaults to TEMP directory)
    
    .EXAMPLE
    Write-Log "Policy deployment started"
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$LogPath = "$env:TEMP\WDAC_Util_Log.txt"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] $Message"
    Add-Content -Path $LogPath -Value $LogEntry
    Write-Host $LogEntry
}

function Convert-PolicyToBinary {
    <#
    .SYNOPSIS
    Converts a WDAC XML policy to binary format
    
    .PARAMETER XmlPath
    Path to the XML policy file
    
    .PARAMETER BinaryPath
    Path where the binary policy should be saved
    
    .EXAMPLE
    Convert-PolicyToBinary -XmlPath "policy.xml" -BinaryPath "policy.bin"
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$XmlPath,
        
        [Parameter(Mandatory=$true)]
        [string]$BinaryPath
    )
    
    try {
        ConvertFrom-CIPolicy -XmlFilePath $XmlPath -BinaryFilePath $BinaryPath
        return $true
    }
    catch {
        Write-Log "Error converting policy: $($_.Exception.Message)"
        return $false
    }
}

function Get-WDACStatus {
    <#
    .SYNOPSIS
    Retrieves the current WDAC policy enforcement status
    
    .EXAMPLE
    Get-WDACStatus
    #>
    
    try {
        $CIState = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
        return [PSCustomObject]@{
            BootStatus = $CIState.CodeIntegrityPolicyEnforcementStatus
            UserModeStatus = $CIState.UserModeCodeIntegrityPolicyEnforcementStatus
            VirtualizationBasedSecurity = $CIState.VirtualizationBasedSecurityStatus
            AvailableSecurityProperties = $CIState.AvailableSecurityProperties
            RequiredSecurityProperties = $CIState.RequiredSecurityProperties
            SecurityServicesConfigured = $CIState.SecurityServicesConfigured
            SecurityServicesRunning = $CIState.SecurityServicesRunning
        }
    }
    catch {
        Write-Log "Error retrieving WDAC status: $($_.Exception.Message)"
        return $null
    }
}

function Get-WDACEvents {
    <#
    .SYNOPSIS
    Retrieves WDAC events from the CodeIntegrity operational log
    
    .PARAMETER Hours
    Number of past hours to retrieve events for (default: 24)
    
    .PARAMETER EventIDs
    Specific event IDs to retrieve (default: 3076, 3077, 3089)
    
    .EXAMPLE
    Get-WDACEvents -Hours 48
    #>
    
    param(
        [Parameter(Mandatory=$false)]
        [int]$Hours = 24,
        
        [Parameter(Mandatory=$false)]
        [int[]]$EventIDs = @(3076, 3077, 3089)
    )
    
    try {
        $StartTime = (Get-Date).AddHours(-$Hours)
        $Events = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
            StartTime = $StartTime
            ID = $EventIDs
        } -ErrorAction SilentlyContinue
        
        return $Events
    }
    catch {
        Write-Log "Error retrieving WDAC events: $($_.Exception.Message)"
        return @()
    }
}

function Test-PolicySignature {
    <#
    .SYNOPSIS
    Validates the digital signature of a policy file
    
    .PARAMETER PolicyPath
    Path to the policy file to validate
    
    .EXAMPLE
    Test-PolicySignature -PolicyPath "policy.xml"
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$PolicyPath
    )
    
    try {
        $Signature = Get-AuthenticodeSignature -FilePath $PolicyPath
        return $Signature.Status -eq "Valid"
    }
    catch {
        Write-Log "Error validating policy signature: $($_.Exception.Message)"
        return $false
    }
}

function Backup-CurrentPolicy {
    <#
    .SYNOPSIS
    Backs up the currently deployed WDAC policy
    
    .PARAMETER BackupPath
    Path where the backup should be saved
    
    .EXAMPLE
    Backup-CurrentPolicy -BackupPath "C:\Backups\wdac-backup.xml"
    #>
    
    param(
        [Parameter(Mandatory=$false)]
        [string]$BackupPath = "$env:TEMP\WDAC_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').xml"
    )
    
    try {
        # Try to export the current policy
        $CurrentPolicyPath = "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
        if (Test-Path $CurrentPolicyPath) {
            Copy-Item -Path $CurrentPolicyPath -Destination $BackupPath
            Write-Log "Current policy backed up to: $BackupPath"
            return $true
        } else {
            Write-Log "No current policy found to backup"
            return $false
        }
    }
    catch {
        Write-Log "Error backing up policy: $($_.Exception.Message)"
        return $false
    }
}

Export-ModuleMember -Function *