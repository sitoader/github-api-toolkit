import { App } from '@octokit/app';
import dotenv from 'dotenv';
import fs from 'fs';

// Load environment variables
dotenv.config();

async function testAuth() {
    try {
        console.log('Testing GitHub App authentication...');
        
        const appId = process.env.GITHUB_APP_ID;
        const privateKeyPath = process.env.GITHUB_PRIVATE_KEY_PATH;
        const installationId = process.env.GITHUB_INSTALLATION_ID;
        const org = process.env.GITHUB_ORG;
        
        console.log('Config:', { appId, privateKeyPath, installationId, org });
        
        // Read private key
        console.log('Reading private key...');
        const privateKey = fs.readFileSync(privateKeyPath, 'utf8');
        console.log('Private key loaded successfully');
        
        // Create app instance
        const app = new App({
            appId: appId,
            privateKey: privateKey,
        });

        // Get installation octokit
        console.log('Getting installation Octokit...');
        const octokit = await app.getInstallationOctokit(installationId);
        console.log('Installation Octokit created successfully');
        

        // Test a simple API call
        console.log('Testing API call...');

        // Try accessing the organization
        console.log('Testing organization access...');
        try {
            console.log('Trying access the organization...');
            const directOrgResponse = await octokit.request('GET /orgs/{org}', { org });
            console.log('Organization:', directOrgResponse.data.login);
        } catch (orgError) {
            console.log('Organization auth failed:', orgError.message);
        }
        
        console.log('Authentication test successful!');
        
    } catch (error) {
        console.error('Authentication test failed:', error.message);
        console.error('Full error:', error);
    }
}

testAuth();
