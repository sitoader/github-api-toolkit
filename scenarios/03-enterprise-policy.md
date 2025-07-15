# Scenario 3: Enterprise Policy Management

## 🏢 Overview

This scenario provides enterprise-level GitHub policy management capabilities, including organization settings, security configurations, Copilot business policies, and compliance monitoring. It enables administrators to maintain consistent governance across the entire GitHub enterprise.

## 🎯 Business Objectives

- **Centralized Governance**: Manage organization-wide policies from a single interface
- **Security Compliance**: Ensure security policies are consistently applied
- **Copilot Governance**: Control Copilot features and usage policies
- **Audit and Compliance**: Generate compliance reports for regulatory requirements
- **Risk Management**: Identify and mitigate security and policy risks
- **Standardization**: Enforce consistent policies across all repositories

### Key Features

1. **Organization Policy Retrieval**
   - Basic organization information and settings
   - Member permissions and access controls
   - Repository creation and deletion policies
   - Branch protection and merge policies

2. **Copilot Business Management**
   - Disable/Enable Copilot features
   - User access and seat management
   - Copilot API usage policies
   - Content filtering and suggestion policies

3. **Security Policy Management**
   - Vulnerability alert settings
   - Dependabot configuration
   - Secret scanning policies
   - Security advisory management

## 📋 Prerequisites

### GitHub App Permissions Required

| Permission | Level | Purpose |
|------------|-------|---------|
| **Administration** | Read & Write | Organization settings and policies |
| **Copilot Business** | Read & Write | Copilot policies and settings |
| **Metadata** | Read | Repository and organization metadata |


### Environment Variables

```bash
GITHUB_APP_ID=your_app_id
GITHUB_PRIVATE_KEY_PATH=./private-key.pem
GITHUB_INSTALLATION_ID=your_installation_id
GITHUB_ORG=your-organization-name
```

## 🚀 Usage Examples

```bash
npm run policy-management
```


## 📈 Output and Reporting

### Console Output Example

```
🏢 Starting Enterprise Policy Management...
✅ Policy Management initialized successfully!

📋 Organization Policies for MyOrg
================================
Organization: MyOrg
Plan: GitHub Enterprise Cloud
Total Members: 350
Private Repositories: 150
Public Repositories: 25

🔒 Security Settings:
✅ Vulnerability alerts enabled
✅ Dependabot alerts enabled
✅ Secret scanning enabled
✅ Dependency graph enabled

🤖 Copilot Settings:
✅ Seat management: assign_selected
⚠️  Public code suggestions: allow (Consider blocking)
✅ Content filtering: enabled
✅ IDE chat: enabled

👥 Member Permissions:
✅ Default repository permission: read
⚠️  Members can create public repos: true (Review policy)
✅ Web commit signoff required: true

📊 Compliance Score: 85% (17/20 policies compliant)

⚠️  Policy Recommendations:
1. Block public code suggestions for enhanced security
2. Restrict public repository creation
3. Review default member permissions
4. Enable advanced security features

================================
```
