//////////
// CONSTS
//////////

// Administrator Values
var adminUsername = 'azureuser'

// SSH Key Values
var keyvaultName = toLower('mockisskv${uniqueString(resourceGroup().id)}')
var keyvaultTenantId = subscription().tenantId
var privateKeySecretName = 'sshPrivateKey'
var publicKeySecretName = 'sshPublicKey'

// SSH Key Generation Script Values
var sshKeyGenScriptName = 'sshKeyGenScript'
var sshKeyGenScript = loadTextContent('./scripts/sshKeyGen.sh')

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

resource sshKeyGenerationScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: sshKeyGenScriptName
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.25.0'
    cleanupPreference: 'OnSuccess'
    scriptContent: sshKeyGenScript
    retentionInterval: 'P1D' // retain script for 1 day
    timeout: 'PT30M' // timeout after 30 minutes
  }
}

resource publicKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyvault.name}/${publicKeySecretName}'
  properties: {
    value: sshKeyGenerationScript.properties.outputs.keyinfo.publicKey
  }
}

resource privateKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyvault.name}/${privateKeySecretName}'
  properties: {
    value: sshKeyGenerationScript.properties.outputs.keyinfo.privateKey
  }
}

module groundstation 'modules/linuxVirtualMachine.bicep' = {
  name: 'mockGroundstationVm'
  params: {
    adminUsername: adminUsername
    location: groundstationLocation
    sshPrivateKey: sshKeyGenerationScript.properties.outputs.keyinfo.privateKey
    sshPublicKey: sshKeyGenerationScript.properties.outputs.keyinfo.publicKey
    virtualMachineName: groundstationVirtualMachineName
  }
}

module spacestation 'modules/linuxVirtualMachine.bicep' = {
  name: 'mockSpacestationVm'
  params: {
    adminUsername: adminUsername
    location: spacestationLocation
    hostToSync: groundstation.outputs.hostName
    sshPrivateKey: sshKeyGenerationScript.properties.outputs.keyinfo.privateKey
    sshPublicKey: sshKeyGenerationScript.properties.outputs.keyinfo.publicKey
    virtualMachineName: spacestationVirtualMachineName
  }
}

//////////
// OUTPUT
//////////

output groundstationAdminUsername string = adminUsername
output groundstationHostName string = groundstation.outputs.hostName
output keyvaultName string = keyvault.name
output privateKeySecretName string = privateKeySecretName
output spacestationAdminUsername string = adminUsername
output spacestationHostName string = spacestation.outputs.hostName
output sshKeyGenScriptName string = sshKeyGenScriptName
