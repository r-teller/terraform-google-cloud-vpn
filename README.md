
# Overview

## Diagram (GCP to GCP)

## Diagram (GCP to External)

# Resource Naming
## Resource Dynamic Name Generation
> Resource state Id's are dynamically generated based on attributes of the resource formatted using name-based uuids.
> - https://developer.hashicorp.com/terraform/language/functions/uuidv5

## Cloud Router (google_compute_router)
### Local Side
> Resource Naming == `format("cr-l-vpn-%s",uuidv5("x500",<...>)`

| Name        | Primary Value                       | Secondary Value           | Default |
| ----------- | ----------------------------------- | ------------------------- | :-----: |
| NAME        | (JSON) `.[].local_router.name`      | N/A                       | `null`  |
| PREFIX      | (JSON) `.[].prefix`                 | N/A                       | `null`  |
| ENVIRONMENT | (JSON) `.[].environment`            | N/A                       | `null`  |
| LABEL       | (JSON) `.[].label`                  | N/A                       | `null`  |
| UNIQUE_ID   | (JSON) `.[].local_router.unique_id` | N/A                       | `null`  |
| PROJECT_ID  | (JSON) `.[].project_id`             | (TF VAR) `var.project_id` |   N/A   |
| NETWORK     | (JSON) `.[].network`                | (TF VAR) `var.network`    |   N/A   |
| REGION      | (JSON) `.[].region`                 | (TF VAR) `var.region`     |   N/A   |
| BGP_ASN     | (JSON) `.[].local_router.bgp.asn`   | N/A                       | `null`  |

### Remote Side (If Managed by this module)
> Resource Naming == `format("cr-r-vpn-%s",uuidv5("x500",<...>)`

| Name        | Primary Value                       | Secondary Value           | Default |
| ----------- | ----------------------------------- | ------------------------- | :-----: |
| NAME        | (JSON) `.[].local_router.name`      | N/A                       | `null`  |
| PREFIX      | (JSON) `.[].prefix`                 | N/A                       | `null`  |
| ENVIRONMENT | (JSON) `.[].environment`            | N/A                       | `null`  |
| LABEL       | (JSON) `.[].label`                  | N/A                       | `null`  |
| UNIQUE_ID   | (JSON) `.[].local_router.unique_id` | N/A                       | `null`  |
| PROJECT_ID  | (JSON) `.[].project_id`             | (TF VAR) `var.project_id` |   N/A   |
| NETWORK     | (JSON) `.[].network`                | (TF VAR) `var.network`    |   N/A   |
| REGION      | (JSON) `.[].region`                 | (TF VAR) `var.region`     |   N/A   |
| BGP_ASN     | (JSON) `.[].local_router.bgp.asn`   | N/A                       | `null`  |

## HA VPN Gateway (google_compute_ha_vpn_gateway)
### Local Side
> Resource Naming == `format("ha-l-vpn-%s",uuidv5("x500",<...>)`

| Name        | Primary Value                             | Secondary Value           | Default |
| ----------- | ----------------------------------------- | ------------------------- | :-----: |
| NAME        | (JSON) `.[].local_vpn_gateway.name`       | N/A                       | `null`  |
| PREFIX      | (JSON) `.[].prefix`                       | N/A                       | `null`  |
| ENVIRONMENT | (JSON) `.[].environment`                  | N/A                       | `null`  |
| LABEL       | (JSON) `.[].label`                        | N/A                       | `null`  |
| UNIQUE_ID   | (JSON) `.[].local_vpn_gateway.unique_id`  | N/A                       | `null`  |
| PROJECT_ID  | (JSON) `.[].project_id`                   | (TF VAR) `var.project_id` |   N/A   |
| NETWORK     | (JSON) `.[].network`                      | (TF VAR) `var.network`    |   N/A   |
| REGION      | (JSON) `.[].region`                       | (TF VAR) `var.region`     |   N/A   |
| VPN_TYPE    | (JSON) `.[].vpn_type`                     | N/A                       |   N/A   |
| STACK_TYPE  | (JSON) `.[].local_vpn_gateway.stack_type` | N/A                       |   N/A   |

### Remote Side (If Managed by this module)
> Resource Naming == `format("ha-r-vpn-%s",uuidv5("x500",<...>)`

| Name        | Primary Value                                                    | Secondary Value         | Tertiary Value            | Default |
| ----------- | ---------------------------------------------------------------- | ----------------------- | ------------------------- | :-----: |
| NAME        | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.name`       | N/A                     | N/A                       | `null`  |
| PREFIX      | (JSON) `.[].prefix`                                              | N/A                     | N/A                       | `null`  |
| ENVIRONMENT | (JSON) `.[].environment`                                         | N/A                     | N/A                       | `null`  |
| LABEL       | (JSON) `.[].label`                                               | N/A                     | N/A                       | `null`  |
| UNIQUE_ID   | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.unique_id`  | N/A                     | N/A                       | `null`  |
| PROJECT_ID  | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.project_id` | (JSON) `.[].project_id` | (TF VAR) `var.project_id` |   N/A   |
| NETWORK     | (JSON) `.[].network`                                             | N/A                     | N/A                       |   N/A   |
| REGION      | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.region`     | (JSON) `.[].region`     | (TF VAR) `var.region`     |   N/A   |

## External VPN Gateway (google_compute_external_vpn_gateway)
> Resource Naming == `format("ha-r-vpn-%s",uuidv5("x500",<...>)`

| Name            | Primary Value                                                        | Secondary Value           |     Default      |
| --------------- | -------------------------------------------------------------------- | ------------------------- | :--------------: |
| NAME            | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.name`           | N/A                       |      `null`      |
| PREFIX          | (JSON) `.[].prefix`                                                  | N/A                       |      `null`      |
| ENVIRONMENT     | (JSON) `.[].environment`                                             | N/A                       |      `null`      |
| LABEL           | (JSON) `.[].label`                                                   | N/A                       |      `null`      |
| UNIQUE_ID       | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.unique_id`      | N/A                       |      `null`      |
| PROJECT_ID      | (JSON) `.[].project_id`                                              | (TF VAR) `var.project_id` |       N/A        |
| REDUNDANCY_TYPE | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.redudancy_type` | N/A                       | `TWO_INTERFACES` |

## VPN Tunnel | Router Interface | BGP Peer (google_compute_vpn_tunnel |google_compute_router_interface | google_compute_router_peer)
### Local Side
> Resource Naming == `format("vpn-%s-tunnel-%s",<...TUNNEL_TYPE...>,uuidv5("x500",<...>)`
> Tunnel Types
> - External == `l-e`
> - GCP == `l-r`

| Name                          | Primary Value                                                    | Secondary Value           | Default |
| ----------------------------- | ---------------------------------------------------------------- | ------------------------- | :-----: |
| NAME                          | `null`                                                           | N/A                       | `null`  |
| PREFIX                        | (JSON) `.[].prefix`                                              | N/A                       | `null`  |
| ENVIRONMENT                   | (JSON) `.[].environment`                                         | N/A                       | `null`  |
| LABEL                         | (JSON) `.[].label`                                               | N/A                       | `null`  |
| UNIQUE_ID                     | (JSON) `.[].local_router.unique_id`                              | N/A                       | `null`  |
| PROJECT_ID                    | (JSON) `.[].project_id`                                          | (TF VAR) `var.project_id` |   N/A   |
| NETWORK                       | (JSON) `.[].network`                                             | (TF VAR) `var.network`    |   N/A   |
| REGION                        | (JSON) `.[].region`                                              | (TF VAR) `var.region`     |   N/A   |
| ROUTER_NAME                   | (JSON) `.[].local_router.name`                                   | N/A                       | `null`  |
| LOCAL_VPN_GATEWAY_NAME        | (JSON) `.[].local_vpn_gateway.name`                              | N/A                       | `null`  |
| LOCAL_VPN_GATEWAY_UNIQUE_ID   | (JSON) `.[].local_vpn_gateway.unique_id`                         | N/A                       | `null`  |
| TUNNEL_INDEX                  | (TF VALUE DERIVED BASED ON Tunnel #)                             | N/A                       |   N/A   |
| REMOTE_VPN_GATEWAY_UUIDV5     | (TF VALUE DERIVED ABOVE)                                         | N/A                       |   N/A   |
| REMOTE_VPN_GATEWAY_TYPE       | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway_type`       | N/A                       |   N/A   |
| REMOTE_VPN_GATEWAY_PROJECT_ID | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.project_id` | `.[].project_id`          |   N/A   |
| REMOTE_VPN_GATEWAY_NETWORK    | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.network`    | N/A                       |   N/A   |
| REMOTE_VPN_GATEWAY_NAME       | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.name`       | N/A                       | `null`  |
| REMOTE_VPN_GATEWAY_UNIQUE_ID  | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.unique_id`  | N/A                       | `null`  |

### Remote Side (If Managed by this module)
> Resource Naming == `format("vpn-r-l-tunnel-%s",uuidv5("x500",<...>)`

| Name                          | Primary Value                                                   | Secondary Value           | Default |
| ----------------------------- | --------------------------------------------------------------- | ------------------------- | :-----: |
| NAME                          | `null`                                                          | N/A                       | `null`  |
| PREFIX                        | (JSON) `.[].prefix`                                             | N/A                       | `null`  |
| ENVIRONMENT                   | (JSON) `.[].environment`                                        | N/A                       | `null`  |
| LABEL                         | (JSON) `.[].label`                                              | N/A                       | `null`  |
| UNIQUE_ID                     | (JSON) `.[].local_router.unique_id`                             | N/A                       | `null`  |
| PROJECT_ID                    | (JSON) `.[].project_id`                                         | (TF VAR) `var.project_id` |   N/A   |
| NETWORK                       | (JSON) `.[].network`                                            | (TF VAR) `var.network`    |   N/A   |
| REGION                        | (JSON) `.[].region`                                             | (TF VAR) `var.region`     |   N/A   |
| ROUTER_NAME                   | (JSON) `.[].remote_vpn_gateways[].remote_router.name`           | N/A                       | `null`  |
| LOCAL_VPN_GATEWAY_NAME        | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.name`      | N/A                       | `null`  |
| LOCAL_VPN_GATEWAY_UNIQUE_ID   | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway.unique_id` | N/A                       | `null`  |
| TUNNEL_INDEX                  | (TF VALUE DERIVED BASED ON Tunnel #)                            | N/A                       |   N/A   |
| REMOTE_VPN_GATEWAY_UUIDV5     | (TF VALUE DERIVED ABOVE)                                        | N/A                       |   N/A   |
| REMOTE_VPN_GATEWAY_TYPE       | (JSON) `.[].remote_vpn_gateways[].remote_vpn_gateway_type`      | N/A                       |   N/A   |
| REMOTE_VPN_GATEWAY_PROJECT_ID | (JSON) `.[].local_vpn_gateway.project_id`                       | `.[].project_id`          |   N/A   |
| REMOTE_VPN_GATEWAY_NETWORK    | (JSON) `.[].local_vpn_gateway.network`                          | N/A                       |   N/A   |
| REMOTE_VPN_GATEWAY_NAME       | (JSON) `.[].local_vpn_gateway.name`                             | N/A                       | `null`  |
| REMOTE_VPN_GATEWAY_UNIQUE_ID  | (JSON) `.[].local_vpn_gateway.unique_id`                        | N/A                       | `null`  |

---
---
---

# Roadmap Module Features
- UI
-- JSON Generation
--- Improve the UI for JSON generation
--- Introduce support for `Advanced Options` toggle that hides fields not required from a minimum viable configuration perspective
-- JSON Import
--- Introduce support for importing pre-created JSON so that it can be manipulated within the UI
- Output Template
-- Introduce output configuration templates so that when Cloud VPN is integrated with 3rd party VPNs configuration is simplier
- Shared Secrets
-- Introduce support this module to retrieve a pre_shared_secret from Secrets Manager instead of storing it in JSON
- HA Cloud VPN
-- Expand automatic creation of BGP ASN to support both 16-bit and 32-bit ranges, currently only 32-bit BGP ASN are supported for automatic creation
-- Determine if local/remote tunnels need to support explicit naming
-- Determine if unique naming is needed for google_compute_router_interface & google_compute_router_peer resources, currently they use the same name as google_compute_vpn_tunnel
- Classic Cloud VPN
-- Support for this needs to be introduced in the near future
--- This may end up being a different module, will know more after i go down the rabbit hole

# Useful Links
## JSON Generator
https://r-teller.github.io/terraform-google-cloud-vpn

## JSON Schema Documentation
https://r-teller.github.io/terraform-google-cloud-vpn/documentation/

# Useful Tools
## JSON Schema Validator
- https://github.com/ajv-validator/ajv
- https://ajv.js.org/packages/ajv-cli.html
```bash
npm install -g ajv-cli

ajv validate -s "./schemas/resolved/resolved.schema.json" -d "./examples/project__network/examples/*.json" --strict=false
ajv validate -s .\json_generator\src\Schema\resolved.schema.json  -d .\test_cases\1_network\1a_network_single_name.json --strict=false
ajv validate -s .\json_generator\src\Schema\resolved.schema.json  -d .\test_cases\*\*.json --strict=false
```

## JSON Schema Dereferencer
https://github.com/davidkelley/json-dereference-cli
```bash
npm install -g json-dereference-cli
json-dereference -s my-schema.json -o compiled-schema.yaml
```

## React Widget from JSON Schema Generator
https://github.com/ui-schema/ui-schema

## JSON Schema to Documentation
https://github.com/coveooss/json-schema-for-humans
```bash
## Install as admin to make globally available
pip install json-schema-for-humans