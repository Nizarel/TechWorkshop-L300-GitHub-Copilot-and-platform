targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the environment (e.g., dev, prod)')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Unique identifier for resource naming')
param resourceToken string = toLower(uniqueString(subscription().id, environmentName, location))

@description('Name of the container registry')
param containerRegistryName string = 'cr${resourceToken}'

@description('Name of the log analytics workspace')
param logAnalyticsName string = 'log${resourceToken}'

@description('Name of the application insights instance')
param applicationInsightsName string = 'appi${resourceToken}'

@description('Name of the app service plan')
param appServicePlanName string = 'plan${resourceToken}'

@description('Name of the app service')
param appServiceName string = 'app-${resourceToken}'

@description('Name of the AI Hub')
param aiHubName string = 'aihub${resourceToken}'

@description('Name of the AI Project')
param aiProjectName string = 'aiproject${resourceToken}'

@description('Docker image name and tag')
param imageName string = 'zavastorefrontapp:latest'

// Tags to be applied to all resources
var tags = {
  environment: environmentName
  'azd-env-name': environmentName
}

// Container Registry
module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'containerRegistry'
  params: {
    name: containerRegistryName
    location: location
    tags: tags
  }
}

// Log Analytics Workspace
module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

// Application Insights
module applicationInsights 'modules/applicationInsights.bicep' = {
  name: 'applicationInsights'
  params: {
    name: applicationInsightsName
    location: location
    tags: tags
    workspaceId: logAnalytics.outputs.id
  }
}

// App Service Plan
module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    sku: {
      name: 'B1'
      tier: 'Basic'
    }
  }
}

// App Service
module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    name: appServiceName
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryName: containerRegistry.outputs.name
    imageName: imageName
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    applicationInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
  }
}

// Role Assignment - Grant AcrPull to App Service Managed Identity
module roleAssignment 'modules/roleAssignment.bicep' = {
  name: 'roleAssignment'
  params: {
    principalId: appService.outputs.principalId
    containerRegistryName: containerRegistry.outputs.name
  }
}

// Azure AI Hub (Microsoft Foundry)
module aiHub 'modules/aiHub.bicep' = {
  name: 'aiHub'
  params: {
    name: aiHubName
    location: location
    tags: tags
    applicationInsightsId: applicationInsights.outputs.id
  }
}

// Azure AI Project
module aiProject 'modules/aiProject.bicep' = {
  name: 'aiProject'
  params: {
    name: aiProjectName
    location: location
    tags: tags
    aiHubId: aiHub.outputs.id
  }
}

// Outputs
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name
output APPLICATIONINSIGHTS_CONNECTION_STRING string = applicationInsights.outputs.connectionString
output AZURE_APP_SERVICE_NAME string = appService.outputs.name
output AZURE_APP_SERVICE_URL string = appService.outputs.uri
output AZURE_AI_HUB_NAME string = aiHub.outputs.name
output AZURE_AI_PROJECT_NAME string = aiProject.outputs.name
