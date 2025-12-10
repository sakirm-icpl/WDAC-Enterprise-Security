# simulate-policy.ps1
# Simulates WDAC policy enforcement to test policies before deployment
#
# Usage: .\simulate-policy.ps1 -PolicyPath "C:\path\to\policy.xml" -TestPath "C:\path\to\test\files"

param(
    [Parameter(Mandatory=$true)]
    [string]$PolicyPath,
    
    [Parameter(Mandatory=$false)]
    [string]$TestPath = ".",
    
    [Parameter(Mandatory=$false)]
    [switch]$IncludeSubdirectories,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputReport = ".\policy-simulation-report.html",
    
    [Parameter(Mandatory=$false)]
    [switch]$DetailedLogging
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
    
    if ($DetailedLogging) {
        Add-Content -Path "$env:TEMP\WDAC_Simulation_Log.txt" -Value $LogMessage
    }
}

function Test-PowerShellVersionCompatibility {
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

function Get-FileHashSHA256 {
    param([string]$FilePath)
    
    try {
        $hash = Get-FileHash -Path $FilePath -Algorithm SHA256
        return $hash.Hash
    } catch {
        Write-Log "Failed to calculate hash for $FilePath: $($_.Exception.Message)" "WARN"
        return $null
    }
}

function Get-FileCertificateInfo {
    param([string]$FilePath)
    
    try {
        # Get authenticode signature
        $signature = Get-AuthenticodeSignature -FilePath $FilePath
        
        if ($signature.Status -eq "Valid") {
            $cert = $signature.SignerCertificate
            return @{
                Subject = $cert.Subject
                Issuer = $cert.Issuer
                Thumbprint = $cert.Thumbprint
                NotBefore = $cert.NotBefore
                NotAfter = $cert.NotAfter
            }
        } else {
            return $null
        }
    } catch {
        Write-Log "Failed to get certificate info for $FilePath: $($_.Exception.Message)" "WARN"
        return $null
    }
}

function Test-PolicyAgainstFile {
    param(
        [xml]$Policy,
        [string]$FilePath
    )
    
    try {
        $fileName = Split-Path $FilePath -Leaf
        $fileExtension = [System.IO.Path]::GetExtension($FilePath)
        $fileDirectory = Split-Path $FilePath -Parent
        
        # Get file hash
        $fileHash = Get-FileHashSHA256 -FilePath $FilePath
        
        # Get certificate info
        $certInfo = Get-FileCertificateInfo -FilePath $FilePath
        
        # Initialize result
        $result = @{
            FilePath = $FilePath
            FileName = $fileName
            Extension = $fileExtension
            Allowed = $false
            Reason = ""
            RuleMatched = ""
            Details = @{
                Hash = $fileHash
                Certificate = $certInfo
            }
        }
        
        # Check explicit denies first
        $denyRules = $Policy.Policy.FileRules.ChildNodes | Where-Object { $_.Name -eq "Deny" }
        foreach ($denyRule in $denyRules) {
            # Check file path rules
            if ($denyRule.FilePath) {
                $denyPath = $denyRule.FilePath
                if ($FilePath -like $denyPath) {
                    $result.Allowed = $false
                    $result.Reason = "Explicitly denied by path rule"
                    $result.RuleMatched = $denyRule.ID
                    return $result
                }
            }
            
            # Check file hash rules
            if ($denyRule.FileHash -and $fileHash) {
                $denyHash = $denyRule.FileHash
                if ($fileHash -eq $denyHash) {
                    $result.Allowed = $false
                    $result.Reason = "Explicitly denied by hash rule"
                    $result.RuleMatched = $denyRule.ID
                    return $result
                }
            }
        }
        
        # Check allow rules
        $allowRules = $Policy.Policy.FileRules.ChildNodes | Where-Object { $_.Name -eq "Allow" }
        foreach ($allowRule in $allowRules) {
            # Check file path rules
            if ($allowRule.FilePath) {
                $allowPath = $allowRule.FilePath
                if ($FilePath -like $allowPath) {
                    $result.Allowed = $true
                    $result.Reason = "Allowed by path rule"
                    $result.RuleMatched = $allowRule.ID
                    return $result
                }
            }
            
            # Check file hash rules
            if ($allowRule.FileHash -and $fileHash) {
                $allowHash = $allowRule.FileHash
                if ($fileHash -eq $allowHash) {
                    $result.Allowed = $true
                    $result.Reason = "Allowed by hash rule"
                    $result.RuleMatched = $allowRule.ID
                    return $result
                }
            }
            
            # Check signer rules if file is signed
            if ($certInfo -and $allowRule.SignerId) {
                # This would require matching the signer ID with actual signers in the policy
                # For simplicity in this simulator, we'll just note that it's a signed file
                $result.Allowed = $true
                $result.Reason = "Allowed as signed executable (simulated)"
                $result.RuleMatched = $allowRule.ID
                return $result
            }
        }
        
        # Default deny if no rules match
        $result.Allowed = $false
        $result.Reason = "Blocked by default deny policy"
        return $result
    } catch {
        Write-Log "Error testing policy against file $FilePath: $($_.Exception.Message)" "ERROR"
        return @{
            FilePath = $FilePath
            FileName = $fileName
            Extension = $fileExtension
            Allowed = $false
            Reason = "Simulation error: $($_.Exception.Message)"
            RuleMatched = ""
            Details = @{
                Hash = $fileHash
                Certificate = $certInfo
            }
        }
    }
}

function Generate-HtmlReport {
    param(
        [array]$Results,
        [string]$PolicyPath,
        [string]$TestPath,
        [string]$OutputPath
    )
    
    try {
        $allowedCount = ($Results | Where-Object { $_.Allowed -eq $true } | Measure-Object).Count
        $deniedCount = ($Results | Where-Object { $_.Allowed -eq $false } | Measure-Object).Count
        $totalCount = $Results.Count
        
        $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>WDAC Policy Simulation Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1, h2 { color: #2E74B5; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        tr.allowed { background-color: #d4edda; }
        tr.denied { background-color: #f8d7da; }
        .summary { background-color: #e9ecef; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .passed { color: #28a745; font-weight: bold; }
        .failed { color: #dc3545; font-weight: bold; }
    </style>
</head>
<body>
    <h1>WDAC Policy Simulation Report</h1>
    
    <div class="summary">
        <h2>Summary</h2>
        <p><strong>Policy Tested:</strong> $PolicyPath</p>
        <p><strong>Test Path:</strong> $TestPath</p>
        <p><strong>Total Files Tested:</strong> $totalCount</p>
        <p><strong>Files Allowed:</strong> <span class="passed">$allowedCount</span></p>
        <p><strong>Files Denied:</strong> <span class="failed">$deniedCount</span></p>
    </div>
    
    <h2>Detailed Results</h2>
    <table>
        <tr>
            <th>File Path</th>
            <th>File Name</th>
            <th>Status</th>
            <th>Reason</th>
            <th>Rule Matched</th>
        </tr>
"@
        
        foreach ($result in $Results) {
            $statusClass = if ($result.Allowed) { "allowed" } else { "denied" }
            $statusText = if ($result.Allowed) { "ALLOWED" } else { "DENIED" }
            
            $htmlContent += @"
        <tr class="$statusClass">
            <td>$($result.FilePath)</td>
            <td>$($result.FileName)</td>
            <td>$statusText</td>
            <td>$($result.Reason)</td>
            <td>$($result.RuleMatched)</td>
        </tr>
"@
        }
        
        $htmlContent += @"
    </table>
</body>
</html>
"@
        
        $htmlContent | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Log "HTML report generated at: $OutputPath" "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to generate HTML report: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

Write-Log "Starting WDAC Policy Simulator" "INFO"

# Check prerequisites
try {
    Write-Log "Checking PowerShell version compatibility..." "INFO"
    Test-PowerShellVersionCompatibility | Out-Null
    Write-Log "PowerShell version compatibility check passed" "SUCCESS"
} catch {
    Write-Log "PowerShell compatibility check failed: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Check if policy file exists
if (-not (Test-Path $PolicyPath)) {
    Write-Log "Policy file not found at $PolicyPath" "ERROR"
    exit 1
}

Write-Log "Policy file found: $PolicyPath" "SUCCESS"

# Check if test path exists
if (-not (Test-Path $TestPath)) {
    Write-Log "Test path not found at $TestPath" "ERROR"
    exit 1
}

Write-Log "Test path found: $TestPath" "SUCCESS"

# Load policy
try {
    Write-Log "Loading WDAC policy..." "INFO"
    [xml]$Policy = Get-Content $PolicyPath
    Write-Log "Policy loaded successfully" "SUCCESS"
} catch {
    Write-Log "Failed to load policy: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Get files to test
try {
    Write-Log "Scanning for executable files to test..." "INFO"
    
    $searchFilter = if ($IncludeSubdirectories) { "*" } else { "" }
    $exeFiles = Get-ChildItem -Path $TestPath -Filter "*.exe" -Recurse:$IncludeSubdirectories -File -ErrorAction SilentlyContinue
    $dllFiles = Get-ChildItem -Path $TestPath -Filter "*.dll" -Recurse:$IncludeSubdirectories -File -ErrorAction SilentlyContinue
    $sysFiles = Get-ChildItem -Path $TestPath -Filter "*.sys" -Recurse:$IncludeSubdirectories -File -ErrorAction SilentlyContinue
    
    $allFiles = $exeFiles + $dllFiles + $sysFiles
    
    Write-Log "Found $($allFiles.Count) executable files to test" "SUCCESS"
} catch {
    Write-Log "Failed to scan for files: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Test each file against the policy
$results = @()
$counter = 0
$totalFiles = $allFiles.Count

Write-Log "Testing files against policy (this may take a while)..." "INFO"

foreach ($file in $allFiles) {
    $counter++
    Write-Progress -Activity "Testing Files Against Policy" -Status "Processing $($file.Name)" -PercentComplete (($counter / $totalFiles) * 100)
    
    $result = Test-PolicyAgainstFile -Policy $Policy -FilePath $file.FullName
    $results += $result
    
    if ($DetailedLogging) {
        $status = if ($result.Allowed) { "ALLOWED" } else { "DENIED" }
        Write-Log "[$counter/$totalFiles] $($file.Name) - $status - $($result.Reason)" "INFO"
    }
}

Write-Progress -Activity "Testing Files Against Policy" -Completed

# Generate report
Write-Log "Generating simulation report..." "INFO"
if (Generate-HtmlReport -Results $results -PolicyPath $PolicyPath -TestPath $TestPath -OutputPath $OutputReport) {
    Write-Log "Simulation report generated successfully" "SUCCESS"
} else {
    Write-Log "Failed to generate simulation report" "ERROR"
}

# Display summary
$allowedCount = ($results | Where-Object { $_.Allowed -eq $true } | Measure-Object).Count
$deniedCount = ($results | Where-Object { $_.Allowed -eq $false } | Measure-Object).Count

Write-Log "===== SIMULATION RESULTS =====" "INFO"
Write-Log "Total files tested: $($results.Count)" "INFO"
Write-Log "Files allowed: $allowedCount" "SUCCESS"
Write-Log "Files denied: $deniedCount" "WARN"
Write-Log "=============================" "INFO"

if ($deniedCount -gt 0) {
    Write-Log "Some files would be blocked by this policy. Review the report for details." "WARN"
} else {
    Write-Log "All tested files would be allowed by this policy." "SUCCESS"
}

Write-Log "WDAC Policy Simulation completed successfully" "INFO"
Write-Log "Report saved to: $OutputReport" "INFO"