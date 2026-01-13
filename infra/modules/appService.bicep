@description('Name of the app service')
param name string

@description('Location for the app service')
param location string

@description('Tags to apply to the app service')
param tags object = {}

@description('App Service Plan resource ID')
param appServicePlanId string

@description('Container Registry name')
param containerRegistryName string

@description('Docker image name and tag')
param imageName string

@description('Application Insights connection string')
param applicationInsightsConnectionString string

@description('Application Insights instrumentation key')
param applicationInsightsInstrumentationKey string

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${imageName}'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistryName}.azurecr.io'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsInstrumentationKey
        }
      ]
      acrUseManagedIdentityCreds: true
    }
  }
}

output id string = appService.id
output name string = appService.name
output principalId string = appService.identity.principalId
output uri string = 'https://${appService.properties.defaultHostName}'
