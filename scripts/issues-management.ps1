function Get-GitHubIssues {
    <#
    .SYNOPSIS
        Retrieves issues from a GitHub repository using the GitHub API.
    
    .PARAMETER Owner
        The owner/organization of the GitHub repository.
    
    .PARAMETER Repo
        The name of the GitHub repository.
    
    .PARAMETER Token
        The GitHub personal access token for authentication.
    
    .EXAMPLE
        Get-GitHubIssues -Owner "microsoft" -Repo "vscode" -Token "your_token_here"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,
        
        [Parameter(Mandatory = $true)]
        [string]$Repo,
        
        [Parameter(Mandatory = $true)]
        [string]$Token
    )
    
    # Construct the API URL
    $apiUrl = "https://api.github.com/repos/$Owner/$Repo/issues"
    
    # Set up headers with authentication
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    try {
        # Make the API request
        Write-Host "Fetching issues from $apiUrl..."
        
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
        
        # Filter out pull requests (GitHub API returns both issues and PRs)
        $issues = $response | Where-Object { -not $_.pull_request }
        
        # Display results
        Write-Host "Found $($issues.Count) issues (filtered from $($response.Count) total items):"
        
        foreach ($issue in $issues) {
            Write-Host "Issue #$($issue.number): $($issue.title)"
            Write-Host "  State: $($issue.state)"
            Write-Host "  Created: $($issue.created_at)"
            Write-Host "  URL: $($issue.html_url)"
            Write-Host "  ID: $($issue.id)"
            Write-Host "  Creator: $($issue.user.login) ($($issue.user.name))"
            Write-Host "  Assignees: $($issue.assignees.Count)"
            Write-Host "  Title: $($issue.title)"
            Write-Host ""
        }

        return $issues
    }
    catch {
        Write-Error "Failed to fetch issues: $($_.Exception.Message)"
        return $null
    }
}

function Get-GitHubIssueAssignees {
    <#
    .SYNOPSIS
        Retrieves current assignees for a specific GitHub issue.
    
    .PARAMETER Owner
        The owner/organization of the GitHub repository.
    
    .PARAMETER Repo
        The name of the GitHub repository.
    
    .PARAMETER IssueNumber
        The issue number to get assignees for.
    
    .PARAMETER Token
        The GitHub personal access token for authentication.
    
    .EXAMPLE
        Get-GitHubIssueAssignees -Owner "microsoft" -Repo "vscode" -IssueNumber 123 -Token "your_token_here"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,
        
        [Parameter(Mandatory = $true)]
        [string]$Repo,
        
        [Parameter(Mandatory = $true)]
        [int]$IssueNumber,
        
        [Parameter(Mandatory = $true)]
        [string]$Token
    )
    
    # Construct the API URL
    $apiUrl = "https://api.github.com/repos/$Owner/$Repo/issues/$IssueNumber"
    
    # Set up headers with authentication
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    try {
        # Make the API request
        Write-Host "Fetching assignees for issue #$IssueNumber..."
        
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
        
        # Display results
        if ($response.assignees.Count -gt 0) {
            Write-Host "Issue #$IssueNumber has $($response.assignees.Count) assignees:"
            
            foreach ($assignee in $response.assignees) {
                Write-Host "$($assignee.login)"
                Write-Host "  Name: $($assignee.name)"
                Write-Host "  Profile: $($assignee.html_url)"
                Write-Host ""
            }
        } else {
            Write-Host "Issue #$IssueNumber has no assignees"
        }
        
        return $response.assignees
    }
    catch {
        Write-Error "Failed to fetch issue assignees: $($_.Exception.Message)"
        return $null
    }
}

function Get-GitHubIssue {
    <#
    .SYNOPSIS
        Retrieves a specific issue from a GitHub repository using the GitHub API.
    
    .PARAMETER Owner
        The owner/organization of the GitHub repository.
    
    .PARAMETER Repo
        The name of the GitHub repository.
    
    .PARAMETER IssueNumber
        The issue number to retrieve.
    
    .PARAMETER Token
        The GitHub personal access token for authentication.
    
    .EXAMPLE
        Get-GitHubIssue -Owner "microsoft" -Repo "vscode" -IssueNumber 123 -Token "your_token_here"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,
        
        [Parameter(Mandatory = $true)]
        [string]$Repo,
        
        [Parameter(Mandatory = $true)]
        [int]$IssueNumber,
        
        [Parameter(Mandatory = $true)]
        [string]$Token
    )
    
    # Construct the API URL
    $apiUrl = "https://api.github.com/repos/$Owner/$Repo/issues/$IssueNumber"
    
    # Set up headers with authentication
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    
    try {
        # Make the API request
        Write-Host "Fetching issue $IssueNumber from $apiUrl..."
        
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

        # Check if this is actually a pull request
        if ($response.pull_request) {
            Write-Host "Item $IssueNumber not found"
            return $null
        }

        # Display detailed results
        Write-Host "Issue $($response.number): $($response.title)"
        Write-Host "  ID: $($response.id)"
        Write-Host "  State: $($response.state)"
        Write-Host "  Creator: $($response.user.login) ($($response.user.name))"
        Write-Host "  Created: $($response.created_at)"
        Write-Host "  Updated: $($response.updated_at)"
        Write-Host "  URL: $($response.html_url)"
        Write-Host ""

        return @{
            IssueNumber = $response.number
            ID = $response.id
            Title = $response.title
            State = $response.state
            Creator = $response.user.login
            CreatedAt = $response.created_at
            UpdatedAt = $response.updated_at
            URL = $response.html_url
        }
    }
    catch {
        Write-Error "Failed to fetch issue $IssueNumber`: $($_.Exception.Message)"
        return $null
    }
}

function Set-GitHubIssueAssignee {
    <#
    .SYNOPSIS
        Assigns one or more users to a GitHub issue using the GitHub API.
    
    .PARAMETER Owner
        The owner/organization of the GitHub repository.
    
    .PARAMETER Repo
        The name of the GitHub repository.
    
    .PARAMETER IssueNumber
        The issue number to assign users to.
    
    .PARAMETER Assignees
        Array of usernames to assign to the issue.
    
    .PARAMETER Token
        The GitHub personal access token for authentication.
    
    .EXAMPLE
        Set-GitHubIssueAssignee -Owner "microsoft" -Repo "vscode" -IssueNumber 123 -Assignees @("username1", "username2") -Token "your_token_here"
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,
        
        [Parameter(Mandatory = $true)]
        [string]$Repo,
        
        [Parameter(Mandatory = $true)]
        [int]$IssueNumber,
        
        [Parameter(Mandatory = $true)]
        [string[]]$Assignees,
        
        [Parameter(Mandatory = $true)]
        [string]$Token
    )
    
    # Construct the API URL
    $apiUrl = "https://api.github.com/repos/$Owner/$Repo/issues/$IssueNumber/assignees"
    
    # Set up headers with authentication
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept" = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
        "Content-Type" = "application/json"
    }
    
    # Prepare the request body
    $body = @{
        assignees = $Assignees
    } | ConvertTo-Json
    
    try {
        # Make the API request
        Write-Host "Assigning users to issue $IssueNumber..."
        Write-Host "Assignees: $($Assignees -join ', ')"
        
        $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Post -Body $body
        
        # Display results
        if ($response.assignees.Count -gt 0) {
            Write-Host "Successfully assigned $($response.assignees.Count) users to issue #$IssueNumber"
            
            foreach ($assignee in $response.assignees) {
                Write-Host "  $($assignee.login)"
                if ($assignee.name) {
                    Write-Host "    Name: $($assignee.name)"
                }
            }
        } else {
            Write-Host "No assignees were added to issue $IssueNumber"
        }
        
        Write-Host ""
        return $response.assignees
    }
    catch {
        Write-Error "Failed to assign users to issue $IssueNumber`: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            Write-Error "   HTTP Status: $statusCode"
            
            if ($statusCode -eq 422) {
                Write-Host "Tip: Check if the usernames are valid and have access to the repository"
            }
        }
        return $null
    }
}