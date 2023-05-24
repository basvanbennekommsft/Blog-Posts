// Storage Account Target Scope
targetScope = 'resourceGroup'

// Generic Parameters
@sys.description('Optional. Location of all the Azure resources. Default: resourceGroup().location')
param location string = resourceGroup().location

// Storage Account Parameters
@sys.description('Required. Name of the Storage Account.')
@minLength(3)
@maxLength(24)
param name string

@sys.description('Optional. Tags of the Storage Account. Default: {}')
param tags object = {}

@sys.description('Required. Name of the SKU of the Storage Account.')
param skuName string

@sys.description('Required. Kind of the Storage Account.')
param kind string

@sys.description('Optional. Whether the System-assigned Managed Identity functionality is enabled on the Storage Account. Default: false')
param systemAssignedManagedIdentity bool = false

@sys.description('Optional. Id of the User-assigned Managed Identity if it is enabled on the Storage Account. Default: {}')
param userAssignedManagedIdentity object = {}

@sys.description('Required. Access tier of the Storage Account.')
param accessTier string

@sys.description('Optional. Whether the blob public access functionality is enabled on the Storage Account. Default: false')
param allowBlobPublicAccess bool = false

@sys.description('Optional. Whether the cross tenant replication functionality is enabled on the Storage Account. Default: false')
param allowCrossTenantReplication bool = false

@sys.description('Required. Whether Storage Account content can be copied to and from an Azure Active Directory Tenant or a Virtual Network.')
param allowedCopyScope string

@sys.description('Optional. Whether the shared key access functionality is enabled on the Storage Account. Default: false')
param allowSharedKeyAccess bool = false

@sys.description('Optional. Identity-based authentication settings for Azure Files on the Storage Account. Default: {}')
param azureFilesIdentityBasedAuthentication object = {}

@sys.description('Optional. Custom domain of the Storage Account. Default: {}')
param customDomain object = {}

@sys.description('Optional. Whether the default to OAuth authentication functionality is enabled on the Storage Account. Default: false')
param defaultToOAuthAuthentication bool = false

@sys.description('Optional. DNS endpoint type of the Storage Account. Default: Standard')
param dnsEndpointType string = 'Standard'

@sys.description('Optional. Identity used for customer-managed data at rest encryption on the Storage Account. Default: {}')
param encryptionIdentity object = {}

@sys.description('Optional. Key source used for data at rest encryption on the Storage Account. Default: Microsoft.Storage')
param encryptionKeySource string = 'Microsoft.Storage'

@sys.description('Optional. Key Vault properties used for customer-managed data at rest encryption on the Storage Account. Default: {}')
param encryptionKeyVaultproperties object = {}

@sys.description('Optional. Whether the infrastructure encryption functionality is enabled on the Storage Account. Default: true')
param requireInfrastructureEncryption bool = true

@sys.description('Required. Encryption settings for Azure Blobs on the Storage Account.')
param encryptionServicesBlobSettings object

@sys.description('Required. Encryption settings for Azure Files on the Storage Account.')
param encryptionServicesFileSettings object

@sys.description('Required. Encryption settings for Azure Tables on the Storage Account.')
param encryptionServicesTableSettings object

@sys.description('Required. Encryption settings for Azure Queues on the Storage Account.')
param encryptionServicesQueueSettings object

@sys.description('Optional. Whether the immutable storage with versioning functionality is enabled on the Storage Account. Default: {}')
param immutableStorageWithVersioning object = {}

@sys.description('Optional. Whether the hierarchical namespace functionality is enabled on the Storage Account. Default: false')
param isHnsEnabled bool = false

@sys.description('Optional. Whether the local user functionality is enabled on the Storage Account. Default: false')
param isLocalUserEnabled bool = false

@sys.description('Optional. Whether the NFS 3.0 protocol support functionality is enabled on the Storage Account. Default: false')
param isNfsV3Enabled bool = false

@sys.description('Optional. Whether the SFTP support functionality is enabled on the Storage Account. Default: false')
param isSftpEnabled bool = false

@sys.description('Optional. Whether the key policy functionality is enabled on the Storage Account. Default: {}')
param keyPolicy object = {}

@sys.description('Optional. Large file share state of the Storage Account. Default: Disabled')
param largeFileSharesState string = 'Disabled'

@sys.description('Optional. Minimum TLS version of the Storage Account. Default: TLS1_2')
param minimumTlsVersion string = 'TLS1_2'

@sys.description('Optional. Network bypass configuration of the Storage Account. Default: None')
param networkAclsBypass string = 'None'

@sys.description('Optional. Network default action configuration of the Storage Account. Default: Deny')
param networkAclsDefaultAction string = 'Deny'

@sys.description('Optional. Network IP rule configuration of the Storage Account. Default: []')
param networkAclsIPRules array = []

@sys.description('Optional. Network resource access rule configuration of the Storage Account. Default: []')
param networkAclsResourceAccessRules array = []

@sys.description('Optional. Network virtual network rule configuration of the Storage Account. Default: []')
param networkAclsvirtualNetworkRules array = []

@sys.description('Optional. Public network access configuration of the Storage Account. Default: Enabled')
param publicNetworkAccess string = 'Enabled'

@sys.description('Optional. Routing routing preference of the Storage Account. Default: {}')
param routingPreference object = {}

@sys.description('Optional. SAS policy of the Storage Account. Default: {}')
param sasPolicy object = {}

@sys.description('Optional. Whether the support HTTPS only traffic functionality is enabled on the Storage Account. Default: true')
param supportsHttpsTrafficOnly bool = true

// Storage Account Variables
var identityType = systemAssignedManagedIdentity ? (!empty(userAssignedManagedIdentity) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedManagedIdentity) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedManagedIdentity) ? userAssignedManagedIdentity : null
} : null

var supportBlobEncryption = kind == 'BlockBlobStorage' || kind == 'BlobStorage' || kind == 'StorageV2' || kind == 'Storage'

var supportFileEncryption = kind == 'FileStorage' || kind == 'StorageV2' || kind == 'Storage'

// Create the Storage Account if it does not exist
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: kind
  extendedLocation: null
  identity: identity
  properties: {
    accessTier: kind != 'Storage' ? accessTier : null
    allowBlobPublicAccess: allowBlobPublicAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    allowedCopyScope: allowedCopyScope
    allowSharedKeyAccess: allowSharedKeyAccess
    azureFilesIdentityBasedAuthentication: !empty(azureFilesIdentityBasedAuthentication) ? azureFilesIdentityBasedAuthentication : null
    customDomain: !empty(customDomain) ? customDomain : null
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    dnsEndpointType: dnsEndpointType
    encryption: {
      identity: encryptionKeySource == 'Microsoft.Keyvault' ? !empty(encryptionIdentity) ? encryptionIdentity : null : null
      keySource: encryptionKeySource
      keyvaultproperties: encryptionKeySource == 'Microsoft.Keyvault' ? !empty(encryptionKeyVaultproperties) ? encryptionKeyVaultproperties : null : null
      requireInfrastructureEncryption: kind != 'Storage' ? requireInfrastructureEncryption : null
      services: {
        blob: supportBlobEncryption ? encryptionServicesBlobSettings : null
        file: supportFileEncryption ? encryptionServicesFileSettings : null
        table: encryptionServicesTableSettings
        queue: encryptionServicesQueueSettings
      }
    }
    immutableStorageWithVersioning: !empty(immutableStorageWithVersioning) ? immutableStorageWithVersioning : null
    isHnsEnabled: isHnsEnabled
    isLocalUserEnabled: isLocalUserEnabled
    isNfsV3Enabled: isHnsEnabled == true ? isNfsV3Enabled : null
    isSftpEnabled: isHnsEnabled == true ? isSftpEnabled : null
    keyPolicy: allowSharedKeyAccess == true ? !empty(keyPolicy) ? keyPolicy : null : null
    largeFileSharesState: largeFileSharesState
    minimumTlsVersion: minimumTlsVersion
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
      ipRules: networkAclsDefaultAction == 'Deny' ? publicNetworkAccess == 'Enabled' ? !empty(networkAclsIPRules) ? networkAclsIPRules : null : null : null
      resourceAccessRules: networkAclsDefaultAction == 'Deny' ? publicNetworkAccess == 'Enabled' ? !empty(networkAclsResourceAccessRules) ? networkAclsResourceAccessRules : null : null : null
      virtualNetworkRules: networkAclsDefaultAction == 'Deny' ? publicNetworkAccess == 'Enabled' ? !empty(networkAclsvirtualNetworkRules) ? networkAclsvirtualNetworkRules : null : null : null
    }
    publicNetworkAccess: publicNetworkAccess
    routingPreference: !empty(routingPreference) ? routingPreference : null
    sasPolicy: !empty(sasPolicy) ? sasPolicy : null
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
  }
}

// Storage Account Output
@sys.description('The Resource Group of the Storage Account.')
output resourceGroupName string = resourceGroup().name

@sys.description('The name of the Storage Account.')
output name string = storageAccount.name

@sys.description('The resource Id of the Storage Account.')
output resourceId string = storageAccount.id

@sys.description('The location of the Storage Account.')
output location string = storageAccount.location
