# Monitor-ADSystems.ps1
# Monitors WDAC policy status on Active Directory domain systems

param(
    [Parameter(Mandatory=$false)]
    [string]$OU = "OU=Workstations,DC=company,DC=com",
    
    [Parameter(Mandatory=$false)]
    [int]$Hours = 24,
    
    [Parameter(Mandatory=$false)]
    [string]$ReportPath = "$env:TEMP\WDAC_Monitoring_Report.csv",
    
    [Parameter(Mandatory=$false)]
    [switch]$AlertOnViolations,
    
    [Parameter(Mandatory=$false)]
    [string]$AlertEmail = "admin@company.com"
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

function Send-AlertEmail {
    param(
        [string]$Subject,
        [string]$Body
    )
    
    # This is a placeholder for actual email sending logic
    # In a real environment, you would use Send-MailMessage or a similar cmdlet
    Write-Log "ALERT: $Subject" "WARN"
    Write-Log "Alert Body: $Body" "INFO"
    Write-Log "Alert would be sent to: $AlertEmail" "INFO"
}

Write-Log "Starting WDAC Active Directory System Monitoring" "INFO"

# Import required modules
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Log "ActiveDirectory module imported successfully" "SUCCESS"
} catch {
    Write-Log "Failed to import ActiveDirectory module: $_" "ERROR"
    exit 1
}

# Get computers from specified OU
try {
    $Computers = Get-ADComputer -SearchBase $OU -Filter * -Properties OperatingSystem, LastLogonDate
    Write-Log "Found $($Computers.Count) computers in OU: $OU" "SUCCESS"
} catch {
    Write-Log "Failed to retrieve computers from OU: $_" "ERROR"
    exit 1
}

# Filter for Windows 10/11 systems
$WindowsSystems = $Computers | Where-Object { $_.OperatingSystem -like "*Windows 10*" -or $_.OperatingSystem -like "*Windows 11*" }
Write-Log "Found $($WindowsSystems.Count) Windows 10/11 systems" "INFO"

# Initialize report data
$ReportData = @()

# Monitor each system
foreach ($Computer in $WindowsSystems) {
    $SystemName = $Computer.Name
    Write-Log "Monitoring system: $SystemName" "INFO"
    
    try {
        # Check if system is online
        if (-not (Test-Connection -ComputerName $SystemName -Count 1 -Quiet)) {
            Write-Log "System $SystemName is offline" "WARN"
            $ReportData += [PSCustomObject]@{
                SystemName = $SystemName
                Online = $false
                PolicyDeployed = "Unknown"
                PolicyVersion = "Unknown"
                Violations = "Unknown"
                LastChecked = Get-Date
                Status = "Offline"
            }
            continue
        }
        
        # Check WDAC policy status
        $PolicyStatus = Invoke-Command -ComputerName $SystemName -ScriptBlock {
            Test-Path "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b"
        } -ErrorAction Stop
        
        $PolicyVersion = "Unknown"
        if ($PolicyStatus) {
            try {
                $PolicyInfo = Invoke-Command -ComputerName $SystemName -ScriptBlock {
                    (Get-ItemProperty "C:\Windows\System32\CodeIntegrity\SIPolicy.p7b").Length
                } -ErrorAction Stop
                $PolicyVersion = "Deployed ($PolicyInfo bytes)"
            } catch {
                $PolicyVersion = "Deployed (size unknown)"
            }
        }
        
        # Check for violations in the last specified hours
        $StartTime = (Get-Date).AddHours(-$Hours)
        $ViolationCount = 0
        
        try {
            $Violations = Invoke-Command -ComputerName $SystemName -ScriptBlock {
                param($StartTime)
                Get-WinEvent -FilterHashtable @{
                    LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
                    StartTime = $StartTime
                    Level = 2  # Error level for blocked applications
                } -ErrorAction SilentlyContinue | Measure-Object
            } -ArgumentList $StartTime -ErrorAction Stop
            
            $ViolationCount = $Violations.Count
        } catch {
            Write-Log "Failed to retrieve violation data from $SystemName: $_" "WARN"
        }
        
        # Check Device Guard status
        $DeviceGuardStatus = "Unknown"
        try {
            $DGStatus = Invoke-Command -ComputerName $SystemName -ScriptBlock {
                Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard -ErrorAction Stop
            } -ErrorAction Stop
            
            if ($DGStatus.SecurityServicesRunning -band 2) {
                $DeviceGuardStatus = "Running"
            } else {
                $DeviceGuardStatus = "Not Running"
            }
        } catch {
            Write-Log "Failed to retrieve Device Guard status from $SystemName: $_" "WARN"
        }
        
        # Determine overall status
        $OverallStatus = "Healthy"
        if (-not $PolicyStatus) {
            $OverallStatus = "No Policy"
        } elseif ($ViolationCount -gt 0) {
            $OverallStatus = "Violations Detected"
        } elseif ($DeviceGuardStatus -ne "Running") {
            $OverallStatus = "Device Guard Issues"
        }
        
        # Add to report data
        $ReportData += [PSCustomObject]@{
            SystemName = $SystemName
            Online = $true
            PolicyDeployed = $PolicyStatus
            PolicyVersion = $PolicyVersion
            Violations = $ViolationCount
            DeviceGuardStatus = $DeviceGuardStatus
            LastChecked = Get-Date
            Status = $OverallStatus
        }
        
        Write-Log "System $SystemName - Policy: $PolicyStatus, Violations: $ViolationCount, Status: $OverallStatus" "SUCCESS"
        
        # Send alert if violations detected and alerting is enabled
        if ($AlertOnViolations -and $ViolationCount -gt 0) {
            $AlertSubject = "WDAC Violations Detected on $SystemName"
            $AlertBody = "System: $SystemName`nViolations in last $Hours hours: $ViolationCount`nTime: $(Get-Date)"
            Send-AlertEmail -Subject $AlertSubject -Body $AlertBody
        }
        
    } catch {
        Write-Log "Failed to monitor system $SystemName: $_" "ERROR"
        $ReportData += [PSCustomObject]@{
            SystemName = $SystemName
            Online = "Error"
            PolicyDeployed = "Error"
            PolicyVersion = "Error"
            Violations = "Error"
            LastChecked = Get-Date
            Status = "Monitoring Error"
        }
    }
}

# Generate summary statistics
$TotalSystems = $ReportData.Count
$OnlineSystems = ($ReportData | Where-Object { $_.Online -eq $true }).Count
$PolicyDeployedSystems = ($ReportData | Where-Object { $_.PolicyDeployed -eq $true }).Count
$SystemsInViolation = ($ReportData | Where-Object { [int]$_.Violations -gt 0 }).Count
$HealthySystems = ($ReportData | Where-Object { $_.Status -eq "Healthy" }).Count

Write-Log "=== MONITORING SUMMARY ===" "SUCCESS"
Write-Log "Total Systems: $TotalSystems" "INFO"
Write-Log "Online Systems: $OnlineSystems" "INFO"
Write-Log "Policy Deployed: $PolicyDeployedSystems" "INFO"
Write-Log "Systems in Violation: $SystemsInViolation" "INFO"
Write-Log "Healthy Systems: $HealthySystems" "INFO"

# Export report to CSV
try {
    $ReportData | Export-Csv -Path $ReportPath -NoTypeInformation -Force
    Write-Log "Monitoring report exported to: $ReportPath" "SUCCESS"
} catch {
    Write-Log "Failed to export report: $_" "ERROR"
}

# Display critical issues
$CriticalIssues = $ReportData | Where-Object { $_.Status -ne "Healthy" -and $_.Status -ne "Offline" }
if ($CriticalIssues.Count -gt 0) {
    Write-Log "=== CRITICAL ISSUES DETECTED ===" "WARN"
    $CriticalIssues | Format-Table SystemName, Status, Violations -AutoSize
}

Write-Log "WDAC Active Directory System Monitoring Completed" "INFO"