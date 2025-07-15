import { App } from '@octokit/app';
import { Octokit } from '@octokit/rest';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

// Get __dirname equivalent for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config();

class GitHubIssueManagement {
    constructor(appId, privateKeyPath, installationId) {
        this.appId = appId;
        this.privateKeyPath = privateKeyPath;
        this.installationId = installationId;
        this.app = null;
        this.octokit = null;
        this.initialized = false;
    }

    async ensureInitialized() {
        if (!this.initialized) {
            await this.initialize();
            this.initialized = true;
        }
    }

    async initialize() {
        try {
            // Read the private key file
            const privateKey = fs.readFileSync(this.privateKeyPath, 'utf8');
            
            // Create the GitHub App instance
            this.app = new App({
                appId: this.appId,
                privateKey: privateKey,
            });

            // Get an installation-specific Octokit instance
            this.octokit = await this.app.getInstallationOctokit(this.installationId);
        } catch (error) {
            console.error('Error initializing GitHub App:', error.message);
            throw error;
        }
    }

    /**
     * Fetch issues from a repository with filtering options
     * @param {string} owner - Repository owner
     * @param {string} repo - Repository name
     * @param {Object} options - Filtering options
     * @returns {Promise<Object>} Issues data with metadata
     */
    async fetchIssues(owner, repo, options = {}) {
        try {
            await this.ensureInitialized();
            
            const {
                state = 'open',
                labels = null,
                assignee = null,
                creator = null,
                mentioned = null,
                milestone = null,
                sort = 'created',
                direction = 'desc',
                since = null,
                per_page = 100,
                page = 1
            } = options;

            console.log(`📋 Fetching issues from ${owner}/${repo}`);
            console.log(`   State: ${state}, Labels: ${labels || 'all'}, Sort: ${sort} ${direction}`);

            const params = {
                owner,
                repo,
                state,
                sort,
                direction,
                per_page,
                page,
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            };

            // Add optional filters
            if (labels) params.labels = labels;
            if (assignee) params.assignee = assignee;
            if (creator) params.creator = creator;
            if (mentioned) params.mentioned = mentioned;
            if (milestone) params.milestone = milestone;
            if (since) params.since = since;

            const response = await this.octokit.request('GET /repos/{owner}/{repo}/issues', params);

            // Filter out pull requests (they come back as issues in the API)
            const issues = response.data.filter(issue => !issue.pull_request);

            const result = {
                repository: `${owner}/${repo}`,
                totalCount: issues.length,
                issues: issues,
                metadata: {
                    state,
                    labels,
                    sort,
                    direction,
                    fetchedAt: new Date().toISOString()
                }
            };

            console.log(` Fetched ${issues.length} issues from ${owner}/${repo}`);
            
            return result;
        } catch (error) {
            console.error(` Failed to fetch issues from ${owner}/${repo}:`, error.message);
            throw error;
        }
    }

    /**
     * Get all issues from a repository (handles pagination)
     * @param {string} owner - Repository owner
     * @param {string} repo - Repository name
     * @param {Object} options - Filtering options
     * @returns {Promise<Object>} All issues data
     */
    async getAllIssues(owner, repo, options = {}) {
        try {
            let allIssues = [];
            let page = 1;
            let hasMorePages = true;

            console.log(` Fetching all issues from ${owner}/${repo} (with pagination)`);

            while (hasMorePages) {
                const response = await this.fetchIssues(owner, repo, { ...options, page, per_page: 100 });
                allIssues = allIssues.concat(response.issues);
                
                // Check if there are more pages
                hasMorePages = response.issues.length === 100;
                page++;
                
                console.log(`   Fetched page ${page - 1}, total issues: ${allIssues.length}`);
            }

            return {
                repository: `${owner}/${repo}`,
                totalCount: allIssues.length,
                issues: allIssues,
                metadata: {
                    ...options,
                    fetchedAt: new Date().toISOString(),
                    pagesProcessed: page - 1
                }
            };
        } catch (error) {
            console.error(` Error fetching all issues from ${owner}/${repo}:`, error.message);
            throw error;
        }
    }

    /**
     * Assign a single issue to one user
     * @param {string} owner - Repository owner
     * @param {string} repo - Repository name
     * @param {number} issue_number - Issue number
     * @param {string} assignee - GitHub username
     * @returns {Promise<Object>} Assignment result
     */
    async assignIssue(owner, repo, issue_number, assignee) {
        try {
            await this.ensureInitialized();

            console.log(` Assigning issue #${issue_number} in ${owner}/${repo} to: ${assignee}`);

            const response = await this.octokit.request('POST /repos/{owner}/{repo}/issues/{issue_number}/assignees', {
                owner,
                repo,
                issue_number,
                assignees: [assignee], // GitHub API expects an array
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });

            console.log(` Successfully assigned issue #${issue_number} to ${assignee}`);

            return {
                issue_number,
                assignee,
                success: true,
                assignedUser: response.data.assignees.find(user => user.login === assignee)?.login || assignee
            };
        } catch (error) {
            console.error(` Failed to assign issue #${issue_number} to ${assignee}:`, error.message);
            return {
                issue_number,
                assignee,
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Get a specific issue by number
     * @param {string} owner - Repository owner
     * @param {string} repo - Repository name
     * @param {number} issue_number - Issue number
     * @returns {Promise<Object>} Issue data
     */
    async getIssue(owner, repo, issue_number) {
        try {
            await this.ensureInitialized();

            console.log(` Fetching issue #${issue_number} from ${owner}/${repo}`);

            const response = await this.octokit.request('GET /repos/{owner}/{repo}/issues/{issue_number}', {
                owner,
                repo,
                issue_number,
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });

            console.log(` Fetched issue #${issue_number}: ${response.data.title}`);

            return {
                issue: response.data,
                success: true
            };
        } catch (error) {
            console.error(` Failed to fetch issue #${issue_number}:`, error.message);
            return {
                issue: null,
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Add labels to an issue
     * @param {string} owner - Repository owner
     * @param {string} repo - Repository name
     * @param {number} issue_number - Issue number
     * @param {string[]} labels - Array of label names
     * @returns {Promise<Object>} Label addition result
     */
    async addLabelsToIssue(owner, repo, issue_number, labels) {
        try {
            await this.ensureInitialized();

            console.log(` Adding labels to issue #${issue_number}: ${labels.join(', ')}`);

            const response = await this.octokit.request('POST /repos/{owner}/{repo}/issues/{issue_number}/labels', {
                owner,
                repo,
                issue_number,
                labels,
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });

            console.log(` Successfully added labels to issue #${issue_number}`);

            return {
                issue_number,
                labels,
                success: true,
                currentLabels: response.data.map(label => label.name)
            };
        } catch (error) {
            console.error(` Failed to add labels to issue #${issue_number}:`, error.message);
            return {
                issue_number,
                labels,
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Print formatted issues summary
     * @param {Object} issuesData - Issues data from fetchIssues or getAllIssues
     */
    printIssuesSummary(issuesData) {
        console.log('\n ISSUES SUMMARY');
        console.log('================================');
        console.log(`Repository: ${issuesData.repository}`);
        console.log(`Total Issues: ${issuesData.totalCount}`);
        console.log(`State: ${issuesData.metadata.state || 'N/A'}`);
        console.log(`Fetched At: ${issuesData.metadata.fetchedAt}`);
        
        if (issuesData.metadata.pagesProcessed) {
            console.log(`Pages Processed: ${issuesData.metadata.pagesProcessed}`);
        }

        if (issuesData.issues && issuesData.issues.length > 0) {
            console.log('\nRecent Issues:');
            issuesData.issues.slice(0, 5).forEach(issue => {
                const assignees = issue.assignees.map(a => a.login).join(', ') || 'Unassigned';
                const labels = issue.labels.map(l => l.name).join(', ') || 'No labels';
                console.log(`  #${issue.number}: ${issue.title}`);
                console.log(`    Assignees: ${assignees}`);
                console.log(`    Labels: ${labels}`);
                console.log(`    Created: ${new Date(issue.created_at).toLocaleDateString()}`);
            });
            
            if (issuesData.issues.length > 5) {
                console.log(`  ... and ${issuesData.issues.length - 5} more issues`);
            }
        }
        console.log('================================\n');
    }
}

export default GitHubIssueManagement;

// Example usage
async function main() {
    // Configuration - replace with your actual values
    const config = {
        appId: process.env.GITHUB_APP_ID || 'your-app-id',
        privateKeyPath: process.env.GITHUB_PRIVATE_KEY_PATH || './private-key.pem',
        installationId: process.env.GITHUB_INSTALLATION_ID || 'your-installation-id',
        owner: process.env.GITHUB_OWNER || 'your-owner',
        repo: process.env.GITHUB_REPO || 'your-repo'
    };

    console.log('Starting GitHub Issue Management...');

    try {
        // Create issue management instance
        const issueManager = new GitHubIssueManagement(
            config.appId,
            config.privateKeyPath,
            config.installationId
        );

        await issueManager.ensureInitialized();
        console.log('Issue Management initialized successfully!');

        // Example 1: Fetch all open issues
        console.log('\n=== Fetching Open Issues ===');
        const openIssues = await issueManager.getAllIssues(config.owner, config.repo, {
            state: 'open'
        });
        
        issueManager.printIssuesSummary(openIssues);

        // Example 2: Get a specific issue
        if (openIssues.issues.length > 0) {
            const firstIssue = openIssues.issues[0];
            console.log('\n=== Fetching Specific Issue ===');
            const issueDetails = await issueManager.getIssue(config.owner, config.repo, firstIssue.number);
            if (issueDetails.success) {
                console.log(`Issue #${firstIssue.number}: ${issueDetails.issue.title}`);
                console.log(`Current assignees: ${issueDetails.issue.assignees.map(a => a.login).join(', ') || 'None'}`);
            }
        }

        // Example 3: Assign a single user to an issue
        if (openIssues.issues.length > 0) {
            const firstIssue = openIssues.issues[0];
            console.log('\n=== Single Issue Assignment Example ===');
            console.log(`Attempting to assign issue #${firstIssue.number} to a user...`);
            
            // Replace 'example-user' with an actual GitHub username
            const assigneeUsername = 'example-user';
            
            // Uncomment to actually perform assignment:
            // const assignResult = await issueManager.assignIssue(
            //     config.owner, 
            //     config.repo, 
            //     firstIssue.number, 
            //     assigneeUsername
            // );
            // 
            // if (assignResult.success) {
            //     console.log(`Successfully assigned issue #${firstIssue.number} to ${assigneeUsername}`);
            // } else {
            //     console.log(`Failed to assign issue: ${assignResult.error}`);
            // }
            
            console.log(`Would assign issue #${firstIssue.number} to: ${assigneeUsername}`);
        }

        // Example 4: Add labels to an issue
        if (openIssues.issues.length > 0) {
            const firstIssue = openIssues.issues[0];
            console.log('\n=== Adding Labels Example ===');
            
            // Uncomment to actually add labels:
            // const labelResult = await issueManager.addLabelsToIssue(
            //     config.owner, 
            //     config.repo, 
            //     firstIssue.number, 
            //     ['needs-review', 'enhancement']
            // );
            // 
            // if (labelResult.success) {
            //     console.log(`Successfully added labels to issue #${firstIssue.number}`);
            // } else {
            //     console.log(`Failed to add labels: ${labelResult.error}`);
            // }
            
            console.log(`Would add labels ['needs-review', 'enhancement'] to issue #${firstIssue.number}`);
        }

    } catch (error) {
        console.error('Error in main execution:', error.message);
        process.exit(1);
    }
}

// Run the example
main().catch(error => {
    console.error('Unhandled error:', error.message);
    process.exit(1);
});
