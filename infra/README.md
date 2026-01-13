# ZavaStorefront Azure Infrastructure

This directory contains the Infrastructure as Code (IaC) for deploying the ZavaStorefront web application to Azure using Bicep templates and Azure Developer CLI (AZD).

## Architecture Overview

The infrastructure provisions the following Azure resources:

### Compute & Container
- **Azure Container Registry (ACR)**: Stores Docker container images
- **App Service Plan**: Linux-based hosting plan (Basic B1 tier for dev)
- **App Service**: Web app configured for Linux containers with system-assigned managed identity

### Monitoring & Observability
- **Log Analytics Workspace**: Centralized logging and analytics
- **Application Insights**: Application performance monitoring and telemetry

### AI/ML Services
- **Azure AI Hub**: Microsoft Foundry workspace for AI services
- **Azure AI Project**: Project workspace for GPT-4 and Phi model deployments

### Security
- **Managed Identity**: System-assigned identity for App Service
- **RBAC Role Assignment**: AcrPull role granted to App Service for passwordless container image pulls

## Resource Naming Convention

Resources are named using a unique token generated from the subscription ID, environment name, and location:

- Container Registry: `cr{resourceToken}`
- Log Analytics: `log{resourceToken}`
- Application Insights: `appi{resourceToken}`
- App Service Plan: `plan{resourceToken}`
- App Service: `app-{resourceToken}`
- AI Hub: `aihub{resourceToken}`
- AI Project: `aiproject{resourceToken}`

## Module Structure

```
infra/
├── main.bicep                      # Main orchestration template
├── main.parameters.json            # Parameter values
└── modules/
    ├── containerRegistry.bicep     # Azure Container Registry
    ├── logAnalytics.bicep          # Log Analytics Workspace
    ├── applicationInsights.bicep   # Application Insights
    ├── appServicePlan.bicep        # App Service Plan (Linux)
    ├── appService.bicep            # App Service with managed identity
    ├── roleAssignment.bicep        # RBAC role assignments
    ├── aiHub.bicep                 # Azure AI Hub
    └── aiProject.bicep             # Azure AI Project
```

## Prerequisites

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Azure Developer CLI**: Install from https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd
3. **Azure CLI**: Install from https://learn.microsoft.com/cli/azure/install-azure-cli
4. **Authentication**: Run `az login` to authenticate with Azure

## Deployment

### Quick Start

Deploy all infrastructure with a single command:

```bash
azd up
```

This command will:
1. Prompt for environment name and Azure location
2. Provision all Azure resources
3. Build and deploy the application container
4. Configure monitoring and AI services

### Step-by-Step Deployment

#### 1. Initialize AZD Environment

```bash
azd init
```

Follow the prompts to configure your environment.

#### 2. Preview Infrastructure Changes

```bash
azd provision --preview
```

This shows what resources will be created without making changes.

#### 3. Provision Infrastructure

```bash
azd provision
```

Creates all Azure resources defined in the Bicep templates.

#### 4. Deploy Application

```bash
azd deploy
```

Builds the Docker image and deploys it to App Service.

## Configuration

### Default Settings

- **Region**: westus3 (required for Microsoft Foundry with GPT-4 and Phi models)
- **Environment**: Development
- **App Service Plan SKU**: Basic B1 (cost-optimized for dev)
- **Container Registry SKU**: Basic

### Customization

To modify default settings, update the parameters in `main.bicep` or override them in `main.parameters.json`.

## Key Features

### Passwordless Container Registry Access

The App Service uses a system-assigned managed identity with the AcrPull role to pull images from ACR. This eliminates the need for:
- Admin credentials
- Password management
- Secret rotation

Configuration is handled automatically in the `appService.bicep` and `roleAssignment.bicep` modules.

### Application Insights Integration

Application Insights is automatically configured with:
- Connection string injected as app settings
- Instrumentation key for legacy SDKs
- Linked to Log Analytics workspace for advanced queries

### Microsoft Foundry (Azure AI)

Azure AI Hub and Project are provisioned for:
- GPT-4 model deployments
- Phi model deployments
- Centralized AI governance and monitoring

Model deployments must be created separately through the Azure Portal or Azure CLI.

## Outputs

After deployment, the following outputs are available:

- `AZURE_CONTAINER_REGISTRY_ENDPOINT`: ACR login server URL
- `AZURE_CONTAINER_REGISTRY_NAME`: ACR name for `az acr build`
- `APPLICATIONINSIGHTS_CONNECTION_STRING`: Connection string for monitoring
- `AZURE_APP_SERVICE_NAME`: Name of the deployed web app
- `AZURE_APP_SERVICE_URL`: Public URL of the web application
- `AZURE_AI_HUB_NAME`: Name of the AI Hub
- `AZURE_AI_PROJECT_NAME`: Name of the AI Project

View outputs with:

```bash
azd env get-values
```

## Building and Deploying Container Images

### Using Azure Container Registry Build (No Local Docker Required)

Build and push images directly in Azure:

```bash
az acr build --registry <registry-name> --image zavastorefrontapp:latest --file Dockerfile .
```

The App Service will automatically pull the new image using its managed identity.

### Continuous Deployment

Set up GitHub Actions or Azure DevOps to automatically build and deploy on code changes. The infrastructure supports cloud-based builds, eliminating the need for Docker on developer machines.

## Resource Cleanup

To delete all provisioned resources:

```bash
azd down
```

This removes the entire resource group and all contained resources.

## Cost Optimization

The infrastructure uses cost-optimized SKUs for development:

- **App Service Plan**: Basic B1 (~$13/month)
- **Container Registry**: Basic (~$5/month)
- **Log Analytics**: Pay-as-you-go with 30-day retention
- **Application Insights**: Pay-as-you-go (free tier available)
- **Azure AI Services**: Pay-per-use for model inference

**Important**: Always run `azd down` when not actively using resources to minimize costs.

## Troubleshooting

### Deployment Fails

1. Check Azure subscription quotas for the region
2. Verify Microsoft Foundry is available in westus3
3. Review deployment logs: `azd provision --debug`

### Container Pull Fails

1. Ensure role assignment completed: Check Azure Portal → ACR → Access Control (IAM)
2. Verify managed identity is enabled on App Service
3. Check image exists in registry: `az acr repository list`

### Application Insights Not Receiving Data

1. Verify connection string in app settings
2. Check Application Insights SDK is included in the application
3. Review Log Analytics workspace connection

## Additional Resources

- [Azure Developer CLI Documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/)
- [Azure Container Registry Documentation](https://learn.microsoft.com/azure/container-registry/)
- [App Service Linux Containers](https://learn.microsoft.com/azure/app-service/configure-custom-container)
- [Azure AI Studio Documentation](https://learn.microsoft.com/azure/ai-studio/)
- [Application Insights for .NET](https://learn.microsoft.com/azure/azure-monitor/app/asp-net-core)
