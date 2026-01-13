@description('Name of the Azure Container Registry')
param acrName string

@description('Location for the Azure Container Registry')
param location string = resourceGroup().location

@description('SKU for the Azure Container Registry')
@allowed(['Basic', 'Standard', 'Premium'])
param sku string = 'Basic'

@description('Tags to apply to resources')
param tags object = {}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: sku
  }
  tags: tags
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
  }
}

@description('The name of the Azure Container Registry')
output acrName string = acr.name

@description('The login server URL of the Azure Container Registry')
output acrLoginServer string = acr.properties.loginServer

@description('The resource ID of the Azure Container Registry')
output acrId string = acr.id
