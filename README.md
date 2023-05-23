## Resource Naming

### Resource Dynamic Name Generation
> uuidv5 naming (goes here)

```tcl
      uuidv5 = format("cr-l-vpn-%s", uuidv5("x500", join(",", [for k, v in {
        NAME        = try(cloud_vpn.local_router.name, null) != null ? cloud_vpn.local_router.name : null           
        PREFIX      = try(cloud_vpn.prefix, null) != null ? cloud_vpn.prefix : null                                 
        ENVIRONMENT = try(cloud_vpn.environment, null) != null ? cloud_vpn.environment : null                       
        LABEL       = try(cloud_vpn.label, null) != null ? cloud_vpn.label : null                                   
        UNIQUE_ID   = try(cloud_vpn.local_router.unique_id, null) != null ? cloud_vpn.local_router.unique_id : null 
        PROJECT_ID  = try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id,
        NETWORK     = try(cloud_vpn.network, null) != null ? cloud_vpn.network : var.network
        REGION      = try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region
        BGP_ASN     = try(cloud_vpn.local_router.bgp.asn, null) != null ? cloud_vpn.local_router.bgp.asn : null 
        } : format("%s=%s", k, v) if v != null])
      ))
```

#### Cloud Router (google_compute_router)

#### HA VPN Gateway (google_compute_ha_vpn_gateway)

#### External VPN Gateway (google_compute_external_vpn_gateway)

#### VPN Tunnel | Router Interface | BGP Peer (google_compute_vpn_tunnel |google_compute_router_interface | google_compute_router_peer)

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