//////////
// CONSTS
//////////

// Administrator Parameters
var adminUsername = 'azureuser'

// SSH Key Parameters
var keyvaultName = toLower('mockisskv${uniqueString(resourceGroup().id)}')
var keyvaultTenantId = subscription().tenantId
var privateKeySecretName = 'sshPrivateKey'
var publicKeySecretName = 'sshPublicKey'

//////////
// PARAMS
//////////

// Groundstation Parameters
@description('The name of the Mock Groundstation Virtual Machine')
param groundstationVirtualMachineName string = 'mockGroundstation'
@description('The region to deploy Mock Groundstation resources into')
param groundstationLocation string = 'eastus'

// Spacestation Parameters
@description('The name of the Mock Spacestation Virtual Machine')
param spacestationVirtualMachineName string = 'mockSpacestation'
@description('The region to deploy Mock Spacestation resources into')
param spacestationLocation string = 'australiaeast'

//////////
// MAIN
//////////

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyvaultName
  location: resourceGroup().location
  properties: {
    accessPolicies: []
    enabledForDeployment: true
    enabledForTemplateDeployment: true
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
    publicKeySecretName: publicKeySecretName
    privateKeySecretName: privateKeySecretName
  }
}

module groundstation 'modules/linuxVirtualMachine.bicep' = {
  name: 'mockGroundstationVm'
  params: {
    adminUsername: adminUsername
    location: groundstationLocation
    sshPublicKey: keyvault.getSecret(publicKeySecretName)
    virtualMachineName: groundstationVirtualMachineName
  }
}

module spacestation 'modules/linuxVirtualMachine.bicep' = {
  name: 'mockSpacestationVm'
  params: {
    adminUsername: adminUsername
    location: spacestationLocation
    sshPublicKey: keyvault.getSecret(publicKeySecretName)
    virtualMachineName: spacestationVirtualMachineName
  }
}

//////////
// OUTPUT
//////////

output keyvaultName string = keyvault.name
output privateKeySecretName string = sshKey.outputs.privateKeySecretName
