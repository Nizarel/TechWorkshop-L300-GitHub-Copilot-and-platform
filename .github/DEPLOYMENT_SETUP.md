# GitHub Actions Deployment Setup

This document explains how to configure GitHub Actions for automated deployment of the ZavaStorefront application to Azure App Service.

## Prerequisites

- Azure CLI installed and authenticated
- GitHub repository with admin access
- Azure resources already deployed (resource group, ACR, App Service)

## 1. Create Azure Service Principal

Create a service principal with contributor access to your resource group:

```bash
az ad sp create-for-rbac \
  --name "github-actions-zavastore" \
  --role contributor \
  --scopes /subscriptions/da9dea7f-1fc8-44de-93da-ce5c58314cdb/resourceGroups/rg-zavastore-prod-westus3 \
  --sdk-auth
```

This command will output JSON credentials. **Copy the entire JSON output** - you'll need it in the next step.

## 2. Configure GitHub Secret

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret**
4. Name: `AZURE_CREDENTIALS`
5. Value: Paste the entire JSON output from step 1
6. Click **Add secret**

## 3. Workflow Configuration

The workflow in [.github/workflows/deploy.yml](workflows/deploy.yml) is configured with:

- **Triggers**: 
  - Automatic deployment on push to `main` branch
  - Manual trigger via GitHub Actions UI (workflow_dispatch)

- **Environment Variables**:
  - `AZURE_WEBAPP_NAME`: app-zavastore-prod-westus3
  - `ACR_NAME`: acrzavastorerh5dhy4dqty3c
  - `IMAGE_NAME`: zavastore

- **Deployment Steps**:
  1. Checkout code
  2. Authenticate with Azure
  3. Build and push Docker image to ACR (tagged with commit SHA and 'latest')
  4. Deploy image to App Service
  5. Logout from Azure

## 4. Test the Deployment

### Option A: Push to Main Branch
```bash
git add .
git commit -m "feat: add GitHub Actions deployment workflow"
git push origin main
```

### Option B: Manual Trigger
1. Go to **Actions** tab in GitHub
2. Select **Deploy to Azure App Service** workflow
3. Click **Run workflow**
4. Select branch and click **Run workflow**

## 5. Monitor Deployment

### View Workflow Status
- GitHub Actions tab shows real-time progress
- Each step displays logs and status

### View Application Logs
```bash
az webapp log tail \
  --name app-zavastore-prod-westus3 \
  --resource-group rg-zavastore-prod-westus3
```

### Check Deployment Status
```bash
az webapp show \
  --name app-zavastore-prod-westus3 \
  --resource-group rg-zavastore-prod-westus3 \
  --query "{state:state, enabled:enabled, defaultHostName:defaultHostName}"
```

## Troubleshooting

- **Authentication errors**: Verify AZURE_CREDENTIALS secret is correctly configured
- **ACR access denied**: Ensure service principal has AcrPush role on the ACR
- **Deployment timeout**: Check App Service logs for container startup issues
- **Image not updating**: Verify the image tag in deployment step matches ACR build output

## Security Notes

- The service principal has contributor access scoped only to the resource group
- Credentials are stored as GitHub encrypted secrets
- Azure logout step ensures credentials aren't leaked in logs
- Consider using OIDC authentication for enhanced security (federated credentials)
