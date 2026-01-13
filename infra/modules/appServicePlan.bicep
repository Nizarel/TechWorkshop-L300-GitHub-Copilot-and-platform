@description('Name of the App Service Plan')
param appServicePlanName string

@description('Location for the App Service Plan')
param location string = resourceGroup().location

@description('SKU for the App Service Plan')
param sku object = {
  name: 'B1'
  tier: 'Basic'
  size: 'B1'
  family: 'B'
  capacity: 1
}

@description('Tags to apply to resources')
param tags object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: sku
  tags: tags
  kind: 'linux'
  properties: {
    reserved: true
  }
}

@description('The name of the App Service Plan')
output appServicePlanName string = appServicePlan.name

@description('The resource ID of the App Service Plan')
output appServicePlanId string = appServicePlan.id
