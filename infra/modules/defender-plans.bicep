@description('Dictionary of Defender plan = pricing tier ("Standard" or "Free")')
param plans object

@batchSize(1)
module pricingItems 'Microsoft.Security/pricings@2023-01-01' = [for planName in union([], planKeys(plans)): {
  name: planName
  properties: {
    pricingTier: plans[planName]
  }
}]

/* Helper to extract keys in Bicep */
function planKeys(o object) array => [for k in items(o): k.key]
