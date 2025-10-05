@description('Target resource ID for diagnostics (e.g., subscription ID, resource group ID, or resource ID)')
param targetResourceId string

@description('Log Analytics workspace resource ID')
param workspaceId string

@description('Array of log categories to enable')
param logsToEnable array = []

resource diag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-law'
  scope: resourceId(targetResourceId)
  properties: {
    workspaceId: workspaceId
    logs: [for c in logsToEnable: {
      category: c
      enabled: true
      retentionPolicy: {
        days: 0
        enabled: false
      }
    }]
    metrics: []
  }
}
