# Audit-Log-Analyzer.ps1
# Analyzes WDAC audit logs to identify applications that need policy allowances

function Analyze-WDACAuditLogs {
    <#
    .SYNOPSIS
    Analyzes WDAC audit logs to identify applications that may need policy allowances
    
    .PARAMETER Hours
    Number of hours of audit logs to analyze (default: 24)
    
    .PARAMETER OutputPath
    Path where the analysis report should be saved
    
    .EXAMPLE
    Analyze-WDACAuditLogs -Hours 168 -OutputPath "C:\Reports\WDAC_Audit_Analysis.csv"
    #>
    
    param(
        [Parameter(Mandatory=$false)]
        [int]$Hours = 24,
        
        [Parameter(Mandatory=$false)]
        [string]$OutputPath = "$env:TEMP\WDAC_Audit_Analysis.csv"
    )
    
    try {
        # Get audit events (Event ID 3076)
        $StartTime = (Get-Date).AddHours(-$Hours)
        $AuditEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-CodeIntegrity/Operational'
            StartTime = $StartTime
            ID = 3076
        } -ErrorAction SilentlyContinue
        
        if ($AuditEvents.Count -eq 0) {
            Write-Host "No audit events found in the last $Hours hours" -ForegroundColor Yellow
            return $null
        }
        
        # Parse event data to extract application information
        $Applications = @()
        
        foreach ($Event in $AuditEvents) {
            # Extract file path from event message
            # This is a simplified approach - in practice, you might need to parse the event XML data
            $Message = $Event.Message
            
            # Look for file path patterns in the message
            if ($Message -match "File name: (.+?)\r?\n") {
                $FilePath = $matches[1].Trim()
                
                # Extract file name
                $FileName = Split-Path $FilePath -Leaf
                
                # Extract directory
                $Directory = Split-Path $FilePath -Parent
                
                # Check if we already have this application
                $ExistingApp = $Applications | Where-Object { $_.FilePath -eq $FilePath }
                
                if ($ExistingApp) {
                    # Increment count
                    $ExistingApp.Count++
                } else {
                    # Add new application
                    $Applications += [PSCustomObject]@{
                        FilePath = $FilePath
                        FileName = $FileName
                        Directory = $Directory
                        Count = 1
                        FirstSeen = $Event.TimeCreated
                        LastSeen = $Event.TimeCreated
                    }
                }
            }
        }
        
        # Sort by count (most frequent first)
        $Applications = $Applications | Sort-Object Count -Descending
        
        # Export to CSV
        $Applications | Export-Csv -Path $OutputPath -NoTypeInformation
        
        Write-Host "Audit log analysis complete. Found $($Applications.Count) unique applications." -ForegroundColor Green
        Write-Host "Report saved to: $OutputPath" -ForegroundColor Green
        
        # Display top 10 most frequent applications
        Write-Host "`nTop 10 Most Frequent Applications:" -ForegroundColor Cyan
        $Applications | Select-Object -First 10 | Format-Table FileName, Count, Directory -AutoSize
        
        return $OutputPath
    }
    catch {
        Write-Error "Failed to analyze audit logs: $($_.Exception.Message)"
        return $null
    }
}

function Convert-AuditAppsToPolicyRules {
    <#
    .SYNOPSIS
    Converts audit log analysis results to WDAC policy rules
    
    .PARAMETER AuditAnalysisPath
    Path to the audit analysis CSV file
    
    .PARAMETER PolicyType
    Type of policy rules to generate (Allow, Deny, or Both)
    
    .EXAMPLE
    Convert-AuditAppsToPolicyRules -AuditAnalysisPath "C:\Reports\WDAC_Audit_Analysis.csv" -PolicyType "Allow"
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$AuditAnalysisPath,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Allow", "Deny", "Both")]
        [string]$PolicyType = "Allow"
    )
    
    try {
        if (-not (Test-Path $AuditAnalysisPath)) {
            Write-Error "Audit analysis file not found: $AuditAnalysisPath"
            return $null
        }
        
        # Import audit analysis data
        $Applications = Import-Csv -Path $AuditAnalysisPath
        
        # Generate policy rules
        $PolicyRules = @()
        $RuleCounter = 1
        
        foreach ($App in $Applications) {
            # Determine if this should be an allow or deny rule
            # For this example, we'll assume frequently used apps should be allowed
            if ($App.Count -gt 5) {
                $RuleType = "Allow"
            } else {
                $RuleType = "Deny"
            }
            
            if ($PolicyType -eq "Both" -or $PolicyType -eq $RuleType) {
                $RuleID = "ID_$($RuleType.ToUpper())_APP_$('{0:D4}' -f $RuleCounter)"
                $FriendlyName = "$RuleType $([System.IO.Path]::GetFileNameWithoutExtension($App.FileName))"
                
                $PolicyRules += [PSCustomObject]@{
                    RuleType = $RuleType
                    RuleID = $RuleID
                    FriendlyName = $FriendlyName
                    FileName = $App.FileName
                    FilePath = $App.FilePath
                    Count = $App.Count
                }
                
                $RuleCounter++
            }
        }
        
        # Display results
        Write-Host "`nGenerated $($PolicyRules.Count) policy rules:" -ForegroundColor Cyan
        $PolicyRules | Format-Table RuleType, FriendlyName, FileName, Count -AutoSize
        
        return $PolicyRules
    }
    catch {
        Write-Error "Failed to convert audit apps to policy rules: $($_.Exception.Message)"
        return $null
    }
}

# Export functions
Export-ModuleMember -Function *