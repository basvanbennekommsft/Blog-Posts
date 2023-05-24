// Scheduled Query Rule Target Scope
targetScope = 'resourceGroup'

// Generic Parameters
@sys.description('Optional. Location of all the Azure resources.')
param location string = resourceGroup().location

// Scheduled Query Rule Parameters
@sys.description('Required. Name of the Scheduled Query Rule.')
param scheduledRuleQueryName string

@sys.description('Optional. Kind of the Scheduled Query Rule.')
param kind string = 'LogAlert'

@sys.description('Required. Id of the Action Group used by the Scheduled Query Rule.')
param actionGroupId string

@sys.description('Required. Whether the Scheduled Query Rule needs to be mitigated automatically.')
param autoMitigate bool

@sys.description('Required. Whether the Scheduled Query Rule needs to be stored.')
param checkWorkspaceAlertsStorageConfigured bool

@sys.description('Required. Number of violations to trigger the Scheduled Query Rule.')
param minFailingPeriodsToAlert int

@sys.description('Required. Number of aggregated lookback points of the Scheduled Query Rule.')
param numberOfEvaluationPeriods int

@sys.description('Required. Operator of the Scheduled Query Rule.')
param operator string

@sys.description('Required. Query of the Scheduled Query Rule.')
param query string

@sys.description('Required. Resource Id Column of the Scheduled Query Rule.')
param resourceIdColumn string

@sys.description('Required. Threshold of the Scheduled Query Rule.')
param threshold int

@sys.description('Required. Time Aggregation of the Scheduled Query Rule.')
param timeAggregation string

@sys.description('Required. Description of the Scheduled Query Rule.')
param scheduledRuleQueryDescription string

@sys.description('Optional. Whether the Scheduled Query Rule is enabled.')
param enabled bool = true

@sys.description('Required. Evaluation frequency of the Scheduled Query Rule.')
param evaluationFrequency string

@sys.description('Required. Id of the Log Analytics Workspace to which the Scheduled Query Rule is scoped.')
param logAnalyticsWorkspaceId string

@sys.description('Required. Severity of the Scheduled Query Rule.')
param severity int

@sys.description('Optional. Whether the provided query of the Scheduled Query Rule should be validated.')
param skipQueryValidation bool = false

@sys.description('Required. Window size of the Scheduled Query Rule.')
param windowSize string

// Create the Scheduled Query Rule if it does not exist
resource scheduledQueryRule 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
  name: scheduledRuleQueryName
  location: location
  tags: {}
  kind: kind
  properties: {
    actions: {
      actionGroups: [
        actionGroupId
      ]
      customProperties: {}
    }
    autoMitigate: autoMitigate
    checkWorkspaceAlertsStorageConfigured: checkWorkspaceAlertsStorageConfigured
    criteria: {
      allOf: [
        {
          dimensions: []
          failingPeriods: {
            minFailingPeriodsToAlert: minFailingPeriodsToAlert
            numberOfEvaluationPeriods: numberOfEvaluationPeriods
          }
          operator: operator
          query: query
          resourceIdColumn: resourceIdColumn
          threshold: threshold
          timeAggregation: timeAggregation
        }
      ]
    }
    description: scheduledRuleQueryDescription
    displayName: scheduledRuleQueryName
    enabled: enabled
    evaluationFrequency: evaluationFrequency
    scopes: [
      logAnalyticsWorkspaceId
    ]
    severity: severity
    skipQueryValidation: skipQueryValidation
    targetResourceTypes: []
    windowSize: windowSize
  }
}

// Scheduled Query Rule Output
@sys.description('The Resource Group of the Scheduled Query Rule.')
output resourceGroupName string = resourceGroup().name

@sys.description('The name of the Scheduled Query Rule.')
output name string = scheduledQueryRule.name

@sys.description('The resource Id of the Scheduled Query Rule.')
output resourceId string = scheduledQueryRule.id

@sys.description('The location of the Scheduled Query Rule.')
output location string = scheduledQueryRule.location
