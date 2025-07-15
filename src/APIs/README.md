# GitHub Enterprise APIs

This folder contains comprehensive implementations of the three core GitHub Enterprise scenarios:

## 🚀 Available APIs

### 1. GitHub Copilot Metrics (`GHCP-metrics.js`)
- **Purpose**: Collect and analyze GitHub Copilot usage metrics
- **Features**:
  - Organization-wide usage metrics
  - Seat allocation and utilization tracking
  - Billing information analysis
  - Comprehensive reporting with export functionality
  - Formatted summary printing

### 2. Issue Management (`issue-management.js`)
- **Purpose**: Automated GitHub issue management and assignment
- **Features**:
  - Fetch issues with advanced filtering
  - Bulk assignment capabilities
  - Auto-assign Copilot experts to AI-related issues
  - Smart detection of Copilot-related issues using keywords and labels
  - Label management
  - Pagination handling for large repositories

### 3. Enterprise Policy Management (`enterprise-policy.js`)
- **Purpose**: Manage enterprise-level GitHub policies and settings
- **Features**:
  - Organization-level policy retrieval
  - Copilot settings management
  - Security and compliance monitoring
  - Repository security settings analysis
  - Dependabot configuration management
  - Comprehensive policy overview generation

### 4. Enterprise Toolkit (`enterprise-toolkit.js`)
- **Purpose**: Integrated demonstration of all three scenarios
- **Features**:
  - Unified interface for all APIs
  - Complete workflow demonstrations
  - Comprehensive reporting
  - Best practices implementation

## 📋 Prerequisites

1. **Node.js** (version 16 or higher)
2. **GitHub App** with appropriate permissions
3. **Environment variables** configured (see Setup section)

## 🛠️ Setup

### 1. Install Dependencies
```bash
# From the root directory
npm install
```

### 2. Environment Configuration
Create a `.env` file in the **root directory** or set environment variables:

```bash
# GitHub App Configuration
GITHUB_APP_ID=your_app_id_here
GITHUB_PRIVATE_KEY_PATH=./your-private-key.pem
GITHUB_INSTALLATION_ID=your_installation_id_here

# Organization and Repository Settings
GITHUB_ORG=your-organization-name
GITHUB_OWNER=your-owner-name
GITHUB_REPO=your-repo-name

# Copilot Expert Users (comma-separated)
COPILOT_EXPERTS=copilot-expert-1,copilot-expert-2,ai-team-lead

# Optional: Date range for metrics
METRICS_SINCE=2024-01-01
METRICS_UNTIL=2024-12-31
```

### 3. GitHub App Permissions

Ensure your GitHub App has these permissions:

#### Organization permissions:
- **Copilot Business management**: Read
- **Administration**: Read

#### Repository permissions:
- **Issues**: Read & Write
- **Metadata**: Read
- **Contents**: Read

## 🎯 Usage Examples

### Run Individual Scenarios

#### 1. Copilot Metrics Collection
```bash
# From the root directory
npm run copilot-metrics
# or
npm run api:copilot
```

#### 2. Issue Management
```bash
# From the root directory
npm run issue-management
# or  
npm run api:issues
```

#### 3. Policy Management
```bash
# From the root directory
npm run policy-management
# or
npm run api:policies
```

#### 4. Complete Enterprise Toolkit
```bash
# From the root directory
npm run enterprise-toolkit
# or
npm run api:start
```

### Import and Use in Your Code

```javascript
import GitHubCopilotMetrics from './GHCP-metrics.js';
import GitHubIssueManagement from './issue-management.js';
import GitHubEnterprisePolicyManagement from './enterprise-policy.js';
import GitHubEnterpriseToolkit from './enterprise-toolkit.js';

// Initialize individual services
const copilotMetrics = new GitHubCopilotMetrics(appId, privateKeyPath, installationId);
const issueManager = new GitHubIssueManagement(appId, privateKeyPath, installationId);
const policyManager = new GitHubEnterprisePolicyManagement(appId, privateKeyPath, installationId);

// Or use the integrated toolkit
const toolkit = new GitHubEnterpriseToolkit(appId, privateKeyPath, installationId);
await toolkit.initialize();
```

## 📊 Example Workflows

### Scenario 1: Copilot Metrics Analysis
```javascript
const metrics = new GitHubCopilotMetrics(appId, privateKeyPath, installationId);
await metrics.ensureInitialized();

// Get comprehensive metrics
const report = await metrics.generateMetricsReport('my-org', '2024-01-01', '2024-12-31');

// Print summary
metrics.printUsageSummary(report.usage);

// Export to file
await metrics.exportReportToFile(report);
```

### Scenario 2: Automated Issue Management
```javascript
const issueManager = new GitHubIssueManagement(appId, privateKeyPath, installationId);
await issueManager.ensureInitialized();

// Fetch all open issues
const issues = await issueManager.getAllIssues('owner', 'repo', { state: 'open' });

// Auto-assign Copilot experts
const results = await issueManager.autoAssignCopilotIssues(
    'owner', 'repo',
    { 
        labels: ['copilot', 'ai'], 
        keywords: ['copilot', 'code completion'] 
    },
    ['copilot-expert-1', 'copilot-expert-2']
);
```

### Scenario 3: Policy Management
```javascript
const policyManager = new GitHubEnterprisePolicyManagement(appId, privateKeyPath, installationId);
await policyManager.ensureInitialized();

// Get comprehensive policy overview
const overview = await policyManager.getComprehensivePolicyOverview('my-org');

// Print formatted summary
policyManager.printPolicySummary(overview);

// Get specific Copilot settings
const copilotSettings = await policyManager.getCopilotSettings('my-org');
```

## 🔧 Configuration Options

### Issue Management Filters
```javascript
const filterOptions = {
    state: 'open',           // 'open', 'closed', 'all'
    labels: 'bug,feature',   // Comma-separated labels
    assignee: 'username',    // Specific assignee
    sort: 'created',         // 'created', 'updated', 'comments'
    direction: 'desc',       // 'asc', 'desc'
    since: '2024-01-01'      // ISO 8601 format
};
```

### Copilot Issue Detection Criteria
```javascript
const criteria = {
    labels: ['copilot', 'ai', 'github-copilot', 'code-completion'],
    keywords: ['copilot', 'code completion', 'ai suggestion', 'autocomplete'],
    state: 'open'
};
```

## 📈 Output and Reporting

### Generated Files
- **Copilot Metrics**: `copilot-metrics-{org}-{timestamp}.json`
- **Console Output**: Formatted summaries and progress indicators
- **Error Logs**: Detailed error information for troubleshooting

### Report Contents
- Usage statistics and trends
- Seat utilization analysis
- Issue assignment results
- Policy compliance status
- Security recommendations

## 🔒 Security Best Practices

1. **Environment Variables**: Store all sensitive information in environment variables
2. **Private Key Security**: Keep your GitHub App private key secure and never commit it
3. **Permissions**: Use minimum required permissions for your GitHub App
4. **Rate Limiting**: All APIs include rate limiting protection
5. **Error Handling**: Comprehensive error handling with detailed logging

## 🐛 Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify GitHub App ID and Installation ID
   - Check private key file path and format
   - Ensure GitHub App has required permissions

2. **API Rate Limiting**
   - APIs include automatic delays for bulk operations
   - Monitor rate limit headers in responses
   - Consider using GitHub App authentication for higher limits

3. **Permission Denied**
   - Check GitHub App permissions
   - Verify organization access
   - Ensure user has appropriate roles

4. **Missing Dependencies**
   - Run `npm install` in the APIs directory
   - Check Node.js version (requires 16+)

### Debug Mode
Set `DEBUG=true` in your environment to enable verbose logging:
```bash
DEBUG=true npm start
```

## 📝 API Documentation

Each API file includes comprehensive JSDoc documentation. Key methods:

### GitHubCopilotMetrics
- `getCopilotUsageForOrg(org, since, until)`
- `getCopilotSeatsForOrg(org, page, perPage)`
- `getCopilotBillingForOrg(org)`
- `generateMetricsReport(org, since, until)`
- `printUsageSummary(metrics)`

### GitHubIssueManagement
- `fetchIssues(owner, repo, options)`
- `getAllIssues(owner, repo, options)`
- `autoAssignCopilotIssues(owner, repo, criteria, experts)`
- `bulkAssignIssues(owner, repo, assignments)`
- `addLabelsToIssue(owner, repo, issue_number, labels)`

### GitHubEnterprisePolicyManagement
- `getOrganizationPolicies(org)`
- `getCopilotSettings(org)`
- `getOrganizationSecuritySettings(org)`
- `getComprehensivePolicyOverview(org)`
- `updateDependabotSettings(owner, repo, enabled)`

## 🤝 Contributing

To extend these APIs:

1. Follow the existing patterns for error handling
2. Include comprehensive JSDoc documentation
3. Add appropriate console logging with emojis
4. Handle pagination for large datasets
5. Include rate limiting protection
6. Add examples in the main functions

## 📄 License

MIT License - see the main project LICENSE file for details.
