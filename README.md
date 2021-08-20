# mock-spacestation

A template for deploying a Mock Spacestation and Mock Groundstation to Azure.

## Deploy via Azure Portal

This will use the Azure Custom Template Deployment UI to deploy the Mock Spacestation and Mock Groundstation into a subscription:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fglennmusa%2Fmock-spacestation%2Fmain%2FmockSpacestation.json)

## Deploy via Azure CLI

If you're comfortable with CLI tools, the Azure CLI provides the `deployment` command to deploy the Mock Spacestation and Mock Groundstation to a subscription:

```plaintext
resourceGroupName="myMockSpacestation"
deploymentName="mockSpaceStationDeploy"

az group create \
  --location eastus \
  --name $resourceGroupName

az deployment group create \
  --resource-group $resourceGroupName \
  --name $deploymentName \
  --template-file ./mockSpacestation.json
```

## Accessing VMs

After you've deployed, take note of your Deployment Name (link to how to get this from the portal) and run [./getConnections.sh](./getConnections.sh) passing in the name of your resource group and the deployment name to retrieve the commands to SSH into the deployed VMs:

```plaintext
./getConnections.sh $resourceGroupName $deploymentName
```
