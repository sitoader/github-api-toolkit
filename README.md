# GitHub API Toolkit

Welcome to the **GitHub API Toolkit** – a collection of code examples and scripts designed to help you quickly get started with the GitHub APIs. This toolkit is especially useful for developers, DevOps engineers, and GitHub administrators who want to automate and manage GitHub at scale.

## 🚀 What This Toolkit Covers

This repository includes practical examples and reusable scripts for:

- 🔍 **Retrieving GitHub Copilot Metrics**  
  Understand Copilot usage across your organization or enterprise.

- 🛡️ **Managing Policies Across Multiple Organizations**  
  Automate the setup and enforcement of policies at the enterprise level.

- 🤖 **Automating Issue Assignment with Copilot**  
  Use GitHub APIs to automatically assign GitHUb Copilot to issues.

## 📦 What's Inside

- `scripts/` – Powershell scripts for supported scenarios. Useful especially for integration with your CI/CD
- `src/APIs` – Sample API calls using Octokit.js
- `src/auth` – GitHub App setup 
- `scenrios/` – Documentation for example scenarios
- `.env.template` – Env template for testing. 


## 🚀 Quick Start

1. **Get started by creating your GitHub App:** Follow  [Github App Setup](./scenarios/00-github-app-setup.md)
2. **Explore scenarios:** Review use cases in [Scenarios Documentation](./scenarios/README.md)
3. **See it in action:** Run the included test scripts to see the results
4. **Customize for your needs:** Adapt the proven patterns to your specific requirements

## 📚 Documentation

For detailed implementation guides, business value analysis, and technical specifications, see the **[Scenarios Documentation](./scenarios/README.md)**:

- **[Scenario 1: GitHub Copilot Metrics](./scenarios/01-copilot-metrics.md)**
- **[Scenario 2: Automated Issue Management](./scenarios/02-issue-management.md)**
- **[Scenario 3: Enterprise Policy Management](./scenarios/03-enterprise-policy.md)**

Each scenario includes:
- 🔧 Technical implementation details
- 📊 Output examples and reporting
- ⚠️ Troubleshooting and common issues
