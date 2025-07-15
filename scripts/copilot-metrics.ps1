# GitHub Copilot Metrics Collection PowerShell Script
# This script provides GitHub Copilot usage metrics collection functions for enterprise organizations

# Function to get Copilot usage metrics
function Get-CopilotMetrics {
    <#
    .SYNOPSIS
        Retrieves GitHub Copilot usage metrics for an organization using the GitHub API.
    
    .PARAMETER Org
        The organization name.
    
    .PARAMETER Token
        The GitHub personal access token for authentication.
    
    .PARAMETER Since
        The start date for metrics (optional).
    
    .PARAMETER Until
        The end date for metrics (optional).
    
    .EXAMPLE
        Get-CopilotMetrics -Org "myorg" -Token "your_token_here"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Org,
        
        [Parameter(Mandatory = $true)]
        [string]$Token,
        
        [Parameter(Mandatory = $false)]
        [string]$Since,
        
        [Parameter(Mandatory = $false)]
        [string]$Until
    )
    
    # Set up headers with authentication
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    $uri = "https://api.github.com/orgs/$Org/copilot/metrics"
    $params = @()
    
    if ($Since) {
        $params += "since=$Since"
    }
    if ($Until) {
        $params += "until=$Until"
    }
    if ($params.Count -gt 0) {
        $uri += "?" + ($params -join "&")
    }
    
    try {
        Write-Host "API Request: GET $uri"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET
        return $response
    }
    catch {
        Write-Error "Failed to fetch Copilot usage metrics: $($_.Exception.Message)"
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Warning "Copilot usage data not found - may require Copilot Business subscription"
        }
        elseif ($_.Exception.Response.StatusCode -eq 403) {
            Write-Warning "Access denied - check permissions for Copilot metrics"
        }
        return $null
    }
}

# Function to get Copilot seats information
function Get-CopilotSeats {
    <#
    .SYNOPSIS
        Retrieves GitHub Copilot seats information for an organization using the GitHub API.
    
    .PARAMETER Org
        The organization name.
    
    .PARAMETER Token
        The GitHub personal access token for authentication.
    
    .EXAMPLE
        Get-CopilotSeats -Org "myorg" -Token "your_token_here"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Org,
        
        [Parameter(Mandatory = $true)]
        [string]$Token
    )
    
    # Set up headers with authentication
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    $uri = "https://api.github.com/orgs/$Org/copilot/billing/seats"
    
    try {
        Write-Host "API Request: GET $uri"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET
        return $response
    }
    catch {
        Write-Error "Failed to fetch Copilot seats information: $($_.Exception.Message)"
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Warning "Copilot seats data not found - may require Copilot Business subscription"
        }
        elseif ($_.Exception.Response.StatusCode -eq 403) {
            Write-Warning "Access denied - check permissions for Copilot billing data"
        }
        return $null
    }
}

# Function to get Copilot billing information
function Get-CopilotBilling {
    <#
    .SYNOPSIS
        Retrieves GitHub Copilot billing information for an organization using the GitHub API.
    
    .PARAMETER Org
        The organization name.
    
    .PARAMETER Token
        The GitHub personal access token for authentication.
    
    .EXAMPLE
        Get-CopilotBilling -Org "myorg" -Token "your_token_here"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Org,
        
        [Parameter(Mandatory = $true)]
        [string]$Token
    )
    
    # Set up headers with authentication
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    $uri = "https://api.github.com/orgs/$Org/copilot/billing"
    
    try {
        Write-Host "API Request: GET $uri"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET
        return $response
    }
    catch {
        Write-Error "Failed to fetch Copilot billing information: $($_.Exception.Message)"
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Warning "Copilot billing data not found - may require Copilot Business subscription"
        }
        elseif ($_.Exception.Response.StatusCode -eq 403) {
            Write-Warning "Access denied - check permissions for Copilot billing data"
        }
        return $null
    }
}

# Function to calculate metrics summary
function Get-MetricsSummary {
    <#
    .SYNOPSIS
        Calculates a comprehensive metrics summary from Copilot usage, seats, and billing data.
    
    .PARAMETER Organization
        The organization name.
    
    .PARAMETER Usage
        The usage data from Get-CopilotMetrics.
    
    .PARAMETER Seats
        The seats data from Get-CopilotSeats.
    
    .PARAMETER Billing
        The billing data from Get-CopilotBilling.
    
    .EXAMPLE
        Get-MetricsSummary -Organization "myorg" -Usage $usage -Seats $seats -Billing $billing
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Organization,
        
        [Parameter(Mandatory = $false)]
        $Usage,
        
        [Parameter(Mandatory = $false)]
        $Seats,
        
        [Parameter(Mandatory = $false)]
        $Billing
    )
    
    try {
        $totalSuggestions = 0
        $totalAcceptances = 0
        $totalLines = 0
        $activeUsers = 0
        $languageBreakdown = @{}
        
        # Process usage data
        if ($Usage -and $Usage.PSObject.Properties['data']) {
            foreach ($day in $Usage.data) {
                $totalSuggestions += $day.total_suggestions_count
                $totalAcceptances += $day.total_acceptances_count
                $totalLines += $day.total_lines_suggested
                $activeUsers = [Math]::Max($activeUsers, $day.total_active_users)
                
                # Language breakdown
                if ($day.PSObject.Properties['breakdown']) {
                    foreach ($breakdown in $day.breakdown) {
                        $lang = $breakdown.language
                        if (-not $languageBreakdown.ContainsKey($lang)) {
                            $languageBreakdown[$lang] = @{
                                suggestions = 0
                                acceptances = 0
                                lines = 0
                            }
                        }
                        $languageBreakdown[$lang].suggestions += $breakdown.suggestions_count
                        $languageBreakdown[$lang].acceptances += $breakdown.acceptances_count
                        $languageBreakdown[$lang].lines += $breakdown.lines_suggested
                    }
                }
            }
        }
        
        # Calculate acceptance rate
        $acceptanceRate = if ($totalSuggestions -gt 0) { 
            [Math]::Round(($totalAcceptances / $totalSuggestions) * 100, 2) 
        } else { 0 }
        
        # Process seats data
        $totalSeats = 0
        $activeSeats = 0
        $inactiveSeats = 0
        
        if ($Seats -and $Seats.PSObject.Properties['seats']) {
            $totalSeats = $Seats.total_seats
            foreach ($seat in $Seats.seats) {
                if ($seat.last_activity_at) {
                    $lastActivity = [DateTime]::Parse($seat.last_activity_at)
                    $daysSinceActivity = ([DateTime]::Now - $lastActivity).Days
                    if ($daysSinceActivity -le 30) {
                        $activeSeats++
                    } else {
                        $inactiveSeats++
                    }
                } else {
                    $inactiveSeats++
                }
            }
        }
        
        # Process billing data
        $costPerSeat = 19  # Default GitHub Copilot Business cost
        $totalMonthlyCost = $totalSeats * $costPerSeat
        $potentialSavings = $inactiveSeats * $costPerSeat
        
        return @{
            Organization = $Organization
            ReportDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            Usage = @{
                TotalSuggestions = $totalSuggestions
                TotalAcceptances = $totalAcceptances
                TotalLines = $totalLines
                AcceptanceRate = $acceptanceRate
                ActiveUsers = $activeUsers
                LanguageBreakdown = $languageBreakdown
            }
            Seats = @{
                TotalSeats = $totalSeats
                ActiveSeats = $activeSeats
                InactiveSeats = $inactiveSeats
            }
            Billing = @{
                CostPerSeat = $costPerSeat
                TotalMonthlyCost = $totalMonthlyCost
                PotentialSavings = $potentialSavings
            }
        }
    }
    catch {
        Write-Error "Failed to calculate metrics summary: $($_.Exception.Message)"
        return @{
            Organization = $Organization
            ReportDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
            Error = $_.Exception.Message
            Usage = @{
                TotalSuggestions = 0
                TotalAcceptances = 0
                TotalLines = 0
                AcceptanceRate = 0
                ActiveUsers = 0
                LanguageBreakdown = @{}
            }
            Seats = @{
                TotalSeats = 0
                ActiveSeats = 0
                InactiveSeats = 0
            }
            Billing = @{
                CostPerSeat = 19
                TotalMonthlyCost = 0
                PotentialSavings = 0
            }
        }
    }
}

# Function to display metrics summary
function Show-MetricsSummary {
    param($Summary)
    
    try {
        Write-Host ""
        Write-Host "==================== COPILOT METRICS SUMMARY ===================="
        Write-Host "Organization: $($Summary.Organization)"
        Write-Host "Report Date: $($Summary.ReportDate)"
        Write-Host ""
        
        Write-Host "SEAT INFORMATION:"
        Write-Host "   Total Seats: $($Summary.Seats.TotalSeats)"
        Write-Host "   Active Seats (last 30 days): $($Summary.Seats.ActiveSeats)"
        Write-Host "   Inactive Seats: $($Summary.Seats.InactiveSeats)"
        Write-Host ""
        
        Write-Host "USAGE METRICS:"
        Write-Host "   Total Suggestions: $($Summary.Usage.TotalSuggestions)"
        Write-Host "   Total Acceptances: $($Summary.Usage.TotalAcceptances)"
        Write-Host "   Acceptance Rate: $($Summary.Usage.AcceptanceRate)%"
        Write-Host "   Total Lines Suggested: $($Summary.Usage.TotalLines)"
        Write-Host "   Active Users: $($Summary.Usage.ActiveUsers)"
        Write-Host ""
        
        Write-Host "COST ANALYSIS:"
        Write-Host "   Cost per Seat: `$$($Summary.Billing.CostPerSeat)/month"
        Write-Host "   Total Monthly Cost: `$$($Summary.Billing.TotalMonthlyCost)"
        Write-Host "   Potential Savings: `$$($Summary.Billing.PotentialSavings)/month"
        Write-Host ""
        
        if ($Summary.Usage.LanguageBreakdown.Count -gt 0) {
            Write-Host "TOP LANGUAGES BY SUGGESTIONS:"
            $sortedLanguages = $Summary.Usage.LanguageBreakdown.GetEnumerator() | 
                Sort-Object { $_.Value.suggestions } -Descending | 
                Select-Object -First 5
                
            foreach ($lang in $sortedLanguages) {
                $name = $lang.Key
                $suggestions = $lang.Value.suggestions
                $acceptances = $lang.Value.acceptances
                $rate = if ($suggestions -gt 0) { [Math]::Round(($acceptances / $suggestions) * 100, 1) } else { 0 }
                Write-Host "   $name`: $suggestions suggestions ($rate% acceptance)"
            }
            Write-Host ""
        }
        
        # Insights and recommendations
        Write-Host "INSIGHTS & RECOMMENDATIONS:"
        
        if ($Summary.Seats.InactiveSeats -gt 0) {
            Write-Host "   $($Summary.Seats.InactiveSeats) inactive seats detected - consider reassigning"
        }
        
        if ($Summary.Usage.AcceptanceRate -lt 50) {
            Write-Host "   Low acceptance rate ($($Summary.Usage.AcceptanceRate)%) - consider training"
        } elseif ($Summary.Usage.AcceptanceRate -gt 70) {
            Write-Host "   Excellent acceptance rate ($($Summary.Usage.AcceptanceRate)%)"
        }
        
        $utilization = if ($Summary.Seats.TotalSeats -gt 0) { 
            [Math]::Round(($Summary.Seats.ActiveSeats / $Summary.Seats.TotalSeats) * 100, 1) 
        } else { 0 }
        
        if ($utilization -lt 80) {
            Write-Host "   Seat utilization is $utilization% - optimize licensing"
        } else {
            Write-Host "   Good seat utilization: $utilization%"
        }
        
        Write-Host "======================================================================"
        Write-Host ""
    }
    catch {
        Write-Error "Failed to display metrics summary: $($_.Exception.Message)"
        Write-Host "Error displaying summary - raw data may still be available in export"
    }
}

# Function to export data to JSON
function Export-ToJson {
    <#
    .SYNOPSIS
        Exports data to a JSON file.
    
    .PARAMETER Data
        The data object to export.
    
    .PARAMETER Path
        The output directory path.
    
    .PARAMETER Filename
        The filename prefix.
    
    .PARAMETER Organization
        The organization name for the filename.
    
    .EXAMPLE
        Export-ToJson -Data $data -Path "reports" -Filename "copilot-metrics" -Organization "myorg"
    #>
    param(
        [Parameter(Mandatory = $true)]
        $Data,
        
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [Parameter(Mandatory = $true)]
        [string]$Filename,
        
        [Parameter(Mandatory = $true)]
        [string]$Organization
    )
    
    try {
        # Create output directory if it doesn't exist
        if (-not (Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-Host "Created directory: $Path"
        }
        
        # Generate filename with timestamp
        $timestamp = (Get-Date).ToString("yyyy-MM-ddTHH-mm-ss-fff") + "Z"
        $filename = "copilot-metrics-$Organization-$timestamp.json"
        $fullPath = Join-Path $Path $filename
        
        # Convert to JSON and save
        $jsonData = $Data | ConvertTo-Json -Depth 10
        $jsonData | Out-File -FilePath $fullPath -Encoding UTF8
        
        Write-Host "Report exported to: $fullPath"
        return $fullPath
    }
    catch {
        Write-Error "Failed to export data to JSON: $($_.Exception.Message)"
        return $null
    }
}

# Example usage
Write-Host "=== GitHub Copilot Metrics Collection Examples ==="

# Set your organization and token
$TOKEN = $env:GITHUB_TOKEN  # Set this environment variable or replace with your token
$ORGANIZATION = "YourOrgName"  # Replace with your organization name

if (-not $TOKEN) {
    Write-Warning "Please set GITHUB_TOKEN environment variable or update the TOKEN variable in this script"
    return
}

# Get Copilot usage metrics
Write-Host "=== Getting Copilot Usage Metrics ==="
$usageMetrics = Get-CopilotMetrics -Org $ORGANIZATION -Token $TOKEN
if ($usageMetrics -and $usageMetrics.Length -gt 0) {
    Write-Host "Found $($usageMetrics.Length) daily usage records"
    $totalSuggestions = ($usageMetrics | Measure-Object -Property total_suggestions_count -Sum).Sum
    Write-Host "Total Suggestions: $totalSuggestions"
} else {
    Write-Host "No usage metrics found"
}

# Get Copilot seat information
Write-Host "=== Getting Copilot Seat Information ==="
$seatInfo = Get-CopilotSeats -Org $ORGANIZATION -Token $TOKEN
if ($seatInfo) {
    Write-Host "Total Seats: $($seatInfo.total_seats)"
    $activeSeats = ($seatInfo.seats | Where-Object { $_.last_activity_at -and ([DateTime]::Parse($_.last_activity_at) -gt (Get-Date).AddDays(-30)) }).Count
    Write-Host "Active Seats (last 30 days): $activeSeats"
} else {
    Write-Host "No seat information found"
}

# Get Copilot billing information
Write-Host "=== Getting Copilot Billing Information ==="
$billingInfo = Get-CopilotBilling -Org $ORGANIZATION -Token $TOKEN
if ($billingInfo) {
    Write-Host "Billing Plan: $($billingInfo.billing_cycle)"
    Write-Host "Seat Management Setting: $($billingInfo.seat_management_setting)"
} else {
    Write-Host "No billing information found"
}

# Calculate comprehensive metrics summary
Write-Host "=== Calculating Comprehensive Metrics Summary ==="
$metricsSummary = Get-MetricsSummary -Organization $ORGANIZATION -Usage $usageMetrics -Seats $seatInfo -Billing $billingInfo
Write-Host "Metrics summary calculated for organization: $($metricsSummary.Organization)"
Write-Host "Acceptance Rate: $($metricsSummary.Usage.AcceptanceRate)%"

# Display formatted metrics summary
Write-Host "=== Displaying Formatted Metrics Summary ==="
Show-MetricsSummary -Summary $metricsSummary

# Export metrics to JSON
Write-Host "=== Exporting Metrics to JSON ==="
$exportPath = Export-ToJson -Data $metricsSummary -Path "reports" -Filename "copilot-metrics" -Organization $ORGANIZATION
if ($exportPath) {
    Write-Host "Metrics exported successfully!"
}

# Alternative: Get all data in one go and display
Write-Host "=== Complete Workflow Example ==="
try {
    # Collect all data
    $allUsage = Get-CopilotMetrics -Org $ORGANIZATION -Token $TOKEN
    $allSeats = Get-CopilotSeats -Org $ORGANIZATION -Token $TOKEN
    $allBilling = Get-CopilotBilling -Org $ORGANIZATION -Token $TOKEN
    
    # Calculate summary
    $completeSummary = Get-MetricsSummary -Organization $ORGANIZATION -Usage $allUsage -Seats $allSeats -Billing $allBilling
    
    # Display and export
    Show-MetricsSummary -Summary $completeSummary
    $finalExport = Export-ToJson -Data $completeSummary -Path "reports" -Filename "copilot-metrics" -Organization $ORGANIZATION
    
    Write-Host "Complete Copilot metrics collection and analysis finished!"
    Write-Host "Report saved to: $finalExport"
}
catch {
    Write-Error "Failed to complete metrics workflow: $($_.Exception.Message)"
}