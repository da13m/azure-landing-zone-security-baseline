# Azure Landing Zone – Security Baseline (Bicep)

Hardened baseline for a small/medium Azure environment using **Bicep**:
- Central Log Analytics workspace (+ optional Microsoft Sentinel)
- Defender for Cloud plans
- Initial policy assignments (parameterized)
- Diagnostics to Log Analytics
- Subscription-scoped deployment
- CI quality gates

> **Scope:** Opinionated starter. Swap modules in/out as needed and add your own policy/initiative IDs via parameters.

## Architecture

```
Subscription
 ├─ Resource Group: <rgName>
 │   └─ Log Analytics Workspace (LAW)
 │       └─ Microsoft Sentinel (optional)
 ├─ Defender for Cloud Pricing (subscription scope)
 └─ Policy Assignments (built-in or custom) [parameterized]
```

## Controls mapping (examples)
- **Zero Trust – Visibility & Analytics:** Central LAW + Sentinel
- **Zero Trust – Threat Protection:** Defender for Cloud plans
- **Governance:** Policy assignments + diagnostics
- **Operations:** CI validation (`bicep build`, PSRule placeholder)

## Deploy (subscription-scoped)

```bash
# Login & select subscription
az login
az account set --subscription "<SUBSCRIPTION_ID>"

# What-if (no changes)
az deployment sub what-if   --location eastus   --template-file infra/main.bicep   --parameters @infra/params/nonprod.parameters.json

# Deploy
az deployment sub create   --location eastus   --template-file infra/main.bicep   --parameters @infra/params/nonprod.parameters.json
```

## Parameters
- `location`: Azure region for RG/LAW
- `rgName`: Resource group name
- `workspaceName`: LAW name
- `lawSku`: PerGB2018 or CapacityReservation
- `lawRetentionDays`: 30–730
- `enableSentinel`: true/false
- `defenderPlans`: Dictionary of plan names → `Standard` or `Free`
- `policyAssignments`: Array of policy assignment objects (see below)

### Example `policyAssignments` item
```json
{
  "displayName": "Deny Public IP on NICs",
  "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/<BUILT_IN_ID>",
  "parameters": {
    "effect": { "value": "Deny" }
  }
}
```

> Look up built-in policy definition IDs with:  
> `az policy definition list --query "[?contains(displayName, 'Public IP')].{name:name, id:id}" -o table`

## Rollback
- Set `enableSentinel=false` and redeploy to remove solution (will delete the solution resource only; LAW remains).
- Remove policy assignments by removing items and redeploying.
- Set Defender plans to `Free` for specific resource types to downgrade.

## Testing
- `bicep build infra/main.bicep`
- `az deployment sub what-if ...`
- Placeholder PSRule step is included in CI for future hardening.

## Security Notes
- No secrets stored. Use federated credentials (GitHub OIDC) for CI-based deploys.
- Give CI a minimum-privileged role (e.g., `Contributor` + `Resource Policy Contributor` if assigning policies).

## Folder layout
```
infra/
  main.bicep
  modules/
    log-analytics.bicep
    sentinel.bicep
    defender-plans.bicep
    policy-assignments.bicep
    diagnostic-settings.bicep
  params/
    nonprod.parameters.json
    prod.parameters.json
policies/
  initiatives/security-baseline.json    (skeleton)
.github/workflows/validate.yml
docs/adr/0001-choose-bicep.md
docs/controls-mapping.md
tools/Test-KqlFormatting.ps1           (placeholder)
```

---

Licensed under the MIT License.
