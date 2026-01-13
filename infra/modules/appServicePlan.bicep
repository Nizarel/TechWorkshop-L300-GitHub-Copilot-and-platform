@description('Name of the app service plan')
param name string

@description('Location for the app service plan')
param location string

@description('Tags to apply to the app service plan')
param tags object = {}

@description('SKU for the app service plan')
param sku object = {
  name: 'B1'
  tier: 'Basic'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  kind: 'linux'
  properties: {
    reserved: true
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name
