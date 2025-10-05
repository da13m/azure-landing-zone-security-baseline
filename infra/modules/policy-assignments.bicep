@description('Array of policy assignments objects')
param assignments array = []

/*
Expected shape:
{
  displayName: 'Deny Public IP on NICs',
  policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/<id>',
  parameters: {
    effect: { value: 'Deny' }
  }
}
*/

@batchSize(1)
resource policyAssign 'Microsoft.Authorization/policyAssignments@2021-06-01' = [for (a, i) in assignments: {
  name: 'alz-sec-' + toLower(replace(a.displayName, ' ', '-')) + '-' + string(i)
  scope: subscription()
  properties: {
    displayName: a.displayName
    policyDefinitionId: a.policyDefinitionId
    parameters: empty(a.parameters) ? null : a.parameters
    enforcementMode: 'Default'
  }
}]
