targetScope = 'subscription'

@description('Azure region for resource group and workspace')
param location string = 'eastus'

@description('Resource group to contain monitoring resources')
param rgName string = 'rg-sec-landing-zone'

@description('Log Analytics workspace name')
param workspaceName string = 'law-sec-landing-zone'

@description('Log Analytics SKU: PerGB2018 or CapacityReservation[_xGB]')
@allowed([
  'PerGB2018'
])
param lawSku string = 'PerGB2018'

@minValue(30)
@maxValue(730)
@description('Log Analytics retention in days')
param lawRetentionDays int = 90

@description('Enable Microsoft Sentinel on the workspace')
param enableSentinel bool = true

@description('Defender for Cloud pricing dictionary: keys = plan names, value = pricing tier')
param defenderPlans object = {
  VirtualMachines: 'Standard'
  SqlServers: 'Standard'
  AppServices: 'Standard'
  StorageAccounts: 'Standard'
  SqlServerVirtualMachines: 'Standard'
  KubernetesService: 'Standard'
  ContainerRegistry: 'Standard'
  KeyVaults: 'Standard'
  Dns: 'Standard'
  Arm: 'Standard'
  OpenSourceRelationalDatabases: 'Standard'
  CosmosDbs: 'Standard'
  Api: 'Standard'
}

@description('Array of policy assignments to create at subscription scope (built-in or custom)')
param policyAssignments array = []

/* Resource Group */
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: rgName
  location: location
  tags: {
    environment: 'lz-security'
  }
}

/* Log Analytics */
module law './modules/log-analytics.bicep' = {
  name: 'logAnalytics'
  scope: rg
  params: {
    location: location
    workspaceName: workspaceName
    sku: lawSku
    retentionDays: lawRetentionDays
  }
}

/* Sentinel (solution resource) */
module sentinel './modules/sentinel.bicep' = if (enableSentinel) {
  name: 'enableSentinel'
  scope: rg
  params: {
    location: location
    workspaceId: law.outputs.workspaceId
    workspaceName: workspaceName
  }
}

/* Defender for Cloud plans at subscription */
module defender './modules/defender-plans.bicep' = {
  name: 'defenderPlans'
  params: {
    plans: defenderPlans
  }
}

/* Policy assignments at subscription */
module policy './modules/policy-assignments.bicep' = {
  name: 'policyAssignments'
  params: {
    assignments: policyAssignments
  }
}

/* Example diagnostic setting for subscription-level activity logs to LAW */
module diag './modules/diagnostic-settings.bicep' = {
  name: 'subscriptionDiagnostics'
  params: {
    targetResourceId: subscription().id
    workspaceId: law.outputs.workspaceId
    logsToEnable: [
      'Administrative'
      'Security'
      'ServiceHealth'
      'Alert'
      'Recommendation'
      'Policy'
      'Autoscale'
      'ResourceHealth'
    ]
  }
}

output workspaceResourceId string = law.outputs.workspaceId
