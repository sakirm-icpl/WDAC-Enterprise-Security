# security-utils.psm1
# Security utility functions for WDAC policy management

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

function Get-SecureTempDirectory {
    <#
    .SYNOPSIS
    Creates a secure temporary directory for policy operations
    
    .DESCRIPTION
    Creates a temporary directory with restricted permissions for secure policy operations
    
    .EXAMPLE
    Get-SecureTempDirectory
    #>
    
    try {
        # Create a unique temporary directory
        $TempDir = Join-Path $env:TEMP "WDAC_Secure_$(Get-Random)"
        
        # Create the directory
        $Directory = New-Item -ItemType Directory -Path $TempDir -ErrorAction Stop
        
        # Set restrictive permissions (only current user can access)
        $Acl = Get-Acl $Directory.FullName
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
            "FullControl",
            "ContainerInherit,ObjectInherit",
            "None",
            "Allow"
        )
        $Acl.SetAccessRule($AccessRule)
        Set-Acl $Directory.FullName $Acl
        
        return $Directory.FullName
    } catch {
        throw "Failed to create secure temporary directory: $($_.Exception.Message)"
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
        [ValidateScript({
            if (-not (Test-Path $_)) {
                throw "Policy file not found: $_"
            }
            return $true
        })]
        [string]$PolicyPath
    )
    
    try {
        $Signature = Get-AuthenticodeSignature -FilePath $PolicyPath -ErrorAction Stop
        return $Signature.Status -eq "Valid"
    } catch {
        throw "Error validating policy signature: $($_.Exception.Message)"
    }
}

function Protect-String {
    <#
    .SYNOPSIS
    Converts a plain text string to a secure string
    
    .PARAMETER PlainText
    The plain text string to protect
    
    .EXAMPLE
    Protect-String -PlainText "sensitive-data"
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$PlainText
    )
    
    try {
        $SecureString = ConvertTo-SecureString $PlainText -AsPlainText -Force -ErrorAction Stop
        return $SecureString
    } catch {
        throw "Failed to protect string: $($_.Exception.Message)"
    }
}

function Unprotect-String {
    <#
    .SYNOPSIS
    Converts a secure string back to plain text
    
    .PARAMETER SecureString
    The secure string to unprotect
    
    .EXAMPLE
    Unprotect-String -SecureString $secureString
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [System.Security.SecureString]$SecureString
    )
    
    try {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $PlainText = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        return $PlainText
    } catch {
        throw "Failed to unprotect string: $($_.Exception.Message)"
    }
}

function Test-PowerShellVersionCompatibility {
    <#
    .SYNOPSIS
    Tests if the current PowerShell version is compatible with WDAC cmdlets
    
    .DESCRIPTION
    Checks if the current PowerShell version supports the required WDAC cmdlets
    
    .EXAMPLE
    Test-PowerShellVersionCompatibility
    #>
    
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

Export-ModuleMember -Function *