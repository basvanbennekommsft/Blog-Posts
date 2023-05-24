// Define the Target Scope
targetScope = 'subscription'

// Generic Parameters
@sys.description('Required. Id of the Subscription that hosts all the Azure resources.')
param subscriptionId string

@sys.description('Optional. Location of all the Azure resources.')
param location string = 'westeurope'

// Generic Variables
@sys.description('Naming convention prefix, used to build the names of most Azure services.')
var standardNamingConventionPrefix = '<REPLACE>'

@sys.description('Naming convention prefix, used to build the name of the Storage Account.')
var specialNamingConventionPrefix = '<REPLACE>'

// Create the Resource Group hosting the resources
module resourceGroupDeployment '../../modules/resourceGroups.bicep' = {
    scope: subscription(subscriptionId)
    name: '${standardNamingConventionPrefix}-01-rg'
    params: {
        location: location
        name: '${standardNamingConventionPrefix}-01-rg'
    }
}

// Storage Account Parameters
@sys.description('Required. Object of the Storage Account.')
param storageAccount object

// Create the Storage Account
module storageAccountDeployment '../../modules/storageAccount.bicep' = {
    scope: resourceGroup(subscriptionId, resourceGroupDeployment.name)
    name: '${specialNamingConventionPrefix}01sa'
    params: {
        location: location
        name: '${specialNamingConventionPrefix}01sa'
        skuName: storageAccount.skuName
        kind: storageAccount.kind
        accessTier: storageAccount.accessTier
        allowBlobPublicAccess: storageAccount.allowBlobPublicAccess
        allowedCopyScope: storageAccount.allowedCopyScope
        allowSharedKeyAccess: storageAccount.allowSharedKeyAccess
        defaultToOAuthAuthentication: storageAccount.defaultToOAuthAuthentication
        encryptionServicesBlobSettings: storageAccount.encryptionServicesBlobSettings
        encryptionServicesFileSettings: storageAccount.encryptionServicesFileSettings
        encryptionServicesQueueSettings: storageAccount.encryptionServicesQueueSettings
        encryptionServicesTableSettings: storageAccount.encryptionServicesTableSettings
        networkAclsBypass: storageAccount.networkAclsBypass
        networkAclsDefaultAction: storageAccount.networkAclsDefaultAction
    }
}

// Application Insights Parameters
@sys.description('Required. Object of the Application Insights.')
param applicationInsights object

// Create the Application Insights
module applicationInsightsDeployment '../../modules/components.bicep' = {
    scope: resourceGroup(subscriptionId, resourceGroupDeployment.name)
    name: '${standardNamingConventionPrefix}-01-ai'
    params: {
        location: location
        name: '${standardNamingConventionPrefix}-01-ai'
        kind: applicationInsights.kind
        ingestionMode: applicationInsights.ingestionMode
        retentionInDays: applicationInsights.retentionInDays
        samplingPercentage: applicationInsights.samplingPercentage
        workspaceResourceId: applicationInsights.workspaceResourceId
    }
}

// App Service Plan Parameters
@sys.description('Required. Object of the App Service Plan.')
param appServicePlan object

// Create the App Service Plan
module appServicePlanDeployment '../../modules/serverFarms.bicep' = {
    scope: resourceGroup(subscriptionId, resourceGroupDeployment.name)
    name: '${standardNamingConventionPrefix}-01-asp'
    params: {
        location: location
        name: '${standardNamingConventionPrefix}-01-asp'
        sku: appServicePlan.sku
        kind: appServicePlan.kind
        maximumElasticWorkerCount: appServicePlan.maximumElasticWorkerCount
        targetWorkerCount: appServicePlan.targetWorkerCount
        targetWorkerSizeId: appServicePlan.targetWorkerSizeId
        zoneRedundant: appServicePlan.zoneRedundant
    }
}

// Function App Parameters
@sys.description('Required. Object of the Function App.')
param functionApp object

// Create the Function App
module functionAppDeployment '../../modules/sites.bicep' = {
    scope: resourceGroup(subscriptionId, resourceGroupDeployment.name)
    name: '${standardNamingConventionPrefix}-01-fa'
    params: {
        storageAccountName: storageAccountDeployment.outputs.name
        applicationInsightsName: applicationInsightsDeployment.outputs.name
        name: '${standardNamingConventionPrefix}-01-fa'
        location: location
        kind: functionApp.kind
        systemAssignedManagedIdentity: functionApp.systemAssignedManagedIdentity
        containerSize: functionApp.containerSize
        dailyMemoryTimeQuota: functionApp.dailyMemoryTimeQuota
        appServicePlanResourceId: appServicePlanDeployment.outputs.resourceId
        appSettings: functionApp.appSettings
        cors: functionApp.cors
        defaultDocuments: functionApp.defaultDocuments
        functionAppScaleLimit: functionApp.functionAppScaleLimit
        ipSecurityRestrictions: functionApp.ipSecurityRestrictions
        loadBalancing: functionApp.loadBalancing
        logsDirectorySizeLimit: functionApp.logsDirectorySizeLimit
        minimumElasticInstanceCount: functionApp.minimumElasticInstanceCount
        netFrameworkVersion: functionApp.netFrameworkVersion
        numberOfWorkers: functionApp.numberOfWorkers
        powerShellVersion: functionApp.powerShellVersion
        preWarmedInstanceCount: functionApp.preWarmedInstanceCount
        scmIpSecurityRestrictions: functionApp.scmIpSecurityRestrictions
        scmType: functionApp.scmType
        vnetPrivatePortsCount: functionApp.vnetPrivatePortsCount
        vnetContentShareEnabled: functionApp.vnetContentShareEnabled
        vnetImagePullEnabled: functionApp.vnetImagePullEnabled
        vnetRouteAllEnabled: functionApp.vnetRouteAllEnabled
    }
}
