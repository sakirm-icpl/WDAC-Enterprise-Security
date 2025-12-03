# Complete-WDACWorkflowDemo.ps1

<#
.SYNOPSIS
    Complete demonstration of WDAC policy implementation workflow

.DESCRIPTION
    This script demonstrates the complete workflow for implementing WDAC policies
    including policy creation, deployment, testing, and validation.

.PARAMETER TestDirectory
    Directory to use for testing (default: C:\temp\wdac_demo)

.PARAMETER RunFullDemo
    Run the complete demonstration workflow

.EXAMPLE
    .\Complete-WDACWorkflowDemo.ps1 -RunFullDemo
    Runs the complete WDAC workflow demonstration
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$TestDirectory = "C:\temp\wdac_demo",
    
    [Parameter(Mandatory=$false)]
    [switch]$RunFullDemo
)

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "WARN") { "Yellow" } elseif ($Level -eq "SUCCESS") { "Green" } else { "White" })
}

function Test-Prerequisites {
    Write-Log "Testing prerequisites"
    
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Log "This script must be run as Administrator" -Level "ERROR"
        return $false
    }
    
    # Check if ConvertFrom-CIPolicy is available
    try {
        $cmd = Get-Command ConvertFrom-CIPolicy -ErrorAction Stop
        Write-Log "ConvertFrom-CIPolicy cmdlet is available" -Level "SUCCESS"
    } catch {
        Write-Log "ConvertFrom-CIPolicy cmdlet is not available. WDAC may not be supported on this system." -Level "ERROR"
        return $false
    }
    
    # Check Windows version
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    if ($os.Version -lt "10.0.18362") {
        Write-Log "WDAC requires Windows 10 version 1903 or later" -Level "ERROR"
        return $false
    }
    
    Write-Log "All prerequisites met" -Level "SUCCESS"
    return $true
}

function Create-DemoEnvironment {
    param([string]$Directory)
    
    Write-Log "Creating demo environment in $Directory"
    
    # Create test directories
    $directories = @(
        "$Directory\Downloads",
        "$Directory\Temp",
        "$Directory\Documents",
        "$Directory\ProgramFiles\MyApp",
        "$Directory\Public"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Log "Created directory: $dir"
        }
    }
    
    Write-Log "Demo environment created" -Level "SUCCESS"
}

function Create-DemoExecutables {
    param([string]$Directory)
    
    Write-Log "Creating demo executables"
    
    # Create a simple executable in each test location
    $testLocations = @(
        "$Directory\Downloads",
        "$Directory\Temp",
        "$Directory\Documents",
        "$Directory\ProgramFiles\MyApp",
        "$Directory\Public"
    )
    
    foreach ($location in $testLocations) {
        $exePath = Join-Path $location "demoapp.exe"
        # Create a minimal executable by copying cmd.exe
        Copy-Item "$env:SystemRoot\System32\cmd.exe" -Destination $exePath -Force
        Write-Log "Created demo executable: $exePath"
    }
    
    Write-Log "Demo executables created" -Level "SUCCESS"
}

function Demonstrate-PolicyCreation {
    Write-Log "Demonstrating policy creation"
    
    # Show how to use the folder restriction implementation script
    Write-Log "Creating folder restriction policy"
    $policyPath = "C:\temp\DemoFolderPolicy.xml"
    
    # Create a policy that restricts Downloads and Temp but allows Program Files
    & ".\scripts\utils\Implement-FolderRestrictions.ps1" -RestrictDownloads -RestrictTemp -AllowProgramFiles -OutputPath $policyPath
    
    if (Test-Path $policyPath) {
        Write-Log "Policy created successfully: $policyPath" -Level "SUCCESS"
        
        # Show policy content
        Write-Log "Policy content preview:"
        $content = Get-Content $policyPath -TotalCount 30
        $content | Write-Host -ForegroundColor Gray
    } else {
        Write-Log "Failed to create policy" -Level "ERROR"
    }
    
    Write-Log "Policy creation demonstration complete" -Level "SUCCESS"
}

function Demonstrate-PolicyTesting {
    Write-Log "Demonstrating policy testing"
    
    # Run the folder restriction test
    Write-Log "Testing folder restrictions"
    & ".\test-files\validation\Test-FolderRestrictions.ps1" -TestBasePath "C:\temp\wdac_folder_tests"
    
    Write-Log "Policy testing demonstration complete" -Level "SUCCESS"
}

function Demonstrate-PolicyDeployment {
    Write-Log "Demonstrating policy deployment process"
    
    # Show the deployment commands without actually deploying
    Write-Log "Deployment workflow:"
    Write-Host "1. Convert policy to audit mode:" -ForegroundColor Cyan
    Write-Host "   .\scripts\convert_to_audit_mode.ps1 -PolicyPath `"C:\temp\DemoFolderPolicy.xml`" -Deploy" -ForegroundColor White
    Write-Host "2. Monitor Code Integrity events:" -ForegroundColor Cyan
    Write-Host "   .\test-files\validation\Analyze-AuditLogs.ps1" -ForegroundColor White
    Write-Host "3. Convert to enforce mode after validation:" -ForegroundColor Cyan
    Write-Host "   .\scripts\convert_to_enforce_mode.ps1 -PolicyPath `"C:\temp\DemoFolderPolicy.xml`" -Deploy" -ForegroundColor White
    Write-Host "4. Rollback if needed:" -ForegroundColor Cyan
    Write-Host "   .\scripts\rollback_policy.ps1 -Restore" -ForegroundColor White
    
    Write-Log "Policy deployment demonstration complete" -Level "SUCCESS"
}

function Show-RepositoryStructure {
    Write-Log "Showing repository structure"
    
    Write-Host "
Repository Structure:
├── architecture/                    # Architecture diagrams and design documents
├── docs/                           # Comprehensive documentation
├── environment-specific/           # Environment-specific policies and scripts
│   ├── active-directory/           # AD environment policies and scripts
│   ├── non-ad/                     # Non-AD environment policies and scripts
│   └── shared/                     # Shared utilities and common components
├── policies/                       # Generic policies for any environment
├── scripts/                        # PowerShell scripts for policy management
├── test-files/                     # Validation and testing files
└── testing-checklists/             # Step-by-step testing procedures

Key Scripts:
- scripts/merge_policies.ps1          # Merge multiple policies
- scripts/convert_to_audit_mode.ps1   # Convert policy to audit mode
- scripts/convert_to_enforce_mode.ps1 # Deploy policy in enforce mode
- scripts/rollback_policy.ps1         # Rollback deployed policies
- scripts/utils/Implement-FolderRestrictions.ps1 # Create folder restriction policies
- test-files/validation/Test-FolderRestrictions.ps1 # Test folder restrictions
- test-files/validation/Analyze-AuditLogs.ps1 # Analyze Code Integrity logs
" -ForegroundColor Gray
    
    Write-Log "Repository structure shown" -Level "SUCCESS"
}

function Show-Usage {
    Write-Host "WDAC Complete Workflow Demonstration" -ForegroundColor Cyan
    Write-Host "Usage: .\Complete-WDACWorkflowDemo.ps1 [-RunFullDemo]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Cyan
    Write-Host "  -RunFullDemo    Run the complete demonstration workflow" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host "  .\Complete-WDACWorkflowDemo.ps1 -RunFullDemo" -ForegroundColor White
    Write-Host ""
    Write-Host "This demonstration shows:" -ForegroundColor Cyan
    Write-Host "  1. Prerequisite checking" -ForegroundColor White
    Write-Host "  2. Environment setup" -ForegroundColor White
    Write-Host "  3. Policy creation" -ForegroundColor White
    Write-Host "  4. Policy testing" -ForegroundColor White
    Write-Host "  5. Deployment workflow" -ForegroundColor White
    Write-Host "  6. Repository structure" -ForegroundColor White
}

# Main script execution
Write-Log "Starting WDAC Complete Workflow Demonstration"

if (-not $RunFullDemo) {
    Show-Usage
    exit 0
}

# Check prerequisites
if (-not (Test-Prerequisites)) {
    Write-Log "Prerequisites not met. Exiting." -Level "ERROR"
    exit 1
}

# Create demo environment
Create-DemoEnvironment -Directory $TestDirectory

# Create demo executables
Create-DemoExecutables -Directory $TestDirectory

# Demonstrate policy creation
Demonstrate-PolicyCreation

# Demonstrate policy testing
Demonstrate-PolicyTesting

# Demonstrate policy deployment
Demonstrate-PolicyDeployment

# Show repository structure
Show-RepositoryStructure

Write-Log "WDAC Complete Workflow Demonstration Finished" -Level "SUCCESS"
Write-Log "Next steps:" -Level "INFO"
Write-Host "1. Review the created policy file: C:\temp\DemoFolderPolicy.xml" -ForegroundColor White
Write-Host "2. Examine the test scripts in test-files/validation/" -ForegroundColor White
Write-Host "3. Try deploying a policy in audit mode to see how it works" -ForegroundColor White
Write-Host "4. Check the documentation files for detailed guidance" -ForegroundColor White