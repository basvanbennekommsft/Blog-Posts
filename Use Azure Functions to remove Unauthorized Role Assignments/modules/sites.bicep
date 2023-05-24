// App Service Target Scope
targetScope = 'resourceGroup'

// Generic Parameters
@sys.description('Optional. Location of all the Azure resources. Default: resourceGroup().location')
param location string = resourceGroup().location

// Storage Account Parameters
@sys.description('Optional. Name of the Storage Account used for the App Service. Default: empty string')
param storageAccountName string = ''

// Retrieve the Storage Account if the App Service is of kind 'functionapp'
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = if (kind == 'functionapp') {
  name: storageAccountName
}

// Application Insights Parameters
@sys.description('Optional. Name of the Application Insights used for the App Service. Default: empty string')
param applicationInsightsName string = ''

// Retrieve the Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

// App Service Parameters
@sys.description('Required. Name of the App Service.')
@minLength(2)
@maxLength(60)
param name string

@sys.description('Optional. Tags of the App Service. Default: {}')
param tags object = {}

@sys.description('Required. Kind of the App Service.')
param kind string

@sys.description('Optional. Whether the System-assigned Managed Identity functionality is enabled on the App Service. Default: false')
param systemAssignedManagedIdentity bool = false

@sys.description('Optional. Id of the User-assigned Managed Identity if it is enabled on the App Service. Default: {}')
param userAssignedManagedIdentity object = {}

@sys.description('Optional. Whether the client affinity functionality is enabled on the App Service. Default: true')
param clientAffinityEnabled bool = true

@sys.description('Optional. Whether the client certificate authentication functionality is enabled on the App Service. Default: false')
param clientCertEnabled bool = false

@sys.description('Optional. Client certificate authentication exclusion paths on the App Service. Default: empty string')
param clientCertExclusionPaths string = ''

@sys.description('Optional. Whether a client certificate is optional or required on the App Service. Default: Optional')
param clientCertMode string = 'Optional'

@sys.description('Optional. Whether the App Service is cloned from another App Service. Default: {}')
param cloningInfo object = {}

@sys.description('Required. Size of the function container of the App Service.')
param containerSize int

@description('Optional. Id of the custom domain of the App Service. Default: empty string')
param customDomainVerificationId string = ''

@sys.description('Required. Maximum daily memory time quota of the App Service.')
param dailyMemoryTimeQuota int

@sys.description('Optional. Whether the App Service is enabled. Default: true')
param enabled bool = true

@sys.description('Optional. Id of the App Service Environment that hosts the App Service Plan. Default: empty string')
param appServiceEnvironmentResourceId string = ''

@sys.description('Optional. Whether the disable public hostnames functionality is enabled on the App Service. Default: false')
param hostNamesDisabled bool = false

@sys.description('Optional. Public hostname SSL states of the App Service. Default: []')
param hostNameSslStates array = []

@sys.description('Optional. Whether the HTTPS only functionality is enabled on the App Service. Default: true')
param httpsOnly bool = true

@sys.description('Optional. Whether the HyperV functionality is enabled on the App Service. Default: false')
param hyperV bool = false

@sys.description('Optional. Id of the Managed Identity on the App Service to access a Key Vault with. Default: empty string')
param keyVaultReferenceIdentity string = ''

@sys.description('Optional. Whether the public network access functionality is enabled on the App Service. Default: Enabled')
param publicNetworkAccess string = 'Enabled'

@sys.description('Optional. Redundancy mode of the App Service. Default: None')
param redundancyMode string = 'None'

@sys.description('Optional. Optional. Whether the reservation functionality is enabled on the App Service. Default: false')
param reserved bool = false

@sys.description('Optional. Whether the SCM site is also stopped when the App Service is stopped. Default: false')
param scmSiteAlsoStopped bool = false

@sys.description('Required. Id of the App Service Plan that hosts the App Service.')
param appServicePlanResourceId string

@sys.description('Optional. Whether the credentials of a Managed Identity are used to pull images from an Azure Container Registry. Default: false')
param acrUseManagedIdentityCreds bool = false

@sys.description('Optional. Id of the Managed Identity that is used to pull images from an Azure Container Registry. Default: empty string')
param acrUserManagedIdentityID string = ''

@sys.description('Optional. Whether the always on functionality is enabled on the App Service. Default: false')
param alwaysOn bool = false

@sys.description('Optional. URL of the API definition of the App Service. Default: empty string')
param apiDefinitionURL string = ''

@sys.description('Optional. Id of the API management configuration of the App Service. Default: empty string')
param apiManagementConfigId string = ''

@sys.description('Optional. App command line to launch on the App Service. Default: empty string')
param appCommandLine string = ''

@sys.description('Required. Application Settings of the App Service.')
param appSettings array

@sys.description('Optional. Whether the auto heal functionality is enabled on the App Service. Default: false')
param autoHealEnabled bool = false

@sys.description('Optional. Automatic heal rules of the App Service. Default: {}')
param autoHealRules object = {}

@sys.description('Optional. Name of the auto-swap slot on the App Service. Default: empty string')
param autoSwapSlotName string = ''

@sys.description('Optional. List of Storage Accounts associated with the App Service. Default: {}')
param azureStorageAccounts object = {}

@sys.description('Optional. Connection strings of the App Service. Default: []')
param connectionStrings array = []

@sys.description('Optional. CORS of the App Service. Default: {}')
param cors object = {}

@sys.description('Required. Default documents of the App Service.')
param defaultDocuments array

@sys.description('Optional. Whether the detailed error logging functionality is enabled on the App Service.')
param detailedErrorLoggingEnabled bool = true

@sys.description('Optional. Document root of the App Service. Default: empty string')
param documentRoot string = ''

@sys.description('Optional. Experiments of the App Service. Default: {}')
param experiments object = {}

@sys.description('Optional. FTPS state of the App Service. Default: FtpsOnly')
param ftpsState string = 'FtpsOnly'

@sys.description('Required. Scale limit of the App Service.')
param functionAppScaleLimit int

@sys.description('Optional. Whether the run time scale monitoring functionality is enabled on the App Service. Default: false')
param functionsRuntimeScaleMonitoringEnabled bool = false

@sys.description('Optional. Handler mappings of the App Service. Default: []')
param handlerMappings array = []

@sys.description('Optional. Health check path of the App Service. Default: empty string')
param healthCheckPath string = ''

@sys.description('Optional. Whether the HTTP 2.0 version is enabled on the App Service. Default: false')
param http20Enabled bool = false

@sys.description('Optional. Whether the HTTP logging functionality is enabled on the App Service. Default: false')
param httpLoggingEnabled bool = false

@sys.description('Required. IP security restrictions of the App Service.')
param ipSecurityRestrictions array

@sys.description('Optional. Java container of the App Service. Default: empty string')
param javaContainer string = ''

@sys.description('Optional. Java container version of the App Service. Default: empty string')
param javaContainerVersion string = ''

@sys.description('Optional. Java version of the App Service. Default: empty string')
param javaVersion string = ''

@sys.description('Optional. Limits of the App Service. Default: {}')
param limits object = {}

@sys.description('Optional. Linux Fx version of the App Service. Default: empty string')
param linuxFxVersion string = ''

@sys.description('Required. Load balancing of the App Service.')
param loadBalancing string

@sys.description('Optional. Whether the local MySQL functionality is enabled on the App Service. Default: false')
param localMySqlEnabled bool = false

@sys.description('Required. Logs directory size limit of the App Service.')
param logsDirectorySizeLimit int

@sys.description('Optional. Managed pipeline mode of the App Service. Default: Integrated')
param managedPipelineMode string = 'Integrated'

@sys.description('Required. Minimum elastic instance count of the App Service.')
param minimumElasticInstanceCount int

@sys.description('Optional. Minimum TLS version of the App Service. Default 1.2')
param minTlsVersion string = '1.2'

@sys.description('Optional. .NET framework version of the App Service. Default: empty string')
param netFrameworkVersion string = ''

@sys.description('Optional. Node.js version of the App Service. Default: empty string')
param nodeVersion string = ''

@sys.description('Required. Number of workers of the App Service.')
param numberOfWorkers int

@sys.description('Optional. PHP version of the App Service. Default: empty string')
param phpVersion string = ''

@sys.description('Optional. PowerShell version of the App Service. Default: empty string')
param powerShellVersion string = ''

@sys.description('Required. Number of pre-warmed instances of the App Service.')
param preWarmedInstanceCount int

@sys.description('Optional. Publishing username of the App Service. Default: empty string')
param publishingUsername string = ''

@sys.description('Optional. Push endpoint settings of the App Service. Default: {}')
param push object = {}

@sys.description('Optional. Python version of the App Service. Default: empty string')
param pythonVersion string = ''

@sys.description('Optional. Whether the remote debugging functionality is enabled on the App Service. Default: false')
param remoteDebuggingEnabled bool = false

@sys.description('Optional. Remote debugging version of the App Service. Default: empty string')
param remoteDebuggingVersion string = ''

@sys.description('Optional. Whether the request tracing functionality is enabled on the App Service. Default: false')
param requestTracingEnabled bool = false

@sys.description('Optional. Request tracting expiration time of the App Service. Default: empty string')
param requestTracingExpirationTime string = ''

@sys.description('Required. SCM IP security restrictions of the App Service.')
param scmIpSecurityRestrictions array

@sys.description('Optional. Whether the IP security use main funtionality is enabled on the App Service. Default: false')
param scmIpSecurityRestrictionsUseMain bool = false

@sys.description('Optional. SCM Minimum TLS version of the App Service. Default: 1.2')
param scmMinTlsVersion string = '1.2'

@sys.description('Required. SCM type of the App Service.')
param scmType string

@sys.description('Optional. Tracing options of the App Service. Default: empty string')
param tracingOptions string = ''

@sys.description('Optional. Whether the 32 bit worker process functionality is enabled on the App Service. Default: true')
param use32BitWorkerProcess bool = true

@sys.description('Optional. Virtual applications of the App Service. Default: []')
param virtualApplications array = []

@sys.description('Optional. Name of the Virtual Network associated to the App Service. Default: empty string')
param vnetName string = ''

@sys.description('Required. Number Virtual Network private ports of the App Service.')
param vnetPrivatePortsCount int

@sys.description('Optional. Time zone of the App Service. Default: empty string')
param websiteTimeZone string = ''

@sys.description('Optional. Whether the web socket functionality is enabled on the App Service. Default: false')
param webSocketsEnabled bool = false

@sys.description('Optional. Windows Fx version of the App Service. Default: empty string')
param windowsFxVersion string = ''

@sys.description('Optional. Whether the customer-provided storage functionality is enabled on the App Service. Default: true')
param storageAccountRequired bool = true

@sys.description('Optional. Id of the Virtual Network that can be used for Virtual Network integration on the App Service. Default: empty string')
param virtualNetworkSubnetId string = ''

@sys.description('Optional. Whether content share traffic is routed through the Virtual Network on the App Service. Default: false')
param vnetContentShareEnabled bool = false

@sys.description('Required. Whether image pull traffic is routed through the Virtual Network on the App Service. Default: false')
param vnetImagePullEnabled bool = false

@sys.description('Required. Whether all private and public traffic is routed through the Virtual Network. Default: false')
param vnetRouteAllEnabled bool = false

// App Service Variables
var identityType = systemAssignedManagedIdentity ? (!empty(userAssignedManagedIdentity) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedManagedIdentity) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedManagedIdentity) ? userAssignedManagedIdentity : null
} : null

var appSettingsFunctionApp = [
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
  }
  {
    name: 'WEBSITE_CONTENTSHARE'
    value: toLower(name)
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: applicationInsights.properties.InstrumentationKey
  }
]

// Create the App Service
resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  identity: identity
  properties: {
    clientAffinityEnabled: clientAffinityEnabled
    clientCertEnabled: clientCertEnabled
    clientCertExclusionPaths: !empty(clientCertExclusionPaths) ? clientCertExclusionPaths : null
    clientCertMode: clientCertMode
    cloningInfo: !empty(cloningInfo) ? cloningInfo : null
    containerSize: containerSize != -1 ? containerSize : null
    customDomainVerificationId: !empty(customDomainVerificationId) ? customDomainVerificationId : null
    dailyMemoryTimeQuota: dailyMemoryTimeQuota != -1 ? dailyMemoryTimeQuota : null
    enabled: enabled
    hostingEnvironmentProfile: !empty(appServiceEnvironmentResourceId) ? {
      id: appServiceEnvironmentResourceId
    } : null
    hostNamesDisabled: hostNamesDisabled
    hostNameSslStates: hostNameSslStates
    httpsOnly: httpsOnly
    hyperV: hyperV
    keyVaultReferenceIdentity: !empty(keyVaultReferenceIdentity) ? keyVaultReferenceIdentity : null
    publicNetworkAccess: publicNetworkAccess
    redundancyMode: redundancyMode
    reserved: reserved
    scmSiteAlsoStopped: scmSiteAlsoStopped
    serverFarmId: appServicePlanResourceId
    siteConfig: {
      acrUseManagedIdentityCreds: acrUseManagedIdentityCreds
      acrUserManagedIdentityID: !empty(acrUserManagedIdentityID) && acrUseManagedIdentityCreds == true ? acrUserManagedIdentityID : null
      alwaysOn: alwaysOn
      apiDefinition: !empty(apiDefinitionURL) ? {
        url: apiDefinitionURL
      } : null
      apiManagementConfig: !empty(apiManagementConfigId) ? {
        id: apiManagementConfigId
      } : null
      appCommandLine: !empty(appCommandLine) ? appCommandLine : null
      appSettings: kind == 'functionapp' ? appSettingsFunctionApp : appSettings
      autoHealEnabled: autoHealEnabled
      autoHealRules: !empty(autoHealRules) && autoHealEnabled == true ? autoHealRules : null
      autoSwapSlotName: !empty(autoSwapSlotName) ? autoSwapSlotName : null
      azureStorageAccounts: !empty(azureStorageAccounts) ? azureStorageAccounts : null
      connectionStrings: !empty(connectionStrings) ? connectionStrings : null
      cors: !empty(cors) ? cors : null
      defaultDocuments: defaultDocuments
      detailedErrorLoggingEnabled: detailedErrorLoggingEnabled
      documentRoot: !empty(documentRoot) ? documentRoot : null
      experiments: !empty(experiments) ? experiments : null
      ftpsState: ftpsState
      functionAppScaleLimit: functionAppScaleLimit
      functionsRuntimeScaleMonitoringEnabled: functionsRuntimeScaleMonitoringEnabled
      handlerMappings: !empty(handlerMappings) ? handlerMappings : null
      healthCheckPath: !empty(healthCheckPath) ? healthCheckPath : null
      http20Enabled: http20Enabled
      httpLoggingEnabled: httpLoggingEnabled
      ipSecurityRestrictions: ipSecurityRestrictions
      javaContainer: !empty(javaContainer) ? javaContainer : null
      javaContainerVersion: !empty(javaContainerVersion) ? javaContainerVersion : null
      javaVersion: !empty(javaVersion) ? javaVersion : null
      keyVaultReferenceIdentity: !empty(keyVaultReferenceIdentity) ? keyVaultReferenceIdentity : null
      limits: !empty(limits) ? limits : null
      linuxFxVersion: !empty(linuxFxVersion) ? linuxFxVersion : null
      loadBalancing: loadBalancing
      localMySqlEnabled: localMySqlEnabled
      logsDirectorySizeLimit: logsDirectorySizeLimit
      managedPipelineMode: managedPipelineMode
      managedServiceIdentityId: null
      minimumElasticInstanceCount: minimumElasticInstanceCount
      minTlsVersion: minTlsVersion
      netFrameworkVersion: !empty(netFrameworkVersion) ? netFrameworkVersion : null
      nodeVersion: !empty(nodeVersion) ? nodeVersion : null
      numberOfWorkers: numberOfWorkers
      phpVersion: !empty(phpVersion) ? phpVersion : null
      powerShellVersion: !empty(powerShellVersion) ? powerShellVersion : null
      preWarmedInstanceCount: preWarmedInstanceCount
      publicNetworkAccess: publicNetworkAccess
      publishingUsername: !empty(publishingUsername) ? publishingUsername : null
      push: !empty(push) ? push : null
      pythonVersion: !empty(pythonVersion) ? pythonVersion : null
      remoteDebuggingEnabled: remoteDebuggingEnabled
      remoteDebuggingVersion: !empty(remoteDebuggingVersion) && remoteDebuggingEnabled == true ? remoteDebuggingVersion : null
      requestTracingEnabled: requestTracingEnabled
      requestTracingExpirationTime: !empty(requestTracingExpirationTime) && requestTracingEnabled == true ? requestTracingExpirationTime : null
      scmIpSecurityRestrictions: scmIpSecurityRestrictions
      scmIpSecurityRestrictionsUseMain: scmIpSecurityRestrictionsUseMain
      scmMinTlsVersion: scmMinTlsVersion
      scmType: scmType
      tracingOptions: !empty(tracingOptions) ? tracingOptions : null
      use32BitWorkerProcess: use32BitWorkerProcess
      virtualApplications: !empty(virtualApplications) ? virtualApplications : null
      vnetName: !empty(vnetName) ? vnetName : null
      vnetPrivatePortsCount: vnetPrivatePortsCount
      vnetRouteAllEnabled: vnetRouteAllEnabled
      websiteTimeZone: !empty(websiteTimeZone) ? websiteTimeZone : null
      webSocketsEnabled: webSocketsEnabled
      windowsFxVersion: !empty(windowsFxVersion) ? windowsFxVersion : null
      xManagedServiceIdentityId: null
    }
    storageAccountRequired: storageAccountRequired
    virtualNetworkSubnetId: !empty(virtualNetworkSubnetId) ? virtualNetworkSubnetId : null
    vnetContentShareEnabled: vnetContentShareEnabled
    vnetImagePullEnabled: vnetImagePullEnabled
    vnetRouteAllEnabled: vnetRouteAllEnabled
  }
}

// App Service Output
@sys.description('The Resource Group of the App Service.')
output resourceGroupName string = resourceGroup().name

@sys.description('The name of the App Service.')
output name string = appService.name

@sys.description('The resource Id of the App Service.')
output resourceId string = appService.id

@sys.description('The location of the App Service.')
output location string = appService.location
