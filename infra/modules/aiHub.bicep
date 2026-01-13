@description('Name of the AI Hub')
param name string

@description('Location for the AI Hub')
param location string

@description('Tags to apply to the AI Hub')
param tags object = {}

@description('Application Insights resource ID')
param applicationInsightsId string

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: name
  location: location
  tags: tags
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: name
    description: 'Azure AI Hub for ZavaStorefront application'
    applicationInsights: applicationInsightsId
    publicNetworkAccess: 'Enabled'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

output id string = aiHub.id
output name string = aiHub.name
output principalId string = aiHub.identity.principalId
