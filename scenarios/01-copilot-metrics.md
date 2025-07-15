# Scenario 1: GitHub Copilot Metrics Collection

## 📊 Overview

This scenario provides comprehensive GitHub Copilot usage analytics for enterprise organizations. It collects detailed metrics about Copilot adoption, usage patterns, billing information, and generates actionable reports for management and optimization.

## 🎯 Business Objectives

- **Track Copilot ROI**: Measure return on investment for GitHub Copilot licenses
- **Monitor Adoption**: Track how teams are adopting and using Copilot features
- **Optimize Licensing**: Identify unused seats and optimize license allocation
- **Performance Analytics**: Understand code completion acceptance rates and productivity gains
- **Compliance Reporting**: Generate reports for leadership and compliance teams

### Key Features

1. **Usage Metrics Collection**
   - Daily active users
   - Code suggestions and acceptances
   - Language-specific usage patterns
   - Team-level breakdown

2. **Seat Management**
   - Active vs. inactive seats
   - Seat allocation by team
   - Last activity tracking
   - Cost optimization insights

3. **Billing Analytics**
   - Current billing cycle information
   - Seat costs and total spending
   - Usage trends over time

4. **Report Generation**
   - JSON export functionality
   - Formatted console summaries
   - Timestamp-based file naming
   - Automatic reports folder creation

## 📋 Prerequisites

### GitHub App Permissions Required

| Permission | Level | Purpose |
|------------|-------|---------|
| **Copilot Business management** | Read | Access usage and billing data |
| **Administration** | Read | Organization-level metrics |

### Environment Variables

```bash
GITHUB_APP_ID=your_app_id
GITHUB_PRIVATE_KEY_PATH=./private-key.pem
GITHUB_INSTALLATION_ID=your_installation_id
GITHUB_ORG=your-organization-name
```

## 🚀 Usage Examples

```bash
npm run copilot-metrics
```

## 📈 Output and Reports

### Console Output Example

```
🚀 Starting GitHub Copilot Metrics collection...
📊 Generating Copilot metrics report for MyOrg...
📁 Created reports directory: /path/to/reports
📊 Report exported to: /reports/copilot-metrics-MyOrg-2025-07-30T09-31-56-676Z.json

=== Copilot Metrics Summary ===
Organization: MyOrg
Total Seats: 150
Active Users (Last 30 days): 142
Total Suggestions: 45,230
Total Acceptances: 28,647
Acceptance Rate: 63.3%
Most Active Language: JavaScript (12,450 suggestions)
Cost per Active User: $19/month
Potential Savings: $152/month (8 inactive seats)
```

### JSON Report Structure

```json
{
  "organization": "MyOrg",
  "reportDate": "2025-07-30T09:31:56.676Z",
  "dateRange": {
    "since": "2024-01-01",
    "until": "2024-12-31"
  },
  "usage": {
    "totalSuggestions": 45230,
    "totalAcceptances": 28647,
    "acceptanceRate": 0.633,
    "activeUsers": 142,
    "breakdown": {
      "byLanguage": {
        "javascript": 12450,
        "python": 8930,
        "typescript": 7820
      },
      "byTeam": {
        "frontend": 15230,
        "backend": 12890,
        "devops": 4560
      }
    }
  },
  "billing": {
    "totalSeats": 150,
    "activeSeats": 142,
    "inactiveSeats": 8,
    "costPerSeat": 19,
    "totalMonthlyCost": 2850,
    "potentialSavings": 152
  },
  "insights": {
    "topPerformingTeams": ["frontend", "backend"],
    "underutilizedSeats": 8,
    "recommendedActions": [
      "Review inactive seat assignments",
      "Provide training for low-adoption teams"
    ]
  }
}
```

## 📊 Key Metrics Tracked

### Usage Metrics
- **Daily Active Users**: Number of developers using Copilot daily
- **Suggestion Volume**: Total code suggestions generated
- **Acceptance Rate**: Percentage of suggestions accepted
- **Language Distribution**: Usage breakdown by programming language
- **Time-based Patterns**: Peak usage hours and days

### Adoption Metrics
- **Team Penetration**: Percentage of team members actively using Copilot
- **Feature Usage**: Which Copilot features are most popular
- **Learning Curve**: Time to active adoption for new users

### Financial Metrics
- **Cost per Active User**: Monthly cost divided by active users
- **ROI Indicators**: Productivity gains vs. licensing costs
- **Optimization Opportunities**: Unused seats and potential savings

## ⚠️ Common Issues and Troubleshooting

### 1. Authentication Errors
```
Error: Bad credentials
```
**Solution**: Verify GitHub App permissions include "Copilot Business management"

### 2. Organization Access
```
Error: Not Found
```
**Solution**: Ensure GitHub App is installed on the target organization

### 3. Rate Limiting
```
Error: API rate limit exceeded
```
**Solution**: Implement retry logic with exponential backoff (included in implementation)

### 4. Insufficient Permissions
```
Error: Resource not accessible by integration
```
**Solution**: Grant "Administration" read permission to GitHub App

## 📚 Additional Resources

- [GitHub Copilot Business API Documentation](https://docs.github.com/en/rest/copilot)
- [GitHub App Authentication Guide](https://docs.github.com/en/developers/apps/building-github-apps/authenticating-with-github-apps)
- [Copilot Usage Analytics Best Practices](https://docs.github.com/en/copilot/managing-copilot-business/reviewing-usage-data-for-github-copilot-business)

