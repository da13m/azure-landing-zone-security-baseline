@description('Region')
param location string

@description('Workspace resource ID')
param workspaceId string

@description('Workspace name')
param workspaceName string

// Historically, enabling Sentinel is deploying the "SecurityInsights" solution
resource sentinel 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(' + workspaceName + ')'
  location: location
  properties: {
    workspaceResourceId: workspaceId
  }
  plan: {
    name: 'SecurityInsights'
    publisher: 'Microsoft'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
  }
}
