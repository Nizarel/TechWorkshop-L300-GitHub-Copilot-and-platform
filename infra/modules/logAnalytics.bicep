@description('Name of the log analytics workspace')
param name string

@description('Location for the log analytics workspace')
param location string

@description('Tags to apply to the log analytics workspace')
param tags object = {}

@description('SKU for the log analytics workspace')
param sku string = 'PerGB2018'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: 30
  }
}

output id string = logAnalyticsWorkspace.id
output name string = logAnalyticsWorkspace.name
output customerId string = logAnalyticsWorkspace.properties.customerId
