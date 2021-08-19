// largely inspired by
// https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.resources/deployment-script-ssh-key-gen

param location string = resourceGroup().location

param keyvaultName string
param publicKeySecretName string = 'sshPublicKey'
param privateKeySecretName string = 'sshPrivateKey'

param sshKeyGenScriptName string = 'sshKeyGenScript'

var sshKeyGenScript = loadTextContent('./sshKeyGen.sh')

/*var sshKeyGenScript = '''
echo -e \'y\' | ssh-keygen -f scratch -N "" &&
privateKey=$(cat scratch) &&
publicKey=$(cat scratch.pub) &&
json="{\"keyinfo\":{\"privateKey\":\"$privateKey\",\"publicKey\":\"$publicKey\"}}" &&
echo "$json" > "$AZ_SCRIPTS_OUTPUT_PATH"
'''
*/

resource keyvault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyvaultName
}

resource sshKeyGenerationScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: sshKeyGenScriptName
  location: location
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
  parent: keyvault
  name: publicKeySecretName
  properties: {
    value: sshKeyGenerationScript.properties.outputs.keyinfo.publicKey
  }
}

resource privateKeySecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyvault
  name: privateKeySecretName
  properties: {
    value: sshKeyGenerationScript.properties.outputs.keyinfo.privateKey
  }
}

output publicKey string = sshKeyGenerationScript.properties.outputs.keyinfo.publicKey
output privateKeySecretName string = privateKeySecret.name
