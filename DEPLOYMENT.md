# ZavaStorefront - Azure Infrastructure Deployment Guide

## Overview

ZavaStorefront is a .NET 6.0 web application deployed as a containerized application on Azure. This repository includes complete infrastructure-as-code using Azure Bicep and Azure Developer CLI (AZD) for automated deployment.

## Architecture

The application is deployed with the following Azure resources:

- **Azure Container Registry (ACR)**: Stores Docker container images
- **Linux App Service**: Hosts the containerized web application
- **Application Insights**: Monitors application performance and logs
- **Microsoft Foundry (Azure AI)**: Provides AI capabilities with GPT-4 and Phi models
- **Managed Identity**: Enables secure, password-less authentication between services

All resources are deployed to the **westus3** region in a single resource group.

## Prerequisites

Before deploying, ensure you have:

1. **Azure CLI** (version 2.50.0 or higher)
   ```bash
   az --version
   ```
   Install from: https://docs.microsoft.com/cli/azure/install-azure-cli

2. **Azure Developer CLI (azd)**
   ```bash
   azd version
   ```
   Install from: https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd

3. **Azure Subscription** with:
   - Owner or Contributor role
   - Sufficient quota for:
     - App Service (B1 tier)
     - Azure Container Registry (Basic tier)
     - Microsoft Foundry resources

4. **Logged in to Azure**
   ```bash
   az login
   azd auth login
   ```

## Deployment

### One-Command Deployment

Deploy the entire infrastructure and application with:

```bash
azd up
```

This command will:
1. Prompt for environment name and Azure subscription
2. Create all Azure resources using Bicep templates
3. Build the Docker image in Azure Container Registry (no local Docker needed)
4. Deploy the container to App Service
5. Configure Application Insights monitoring
6. Set up Microsoft Foundry AI resources

### Step-by-Step Deployment

If you prefer granular control:

1. **Initialize the environment**
   ```bash
   azd env new <environment-name>
   ```

2. **Provision infrastructure**
   ```bash
   azd provision
   ```
   This creates all Azure resources defined in [infra/main.bicep](infra/main.bicep)

3. **Build and deploy the application**
   ```bash
   azd deploy
   ```

## Infrastructure Details

### Resource Naming Convention

Resources follow Azure naming best practices:

- Resource Group: `rg-zavastore-dev-westus3`
- Container Registry: `acrzavastoreabc123` (unique suffix)
- App Service Plan: `asp-zavastore-dev-westus3`
- Web App: `app-zavastore-dev-westus3`
- Application Insights: `appi-zavastore-dev-westus3`
- AI Hub: `aih-zavastore-dev-westus3`
- AI Project: `aip-zavastore-dev-westus3`

### Security Features

- **No Docker Credentials**: App Service uses system-assigned managed identity with AcrPull role
- **HTTPS Only**: Web app enforces HTTPS
- **TLS 1.2+**: Minimum TLS version enforced
- **Admin User Disabled**: ACR admin account is disabled

### Container Build Process

The application is built in the cloud using `az acr build`:

```bash
az acr build --registry <acr-name> --image zavastore:latest --file ./src/Dockerfile ./src
```

This eliminates the need for local Docker installation.

## Configuration

### Environment Variables

The deployment automatically configures these application settings:

- `DOCKER_REGISTRY_SERVER_URL`: ACR login server URL
- `DOCKER_ENABLE_CI`: Enables continuous deployment
- `APPLICATIONINSIGHTS_CONNECTION_STRING`: Application Insights connection

### Customization

Modify parameters in [infra/main.parameters.json](infra/main.parameters.json):

```json
{
  "environmentName": "dev",
  "location": "westus3",
  "appName": "zavastore"
}
```

## Monitoring

Access Application Insights for monitoring:

```bash
azd monitor
```

Or view in Azure Portal:
- Navigate to Application Insights resource
- View Live Metrics, Failures, Performance metrics

## Microsoft Foundry AI Integration

The deployment includes Microsoft Foundry (Azure AI) resources:

- **AI Hub**: Central workspace for AI resources
- **AI Project**: Project-level workspace for GPT-4 and Phi models

Access the AI Project endpoint from deployment outputs:

```bash
azd env get-values
```

Look for `AI_PROJECT_ENDPOINT` value.

## Costs

Estimated monthly costs for dev environment:

- App Service (B1): ~$13/month
- Azure Container Registry (Basic): ~$5/month
- Application Insights: Pay-as-you-go (minimal for dev)
- Microsoft Foundry: Pay-as-you-go based on usage
- Log Analytics: ~$5/month (minimal retention)

**Total estimated: ~$25-50/month** (excluding AI usage)

## Cleanup

Remove all resources:

```bash
azd down
```

This deletes the entire resource group and all contained resources.

## CI/CD Integration

The repository can be extended with GitHub Actions for automated deployments. The infrastructure supports:

- Cloud-based container builds (no local Docker)
- Automatic image pulls via managed identity
- Continuous deployment via webhook

## Troubleshooting

### Deployment Fails

Check deployment logs:
```bash
azd provision --debug
```

### App Service Not Starting

View application logs:
```bash
az webapp log tail --name <web-app-name> --resource-group <rg-name>
```

### Container Not Pulling

Verify managed identity role assignment:
```bash
az role assignment list --assignee <managed-identity-principal-id> --all
```

## Additional Resources

- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Azure Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [App Service Container Documentation](https://learn.microsoft.com/azure/app-service/configure-custom-container)
- [Microsoft Foundry Documentation](https://learn.microsoft.com/azure/ai-studio/)

## Support

For issues or questions, please open an issue in this repository.
