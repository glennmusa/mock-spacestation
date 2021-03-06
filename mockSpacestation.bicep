//////////
// CONSTS
//////////

// Administrator Values
var adminUsername = 'azureuser'

// SSH Key Generation Script Values
var generateSshKeyScriptContent = loadTextContent('./scripts/generateSshKey.sh')
var generateSshKeyScriptName = 'generateSshKey'

// KeyVault Values
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

resource generateSshKeyScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: generateSshKeyScriptName
  location: resourceGroup().location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.25.0'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D' // retain script for 1 day
    scriptContent: generateSshKeyScriptContent
    timeout: 'PT30M' // timeout after 30 minutes
  }
}

resource publicKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyvault.name}/${publicKeySecretName}'
  properties: {
    value: generateSshKeyScript.properties.outputs.keyinfo.publicKey
  }
}

resource privateKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyvault.name}/${privateKeySecretName}'
  properties: {
    value: generateSshKeyScript.properties.outputs.keyinfo.privateKey
  }
}

module groundstation 'modules/linuxVirtualMachine.bicep' = {
  name: 'mockGroundstationVm'
  params: {
    adminUsername: adminUsername
    location: groundstationLocation
    sshPrivateKey: generateSshKeyScript.properties.outputs.keyinfo.privateKey
    sshPublicKey: generateSshKeyScript.properties.outputs.keyinfo.publicKey
    virtualMachineName: groundstationVirtualMachineName
  }
}

module spacestation 'modules/linuxVirtualMachine.bicep' = {
  name: 'mockSpacestationVm'
  params: {
    adminUsername: adminUsername
    location: spacestationLocation
    hostToSync: groundstation.outputs.hostName
    sshPrivateKey: generateSshKeyScript.properties.outputs.keyinfo.privateKey
    sshPublicKey: generateSshKeyScript.properties.outputs.keyinfo.publicKey
    virtualMachineName: spacestationVirtualMachineName
  }
}

//////////
// OUTPUT
//////////

output generateSshKeyScriptName string = generateSshKeyScriptName
output groundstationAdminUsername string = adminUsername
output groundstationHostName string = groundstation.outputs.hostName
output keyvaultName string = keyvault.name
output privateKeySecretName string = privateKeySecretName
output spacestationAdminUsername string = adminUsername
output spacestationHostName string = spacestation.outputs.hostName
