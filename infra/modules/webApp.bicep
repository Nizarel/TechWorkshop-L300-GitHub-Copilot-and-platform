@description('Name of the Web App')
param webAppName string

@description('Location for the Web App')
param location string = resourceGroup().location

@description('Resource ID of the App Service Plan')
param appServicePlanId string

@description('Login server URL of the Azure Container Registry')
param acrLoginServer string

@description('Docker image name and tag')
param dockerImageName string = 'zavastore:latest'

@description('Application Insights connection string')
param appInsightsConnectionString string = ''

@description('Tags to apply to resources')
param tags object = {}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: webAppName
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
      linuxFxVersion: 'DOCKER|${acrLoginServer}/${dockerImageName}'
      alwaysOn: true
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
      ]
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

@description('The name of the Web App')
output webAppName string = webApp.name

@description('The default hostname of the Web App')
output webAppHostName string = webApp.properties.defaultHostName

@description('The principal ID of the system-assigned managed identity')
output webAppPrincipalId string = webApp.identity.principalId

@description('The resource ID of the Web App')
output webAppId string = webApp.id
