#!/bin/bash
#
# shellcheck disable=SC2207
# SC2207: Prefer mapfile or read -a to split command output (or quote to avoid splitting).
#         Disabled because we want to split on newlines from deployment output
#
# getSshCommands.sh - retrieves output from a mockSpacestation.bicep deployment
#   and adds the current user to the KeyVault Administrator role
#   and writes the private key to the specified file
#   and outputs to the user the commands to SSH to their machines

set -e

error_log() {
  local message="$1"
  echo "ERROR: $1!" 1>&2;
}

info_log() {
  local message="$1"
  echo "INFO: $message..."
}

# Check for Azure CLI
if ! command -v az &> /dev/null; then
    echo "az could not be found. This script requires the Azure CLI."
    echo "see https://docs.microsoft.com/en-us/cli/azure/install-azure-cli for installation instructions."
    exit 1
fi

# parse arguments
if [[ "$#" -lt 2 ]]; then
   echo "writePrivateKey.sh: retrieves output from a mockSpacestation.bicep deployment and adds the current user to the KeyVault Administrator role and writes the private key to the specified file"
   echo "usage: writePrivateKey.sh <resourceGroupName> <deploymentName>"
   exit 1
fi

resourceGroupName="$1"
deploymentName="$2"

keyvaultRole="Key Vault Administrator"
privateKeyFileName="mockSpacestationPrivateKey"
userAccount=$(az ad signed-in-user show --query '[userPrincipalName]' -o tsv)
# removing trailing character
userAccount=$(echo $userAccount | sed 's/.$//')

# get deployment output
info_log "Querying outputs from deployment $deploymentName into resource group $resourceGroupName"
outputs=($(az deployment group show \
  -g "$resourceGroupName" \
  -n "$deploymentName" \
  --query \
    "[ \
      properties.outputs.groundstationAdminUsername.value, \
      properties.outputs.groundstationHostName.value, \
      properties.outputs.keyvaultName.value, \
      properties.outputs.keyvaultResourceId.value, \
      properties.outputs.privateKeySecretName.value, \
      properties.outputs.spacestationAdminUsername.value, \
      properties.outputs.spacestationHostName.value \
    ]" \
  --output tsv))

# assign values from outputs
groundstationAdminUsername=${outputs[0]}
groundstationHostName=${outputs[1]}
keyvaultName=${outputs[2]}
keyvaultResourceId=${outputs[3]}
# removing carriage return
keyvaultResourceId=$(echo $keyvaultResourceId | sed 's/.$//')
privateKeySecretName=${outputs[4]}
spacestationAdminUsername=${outputs[5]}
spacestationHostName=${outputs[6]}

# add the user to the KeyVault Administrator role
# info_log "Adding $keyvaultRole for current user $userAccount"

az role assignment create \
  --assignee $userAccount \
  --role "Key Vault Administrator" \
  --scope $keyvaultResourceId

# write the private key to the specified file
info_log "Writing $privateKeySecretName to file $privateKeyFileName"
az keyvault secret show \
  --vault-name "$keyvaultName" \
  --name "$privateKeySecretName" \
  --output tsv >> "$privateKeyFileName"

# set the perms on the private key
info_log "Setting permissions on $privateKeySecretName to allow SSH"
chmod 600 "$privateKeyFileName"

# echo out the SSH command
info_log "Success! Private key written to ./$privateKeyFileName. Run these commands to SSH into your machines"
echo "ssh -i $privateKeyFileName $groundstationAdminUsername@$groundstationHostName"
echo "ssh -i $privateKeyFileName $spacestationAdminUsername@$spacestationHostName"
