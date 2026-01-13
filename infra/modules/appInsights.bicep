@description('Name of the Application Insights instance')
param appInsightsName string

@description('Name of the Log Analytics workspace')
param logAnalyticsWorkspaceName string

@description('Location for the resources')
param location string = resourceGroup().location

@description('Tags to apply to resources')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('The name of the Application Insights instance')
output appInsightsName string = appInsights.name

@description('The instrumentation key of the Application Insights instance')
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey

@description('The connection string of the Application Insights instance')
output appInsightsConnectionString string = appInsights.properties.ConnectionString

@description('The resource ID of the Application Insights instance')
output appInsightsId string = appInsights.id
