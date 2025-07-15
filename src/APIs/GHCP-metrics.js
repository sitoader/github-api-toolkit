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

class GitHubCopilotMetrics {
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
     * Get Copilot usage metrics for an organization
     * @param {string} org - Organization name
     * @param {string} since - Start date (YYYY-MM-DD format)
     * @param {string} until - End date (YYYY-MM-DD format)
     * @returns {Promise<Object>} Copilot usage data
     */
    async getCopilotUsageForOrg(org, since = null, until = null) {
        try {
            await this.ensureInitialized();
            const params = { org };
            if (since) params.since = since;
            if (until) params.until = until;

            // Use the correct metrics endpoint
            const response = await this.octokit.request('GET /orgs/{org}/copilot/metrics', params);
            console.log(`Usage data for ${org}:`, response.data);
            return response.data;
        } catch (error) {
            console.error(`Error fetching Copilot usage for org ${org}:`, error.message);
            throw error;
        }
    }

    /**
     * Get Copilot seat information for an organization
     * @param {string} org - Organization name
     * @param {number} page - Page number for pagination
     * @param {number} perPage - Items per page (max 100)
     * @returns {Promise<Object>} Copilot seat data
     */
    async getCopilotSeatsForOrg(org, page = 1, perPage = 50) {
        try {
            await this.ensureInitialized();
            const response = await this.octokit.request('GET /orgs/{org}/copilot/billing/seats', {
                org,
                page,
                per_page: perPage
            });
            console.log(`Seats data for ${org}:`, response.data);
            return response.data;
        } catch (error) {
            console.error(`Error fetching Copilot seats for org ${org}:`, error.message);
            throw error;
        }
    }

    /**
     * Get all Copilot seats for an organization (handles pagination)
     * @param {string} org - Organization name
     * @returns {Promise<Array>} All Copilot seats
     */
    async getAllCopilotSeatsForOrg(org) {
        try {
            let allSeats = [];
            let page = 1;
            let hasMorePages = true;

            while (hasMorePages) {
                const response = await this.getCopilotSeatsForOrg(org, page, 100);
                allSeats = allSeats.concat(response.seats || []);
                
                // Check if there are more pages
                hasMorePages = response.seats && response.seats.length === 100;
                page++;
            }

            return allSeats;
        } catch (error) {
            console.error(`Error fetching all Copilot seats for org ${org}:`, error.message);
            throw error;
        }
    }

    /**
     * Get Copilot billing information for an organization
     * @param {string} org - Organization name
     * @returns {Promise<Object>} Copilot billing data
     */
    async getCopilotBillingForOrg(org) {
        try {
            await this.ensureInitialized();
            const response = await this.octokit.request('GET /orgs/{org}/copilot/billing', { org });
            console.log(`Billing data for ${org}:`, response.data);
            return response.data;
        } catch (error) {
            console.error(`Error fetching Copilot billing for org ${org}:`, error.message);
            throw error;
        }
    }

    /**
     * Generate a comprehensive Copilot metrics report
     * @param {string} org - Organization name
     * @param {string} since - Start date (YYYY-MM-DD format)
     * @param {string} until - End date (YYYY-MM-DD format)
     * @returns {Promise<Object>} Complete metrics report
     */
    async generateMetricsReport(org, since = null, until = null) {
        try {
            console.log(`Generating Copilot metrics report for ${org}...`);

            const [usage, seats, billing] = await Promise.all([
                this.getCopilotUsageForOrg(org, since, until),
                this.getAllCopilotSeatsForOrg(org),
                this.getCopilotBillingForOrg(org)
            ]);

            const report = {
                organization: org,
                reportDate: new Date().toISOString(),
                period: {
                    since: since || 'N/A',
                    until: until || 'N/A'
                },
                usage: usage,
                seats: {
                    total: seats.length,
                    details: seats
                },
                billing: billing,
                summary: {
                    totalSeats: seats.length,
                    activeUsers: usage.filter(day => day.total_active_users > 0).length,
                    totalAcceptances: usage.reduce((sum, day) => sum + (day.total_acceptances || 0), 0),
                    totalSuggestions: usage.reduce((sum, day) => sum + (day.total_suggestions || 0), 0)
                }
            };

            return report;
        } catch (error) {
            console.error('Error generating metrics report:', error.message);
            throw error;
        }
    }

    /**
     * Export metrics report to JSON file
     * @param {Object} report - Metrics report data
     * @param {string} filename - Output filename
     */
    async exportReportToFile(report, filename = null) {
        try {
            // Create reports directory if it doesn't exist
            const reportsDir = path.join(process.cwd(), 'reports');
            if (!fs.existsSync(reportsDir)) {
                fs.mkdirSync(reportsDir, { recursive: true });
                console.log(`📁 Created reports directory: ${reportsDir}`);
            }

            const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
            const defaultFilename = `copilot-metrics-${report.organization}-${timestamp}.json`;
            const filename_only = filename || defaultFilename;
            const outputFilename = path.join(reportsDir, filename_only);

            fs.writeFileSync(outputFilename, JSON.stringify(report, null, 2));
            console.log(`📊 Report exported to: ${outputFilename}`);
            return outputFilename;
        } catch (error) {
            console.error('Error exporting report to file:', error.message);
            throw error;
        }
    }
}

export default GitHubCopilotMetrics;

// Example usage
async function main() {
    // Configuration - replace with your actual values
    const config = {
        appId: process.env.GITHUB_APP_ID || 'your-app-id',
        privateKeyPath: process.env.GITHUB_PRIVATE_KEY_PATH || './private-key.pem',
        installationId: process.env.GITHUB_INSTALLATION_ID || 'your-installation-id',
        organization: process.env.GITHUB_ORG || 'your-org-name'
    };

    console.log('Starting GitHub Copilot Metrics collection...');
    console.log(`Configuration:`, {
        appId: config.appId,
        privateKeyPath: config.privateKeyPath,
        installationId: config.installationId,
        organization: config.organization
    });

    try {
        // Create metrics instance
        console.log('Creating GitHubCopilotMetrics instance...');
        const metrics = new GitHubCopilotMetrics(
            config.appId,
            config.privateKeyPath,
            config.installationId
        );

        console.log('Ensuring initialization...');
        await metrics.ensureInitialized();
        console.log('Initialization complete!');

        // Generate report for the last 30 days
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        const since = thirtyDaysAgo.toISOString().split('T')[0];

        console.log(`Generating report from ${since} to ${new Date().toISOString().split('T')[0]}...`);

        const report = await metrics.generateMetricsReport(
            config.organization,
            since,
            new Date().toISOString().split('T')[0]
        );

        // Export to file
        await metrics.exportReportToFile(report);

        // Display summary
        console.log('\n=== Copilot Metrics Summary ===');
        console.log(`Organization: ${report.organization}`);
        console.log(`Total Seats: ${report.summary.totalSeats}`);
        console.log(`Total Acceptances: ${report.summary.totalAcceptances}`);
        console.log(`Total Suggestions: ${report.summary.totalSuggestions}`);
        
        if (report.summary.totalSuggestions > 0) {
            const acceptanceRate = (report.summary.totalAcceptances / report.summary.totalSuggestions * 100).toFixed(2);
            console.log(`Acceptance Rate: ${acceptanceRate}%`);
        }

    } catch (error) {
        console.error('Error in main execution:', error.message);
        console.error('Full error:', error);
        process.exit(1);
    }
}

// Run the main function
main().catch(error => {
    console.error('Unhandled error:', error.message);
    process.exit(1);
});