
## Step 1: Create a GitHub App

### 1.1 Navigate to GitHub App Settings

1. Go to your GitHub enterprise
2. Click **Settings** 
3. Click **GitHub Apps**
4. Click **New GitHub App**

### 1.2 Configure Basic App Information

Fill in the required fields:

- **GitHub App name**: `copilot-metrics-app` (must be globally unique)
- **Description**: `App to retrieve GitHub Copilot usage metrics`
- **Homepage URL**: `https://github.com/{YOUR_ORG}` (your organization URL)
- **User authorization callback URL**: Leave blank (not needed)
- **Setup URL**: Leave blank (not needed)
- **Webhook URL**: `https://example.com/webhook` (placeholder - not used)
- **Webhook secret**: Leave blank

### 2.3 Set Permissions (CRITICAL STEP)

Provide the right permissions based on the usecase. 

Under **Permissions**, configure the following:

#### Repository permissions
- **Issues**: **Read and Write** (for issue management)
- **Metadata**: **Read** (for repository information)
- Vulnerability Alerts: **Read & Write**
- Contents: **Read**

#### Organization permissions
- **Copilot Business management**: **Read & Write** (for Copilot metrics)
- **Administration**: **Read & Write** (for billing and org information)

#### Account permissions  
- **No account permissions needed** - leave all as "No access"

### 1.5 Installation Options
- Select **Only on this account** (recommended for organization-specific apps)

### 1.6 Create the App
- Click **Create GitHub App**

## Step 2: Configure Your GitHub App

### 2.1 Note Your App ID
After creation, you'll see your app's page. **Save the App ID** (you'll find it at the top of the page).

### 2.2 Generate a Private Key
1. Scroll down to **Private keys** section
2. Click **Generate a private key**
3. A `.pem` file will be downloaded automatically
4. **Move this file** to your project directory and rename it to match your `.env` file

### 2.3 Install the App on Your Organization

1. In your GitHub App settings, click **Install App** in the left sidebar
2. Next to your organization name, click **Install**
3. Choose installation scope:
   - **All repositories** (recommended), or
   - **Selected repositories** (if you want to limit access)
4. Click **Install**

### 2.4 Get the Installation ID
After installation, you'll be redirected to a URL like:
```
https://github.com/settings/installations/{INSTALLATION_ID}
```
**Save the Installation ID** (the number at the end of the URL).

## Step 3: Set Up Your Environment

### 3.1 Install Dependencies
```bash
npm install
```

### 3.2 Create Environment File
Copy the template and add your values:

```bash
cp .env.template .env
```

Edit `.env` with your actual values:
```bash
# GitHub App Configuration
GITHUB_APP_ID=123456
GITHUB_PRIVATE_KEY_PATH=./ghcpmetricsapp.2025-07-29.private-key.pem
GITHUB_INSTALLATION_ID=12345678
GITHUB_ORG=your-organization-name

# Optional: Date range (defaults to last 30 days)
# METRICS_START_DATE=2024-01-01
# METRICS_END_DATE=2024-01-31
```

### 3.3 Verify Private Key Location
Make sure your private key file is in the correct location specified in your `.env` file.
