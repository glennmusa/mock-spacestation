//////////
// PARAMS
//////////

// Administrator Parameters
@description('Username for the Virtual Machine.')
param adminUsername string
@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'
@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

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

//////////
// MAIN
//////////

module groundstation 'modules/linuxVirtualMachine.bicep' = {
  name: 'mockGroundstationVm'
  params: {
    adminPasswordOrKey: adminPasswordOrKey
    adminUsername: adminUsername
    authenticationType: authenticationType
    location: groundstationLocation
    vmName: groundstationVmName
  }
}

module spacestation 'modules/linuxVirtualMachine.bicep' = {
  name: 'mockSpacestationVm'
  params: {
    adminPasswordOrKey: adminPasswordOrKey
    adminUsername: adminUsername
    authenticationType: authenticationType
    location: spacestationLocation
    vmName: spacestationVmName
  }
}
