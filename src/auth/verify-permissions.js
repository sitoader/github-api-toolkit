// Verify Permissions Script
// This script checks if your GitHub App has the correct permissions
// and can access the required Copilot API endpoints

import { App } from '@octokit/app';
import dotenv from 'dotenv';
import fs from 'fs';

dotenv.config();

async function verifyPermissions() {
    try {
        console.log('🔐 GitHub App Permissions Verification');
        console.log('======================================\n');

        const appId = process.env.GITHUB_APP_ID;
        const privateKeyPath = process.env.GITHUB_PRIVATE_KEY_PATH;
        const installationId = process.env.GITHUB_INSTALLATION_ID;
        const org = process.env.GITHUB_ORG;

        console.log('📋 Configuration:');
        console.log(`   App ID: ${appId}`);
        console.log(`   Private Key: ${privateKeyPath}`);
        console.log(`   Installation ID: ${installationId}`);
        console.log(`   Organization: ${org}\n`);

        // Read private key
        console.log('🔑 Reading private key...');
        const privateKey = fs.readFileSync(privateKeyPath, 'utf8');
        console.log('   ✅ Private key loaded successfully\n');

        // Create app and get installation
        console.log('🚀 Creating GitHub App...');
        const app = new App({
            appId: appId,
            privateKey: privateKey,
        });
        
        const octokit = await app.getInstallationOctokit(installationId);
        console.log('   ✅ GitHub App created and authenticated\n');

        // Test 1: Check organization access
        console.log('🏢 Testing organization access...');
        try {
            const orgResponse = await octokit.request('GET /orgs/{org}', { org });
            console.log(`   ✅ Organization access confirmed: ${orgResponse.data.login}`);
            console.log(`   📊 Organization type: ${orgResponse.data.type}`);
            console.log(`   👥 Public repos: ${orgResponse.data.public_repos}`);
        } catch (error) {
            console.log(`   ❌ Organization access failed: ${error.message}`);
            console.log('   💡 Check that your app is installed on this organization');
            return;
        }

        console.log('\n🧪 Testing Copilot API endpoints...\n');

        // Test 2: Check Copilot metrics endpoint
        console.log('📊 Testing metrics endpoint...');
        try {
            const since = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
            const until = new Date().toISOString().split('T')[0];
            
            const metricsResponse = await octokit.request('GET /orgs/{org}/copilot/metrics', {
                org,
                since,
                until,
                page: 1,
                per_page: 1 // Just test access, don't need all data
            });
            console.log(`   ✅ Metrics endpoint accessible`);
            console.log(`   📈 Found ${metricsResponse.data.length} days of metrics data`);
        } catch (error) {
            console.log(`   ❌ Metrics endpoint failed: ${error.message}`);
            if (error.status === 404) {
                console.log('   💡 This may indicate missing "Copilot Business management" read permission');
            }
        }

        // Test 3: Check Copilot billing endpoint  
        console.log('\n💰 Testing billing endpoint...');
        try {
            const billingResponse = await octokit.request('GET /orgs/{org}/copilot/billing', { org });
            console.log(`   ✅ Billing endpoint accessible`);
            console.log(`   💳 Plan type: ${billingResponse.data.plan_type}`);
            console.log(`   👥 Total seats: ${billingResponse.data.seat_breakdown.total}`);
        } catch (error) {
            console.log(`   ❌ Billing endpoint failed: ${error.message}`);
            if (error.status === 404) {
                console.log('   💡 This may indicate missing "Organization administration" read permission');
            }
        }

        // Test 4: Check Copilot seats endpoint
        console.log('\n💺 Testing seats endpoint...');
        try {
            const seatsResponse = await octokit.request('GET /orgs/{org}/copilot/billing/seats', {
                org,
                page: 1,
                per_page: 1 // Just test access
            });
            console.log(`   ✅ Seats endpoint accessible`);
            console.log(`   👤 Total seats found: ${seatsResponse.data.total_seats || 'Unknown'}`);
        } catch (error) {
            console.log(`   ❌ Seats endpoint failed: ${error.message}`);
            if (error.status === 404) {
                console.log('   💡 This may indicate missing "Organization administration" read permission');
            }
        }

        console.log('\n🔍 Permission Analysis Summary:');
        console.log('================================');
        
        // Test 5: Get installation details
        try {
            const installationResponse = await octokit.request('GET /installation');
            console.log(`📱 Installation Details:`);
            console.log(`   ID: ${installationResponse.data.id}`);
            console.log(`   Account: ${installationResponse.data.account.login}`);
            console.log(`   Created: ${new Date(installationResponse.data.created_at).toLocaleDateString()}`);
            console.log(`   Updated: ${new Date(installationResponse.data.updated_at).toLocaleDateString()}`);
            
            // Show permissions
            if (installationResponse.data.permissions) {
                console.log('\n🔐 Current Permissions:');
                Object.entries(installationResponse.data.permissions).forEach(([permission, level]) => {
                    const icon = level === 'read' ? '👁️' : level === 'write' ? '✏️' : '❓';
                    console.log(`   ${icon} ${permission}: ${level}`);
                });
            }
        } catch (error) {
            console.log(`❌ Could not fetch installation details: ${error.message}`);
        }

        console.log('\n✅ Permission verification completed!');
        console.log('\n💡 Required Permissions for Copilot Metrics:');
        console.log('   👁️  Copilot Business management: read');
        console.log('   👁️  Organization administration: read');
        console.log('\n🔗 To update permissions:');
        console.log(`   1. Go to: https://github.com/settings/apps`);
        console.log(`   2. Select your app`);
        console.log(`   3. Update permissions under "Permissions & events"`);
        console.log(`   4. Organization owner must accept the permission changes`);

    } catch (error) {
        console.error('❌ Permission verification failed:', error.message);
        console.error('\n🔧 Troubleshooting steps:');
        console.error('   1. Verify your .env configuration');
        console.error('   2. Check that your GitHub App exists');
        console.error('   3. Ensure the app is installed on your organization');
        console.error('   4. Run: node scripts/test-auth.js for basic auth testing');
    }
}

verifyPermissions();
