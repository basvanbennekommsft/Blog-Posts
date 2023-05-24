// Application Insights Target Scope
targetScope = 'resourceGroup'

// Generic Parameters
@sys.description('Optional. Location of all the Azure resources. Default: resourceGroup().location')
param location string = resourceGroup().location

// Application Insights Parameters
@sys.description('Required. Name of the Application Insights.')
@minLength(1)
@maxLength(260)
param name string

@sys.description('Optional. Tags of the Application Insights. Default: {}')
param tags object = {}

@sys.description('Required. Kind of the Application Insights.')
param kind string

@sys.description('Optional. Type of application monitored by the Application Insights. Default: web')
param applicationType string = 'web'

@sys.description('Optional. Whether the disable IP masking functionality is enabled on the Application Insights. Default: false')
param disableIpMasking bool = false

@sys.description('Optional. Whether the disable local authentication functionality is enabled on the Application Insights. Default: false')
param disableLocalAuth bool = false

@sys.description('Optional. Whether the customer storage for profiler functionality is enabled on the Application Insights. Default: false')
param forceCustomerStorageForProfiler bool = false

@sys.description('Optional. Id of the HockeyApp that can be integrated with the Application Insights. Default: empty string')
param hockeyAppId string = ''

@sys.description('Required. Ingestion mode of the Application Insights.')
param ingestionMode string

@sys.description('Optional. Whether the public network access for ingestion functionality is enabled on the Application Insights. Default: Enabled')
param publicNetworkAccessForIngestion string = 'Enabled'

@sys.description('Optional. Whether the public network access for query functionality is enabled on the Application Insights. Default: Enabled')
param publicNetworkAccessForQuery string = 'Enabled'

@sys.description('Required. Retention in days of the Application Insights.')
param retentionInDays int

@sys.description('Required. Sampling percentage of the Application Insights.')
@minValue(0)
@maxValue(100)
param samplingPercentage int

@sys.description('Required. Id of the Log Analytics workspace associated to the Application Insights.')
param workspaceResourceId string

// Create the Application Insights if it does not exist
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    Application_Type: applicationType
    DisableIpMasking: disableIpMasking
    DisableLocalAuth: disableLocalAuth
    Flow_Type: 'Bluefield'
    ForceCustomerStorageForProfiler: forceCustomerStorageForProfiler
    HockeyAppId: !empty(hockeyAppId) ? hockeyAppId : null
    IngestionMode: ingestionMode
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    Request_Source: 'rest'
    RetentionInDays: retentionInDays
    SamplingPercentage: samplingPercentage
    WorkspaceResourceId: workspaceResourceId
  }
}

// Application Insights Output
@sys.description('The Resource Group of the Application Insights.')
output resourceGroupName string = resourceGroup().name

@sys.description('The name of the Application Insights.')
output name string = applicationInsights.name

@sys.description('The resource Id of the Application Insights.')
output resourceId string = applicationInsights.id

@sys.description('The location of the Application Insights.')
output location string = applicationInsights.location
