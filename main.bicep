@secure()
param adminPassword string = 'YourSecurePassword123!'
param location string = 'eastus'
param adminUsername string = 'azureuser'
param environment string = 'dev'
param owner string = 'jarrod-mills'
param keyVaultName string = 'nwf-kv-${uniqueString(resourceGroup().id)}'
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  tags: {
    environment: environment
    owner: owner
  }
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    accessPolicies: []
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}
 resource adminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'vm-admin-password'
  parent: keyVault
  properties: {
    value: 'YourSecurePassword123!'
  }
}
 resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet-nwf-kv'
  location: location
  tags: {
    environment: environment
    owner: owner
  }
  properties: {
    addressSpace: {
      addressPrefixes: ['10.4.0.0/16']
    }
    subnets: [
      {
        name: 'subnet-app'
        properties: {
          addressPrefix: '10.4.1.0/24'
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'nsg-nwf-kv'
  location: location
  tags: {
    environment: environment
    owner: owner
  }
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Deny-RDP'
        properties: {
          priority: 2000
          access: 'Deny'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: 'nwf-kv-public-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  tags: {
    environment: environment
    owner: owner
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: 'nwf-nic-kv'
  location: location
  tags: {
    environment: environment
    owner: owner
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: 'nwf-vm-kv'
  location: location
  tags: {
    environment: environment
    owner: owner
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'nwf-vm-kv'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
