// Resource Group Target Scope
targetScope = 'subscription'

// Generic Parameters
@sys.description('Required. Location of all the Azure resources.')
param location string

// Resource Group Parameters
@sys.description('Required. Name of the Resource Group.')
@minLength(1)
@maxLength(90)
param name string

@sys.description('Optional. Tags of the Resource Group. Default: {}')
param tags object = {}

// Create the Resource Group if it does not exist
resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: name
  location: location
  tags: tags
  managedBy: null
  properties: {}
}

// Resource Group Output
@sys.description('The name of the Resource Group.')
output name string = resourceGroup.name

@sys.description('The resource Id of the Resource Group.')
output resourceId string = resourceGroup.id

@sys.description('The location of the Resource Group.')
output location string = resourceGroup.location
