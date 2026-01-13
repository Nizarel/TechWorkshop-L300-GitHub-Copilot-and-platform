# Project

This lab guides you through a series of practical exercises focused on modernising Zava's business applications and databases by migrating everything to Azure, leveraging GitHub Enterprise, Copilot, and Azure services. Each exercise is designed to deliver hands-on experience in governance, automation, security, AI integration, and observability, ensuring Zava’s transition to Azure is robust, secure, and future-ready.

## ZavaStorefront Application

The ZavaStorefront is an ASP.NET Core 6.0 MVC web application that can be deployed to Azure using containerization and Azure Developer CLI.

### Prerequisites

- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- Active Azure subscription
- No local Docker installation required (uses Azure Container Registry build)

### Quick Start - Deploy to Azure

1. **Authenticate with Azure**
   ```bash
   az login
   ```

2. **Deploy everything with one command**
   ```bash
   azd up
   ```

   This will:
   - Prompt for environment name and location (use westus3 for Microsoft Foundry support)
   - Provision all Azure resources (Container Registry, App Service, Application Insights, Azure AI Hub/Project)
   - Build the container image in Azure (no local Docker needed)
   - Deploy the application

3. **Access your application**
   
   The deployment will output the application URL. Visit it in your browser.

### What Gets Deployed

The infrastructure provisions:
- **Azure Container Registry** - Stores Docker images
- **Linux App Service** - Hosts the web application
- **Application Insights** - Application monitoring and telemetry
- **Log Analytics Workspace** - Centralized logging
- **Azure AI Hub & Project** - Microsoft Foundry for GPT-4 and Phi models
- **Managed Identity & RBAC** - Passwordless container image pulls

All resources are deployed to westus3 region in a single resource group.

### Infrastructure Details

See [infra/README.md](infra/README.md) for detailed infrastructure documentation, including:
- Architecture overview
- Resource naming conventions
- Module structure
- Configuration options
- Troubleshooting guide

### Clean Up Resources

To delete all Azure resources:
```bash
azd down
```
## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
