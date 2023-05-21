### Roadmap Module Features
- Shared Secrets
-- Introduce support this module to retrieve a pre_shared_secret from Secrets Manager instead of storing it in JSON
- HA Cloud VPN
-- Expand to support IPv6
-- Expand json attributes to support customizing route advertisements
-- Expand to support remote endpoints outside of GCP (Hybrid Cloud / On-premises)
- Classic Cloud VPN
-- Support for this needs to be introduced
-- This may end up being a different module, will know more after i go down the rabbit hole


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