# Load the issues management functions
. "$PSScriptRoot\issues-management.ps1"

# Set your repository details and token
$TOKEN = $env:GITHUB_TOKEN  # Set this environment variable or replace with your token
$OWNER = $env:GITHUB_OWNER  # Replace with your organization/owner name
$REPO = $env:GITHUB_REPO  # Replace with your repository name
$ISSUE_NUMBER = 1  # Replace with a specific issue number to test

if (-not $TOKEN) {
    Write-Warning "Please set GITHUB_TOKEN environment variable or update the TOKEN variable in this script"
    return
}

# Example usage
Write-Host "=== GitHub Issues Example ==="

# Get all issues
Write-Host "=== Getting Issues ==="
Get-GitHubIssues -Owner $OWNER -Repo $REPO -Token $TOKEN

# Get a specific issue
Write-Host "=== Getting Specific Issue ==="
Get-GitHubIssue -Owner $OWNER -Repo $REPO -IssueNumber $ISSUE_NUMBER -Token $TOKEN

# Get assignees for a specific issue
Write-Host "=== Getting Issue Assignees ==="
Get-GitHubIssueAssignees -Owner $OWNER -Repo $REPO -IssueNumber $ISSUE_NUMBER -Token $TOKEN

# Assign a user to issue #1 (replace "username" with actual username)
Write-Host "=== Assigning User to Issue ==="
Set-GitHubIssueAssignee -Owner $OWNER -Repo $REPO -IssueNumber $ISSUE_NUMBER -Assignees @("username") -Token $TOKEN

# Get assignees again to verify
Write-Host "=== Getting Updated Assignees ==="
Get-GitHubIssueAssignees -Owner $OWNER -Repo $REPO -IssueNumber $ISSUE_NUMBER -Token $TOKEN