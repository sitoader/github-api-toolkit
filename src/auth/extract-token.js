import { createAppAuth } from '@octokit/auth-app';
import dotenv from 'dotenv';
import fs from 'fs';

// Load environment variables
dotenv.config();

async function getGitHubAppToken() {
    try {
        const appId = process.env.GITHUB_APP_ID;
        const privateKeyPath = process.env.GITHUB_PRIVATE_KEY_PATH;
        const installationId = process.env.GITHUB_INSTALLATION_ID;
        
        // Read private key
        const privateKey = fs.readFileSync(privateKeyPath, 'utf8');
        
        // Create auth instance
        const auth = createAppAuth({
            appId: appId,
            privateKey: privateKey,
        });
        
        // Get installation token
        const { token } = await auth({
            type: 'installation',
            installationId: installationId,
        });

        // console.log(token);
        return token;
        
    } catch (error) {
        console.error('Error getting GitHub App token:', error.message);
        throw error;
    }
}

var GHAppToken = await getGitHubAppToken();
console.log(GHAppToken);
