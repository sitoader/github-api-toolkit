# Load the copilot metrics functions
. "$PSScriptRoot\copilot-metrics.ps1"

# Set your organization and token
$TOKEN = $env:GITHUB_TOKEN  # Set this environment variable or replace with your token
$ORGANIZATION = $env:GITHUB_ORG  # Replace with your organization name

# Example usage
Write-Host "=== GitHub Copilot Metrics Example ==="

# Get Copilot usage metrics
Write-Host "=== Getting Copilot Usage Metrics ==="
$usageMetrics = Get-CopilotMetrics -Org $ORGANIZATION -Token $TOKEN

# Get Copilot seat information
Write-Host "=== Getting Copilot Seat Information ==="
$seatInfo = Get-CopilotSeats -Org $ORGANIZATION -Token $TOKEN

# Get Copilot billing information
Write-Host "=== Getting Copilot Billing Information ==="
$billingInfo = Get-CopilotBilling -Org $ORGANIZATION -Token $TOKEN

# Calculate comprehensive metrics summary
Write-Host "=== Calculating Comprehensive Metrics Summary ==="
$metricsSummary = Get-MetricsSummary -Organization $ORGANIZATION -Usage $usageMetrics -Seats $seatInfo -Billing $billingInfo

# Display formatted metrics summary
Write-Host "=== Displaying Formatted Metrics Summary ==="
Show-MetricsSummary -Summary $metricsSummary

# Export metrics to JSON
Write-Host "=== Exporting Metrics to JSON ==="
$exportPath = Export-ToJson -Data $metricsSummary -Path "reports" -Filename "copilot-metrics" -Organization $ORGANIZATION
if ($exportPath) {
    Write-Host "Metrics exported successfully to: $exportPath"
}