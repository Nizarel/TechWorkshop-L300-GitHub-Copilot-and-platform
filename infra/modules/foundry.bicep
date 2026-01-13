@description('Name of the AI Hub')
param aiHubName string

@description('Name of the AI Project')
param aiProjectName string

@description('Location for the AI resources')
param location string = resourceGroup().location

@description('Resource ID of the Application Insights instance')
param appInsightsId string

@description('Tags to apply to resources')
param tags object = {}

// Storage Account for AI Hub
// Storage account names must be 3-24 chars, lowercase and numbers only
var storageAccountBaseName = replace(toLower('${aiHubName}sa'), '-', '')
var storageAccountName = length(storageAccountBaseName) >= 3 ? take(storageAccountBaseName, 24) : take('${storageAccountBaseName}sto', 24)
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// Key Vault for AI Hub
// Key Vault names must be 3-24 chars
var keyVaultName = take(replace('${aiHubName}kv', '-', ''), 24)
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}

// AI Hub (Azure AI Foundry Hub)
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: aiHubName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'Hub'
  properties: {
    friendlyName: aiHubName
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: appInsightsId
    publicNetworkAccess: 'Enabled'
  }
}

// AI Project (Azure AI Foundry Project)
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: aiProjectName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'Project'
  properties: {
    friendlyName: aiProjectName
    hubResourceId: aiHub.id
    publicNetworkAccess: 'Enabled'
  }
}

@description('The name of the AI Hub')
output aiHubName string = aiHub.name

@description('The resource ID of the AI Hub')
output aiHubId string = aiHub.id

@description('The name of the AI Project')
output aiProjectName string = aiProject.name

@description('The resource ID of the AI Project')
output aiProjectId string = aiProject.id

@description('The endpoint URL of the AI Project')
output aiProjectEndpoint string = aiProject.properties.discoveryUrl
