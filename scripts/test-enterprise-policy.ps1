# Load the enterprise policy functions
. "$PSScriptRoot\enterprise-policy.ps1"

# Set your organization and token
$TOKEN = $env:GITHUB_TOKEN  # Set this environment variable or replace with your token
$ORGANIZATION = $env:GITHUB_ORG  # Replace with your organization name

# Example usage
Write-Host "=== GitHub Enterprise Policy Example ==="

# Get organization information
Write-Host "=== Getting Organization Information ==="
Get-OrganizationInfo -Org $ORGANIZATION -Token $TOKEN

# Get Copilot settings
Write-Host "=== Getting Copilot Settings ==="
$copilotSettings = Get-CopilotSettings -Org $ORGANIZATION -Token $TOKEN

# Get security settings
Write-Host "=== Getting Security Settings ==="
$securitySettings = Get-SecuritySettings -Org $ORGANIZATION -Token $TOKEN

# Get access policies
Write-Host "=== Getting Access Policies ==="
$accessPolicies = Get-AccessPolicies -Org $ORGANIZATION -Token $TOKEN

# Calculate compliance score
Write-Host "=== Calculating Compliance Score ==="
$complianceScore = Get-ComplianceScore -CopilotSettings $copilotSettings -SecuritySettings $securitySettings -AccessPolicies $accessPolicies

# Display policy summary
Write-Host "=== Displaying Policy Summary ==="
$orgInfo = Get-OrganizationInfo -Org $ORGANIZATION -Token $TOKEN
Show-PolicySummary -OrgInfo $orgInfo -CopilotSettings $copilotSettings -SecuritySettings $securitySettings -AccessPolicies $accessPolicies -ComplianceScore $complianceScore

# Export policy data to JSON
Write-Host "=== Exporting Policy Data ==="
$policyData = @{
    Organization = $ORGANIZATION
    Timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    OrganizationInfo = $orgInfo
    CopilotSettings = $copilotSettings
    SecuritySettings = $securitySettings
    AccessPolicies = $accessPolicies
    ComplianceScore = $complianceScore
}
Export-PolicyToJson -Data $policyData -Path "reports" -Prefix "enterprise-policy" -Organization $ORGANIZATION