# GitHub Enterprise Policy Management PowerShell Script
# This script provides comprehensive enterprise policy management and compliance monitoring functions

# Function to get organization information
function Get-OrganizationInfo {
    <#
    .SYNOPSIS
        Retrieves organization information from GitHub using the GitHub API.
    
    .PARAMETER Org
        The organization name.
    
    .PARAMETER Token
        The GitHub personal access token for authentication.
    
    .EXAMPLE
        Get-OrganizationInfo -Org "myorg" -Token "your_token_here"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Org,
        
        [Parameter(Mandatory = $true)]
        [string]$Token
    )
    
    $uri = "https://api.github.com/orgs/$Org"
    
    # Set up headers with authentication
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    try {
        Write-Host "🔄 API Request: GET $uri"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET
        return $response
    }
    catch {
        Write-Error "Failed to fetch organization information: $($_.Exception.Message)"
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Warning "   Organization not found - check organization name and permissions"
        }
        return $null
    }
}

# Function to get Copilot settings
function Get-CopilotSettings {
    <#
    .SYNOPSIS
        Retrieves GitHub Copilot settings for an organization using the GitHub API.
    
    .PARAMETER Org
        The organization name.
    
    .PARAMETER Token
        The GitHub personal access token for authentication.
    
    .EXAMPLE
        Get-CopilotSettings -Org "myorg" -Token "your_token_here"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Org,
        
        [Parameter(Mandatory = $true)]
        [string]$Token
    )
    
    Write-Host "🤖 Retrieving Copilot settings..."
    
    # Set up headers with authentication
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    # Try to get Copilot billing info (includes settings)
    $billingUri = "https://api.github.com/orgs/$Org/copilot/billing"
    
    try {
        Write-Host "🔄 API Request: GET $billingUri"
        $billing = Invoke-RestMethod -Uri $billingUri -Headers $headers -Method GET
        
        return @{
            HasCopilot = $true
            TotalSeats = $billing.total_seats
            SeatsCurrentlyInUse = $billing.seats_currently_in_use
            SeatManagementSetting = $billing.seat_management_setting
            PublicCodeSuggestions = $billing.public_code_suggestions
        }
    }
    catch {
        Write-Error "Failed to fetch Copilot settings: $($_.Exception.Message)"
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Warning "   Copilot Business not available or insufficient permissions"
        }
        return @{
            HasCopilot = $false
            Message = "Copilot Business not available or insufficient permissions"
        }
    }
}

# Function to get organization security settings
function Get-SecuritySettings {
    <#
    .SYNOPSIS
        Retrieves security settings for an organization using the GitHub API.
    
    .PARAMETER Org
        The organization name.
    
    .PARAMETER Token
        The GitHub personal access token for authentication.
    
    .EXAMPLE
        Get-SecuritySettings -Org "myorg" -Token "your_token_here"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Org,
        
        [Parameter(Mandatory = $true)]
        [string]$Token
    )
    
    Write-Host "🔒 Retrieving security settings..."
    
    # Set up headers with authentication
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    $settings = @{}
    
    try {
        # Get organization info (includes some security settings)
        $orgInfo = Get-OrganizationInfo -Org $Org -Token $Token
        if ($orgInfo) {
            $settings.DependencyGraphEnabled = $orgInfo.dependency_graph_enabled_for_new_repositories
            $settings.DependabotAlertsEnabled = $orgInfo.dependabot_alerts_enabled_for_new_repositories
            $settings.DependabotSecurityUpdatesEnabled = $orgInfo.dependabot_security_updates_enabled_for_new_repositories
            $settings.AdvancedSecurityEnabled = $orgInfo.advanced_security_enabled_for_new_repositories
            $settings.SecretScanningEnabled = $orgInfo.secret_scanning_enabled_for_new_repositories
            $settings.SecretScanningPushProtectionEnabled = $orgInfo.secret_scanning_push_protection_enabled_for_new_repositories
        }
        
        # Try to get security advisories
        $advisoriesUri = "https://api.github.com/orgs/$Org/security-advisories"
        try {
            Write-Host "🔄 API Request: GET $advisoriesUri"
            $advisories = Invoke-RestMethod -Uri $advisoriesUri -Headers $headers -Method GET
            $settings.SecurityAdvisoriesCount = if ($advisories) { $advisories.Count } else { 0 }
        }
        catch {
            Write-Warning "Failed to fetch security advisories: $($_.Exception.Message)"
            $settings.SecurityAdvisoriesCount = 0
        }
        
        return $settings
    }
    catch {
        Write-Error "Failed to fetch security settings: $($_.Exception.Message)"
        return @{ Error = "Unable to retrieve security settings" }
    }
}

# Function to get member access policies
function Get-AccessPolicies {
    <#
    .SYNOPSIS
        Retrieves access policies for an organization using the GitHub API.
    
    .PARAMETER Org
        The organization name.
    
    .PARAMETER Token
        The GitHub personal access token for authentication.
    
    .EXAMPLE
        Get-AccessPolicies -Org "myorg" -Token "your_token_here"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Org,
        
        [Parameter(Mandatory = $true)]
        [string]$Token
    )
    
    Write-Host "👥 Retrieving access policies..."
    
    try {
        $orgInfo = Get-OrganizationInfo -Org $Org -Token $Token
        if (-not $orgInfo) {
            return @{ Error = "Unable to retrieve organization information" }
        }
        
        return @{
            DefaultRepositoryPermission = $orgInfo.default_repository_permission
            MembersCanCreateRepositories = $orgInfo.members_can_create_repositories
            MembersCanCreatePublicRepositories = $orgInfo.members_can_create_public_repositories
            MembersCanCreatePrivateRepositories = $orgInfo.members_can_create_private_repositories
            MembersCanForkPrivateRepositories = $orgInfo.members_can_fork_private_repositories
            WebCommitSignoffRequired = $orgInfo.web_commit_signoff_required
            MembersAllowedRepositoryCreationType = $orgInfo.members_allowed_repository_creation_type
            Plan = $orgInfo.plan.name
            TotalPrivateRepos = $orgInfo.total_private_repos
            PublicRepos = $orgInfo.public_repos
            TotalMembers = $orgInfo.public_members + $orgInfo.total_private_repos  # Approximation
        }
    }
    catch {
        Write-Error "Failed to fetch access policies: $($_.Exception.Message)"
        return @{ Error = "Unable to retrieve access policies" }
    }
}

# Function to calculate compliance score
function Get-ComplianceScore {
    param(
        $CopilotSettings,
        $SecuritySettings, 
        $AccessPolicies
    )
    
    try {
        $score = 0
        $maxScore = 0
        $recommendations = @()
        
        # Security compliance checks
        if ($SecuritySettings.DependencyGraphEnabled) { $score += 10 } else { 
            $recommendations += "Enable dependency graph for new repositories"
        }
        $maxScore += 10
        
        if ($SecuritySettings.DependabotAlertsEnabled) { $score += 10 } else {
            $recommendations += "Enable Dependabot alerts for new repositories"
        }
        $maxScore += 10
        
        if ($SecuritySettings.SecretScanningEnabled) { $score += 15 } else {
            $recommendations += "Enable secret scanning for new repositories"
        }
        $maxScore += 15
        
        if ($SecuritySettings.SecretScanningPushProtectionEnabled) { $score += 15 } else {
            $recommendations += "Enable secret scanning push protection"
        }
        $maxScore += 15
        
        # Access control compliance checks  
        if ($AccessPolicies.DefaultRepositoryPermission -eq "read") { $score += 10 } else {
            $recommendations += "Set default repository permission to 'read'"
        }
        $maxScore += 10
        
        if (-not $AccessPolicies.MembersCanCreatePublicRepositories) { $score += 10 } else {
            $recommendations += "Restrict public repository creation"
        }
        $maxScore += 10
        
        if ($AccessPolicies.WebCommitSignoffRequired) { $score += 5 } else {
            $recommendations += "Require web commit signoff"
        }
        $maxScore += 5
        
        # Copilot compliance checks
        if ($CopilotSettings.HasCopilot) {
            if ($CopilotSettings.PublicCodeSuggestions -eq "block") { $score += 15 } else {
                $recommendations += "Block public code suggestions in Copilot"
            }
            $maxScore += 15
            
            if ($CopilotSettings.SeatManagementSetting -eq "assign_selected") { $score += 10 } else {
                $recommendations += "Use selective seat assignment for Copilot"
            }
            $maxScore += 10
        } else {
            $maxScore += 25  # Still count Copilot policies in total possible score
        }
        
        $compliancePercentage = if ($maxScore -gt 0) { [Math]::Round(($score / $maxScore) * 100, 1) } else { 0 }
        
        return @{
            Score = $score
            MaxScore = $maxScore
            Percentage = $compliancePercentage
            Recommendations = $recommendations
            PolicyBreakdown = @{
                SecurityScore = [Math]::Round((($score / $maxScore) * 100), 1)
                AccessScore = [Math]::Round((($score / $maxScore) * 100), 1)
                CopilotScore = if ($CopilotSettings.HasCopilot) { [Math]::Round((($score / $maxScore) * 100), 1) } else { "N/A" }
            }
        }
    }
    catch {
        Write-Error "Failed to calculate compliance score: $($_.Exception.Message)"
        return @{
            Score = 0
            MaxScore = 0
            Percentage = 0
            Recommendations = @("Error calculating compliance score")
            Error = $_.Exception.Message
        }
    }
}

# Function to display policy summary
function Show-PolicySummary {
    param(
        $OrgInfo,
        $CopilotSettings,
        $SecuritySettings,
        $AccessPolicies,
        $ComplianceScore
    )
    
    try {
        Write-Host ""
        Write-Host "==================== ENTERPRISE POLICY SUMMARY ===================="
        Write-Host "Organization: $($OrgInfo.name)"
        Write-Host "Plan: $($AccessPolicies.Plan)"
        Write-Host "Total Members: ~$($AccessPolicies.TotalMembers)"
        Write-Host "Private Repositories: $($AccessPolicies.TotalPrivateRepos)"
        Write-Host "Public Repositories: $($AccessPolicies.PublicRepos)"
        Write-Host ""
        
        # Security Settings
        Write-Host "SECURITY SETTINGS:"
        Write-Host "   Dependency Graph: $(if ($SecuritySettings.DependencyGraphEnabled) { 'Enabled' } else { 'Disabled' })"
        Write-Host "   Dependabot Alerts: $(if ($SecuritySettings.DependabotAlertsEnabled) { 'Enabled' } else { 'Disabled' })"
        Write-Host "   Secret Scanning: $(if ($SecuritySettings.SecretScanningEnabled) { 'Enabled' } else { 'Disabled' })"
        Write-Host "   Push Protection: $(if ($SecuritySettings.SecretScanningPushProtectionEnabled) { 'Enabled' } else { 'Disabled' })"
        Write-Host ""
        
        # Copilot Settings
        Write-Host "COPILOT SETTINGS:"
        if ($CopilotSettings.HasCopilot) {
            Write-Host "   Copilot Business: Active"
            Write-Host "   Total Seats: $($CopilotSettings.TotalSeats)"
            Write-Host "   Seats In Use: $($CopilotSettings.SeatsCurrentlyInUse)"
            Write-Host "   Seat Management: $($CopilotSettings.SeatManagementSetting)"
            $publicCodeStatus = if ($CopilotSettings.PublicCodeSuggestions -eq "block") { "Blocked" } else { "Allowed" }
            Write-Host "   Public Code Suggestions: $publicCodeStatus"
        } else {
            Write-Host "   Copilot Business: Not Available"
            Write-Host "   $($CopilotSettings.Message)"
        }
        Write-Host ""
        
        # Access Policies
        Write-Host "ACCESS POLICIES:"
        Write-Host "   Default Repository Permission: $($AccessPolicies.DefaultRepositoryPermission)"
        
        $publicRepoStatus = if (-not $AccessPolicies.MembersCanCreatePublicRepositories) { "Restricted" } else { "Allowed" }
        Write-Host "   Public Repo Creation: $publicRepoStatus"
        
        $signoffStatus = if ($AccessPolicies.WebCommitSignoffRequired) { "Required" } else { "Not Required" }
        Write-Host "   Web Commit Signoff: $signoffStatus"
        Write-Host ""
        
        # Compliance Score
        Write-Host "COMPLIANCE SCORE: $($ComplianceScore.Percentage)% ($($ComplianceScore.Score)/$($ComplianceScore.MaxScore))"
        Write-Host ""
        
        # Recommendations
        if ($ComplianceScore.Recommendations.Count -gt 0) {
            Write-Host "POLICY RECOMMENDATIONS:"
            foreach ($recommendation in $ComplianceScore.Recommendations) {
                Write-Host "   $recommendation"
            }
            Write-Host ""
        } else {
            Write-Host "All policy checks passed!"
            Write-Host ""
        }
        
        Write-Host "======================================================================"
        Write-Host ""
    }
    catch {
        Write-Error "Failed to display policy summary: $($_.Exception.Message)"
    }
}

# Function to export policy data to JSON
function Export-PolicyToJson {
    <#
    .SYNOPSIS
        Exports policy data to a JSON file.
    
    .PARAMETER Data
        The data object to export.
    
    .PARAMETER Path
        The output directory path.
    
    .PARAMETER Prefix
        The filename prefix.
    
    .PARAMETER Organization
        The organization name for the filename.
    
    .EXAMPLE
        Export-PolicyToJson -Data $data -Path "reports" -Prefix "enterprise-policy" -Organization "myorg"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [object]$Data,
        
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [Parameter(Mandatory = $true)]
        [string]$Prefix,
        
        [Parameter(Mandatory = $true)]
        [string]$Organization
    )
    
    try {
        if (-not (Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-Host "📁 Created directory: $Path"
        }
        
        $timestamp = (Get-Date).ToString("yyyy-MM-ddTHH-mm-ss-fff") + "Z"
        $filename = "$Prefix-$Organization-$timestamp.json"
        $fullPath = Join-Path $Path $filename
        
        $jsonData = $Data | ConvertTo-Json -Depth 10
        $jsonData | Out-File -FilePath $fullPath -Encoding UTF8
        
        Write-Host "📊 Policy report exported to: $fullPath"
        return $fullPath
    }
    catch {
        Write-Error "Failed to export policy data to JSON: $($_.Exception.Message)"
        return $null
    }
}
