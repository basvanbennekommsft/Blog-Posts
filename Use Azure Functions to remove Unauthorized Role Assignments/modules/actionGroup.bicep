// Action Group Target Scope
targetScope = 'resourceGroup'

// Generic Parameters
@sys.description('Optional. Location of all the Azure resources. Default: resourceGroup().location')
param location string = resourceGroup().location

// Action Group Parameters
@sys.description('Required. Name of the Action Group.')
@minLength(1)
@maxLength(260)
param actionGroupName string

@sys.description('Required. Short name of the Action Group.')
param actionGroupShortName string

@sys.description('Optional. Whether the Action Group is enabled. Default: true')
param enabled bool = true

@sys.description('Optional. The ARM role receivers of the Action Group. Default: []')
param armRoleReceivers array = []

@sys.description('Optional. The Automation Account receivers of the Action Group. Default: []')
param automationRunbookReceivers array = []

@sys.description('Optional. The Azure Push receivers of the Action Group. Default: []')
param azureAppPushReceivers array = []

@sys.description('Optional. The Azure Function receivers of the Action Group. Default: []')
param azureFunctionReceivers array = []

@sys.description('Optional. The email receivers of the Action Group. Default: []')
param emailReceivers array = []

@sys.description('Optional. The ITSM receivers of the Action Group. Default: []')
param itsmReceivers array = []

@sys.description('Optional. The Logic App receivers of the Action Group. Default: []')
param logicAppReceivers array = []

@sys.description('Optional. The sms receivers of the Action Group. Default: []')
param smsReceivers array = []

@sys.description('Optional. The voice receivers of the Action Group. Default: []')
param voiceReceivers array = []

@sys.description('Optional. The webhook receivers of the Action Group. Default: []')
param webhookReceivers array = []

// Create the Action Group if it does not exist
resource actionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = {
  name: actionGroupName
  location: location
  tags: {}
  properties: {
    groupShortName: actionGroupShortName
    enabled: enabled
    armRoleReceivers: !empty(armRoleReceivers) ? armRoleReceivers : null
    automationRunbookReceivers: !empty(automationRunbookReceivers) ? automationRunbookReceivers : null
    azureAppPushReceivers: !empty(azureAppPushReceivers) ? azureAppPushReceivers : null
    azureFunctionReceivers: !empty(azureFunctionReceivers) ? azureFunctionReceivers : null
    emailReceivers: !empty(emailReceivers) ? emailReceivers : null
    itsmReceivers: !empty(itsmReceivers) ? itsmReceivers : null
    logicAppReceivers: !empty(logicAppReceivers) ? logicAppReceivers : null
    smsReceivers: !empty(smsReceivers) ? smsReceivers : null
    voiceReceivers: !empty(voiceReceivers) ? voiceReceivers : null
    webhookReceivers: !empty(webhookReceivers) ? webhookReceivers : null
  }
}

// Action Group Output
@sys.description('The Resource Group of the Action Group.')
output resourceGroupName string = resourceGroup().name

@sys.description('The name of the Action Group.')
output name string = actionGroup.name

@sys.description('The resource Id of the Action Group.')
output resourceId string = actionGroup.id

@sys.description('The location of the Action Group.')
output location string = actionGroup.location
