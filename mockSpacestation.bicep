//////////
// PARAMS
//////////

// Administrator Parameters
var adminUsername = 'azureuser'

// Groundstation Parameters
@description('The name of the Mock Groundstation Virtual Machine')
param groundstationVmName string = 'mockGroundstation'
@description('The region to deploy Mock Groundstation resources into')
param groundstationLocation string = 'eastus'

// Spacestation Parameters
@description('The region to deploy Mock Spacestation resources into')
param spacestationLocation string = 'australiaeast'
@description('The name of the Mock Spacestation Virtual Machine')
param spacestationVmName string = 'mockSpacestation'

// SSH Key Parameters
var keyvaultName = toLower('mockisskv${uniqueString(resourceGroup().id)}')
var keyvaultTenantId = subscription().tenantId

//////////
// MAIN
//////////

resource keyvault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyvaultName
  location: resourceGroup().location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: false
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: keyvaultTenantId
  }
}

module sshKey 'modules/sshKey.bicep' = {
  name: 'sshKey'
  params: {
    keyvaultName: keyvault.name
  }
}

module groundstation 'modules/linuxVirtualMachine.bicep' = {
  name: 'mockGroundstationVm'
  params: {
    adminUsername: adminUsername
    sshPublicKey: sshKey.outputs.publicKey
    location: groundstationLocation
    vmName: groundstationVmName
  }
}

module spacestation 'modules/linuxVirtualMachine.bicep' = {
  name: 'mockSpacestationVm'
  params: {
    adminUsername: adminUsername
    sshPublicKey: sshKey.outputs.publicKey
    location: spacestationLocation
    vmName: spacestationVmName
  }
}

output keyvaultResourceId string = keyvault.id
output keyvaultName string = keyvault.name
output privateKeySecretName string = sshKey.outputs.privateKeySecretName

output groundstationAdminUsername string = adminUsername
output groundstationHostName string = groundstation.outputs.hostName

output spacestationAdminUsername string = adminUsername
output spacestationHostName string = spacestation.outputs.hostName
