targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Azure region for resource deployment')
param azureLocation string = 'westus3'

@description('Name of the environment (e.g., dev, prod)')
@maxLength(10)
param environmentName string = 'dev'

@description('Primary location for all resources')
param location string = azureLocation

@description('Base name for the application')
param appName string = 'zavastore'

@description('Tags to apply to all resources')
param tags object = {
  Environment: environmentName
  Application: appName
  ManagedBy: 'azd'
}

// Generate resource names with naming convention
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var resourceGroupName = 'rg-${appName}-${environmentName}-${location}'
var acrName = replace('acr-${appName}-${resourceToken}', '-', '')
var appServicePlanName = 'asp-${appName}-${environmentName}-${location}'
var webAppName = 'app-${appName}-${environmentName}-${location}'
var appInsightsName = 'appi-${appName}-${environmentName}-${location}'
var logAnalyticsName = 'log-${appName}-${environmentName}-${location}'
var aiHubName = 'aih-${appName}-${environmentName}-${location}'
var aiProjectName = 'aip-${appName}-${environmentName}-${location}'

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Deploy Azure Container Registry
module acr './modules/acr.bicep' = {
  name: 'acr-deployment'
  scope: rg
  params: {
    acrName: acrName
    location: location
    sku: 'Basic'
    tags: tags
  }
}

// Deploy App Service Plan
module appServicePlan './modules/appServicePlan.bicep' = {
  name: 'appServicePlan-deployment'
  scope: rg
  params: {
    appServicePlanName: appServicePlanName
    location: location
    sku: {
      name: 'B1'
      tier: 'Basic'
      size: 'B1'
      family: 'B'
      capacity: 1
    }
    tags: tags
  }
}

// Deploy Application Insights
module appInsights './modules/appInsights.bicep' = {
  name: 'appInsights-deployment'
  scope: rg
  params: {
    appInsightsName: appInsightsName
    logAnalyticsWorkspaceName: logAnalyticsName
    location: location
    tags: tags
  }
}

// Deploy Web App
module webApp './modules/webApp.bicep' = {
  name: 'webApp-deployment'
  scope: rg
  params: {
    webAppName: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    acrLoginServer: acr.outputs.acrLoginServer
    dockerImageName: '${appName}:latest'
    appInsightsConnectionString: appInsights.outputs.appInsightsConnectionString
    tags: tags
  }
}

// Deploy Microsoft Foundry (AI Hub and Project)
module foundry './modules/foundry.bicep' = {
  name: 'foundry-deployment'
  scope: rg
  params: {
    aiHubName: aiHubName
    aiProjectName: aiProjectName
    location: location
    appInsightsId: appInsights.outputs.appInsightsId
    tags: tags
  }
}

// Role Assignment: Grant AcrPull role to Web App's managed identity
resource acrPullRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull role ID
}

module acrRoleAssignment 'modules/roleAssignment.bicep' = {
  name: 'acrRoleAssignment-deployment'
  scope: rg
  params: {
    principalId: webApp.outputs.webAppPrincipalId
    roleDefinitionId: acrPullRoleDefinition.id
    resourceId: acr.outputs.acrId
  }
}

// Outputs for AZD (UPPER_CASE names become environment variables)
@description('The name of the resource group')
output RESOURCE_GROUP_NAME string = rg.name

@description('The login server URL of the Azure Container Registry')
output ACR_LOGIN_SERVER string = acr.outputs.acrLoginServer

@description('The name of the Azure Container Registry')
output ACR_NAME string = acr.outputs.acrName

@description('The default hostname of the Web App')
output WEB_APP_URL string = 'https://${webApp.outputs.webAppHostName}'

@description('The name of the Web App')
output WEB_APP_NAME string = webApp.outputs.webAppName

@description('The connection string for Application Insights')
output APPLICATIONINSIGHTS_CONNECTION_STRING string = appInsights.outputs.appInsightsConnectionString

@description('The name of the AI Hub')
output AI_HUB_NAME string = foundry.outputs.aiHubName

@description('The name of the AI Project')
output AI_PROJECT_NAME string = foundry.outputs.aiProjectName

@description('The endpoint URL of the AI Project')
output AI_PROJECT_ENDPOINT string = foundry.outputs.aiProjectEndpoint
