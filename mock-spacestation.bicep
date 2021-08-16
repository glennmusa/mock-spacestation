targetScope = 'subscription'

@description('The region to deploy Mock Groundstation resources into')
param groundstationLocation string = 'eastus'

@description('The name for the Mock Spacestation resource group')
param resourceGroupName string = 'mock-spacestation'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: groundstationLocation
}
