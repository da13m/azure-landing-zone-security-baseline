@description('Region for workspace')
param location string

@description('Log Analytics workspace name')
param workspaceName string

@description('Workspace SKU')
param sku string = 'PerGB2018'

@description('Retention days 30-730')
param retentionDays int = 90

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output workspaceId string = law.id
