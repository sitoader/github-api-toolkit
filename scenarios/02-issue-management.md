# Scenario 2: Automated Issue Management

## 📋 Overview

This scenario provides streamlined issue workflows with focused single-user assignments to ensure proper expertise allocation across development teams.

## 🎯 Business Objectives

- **Precise Issue Assignment**: Assign specific issues to individual experts
- **Expert Routing**: Route issues to the most qualified team member
- **Clear Accountability**: Ensure each issue has a single responsible owner
- **Response Time Optimization**: Get issues to the right person quickly
- **Process Standardization**: Maintain consistent issue management workflows

## 🔧 Technical Implementation

### Core API: `issue-management.js`

The implementation uses the GitHub REST API v3 with the following endpoints:

```javascript
// List Repository Issues
GET /repos/{owner}/{repo}/issues

// Get Specific Issue
GET /repos/{owner}/{repo}/issues/{issue_number}

// Assign Issue to User
POST /repos/{owner}/{repo}/issues/{issue_number}/assignees

// Add Labels to Issue
POST /repos/{owner}/{repo}/issues/{issue_number}/labels
```

### Key Features

1. **Advanced Issue Fetching**
   - Multi-criteria filtering (state, labels, assignee, etc.)
   - Pagination handling for large repositories
   - Automatic pull request filtering
   - Metadata tracking and timestamps

2. **Focused Assignment**
   - Single-user assignment per operation
   - Clear ownership and accountability
   - Assignment validation and error handling
   - Detailed success/failure reporting

3. **Issue Discovery**
   - Fetch specific issues by number
   - Filter by multiple criteria
   - Search across large repositories
   - Real-time issue status checking

4. **Label Management**
   - Add labels to issues
   - Support for multiple labels per operation
   - Label consistency enforcement

## 📋 Prerequisites

### GitHub App Permissions Required

| Permission | Level | Purpose |
|------------|-------|---------|
| **Issues** | Read & Write | Access and modify issues |
| **Metadata** | Read | Repository information |
| **Contents** | Read | Repository structure access |

### Environment Variables

```bash
GITHUB_APP_ID=your_app_id
GITHUB_PRIVATE_KEY_PATH=./private-key.pem
GITHUB_INSTALLATION_ID=your_installation_id
GITHUB_OWNER=repository_owner
GITHUB_REPO=repository_name
COPILOT_EXPERTS=expert1,expert2,expert3
```

## 🚀 Usage Examples

```bash
npm run issue-management
```

## 📈 Output and Reporting

### Console Output Example

```
📋 Starting GitHub Issue Management...
✅ Issue Management initialized successfully!

📚 Fetching all issues from owner/repo (with pagination)
📋 Fetching issues from owner/repo
   State: open, Labels: all, Sort: created desc
✅ Fetched 45 issues from owner/repo
   Fetched page 1, total issues: 45

📋 ISSUES SUMMARY
================================
Repository: owner/repo
Total Issues: 45
State: open
Fetched At: 2025-07-30T09:31:56.676Z
Pages Processed: 1

Recent Issues:
  #123: Fix Copilot suggestion not working in TypeScript
    Assignees: Unassigned
    Labels: bug, copilot
    Created: 7/29/2025
  #124: Add GitHub Copilot configuration guide
    Assignees: developer1
    Labels: documentation, copilot
    Created: 7/28/2025

📋 Fetching issue #123 from owner/repo
✅ Fetched issue #123: Fix Copilot suggestion not working in TypeScript
Issue #123: Fix Copilot suggestion not working in TypeScript
Current assignees: None

👤 Assigning issue #123 in owner/repo to: copilot-expert
✅ Successfully assigned issue #123 to copilot-expert

🏷️ Adding labels to issue #123: needs-review, high-priority
✅ Successfully added labels to issue #123
```

### Assignment Result Structure

```json
{
  "issue_number": 123,
  "assignee": "copilot-expert",
  "success": true,
  "assignedUser": "copilot-expert"
}
```

### Issue Details Structure

```json
{
  "issue": {
    "number": 123,
    "title": "Fix Copilot suggestion not working in TypeScript",
    "body": "Description of the issue...",
    "state": "open",
    "assignees": [
      {
        "login": "copilot-expert",
        "id": 12345
      }
    ],
    "labels": [
      {
        "name": "bug",
        "color": "d73a4a"
      },
      {
        "name": "copilot",
        "color": "0075ca"
      }
    ],
    "created_at": "2025-07-29T10:00:00Z",
    "updated_at": "2025-07-30T09:31:56Z"
  },
  "success": true
}
```

## ⚠️ Common Issues and Troubleshooting

### 1. Permission Errors
```
Error: Resource not accessible by integration
```
**Solution**: Ensure GitHub App has "Issues" write permission

### 2. Assignment Failures
```
Error: Validation Failed - user does not exist
```
**Solution**: Verify usernames exist and have repository access

### 3. Rate Limiting
```
Error: API rate limit exceeded
```
**Solution**: Implement delays between operations (included in implementation)

### 4. Large Repository Performance
```
Timeout fetching issues
```
**Solution**: Use pagination and implement timeout handling

## 📚 Additional Resources

- [GitHub Issues API Documentation](https://docs.github.com/en/rest/issues)
- [GitHub App Permissions Guide](https://docs.github.com/en/developers/apps/building-github-apps/setting-permissions-for-github-apps)
- [Issue Management Best Practices](https://docs.github.com/en/issues/tracking-your-work-with-issues)
