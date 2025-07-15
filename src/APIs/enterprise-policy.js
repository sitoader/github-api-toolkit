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

class GitHubEnterprisePolicyManagement {
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
     * Get organization-level policies and settings
     * @param {string} org - Organization name
     * @returns {Promise<Object>} Organization policies
     */
    async getOrganizationPolicies(org) {
        try {
            await this.ensureInitialized();

            console.log(`🏢 Fetching organization policies for: ${org}`);

            const response = await this.octokit.request('GET /orgs/{org}', {
                org,
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });

            const orgData = response.data;

            const policies = {
                organization: org,
                fetchedAt: new Date().toISOString(),
                basicInfo: {
                    name: orgData.name,
                    description: orgData.description,
                    company: orgData.company,
                    location: orgData.location,
                    email: orgData.email,
                    blog: orgData.blog,
                    plan: orgData.plan?.name
                },
                membershipPolicies: {
                    membersCanCreateRepositories: orgData.members_can_create_repositories,
                    membersCanCreatePublicRepositories: orgData.members_can_create_public_repositories,
                    membersCanCreatePrivateRepositories: orgData.members_can_create_private_repositories,
                    membersCanCreateInternalRepositories: orgData.members_can_create_internal_repositories,
                    membersCanCreatePages: orgData.members_can_create_pages,
                    membersCanCreatePublicPages: orgData.members_can_create_public_pages,
                    membersCanCreatePrivatePages: orgData.members_can_create_private_pages,
                    membersCanForkPrivateRepositories: orgData.members_can_fork_private_repositories
                },
                securityPolicies: {
                    twoFactorRequirementEnabled: orgData.two_factor_requirement_enabled,
                    membersAllowedRepositoryCreationType: orgData.members_allowed_repository_creation_type,
                    dependencyGraphEnabledForNewRepositories: orgData.dependency_graph_enabled_for_new_repositories,
                    dependabotAlertsEnabledForNewRepositories: orgData.dependabot_alerts_enabled_for_new_repositories,
                    dependabotSecurityUpdatesEnabledForNewRepositories: orgData.dependabot_security_updates_enabled_for_new_repositories,
                    dependencyGraphEnabled: orgData.dependency_graph_enabled_for_new_repositories
                },
                billingInfo: {
                    publicRepos: orgData.public_repos,
                    privateRepos: orgData.total_private_repos,
                    ownedPrivateRepos: orgData.owned_private_repos,
                    diskUsage: orgData.disk_usage,
                    collaborators: orgData.collaborators,
                    publicMembers: orgData.public_members_count
                }
            };

            console.log(`✅ Successfully fetched organization policies for ${org}`);
            
            return policies;
        } catch (error) {
            console.error(`❌ Failed to fetch organization policies for ${org}:`, error.message);
            throw error;
        }
    }

    /**
     * Get Copilot settings and policies for the organization
     * @param {string} org - Organization name
     * @returns {Promise<Object>} Copilot settings
     */
    async getCopilotSettings(org) {
        try {
            await this.ensureInitialized();

            console.log(`🤖 Fetching Copilot settings for: ${org}`);

            // Get Copilot billing information which includes settings
            const billingResponse = await this.octokit.request('GET /orgs/{org}/copilot/billing', {
                org,
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });

            const copilotSettings = {
                organization: org,
                fetchedAt: new Date().toISOString(),
                enabled: true, // If we can fetch billing, Copilot is enabled
                seatManagement: billingResponse.data.seat_management_setting,
                seatBreakdown: billingResponse.data.seat_breakdown,
                publicCodeSuggestions: billingResponse.data.public_code_suggestions || 'unknown'
            };

            console.log(`✅ Successfully fetched Copilot settings for ${org}`);
            
            return copilotSettings;
        } catch (error) {
            if (error.status === 404) {
                console.log(`ℹ️ Copilot is not enabled for organization ${org}`);
                return {
                    organization: org,
                    fetchedAt: new Date().toISOString(),
                    enabled: false,
                    message: 'Copilot is not enabled for this organization'
                };
            }
            console.error(`❌ Failed to fetch Copilot settings for ${org}:`, error.message);
            throw error;
        }
    }

    /**
     * Update Copilot settings for the organization
     * @param {string} org - Organization name
     * @param {Object} settings - Settings to update
     * @returns {Promise<Object>} Update result
     */
    async updateCopilotSettings(org, settings) {
        try {
            await this.ensureInitialized();

            console.log(`🔧 Updating Copilot settings for: ${org}`);
            console.log('Settings to update:', settings);

            // Note: As of the current GitHub API, direct updates to Copilot settings
            // may be limited. This is a placeholder for when such endpoints become available.
            
            const updateResults = {
                organization: org,
                updatedAt: new Date().toISOString(),
                settingsUpdated: settings,
                status: 'pending',
                message: 'Copilot settings update is not yet fully supported via API. Use GitHub web interface for now.'
            };

            // Placeholder for future API endpoints
            // const response = await this.octokit.request('PATCH /orgs/{org}/copilot/settings', {
            //     org,
            //     ...settings,
            //     headers: {
            //         'X-GitHub-Api-Version': '2022-11-28'
            //     }
            // });

            console.log(`⚠️ Copilot settings update API not fully available yet`);
            
            return updateResults;
        } catch (error) {
            console.error(`❌ Failed to update Copilot settings for ${org}:`, error.message);
            throw error;
        }
    }

    /**
     * Get repository security and analysis settings
     * @param {string} owner - Repository owner
     * @param {string} repo - Repository name
     * @returns {Promise<Object>} Repository security settings
     */
    async getRepositorySecuritySettings(owner, repo) {
        try {
            await this.ensureInitialized();

            console.log(`🔒 Fetching security settings for: ${owner}/${repo}`);

            const [repoResponse, vulnerabilityAlertsResponse] = await Promise.allSettled([
                this.octokit.request('GET /repos/{owner}/{repo}', {
                    owner,
                    repo,
                    headers: {
                        'X-GitHub-Api-Version': '2022-11-28'
                    }
                }),
                this.octokit.request('GET /repos/{owner}/{repo}/vulnerability-alerts', {
                    owner,
                    repo,
                    headers: {
                        'X-GitHub-Api-Version': '2022-11-28'
                    }
                }).catch(() => ({ data: { enabled: false } }))
            ]);

            const repoData = repoResponse.status === 'fulfilled' ? repoResponse.value.data : null;
            const vulnerabilityAlerts = vulnerabilityAlertsResponse.status === 'fulfilled' ? vulnerabilityAlertsResponse.value : { data: { enabled: false } };

            if (!repoData) {
                throw new Error('Repository not found or not accessible');
            }

            const securitySettings = {
                repository: `${owner}/${repo}`,
                fetchedAt: new Date().toISOString(),
                visibility: repoData.visibility,
                private: repoData.private,
                securityAndAnalysis: repoData.security_and_analysis || {},
                vulnerabilityAlertsEnabled: vulnerabilityAlerts.data?.enabled || false,
                hasIssues: repoData.has_issues,
                hasProjects: repoData.has_projects,
                hasWiki: repoData.has_wiki,
                allowForking: repoData.allow_forking,
                allowMergeCommit: repoData.allow_merge_commit,
                allowSquashMerge: repoData.allow_squash_merge,
                allowRebaseMerge: repoData.allow_rebase_merge,
                allowAutoMerge: repoData.allow_auto_merge,
                deleteBranchOnMerge: repoData.delete_branch_on_merge,
                defaultBranch: repoData.default_branch
            };

            console.log(`✅ Successfully fetched security settings for ${owner}/${repo}`);
            
            return securitySettings;
        } catch (error) {
            console.error(`❌ Failed to fetch security settings for ${owner}/${repo}:`, error.message);
            throw error;
        }
    }

    /**
     * Get organization security and analysis settings
     * @param {string} org - Organization name
     * @returns {Promise<Object>} Organization security settings
     */
    async getOrganizationSecuritySettings(org) {
        try {
            await this.ensureInitialized();

            console.log(`🔐 Fetching organization security settings for: ${org}`);

            // Get organization settings
            const orgResponse = await this.octokit.request('GET /orgs/{org}', {
                org,
                headers: {
                    'X-GitHub-Api-Version': '2022-11-28'
                }
            });

            const orgData = orgResponse.data;

            const securitySettings = {
                organization: org,
                fetchedAt: new Date().toISOString(),
                twoFactorRequirementEnabled: orgData.two_factor_requirement_enabled,
                membersCanCreateRepositories: orgData.members_can_create_repositories,
                membersCanCreatePublicRepositories: orgData.members_can_create_public_repositories,
                membersCanCreatePrivateRepositories: orgData.members_can_create_private_repositories,
                membersCanCreateInternalRepositories: orgData.members_can_create_internal_repositories,
                membersAllowedRepositoryCreationType: orgData.members_allowed_repository_creation_type,
                dependencyGraphEnabledForNewRepositories: orgData.dependency_graph_enabled_for_new_repositories,
                dependabotAlertsEnabledForNewRepositories: orgData.dependabot_alerts_enabled_for_new_repositories,
                dependabotSecurityUpdatesEnabledForNewRepositories: orgData.dependabot_security_updates_enabled_for_new_repositories,
                advancedSecurityEnabledForNewRepositories: orgData.advanced_security_enabled_for_new_repositories
            };

            console.log(`✅ Successfully fetched organization security settings for ${org}`);
            
            return securitySettings;
        } catch (error) {
            console.error(`❌ Failed to fetch organization security settings for ${org}:`, error.message);
            throw error;
        }
    }

    /**
     * Enable or disable Dependabot for a repository
     * @param {string} owner - Repository owner
     * @param {string} repo - Repository name
     * @param {boolean} enabled - Whether to enable or disable Dependabot
     * @returns {Promise<Object>} Update result
     */
    async updateDependabotSettings(owner, repo, enabled) {
        try {
            await this.ensureInitialized();

            console.log(`🔧 ${enabled ? 'Enabling' : 'Disabling'} Dependabot for: ${owner}/${repo}`);

            if (enabled) {
                // Enable vulnerability alerts
                await this.octokit.request('PUT /repos/{owner}/{repo}/vulnerability-alerts', {
                    owner,
                    repo,
                    headers: {
                        'X-GitHub-Api-Version': '2022-11-28'
                    }
                });
                console.log(`✅ Enabled Dependabot vulnerability alerts for ${owner}/${repo}`);
            } else {
                // Disable vulnerability alerts
                await this.octokit.request('DELETE /repos/{owner}/{repo}/vulnerability-alerts', {
                    owner,
                    repo,
                    headers: {
                        'X-GitHub-Api-Version': '2022-11-28'
                    }
                });
                console.log(`✅ Disabled Dependabot vulnerability alerts for ${owner}/${repo}`);
            }

            return {
                repository: `${owner}/${repo}`,
                dependabotEnabled: enabled,
                updatedAt: new Date().toISOString(),
                success: true
            };
        } catch (error) {
            console.error(`❌ Failed to update Dependabot settings for ${owner}/${repo}:`, error.message);
            return {
                repository: `${owner}/${repo}`,
                dependabotEnabled: enabled,
                updatedAt: new Date().toISOString(),
                success: false,
                error: error.message
            };
        }
    }

    /**
     * Get comprehensive policy overview for organization
     * @param {string} org - Organization name
     * @returns {Promise<Object>} Comprehensive policy data
     */
    async getComprehensivePolicyOverview(org) {
        try {
            console.log(`📋 Fetching comprehensive policy overview for: ${org}`);

            const [orgPolicies, copilotSettings, orgSecuritySettings] = await Promise.allSettled([
                this.getOrganizationPolicies(org),
                this.getCopilotSettings(org),
                this.getOrganizationSecuritySettings(org)
            ]);

            const overview = {
                organization: org,
                fetchedAt: new Date().toISOString(),
                organizationPolicies: orgPolicies.status === 'fulfilled' ? orgPolicies.value : { error: orgPolicies.reason?.message },
                copilotSettings: copilotSettings.status === 'fulfilled' ? copilotSettings.value : { error: copilotSettings.reason?.message },
                securitySettings: orgSecuritySettings.status === 'fulfilled' ? orgSecuritySettings.value : { error: orgSecuritySettings.reason?.message }
            };

            console.log(`✅ Successfully compiled comprehensive policy overview for ${org}`);
            
            return overview;
        } catch (error) {
            console.error(`❌ Failed to get comprehensive policy overview for ${org}:`, error.message);
            throw error;
        }
    }

    /**
     * Print formatted policy summary
     * @param {Object} policyData - Policy data from getComprehensivePolicyOverview
     */
    printPolicySummary(policyData) {
        console.log('\n🏢 ORGANIZATION POLICY SUMMARY');
        console.log('=====================================');
        console.log(`Organization: ${policyData.organization}`);
        console.log(`Generated: ${policyData.fetchedAt}`);

        // Organization Info
        if (policyData.organizationPolicies && !policyData.organizationPolicies.error) {
            const org = policyData.organizationPolicies;
            console.log('\n📋 Basic Information:');
            console.log(`  Name: ${org.basicInfo.name || 'N/A'}`);
            console.log(`  Plan: ${org.basicInfo.plan || 'N/A'}`);
            console.log(`  Public Repos: ${org.billingInfo.publicRepos || 0}`);
            console.log(`  Private Repos: ${org.billingInfo.privateRepos || 0}`);
            console.log(`  Public Members: ${org.billingInfo.publicMembers || 0}`);

            console.log('\n👥 Membership Policies:');
            console.log(`  Members can create repositories: ${org.membershipPolicies.membersCanCreateRepositories ? 'Yes' : 'No'}`);
            console.log(`  Members can create public repos: ${org.membershipPolicies.membersCanCreatePublicRepositories ? 'Yes' : 'No'}`);
            console.log(`  Members can create private repos: ${org.membershipPolicies.membersCanCreatePrivateRepositories ? 'Yes' : 'No'}`);
        }

        // Security Settings
        if (policyData.securitySettings && !policyData.securitySettings.error) {
            const security = policyData.securitySettings;
            console.log('\n🔒 Security Policies:');
            console.log(`  Two-factor authentication required: ${security.twoFactorRequirementEnabled ? 'Yes' : 'No'}`);
            console.log(`  Dependency graph for new repos: ${security.dependencyGraphEnabledForNewRepositories ? 'Enabled' : 'Disabled'}`);
            console.log(`  Dependabot alerts for new repos: ${security.dependabotAlertsEnabledForNewRepositories ? 'Enabled' : 'Disabled'}`);
            console.log(`  Dependabot security updates: ${security.dependabotSecurityUpdatesEnabledForNewRepositories ? 'Enabled' : 'Disabled'}`);
        }

        // Copilot Settings
        if (policyData.copilotSettings && !policyData.copilotSettings.error) {
            const copilot = policyData.copilotSettings;
            console.log('\n🤖 GitHub Copilot Settings:');
            console.log(`  Status: ${copilot.enabled ? 'Enabled' : 'Disabled'}`);
            if (copilot.enabled) {
                console.log(`  Seat Management: ${copilot.seatManagement || 'N/A'}`);
                if (copilot.seatBreakdown) {
                    console.log(`  Total Seats: ${copilot.seatBreakdown.total || 0}`);
                    console.log(`  Assigned Seats: ${copilot.seatBreakdown.assigned_breakdown?.total || 0}`);
                }
                console.log(`  Public Code Suggestions: ${copilot.publicCodeSuggestions || 'Unknown'}`);
            }
        } else {
            console.log('\n🤖 GitHub Copilot Settings:');
            console.log('  Status: Not enabled or not accessible');
        }

        console.log('=====================================\n');
    }
}

export default GitHubEnterprisePolicyManagement;

// Example usage
async function main() {
    // Configuration - replace with your actual values
    const config = {
        appId: process.env.GITHUB_APP_ID || 'your-app-id',
        privateKeyPath: process.env.GITHUB_PRIVATE_KEY_PATH || './private-key.pem',
        installationId: process.env.GITHUB_INSTALLATION_ID || 'your-installation-id',
        organization: process.env.GITHUB_ORG || 'your-org-name'
    };

    console.log('Starting GitHub Enterprise Policy Management...');

    try {
        // Create policy management instance
        const policyManager = new GitHubEnterprisePolicyManagement(
            config.appId,
            config.privateKeyPath,
            config.installationId
        );

        await policyManager.ensureInitialized();
        console.log('Policy Management initialized successfully!');

        // Example 1: Get comprehensive policy overview
        console.log('\n=== Comprehensive Policy Overview ===');
        const overview = await policyManager.getComprehensivePolicyOverview(config.organization);
        
        policyManager.printPolicySummary(overview);

        // Example 2: Get specific Copilot settings
        console.log('\n=== Copilot Settings Detail ===');
        const copilotSettings = await policyManager.getCopilotSettings(config.organization);
        console.log('Copilot Settings:', JSON.stringify(copilotSettings, null, 2));

        // Example 3: Get organization security settings
        console.log('\n=== Organization Security Settings ===');
        const securitySettings = await policyManager.getOrganizationSecuritySettings(config.organization);
        console.log('Security Settings:', JSON.stringify(securitySettings, null, 2));

        // Example 4: Update Copilot settings (placeholder)
        console.log('\n=== Update Copilot Settings Example ===');
        const updateSettings = {
            public_code_suggestions: 'block',
            ide_chat: 'enabled',
            platform_chat: 'enabled'
        };
        
        const updateResult = await policyManager.updateCopilotSettings(config.organization, updateSettings);
        console.log('Update Result:', updateResult);

    } catch (error) {
        console.error('Error in main execution:', error.message);
        process.exit(1);
    }
}

// Uncomment to run the example
// main().catch(error => {
//     console.error('Unhandled error:', error.message);
//     process.exit(1);
// });
