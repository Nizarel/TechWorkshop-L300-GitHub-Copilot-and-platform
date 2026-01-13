@description('Name of the AI Project')
param name string

@description('Location for the AI Project')
param location string

@description('Tags to apply to the AI Project')
param tags object = {}

@description('AI Hub resource ID')
param aiHubId string

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: name
  location: location
  tags: tags
  kind: 'Project'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: name
    description: 'Azure AI Project for ZavaStorefront with GPT-4 and Phi models'
    hubResourceId: aiHubId
    publicNetworkAccess: 'Enabled'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

output id string = aiProject.id
output name string = aiProject.name
output principalId string = aiProject.identity.principalId
