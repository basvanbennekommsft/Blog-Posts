// App Service Plan Target Scope
targetScope = 'resourceGroup'

// Generic Parameters
@sys.description('Optional. Location of all the Azure resources. Default: resourceGroup().location')
param location string = resourceGroup().location

// App Service Plan Parameters
@sys.description('Required. Name of the App Service Plan.')
@minLength(1)
@maxLength(40)
param name string

@sys.description('Optional. Tags of the App Service Plan. Default: {}')
param tags object = {}

@sys.description('Required. SKU of the App Service Plan.')
param sku object

@sys.description('Required. Kind of the App Service Plan.')
param kind string

@sys.description('Optional. Whether the elastic scaling functionality is enabled on the App Service Plan. = false')
param elasticScaleEnabled bool = false

@sys.description('Optional. Id of the App Service Environment that hosts the App Service Plan. Default: empty string')
param appServiceEnvironmentId string = ''

@sys.description('Optional. Whether the HyperV functionality is enabled on the App Service Plan. Default: false')
param hyperV bool = false

@sys.description('Optional. Whether the spot instance functionality is enabled on the App Service Plan. Default: false')
param isSpot bool = false

@sys.description('Optional. Id of the Azure Kubernetes Services instance that hosts the App Service Plan. Default: empty string')
param azureKubernetesServicesId string = ''

@sys.description('Required. Maximum number of total workers allowed on the App Service Plan.')
param maximumElasticWorkerCount int

@sys.description('Optional. Whether the independent worker scaling functionality is enabled on the App Service Plan. Default: false')
param perSiteScaling bool = false

@sys.description('Optional. Whether the reservation functionality is enabled on the App Service Plan. Default: false')
param reserved bool = false

@sys.description('Optional. Expiration time of the App Service Plan. Default: empty string')
param spotExpirationTime string = ''

@sys.description('Required. Number of the total workers on the App Service Plan.')
param targetWorkerCount int

@sys.description('Required. Size of the workers on the App Service Plan.')
param targetWorkerSizeId int

@sys.description('Optional. Target worker tier of the App Service Plan. Default: empty string')
param workerTierName string = ''

@sys.description('Optional. Whether the zone redundancy functionality is enabled on the App Service Plan.')
param zoneRedundant bool = true

// Create the App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  kind: kind
  extendedLocation: null
  properties: {
    elasticScaleEnabled: elasticScaleEnabled
    freeOfferExpirationTime: null
    hostingEnvironmentProfile: !empty(appServiceEnvironmentId) ? {
      id: appServiceEnvironmentId
    } : null
    hyperV: hyperV
    isSpot: isSpot
    isXenon: null
    kubeEnvironmentProfile: !empty(azureKubernetesServicesId) ? {
      id: azureKubernetesServicesId
    } : null
    maximumElasticWorkerCount: maximumElasticWorkerCount
    perSiteScaling: perSiteScaling
    reserved: reserved
    spotExpirationTime: !empty(spotExpirationTime) && isSpot == true ? spotExpirationTime : null
    targetWorkerCount: targetWorkerCount
    targetWorkerSizeId: targetWorkerSizeId
    workerTierName: !empty(workerTierName) ? workerTierName : null
    zoneRedundant: zoneRedundant
  }
}

// App Service Plan Output
@sys.description('The Resource Group of the App Service Plan.')
output resourceGroupName string = resourceGroup().name

@sys.description('The name of the App Service Plan.')
output name string = appServicePlan.name

@sys.description('The resource Id of the App Service Plan.')
output resourceId string = appServicePlan.id

@sys.description('The location of the App Service Plan.')
output location string = appServicePlan.location
