// Define the Target Scope
targetScope = 'resourceGroup'

// Generic Parameters
@sys.description('Required. Id of the Subscription that hosts all the Azure resources.')
param subscriptionId string

@sys.description('Optional. Location of all the Azure resources.')
param location string = 'westeurope'

@sys.description('Required. Name of the Function.')
param functionName string

// Generic Variables
@sys.description('Naming convention prefix, used to build the names of most Azure services.')
var standardNamingConventionPrefix = 'tech-community-blog'

// Retrieve the existing Resource Group
resource existingResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
    scope: subscription(subscriptionId)
    name: '${standardNamingConventionPrefix}-01-rg'
}

// Retrieve the existing Function App
resource existingFunctionApp 'Microsoft.Web/sites@2022-09-01' existing = {
    scope: resourceGroup(subscriptionId, existingResourceGroup.name)
    name: '${standardNamingConventionPrefix}-01-fa'
}

// Retrieve the existing Function
resource existingFunction 'Microsoft.Web/sites/functions@2022-09-01' existing = {
    parent: existingFunctionApp
    name: functionName
}

// Retrieve the Default Key of the existing Function
var existingFunctionKey = listKeys('${existingFunction.id}', '2021-02-01').default

// Action Group Parameters
@sys.description('Required. Object of the Action Group.')
param actionGroup object

// Create the Action Group
module actionGroupDeployment '../../modules/actionGroup.bicep' = {
    scope: resourceGroup(subscriptionId, existingResourceGroup.name)
    name: '${standardNamingConventionPrefix}-01-ag'
    params: {
        location: 'Global'
        actionGroupName: '${standardNamingConventionPrefix}-01-ag'
        actionGroupShortName: actionGroup.actionGroupShortName
        azureFunctionReceivers: [
            {
                functionAppResourceId: existingFunctionApp.id
                functionName: existingFunction.name
                httpTriggerUrl: 'https://${existingFunctionApp.name}.azurewebsites.net/api/${existingFunction.name}?code=${existingFunctionKey}'
                name: '${existingFunction.name}-receiver'
                useCommonAlertSchema: true
            }
        ]
    }
}

// Scheduled Query Rule Parameters (unauthorized Role Assignments)
@sys.description('Required. Object of the Action Group.')
param scheduledQueryRuleUnauthorizedRoleAssignments object

// Create the Scheduled Query Rule (unauthorized Role Assignments)
module scheduledQueryRuleUnauthorizedRoleAssignmentsDeployment '../../modules/scheduledQueryRules.bicep' = {
    scope: resourceGroup(subscriptionId, existingResourceGroup.name)
    name: '${standardNamingConventionPrefix}-01-qr'
    params: {
        location: location
        scheduledRuleQueryName: '${standardNamingConventionPrefix}-01-qr'
        actionGroupId: actionGroupDeployment.outputs.resourceId
        autoMitigate: scheduledQueryRuleUnauthorizedRoleAssignments.autoMitigate
        checkWorkspaceAlertsStorageConfigured: scheduledQueryRuleUnauthorizedRoleAssignments.checkWorkspaceAlertsStorageConfigured
        minFailingPeriodsToAlert: scheduledQueryRuleUnauthorizedRoleAssignments.minFailingPeriodsToAlert
        numberOfEvaluationPeriods: scheduledQueryRuleUnauthorizedRoleAssignments.numberOfEvaluationPeriods
        operator: scheduledQueryRuleUnauthorizedRoleAssignments.operator
        query: scheduledQueryRuleUnauthorizedRoleAssignments.query
        resourceIdColumn: scheduledQueryRuleUnauthorizedRoleAssignments.resourceIdColumn
        threshold: scheduledQueryRuleUnauthorizedRoleAssignments.threshold
        timeAggregation: scheduledQueryRuleUnauthorizedRoleAssignments.timeAggregation
        scheduledRuleQueryDescription: scheduledQueryRuleUnauthorizedRoleAssignments.scheduledRuleQueryDescription
        evaluationFrequency: scheduledQueryRuleUnauthorizedRoleAssignments.evaluationFrequency
        logAnalyticsWorkspaceId: scheduledQueryRuleUnauthorizedRoleAssignments.logAnalyticsWorkspaceId
        severity: scheduledQueryRuleUnauthorizedRoleAssignments.severity
        windowSize: scheduledQueryRuleUnauthorizedRoleAssignments.windowSize
    }
}
