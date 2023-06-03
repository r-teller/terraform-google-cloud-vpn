###### DEFAULTS - START ######
locals {
  defaults = {
    max_random_subnet_ranges = 128,
  }

  lookups_peer_vpn_gateway_redudancy_type = {
    ONE_INTERFACE   = "SINGLE_IP_INTERNALLY_REDUNDANT",
    TWO_INTERFACES  = "TWO_IPS_REDUNDANCY",
    FOUR_INTERFACES = "FOUR_IPS_REDUNDANCY",
  }

  lookups_bgp_advertise_mode = {
    DEFAULT        = "DEFAULT",
    CUSTOM         = "CUSTOM",
    DEFAULT_CUSTOM = "CUSTOM"
  }

  defaults_endpoints = {
    environment  = "UNKNOWN",
    prefix       = "UNKNOWN",
    tunnel_count = 2
  }

  defaults_peer_vpn_gateways = {
    redudancy_type = "TWO_INTERFACES"
  }

  default_bgp_peers = {
    enabled      = true,
    ipv6_enabled = true,
  }

  default_ha_vpn_gateways = {
    stack_type  = "IPV4_ONLY"
    ike_version = 2
  }
}
###### DEFAULTS - END ######


###### ENDPOINTS - START ######
locals {
  cloud_vpns = [for cloud_vpn in var.cloud_vpns : {
    prefix      = try(cloud_vpn.prefix, null)
    environment = try(cloud_vpn.environment, null)
    label       = try(cloud_vpn.label, null)

    project_id = try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id
    network    = try(cloud_vpn.network, null) != null ? cloud_vpn.network : var.network
    region     = lower(try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region)

    hub_router = {
      name      = try(cloud_vpn.hub_router.name, null)
      unique_id = try(cloud_vpn.hub_router.unique_id, null)


      uuidv5 = format("cr-hub-vpn-%s", uuidv5("x500", join(",", [for k, v in {
        NAME        = try(cloud_vpn.hub_router.name, null) != null ? cloud_vpn.hub_router.name : null,
        PREFIX      = try(cloud_vpn.prefix, null) != null ? cloud_vpn.prefix : null,
        ENVIRONMENT = try(cloud_vpn.environment, null) != null ? cloud_vpn.environment : null,
        LABEL       = try(cloud_vpn.label, null) != null ? cloud_vpn.label : null,
        UNIQUE_ID   = try(cloud_vpn.hub_router.unique_id, null) != null ? cloud_vpn.hub_router.unique_id : null,
        PROJECT_ID  = try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id,
        NETWORK     = try(cloud_vpn.network, null) != null ? cloud_vpn.network : var.network,
        REGION      = try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region,
        BGP_ASN     = try(cloud_vpn.hub_router.bgp.asn, null) != null ? cloud_vpn.hub_router.bgp.asn : null,
        } : format("%s=%s", k, v) if v != null])
      ))

      pre_existing = try(cloud_vpn.hub_router.pre_existing, false)
      bgp = {
        asn                  = try(cloud_vpn.hub_router.bgp.asn, null)
        advertise_mode       = lookup(local.lookups_bgp_advertise_mode, try(cloud_vpn.hub_router.bgp.hub_subnet_advertisements, "DEFAULT"))
        advertised_groups    = try(cloud_vpn.hub_router.bgp.hub_subnet_advertisements, "DEFAULT") == "DEFAULT_CUSTOM" ? ["ALL_SUBNETS"] : []
        advertised_ip_ranges = try(cloud_vpn.hub_router.bgp.custom_hub_subnet_advertisements, [])
      }
    }


    hub_vpn_gateway = {
      name      = try(cloud_vpn.hub_vpn_gateway.name, null)
      unique_id = try(cloud_vpn.hub_vpn_gateway.unique_id, null)

      uuidv5 = format("ha-hub-vpn-%s", uuidv5("x500", join(",", [for k, v in {
        NAME        = try(cloud_vpn.hub_vpn_gateway.name, null) != null ? cloud_vpn.hub_vpn_gateway.name : null,
        PREFIX      = try(cloud_vpn.prefix, null) != null ? cloud_vpn.prefix : null,
        ENVIRONMENT = try(cloud_vpn.environment, null) != null ? cloud_vpn.environment : null,
        LABEL       = try(cloud_vpn.label, null) != null ? cloud_vpn.label : null,
        UNIQUE_ID   = try(cloud_vpn.hub_vpn_gateway.unique_id, null) != null ? cloud_vpn.hub_vpn_gateway.unique_id : null,
        PROJECT_ID  = try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id,
        NETWORK     = try(cloud_vpn.network, null) != null ? cloud_vpn.network : var.network,
        REGION      = try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region,
        VPN_TYPE    = try(cloud_vpn.vpn_type, null) != null ? cloud_vpn.vpn_type : "HA",
        STACK_TYPE  = try(cloud_vpn.hub_vpn_gateway.stack_type, null) != null ? cloud_vpn.hub_vpn_gateway.stack_type : local.default_ha_vpn_gateways.stack_type,
        } : format("%s=%s", k, v) if v != null])
      ))

      stack_type   = try(cloud_vpn.hub_vpn_gateway.stack_type, null) != null ? cloud_vpn.hub_vpn_gateway.stack_type : local.default_ha_vpn_gateways.stack_type
      pre_existing = try(cloud_vpn.hub_vpn_gateway.pre_existing, false)
    }

    ### Spoke VPN Gateway -- TO --> GCP
    spoke_vpn_gateways_gcp = [for v1 in try(cloud_vpn.spoke_vpn_gateways, {}) : {
      name      = try(v1.spoke_vpn_gateway.name, null)
      unique_id = try(v1.spoke_vpn_gateway.unique_id, null)

      project_id = try(v1.spoke_vpn_gateway.project_id, null) != null ? v1.spoke_vpn_gateway.project_id : try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id
      network    = v1.spoke_vpn_gateway.network
      region     = lower(try(v1.spoke_vpn_gateway.region, null) != null ? v1.spoke_vpn_gateway.region : try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region)

      uuidv5 = format("ha-spoke-vpn-%s", uuidv5("x500", join(",", [for k, v in {
        NAME        = try(v1.spoke_vpn_gateway.name, null) != null ? v1.spoke_vpn_gateway.name : null,
        PREFIX      = try(cloud_vpn.prefix, null) != null ? cloud_vpn.prefix : null,
        ENVIRONMENT = try(cloud_vpn.environment, null) != null ? cloud_vpn.environment : null,
        LABEL       = try(cloud_vpn.label, null) != null ? cloud_vpn.label : null,
        UNIQUE_ID   = try(v1.spoke_vpn_gateway.unique_id, null) != null ? v1.spoke_vpn_gateway.unique_id : null,
        PROJECT_ID  = try(v1.spoke_vpn_gateway.project_id, null) != null ? v1.spoke_vpn_gateway.project_id : try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id,
        NETWORK     = v1.spoke_vpn_gateway.network,
        REGION      = try(v1.spoke_vpn_gateway.region, null) != null ? v1.spoke_vpn_gateway.region : try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region,
        } : format("%s=%s", k, v) if v != null])
      ))

      pre_existing = try(v1.spoke_vpn_gateway.pre_existing, false)
      ike_version  = try(v1.spoke_vpn_gateway.ike_version, null) != null ? v1.spoke_vpn_gateway.ike_version : local.default_ha_vpn_gateways.ike_version
      tunnel_count = try(v1.spoke_vpn_gateway.tunnel_count, null) != null ? v1.spoke_vpn_gateway.tunnel_count : local.defaults_endpoints.tunnel_count

      advanced_tunnel_configuration = try(v1.spoke_router.bgp.advanced_tunnel_configuration, null)

      spoke_router = {
        name      = try(v1.spoke_router.name, null)
        unique_id = try(v1.spoke_router.unique_id, null)

        pre_existing = try(v1.spoke_router.pre_existing, false),

        uuidv5 = format("cr-spoke-vpn-%s", uuidv5("x500", join(",", [for k, v in {
          NAME        = try(v1.spoke_router.name, null) != null ? v1.spoke_router.name : null,
          PREFIX      = try(cloud_vpn.prefix, null) != null ? cloud_vpn.prefix : null,
          ENVIRONMENT = try(cloud_vpn.environment, null) != null ? cloud_vpn.environment : null,
          LABEL       = try(cloud_vpn.label, null) != null ? cloud_vpn.label : null,
          UNIQUE_ID   = try(v1.spoke_router.unique_id, null) != null ? v1.spoke_router.unique_id : null,
          PROJECT_ID  = try(v1.spoke_vpn_gateway.project_id, null) != null ? v1.spoke_vpn_gateway.project_id : try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id,
          NETWORK     = v1.spoke_vpn_gateway.network,
          REGION      = try(v1.spoke_vpn_gateway.region, null) != null ? v1.spoke_vpn_gateway.region : try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region,
          BGP_ASN     = try(v1.spoke_router.bgp.asn, null) != null ? v1.spoke_router.bgp.asn : null,
          } : format("%s=%s", k, v) if v != null])
        ))

        bgp = {
          asn                  = try(v1.spoke_router.bgp.asn, null)
          advertise_mode       = "DEFAULT"
          advertised_groups    = null
          advertised_ip_ranges = []

          # advertise_mode       = lookup(local.lookups_bgp_advertise_mode, try(v1.spoke_router.bgp.spoke_subnet_advertisements, "DEFAULT"))
          # advertised_groups    = try(v1.spoke_router.bgp.spoke_subnet_advertisements, "DEFAULT") == "DEFAULT_CUSTOM" ? ["ALL_SUBNETS"] : []
          # advertised_ip_ranges = try(v1.spoke_router.bgp.custom_spoke_subnet_advertisements, [])
        }
      }

      custom_routing = {
        hub_advertise_mode       = lookup(local.lookups_bgp_advertise_mode, try(v1.spoke_router.bgp.hub_subnet_advertisements, "DEFAULT"))
        hub_advertised_groups    = try(v1.spoke_router.bgp.hub_subnet_advertisements, null) == "DEFAULT_CUSTOM" ? ["ALL_SUBNETS"] : []
        hub_advertised_ip_ranges = try(v1.spoke_router.bgp.custom_hub_subnet_advertisements, [])

        spoke_advertise_mode       = lookup(local.lookups_bgp_advertise_mode, try(v1.spoke_router.bgp.spoke_subnet_advertisements, "DEFAULT"))
        spoke_advertised_groups    = try(v1.spoke_router.bgp.spoke_subnet_advertisements, "DEFAULT") == "DEFAULT_CUSTOM" ? ["ALL_SUBNETS"] : []
        spoke_advertised_ip_ranges = try(v1.spoke_router.bgp.custom_spoke_subnet_advertisements, [])
      }

    } if try(v1.spoke_vpn_gateway_type, null) == "GCP"]

    ### Spoke VPN Gateway -- TO --> External
    spoke_vpn_gateways_external = [for v1 in try(cloud_vpn.spoke_vpn_gateways, {}) : {
      name      = try(v1.spoke_vpn_gateway.name, null)
      unique_id = try(v1.spoke_vpn_gateway.unique_id, null)

      project_id = try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id

      interfaces      = try(v1.spoke_vpn_gateway.interfaces, [])
      redundancy_type = try(lookup(local.lookups_peer_vpn_gateway_redudancy_type, v1.spoke_vpn_gateway.redudancy_type), local.defaults_peer_vpn_gateways.redudancy_type)

      uuidv5 = format("ha-peer-vpn-%s", uuidv5("x500", join(",", [for k, v in {
        NAME            = try(v1.spoke_vpn_gateway.name, null) != null ? v1.spoke_vpn_gateway.name : null,
        PREFIX          = try(cloud_vpn.prefix, null) != null ? cloud_vpn.prefix : null,
        ENVIRONMENT     = try(cloud_vpn.environment, null) != null ? cloud_vpn.environment : null,
        LABEL           = try(cloud_vpn.label, null) != null ? cloud_vpn.label : null,
        UNIQUE_ID       = try(v1.spoke_vpn_gateway.unique_id, null) != null ? v1.spoke_vpn_gateway.unique_id : null,
        PROJECT_ID      = try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id,
        INTERFACES      = try(md5(jsonencode(v1.spoke_vpn_gateway.interfaces)), null)
        REDUNDANCY_TYPE = try(lookup(local.lookups_peer_vpn_gateway_redudancy_type, v1.spoke_vpn_gateway.redudancy_type), local.defaults_peer_vpn_gateways.redudancy_type),
        } : format("%s=%s", k, v) if v != null])
      ))

      pre_existing = try(v1.spoke_vpn_gateway.pre_existing, false)
      ike_version  = try(v1.spoke_vpn_gateway.ike_version, null) != null ? v1.spoke_vpn_gateway.ike_version : local.default_ha_vpn_gateways.ike_version
      tunnel_count = try(v1.spoke_vpn_gateway.tunnel_count, null) != null ? v1.spoke_vpn_gateway.tunnel_count : local.defaults_endpoints.tunnel_count

      advanced_tunnel_configuration = try(v1.spoke_router.bgp.advanced_tunnel_configuration, null)

      spoke_router = {
        name      = null
        unique_id = null

        bgp = {
          asn = v1.spoke_router.bgp.asn
          # advertise_mode       = lookup(local.lookups_bgp_advertise_mode, try(v1.spoke_router.bgp.spoke_subnet_advertisements, "DEFAULT"))
          # advertised_groups    = try(v1.spoke_router.bgp.spoke_subnet_advertisements, "DEFAULT") == "DEFAULT_CUSTOM" ? ["ALL_SUBNETS"] : []
          # advertised_ip_ranges = try(v1.spoke_router.bgp.custom_spoke_subnet_advertisements, [])
        }
      }

      custom_routing = {
        hub_advertise_mode       = lookup(local.lookups_bgp_advertise_mode, try(v1.spoke_router.bgp.hub_subnet_advertisements, "DEFAULT"))
        hub_advertised_groups    = try(v1.spoke_router.bgp.hub_subnet_advertisements, null) == "DEFAULT_CUSTOM" ? ["ALL_SUBNETS"] : []
        hub_advertised_ip_ranges = try(v1.spoke_router.bgp.custom_hub_subnet_advertisements, [])
      }

    } if try(v1.spoke_vpn_gateway_type, null) == "EXTERNAL"]

  }]
}
###### ENDPOINTS - END ######


###### CLOUD ROUTERS - START ######
## Cloud Router Quots / Limits
# 5 per vpc / region
locals {
  _hub_routers = distinct(flatten([for cloud_vpn in local.cloud_vpns : {

    label       = cloud_vpn.label
    prefix      = cloud_vpn.prefix
    environment = cloud_vpn.environment

    # name      = cloud_vpn.hub_router.name != null ? cloud_vpn.hub_router.name : cloud_vpn.hub_router.uuidv5
    name      = cloud_vpn.hub_router.name != null ? cloud_vpn.hub_router.name : (var.generate_random_shortnames ? substr(cloud_vpn.hub_router.uuidv5, 0, length(cloud_vpn.hub_router.uuidv5) - 28) : cloud_vpn.hub_router.uuidv5)
    unique_id = cloud_vpn.hub_router.unique_id
    uuidv5    = cloud_vpn.hub_router.uuidv5

    project_id = cloud_vpn.project_id
    region     = cloud_vpn.region
    network    = cloud_vpn.network

    pre_existing = cloud_vpn.hub_router.pre_existing

    bgp = {
      asn                  = cloud_vpn.hub_router.bgp.asn
      advertise_mode       = cloud_vpn.hub_router.bgp.advertise_mode
      advertised_groups    = cloud_vpn.hub_router.bgp.advertised_groups
      advertised_ip_ranges = cloud_vpn.hub_router.bgp.advertised_ip_ranges
    }
  }]))

  _spoke_routers = distinct(flatten([for cloud_vpn in local.cloud_vpns : concat(
    ### Spoke VPN Gateway -- TO --> GCP
    [for k1, v1 in cloud_vpn.spoke_vpn_gateways_gcp : {
      label       = cloud_vpn.label
      prefix      = cloud_vpn.prefix
      environment = cloud_vpn.environment

      # name      = v1.spoke_router.name != null ? v1.spoke_router.name : v1.spoke_router.uuidv5
      name      = v1.spoke_router.name != null ? v1.spoke_router.name : (var.generate_random_shortnames ? substr(v1.spoke_router.uuidv5, 0, length(v1.spoke_router.uuidv5) - 28) : v1.spoke_router.uuidv5)
      unique_id = v1.spoke_router.unique_id
      uuidv5    = v1.spoke_router.uuidv5

      project_id = v1.project_id
      region     = v1.region
      network    = v1.network

      pre_existing = v1.spoke_router.pre_existing
      bgp = {
        asn                  = v1.spoke_router.bgp.asn
        advertise_mode       = v1.spoke_router.bgp.advertise_mode
        advertised_groups    = v1.spoke_router.bgp.advertised_groups
        advertised_ip_ranges = v1.spoke_router.bgp.advertised_ip_ranges
      }
    }],
    ### Spoke VPN Gateway -- TO --> External
    [for k1, v1 in cloud_vpn.spoke_vpn_gateways_external : {
      label       = cloud_vpn.label
      prefix      = cloud_vpn.prefix
      environment = cloud_vpn.environment

      name      = null
      unique_id = null
      uuidv5    = null

      project_id = null
      region     = null
      network    = null

      pre_existing = null

      bgp = {
        asn                  = v1.spoke_router.bgp.asn
        advertise_mode       = null
        advertised_groups    = null
        advertised_ip_ranges = []
      }
    }]
  )]))

  map_hub_routers   = { for hub_routers in local._hub_routers : hub_routers.uuidv5 => hub_routers }
  map_spoke_routers = { for spoke_routers in local._spoke_routers : spoke_routers.uuidv5 => spoke_routers if spoke_routers.uuidv5 != null }
}

## Used to randomly generate 16-bit ASN as needed
resource "random_integer" "random_bgp_asn_16_bit" {
  for_each = { for k1, v1 in merge(local.map_hub_routers, local.map_spoke_routers) : k1 => v1 if v1.bgp.asn == null && v1.pre_existing == false && try(v1.bgp.length, 0) == 16 }
  min      = 64512
  max      = 65534
  seed     = each.key
}

## Used to randomly generate 32-bit ASN as needed
resource "random_integer" "random_bgp_asn_32_bit" {
  for_each = { for k1, v1 in merge(local.map_hub_routers, local.map_spoke_routers) : k1 => v1 if v1.bgp.asn == null && v1.pre_existing == false && try(v1.bgp.length, 0) == 32 }
  min      = 4200000000
  max      = 4294967293
  seed     = each.key
}

## Used to randomly generate 32-bit ASN as needed | This is a temp default, future versions will support random 16 or 32 bit
resource "random_integer" "random_bgp_asn" {
  for_each = { for k1, v1 in merge(local.map_hub_routers, local.map_spoke_routers) : k1 => v1 if v1.bgp.asn == null && v1.pre_existing == false }
  min      = 4200000000
  max      = 4294967293
  seed     = each.key
}

## Local Cloud Router logic to assign randomly generated BGP ASNs as needed
locals {
  hub_routers = { for k1, v1 in local.map_hub_routers : k1 => merge(
    v1,
    {
      bgp = merge(v1.bgp, {
        asn : v1.bgp.asn != null ? v1.bgp.asn : random_integer.random_bgp_asn[k1].result
      })
    }
  ) }

  spoke_routers = { for k1, v1 in local.map_spoke_routers : k1 => merge(
    v1,
    {
      bgp = merge(v1.bgp, {
        asn : v1.bgp.asn != null ? v1.bgp.asn : random_integer.random_bgp_asn[k1].result
      })
    }
  ) }
}

## Used for interface configuration tracking to signal when tunnel should be re-created
resource "null_resource" "cloud_routers" {
  for_each = { for k1, v1 in merge(local.hub_routers, local.spoke_routers) : k1 => v1 if v1.pre_existing == false }
  triggers = {
    uuidv5 = each.value.uuidv5
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
resource "google_compute_router" "cloud_routers" {
  provider = google-beta

  for_each = { for k1, v1 in merge(local.hub_routers, local.spoke_routers) : k1 => v1 if v1.pre_existing == false }

  name    = each.value.name
  project = each.value.project_id

  network = each.value.network
  region  = each.value.region

  bgp {
    asn               = each.value.bgp.asn
    advertise_mode    = each.value.bgp.advertise_mode
    advertised_groups = each.value.bgp.advertised_groups
    dynamic "advertised_ip_ranges" {
      for_each = each.value.bgp.advertised_ip_ranges != null ? each.value.bgp.advertised_ip_ranges : []
      content {
        range = advertised_ip_ranges.value
      }
    }
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.cloud_routers[each.key].id
    ]
  }
}
###### CLOUD ROUTERS - END ######

###### VPN GATEWAYS - START ######
## VPN Gateway Quotas / Limits
# 125 Int / Ext Gateways
locals {
  _ha_hub_vpn_gateways = distinct(flatten([for cloud_vpn in local.cloud_vpns : {
    label       = cloud_vpn.label
    prefix      = cloud_vpn.prefix
    environment = cloud_vpn.environment

    # name      = cloud_vpn.hub_vpn_gateway.name != null ? cloud_vpn.hub_vpn_gateway.name : cloud_vpn.hub_vpn_gateway.uuidv5
    name      = cloud_vpn.hub_vpn_gateway.name != null ? cloud_vpn.hub_vpn_gateway.name : (var.generate_random_shortnames ? substr(cloud_vpn.hub_vpn_gateway.uuidv5, 0, length(cloud_vpn.hub_vpn_gateway.uuidv5) - 28) : cloud_vpn.hub_vpn_gateway.uuidv5)
    unique_id = cloud_vpn.hub_vpn_gateway.unique_id
    uuidv5    = cloud_vpn.hub_vpn_gateway.uuidv5

    project_id = cloud_vpn.project_id
    region     = cloud_vpn.region
    network    = cloud_vpn.network

    stack_type = cloud_vpn.hub_vpn_gateway.stack_type

    pre_existing = cloud_vpn.hub_vpn_gateway.pre_existing
  }]))

  map_ha_hub_vpn_gateways = { for ha_hub_vpn_gateways in local._ha_hub_vpn_gateways : ha_hub_vpn_gateways.uuidv5 => ha_hub_vpn_gateways }

  _ha_spoke_vpn_gateways_gcp = distinct(flatten([for cloud_vpn in local.cloud_vpns : [
    for k1, v1 in cloud_vpn.spoke_vpn_gateways_gcp : {
      label       = cloud_vpn.label
      prefix      = cloud_vpn.prefix
      environment = cloud_vpn.environment

      unique_id = v1.unique_id
      # name      = try(v1.name, null) != null ? v1.name : v1.uuidv5
      name   = v1.name != null ? v1.name : (var.generate_random_shortnames ? substr(v1.uuidv5, 0, length(v1.uuidv5) - 28) : v1.uuidv5)
      uuidv5 = v1.uuidv5

      project_id = v1.project_id
      region     = v1.region
      network    = v1.network

      stack_type = cloud_vpn.hub_vpn_gateway.stack_type

      pre_existing = v1.pre_existing
    }
  ]]))

  map_ha_spoke_vpn_gateways_gcp = { for v1 in local._ha_spoke_vpn_gateways_gcp : v1.uuidv5 => v1 }

  _ha_spoke_vpn_gateways_external = distinct(flatten([for cloud_vpn in local.cloud_vpns : [
    for k1, v1 in cloud_vpn.spoke_vpn_gateways_external : {
      label       = cloud_vpn.label
      prefix      = cloud_vpn.prefix
      environment = cloud_vpn.environment

      unique_id = v1.unique_id
      # name      = try(v1.name, null) != null ? v1.name : v1.uuidv5
      name   = v1.name != null ? v1.name : (var.generate_random_shortnames ? substr(v1.uuidv5, 0, length(v1.uuidv5) - 28) : v1.uuidv5)
      uuidv5 = v1.uuidv5

      project_id = v1.project_id

      interfaces      = v1.interfaces
      redundancy_type = v1.redundancy_type

      pre_existing = v1.pre_existing
    }
  ]]))

  map_ha_spoke_vpn_gateways_external = { for key in local._ha_spoke_vpn_gateways_external : key.uuidv5 => key }

  ha_hub_vpn_gateways = local.map_ha_hub_vpn_gateways
  hub_vpn_gateways    = local.ha_hub_vpn_gateways
}

resource "null_resource" "ha_hub_vpn_gateways" {
  for_each = { for k1, v1 in local.map_ha_hub_vpn_gateways : k1 => v1 if v1.pre_existing == false }

  triggers = {
    uuidv5 = each.value.uuidv5
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway
resource "google_compute_ha_vpn_gateway" "ha_hub_vpn_gateways" {
  provider = google-beta

  for_each = { for k1, v1 in local.map_ha_hub_vpn_gateways : k1 => v1 if v1.pre_existing == false }

  name    = each.value.name
  project = each.value.project_id

  network = each.value.network
  region  = each.value.region

  stack_type = each.value.stack_type

  lifecycle {
    replace_triggered_by = [
      null_resource.ha_hub_vpn_gateways[each.key].id
    ]
  }
}

resource "null_resource" "ha_spoke_vpn_gateways_gcp" {
  for_each = { for k1, v1 in local.map_ha_spoke_vpn_gateways_gcp : k1 => v1 if v1.pre_existing == false }

  triggers = {
    uuidv5 = each.value.uuidv5
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway
resource "google_compute_ha_vpn_gateway" "ha_spoke_vpn_gateways_gcp" {
  provider = google-beta

  for_each = { for k1, v1 in local.map_ha_spoke_vpn_gateways_gcp : k1 => v1 if v1.pre_existing == false }

  name    = each.value.name
  project = each.value.project_id

  network = each.value.network
  region  = each.value.region

  stack_type = each.value.stack_type

  lifecycle {
    replace_triggered_by = [
      null_resource.ha_spoke_vpn_gateways_gcp[each.key].id
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_external_vpn_gateway
resource "google_compute_external_vpn_gateway" "ha_spoke_vpn_gateways_external" {
  provider = google-beta

  for_each = { for k1, v1 in local.map_ha_spoke_vpn_gateways_external : k1 => v1 if v1.pre_existing == false }

  name    = each.value.name
  project = each.value.project_id

  redundancy_type = each.value.redundancy_type

  labels = {
    prefix      = each.value.prefix,
    environment = each.value.environment,
    label       = each.value.label,
  }

  dynamic "interface" {
    for_each = each.value.interfaces
    content {
      id         = interface.key
      ip_address = interface.value
    }
  }
}
###### VPN GATEWAYS - END ######

###### VPN TUNNELS - START ######
locals {
  _vpn_tunnels = flatten([for v1 in local.cloud_vpns : concat(
    ### Remote VPN Gateway -- TO --> GCP
    [for v2 in v1.spoke_vpn_gateways_gcp : [
      for i in range(v2.tunnel_count) : {
        region      = v1.region
        label       = v1.label
        prefix      = v1.prefix
        environment = v1.environment

        tunnel_index = i
        ike_version  = v2.ike_version

        pre_shared_secret_method  = try(v2.advanced_tunnel_configuration[i].pre_shared_secret_method, "DYNAMIC")
        pre_shared_secret_manager = try(v2.advanced_tunnel_configuration[i].secret_manager_pre_shared_secret, null)

        pre_shared_secret = (
          try(v2.advanced_tunnel_configuration[i].pre_shared_secret_method, null) == "STATIC" ? v2.advanced_tunnel_configuration[i].static_pre_shared_secret :
          try(v2.advanced_tunnel_configuration[i].pre_shared_secret_method, null) == "TERRAFORM_VARIABLE" ? var.variable_pre_shared_secret[v2.advanced_tunnel_configuration[i].terraform_variable_pre_shared_secret] :
          null
        )


        hub_vpn_gateway = {
          # name       = v1.hub_vpn_gateway.name != null ? v1.hub_vpn_gateway.name : v1.hub_vpn_gateway.uuidv5
          name       = v1.hub_vpn_gateway.name != null ? v1.hub_vpn_gateway.name : (var.generate_random_shortnames ? substr(v1.hub_vpn_gateway.uuidv5, 0, length(v1.hub_vpn_gateway.uuidv5) - 28) : v1.hub_vpn_gateway.uuidv5)
          uuidv5     = v1.hub_vpn_gateway.uuidv5
          unique_id  = v1.hub_vpn_gateway.unique_id
          project_id = v1.project_id
          network    = v1.network
          stack_type = v1.hub_vpn_gateway.stack_type

          hub_router = {
            uuidv5 = v1.hub_router.uuidv5
            # name   = v1.hub_router.name != null ? v1.hub_router.name : v1.hub_router.uuidv5
            name = v1.hub_router.name != null ? v1.hub_router.name : (var.generate_random_shortnames ? substr(v1.hub_router.uuidv5, 0, length(v1.hub_router.uuidv5) - 28) : v1.hub_router.uuidv5)
            bgp = {
              asn = local.hub_routers[v1.hub_router.uuidv5].bgp.asn
            }
          }
        }

        spoke_vpn_gateway = {
          type = "gcp"

          uuidv5 = v2.uuidv5
          # name      = v2.name != null ? v2.name : v2.uuidv5
          name      = v2.name != null ? v2.name : (var.generate_random_shortnames ? substr(v2.uuidv5, 0, length(v2.uuidv5) - 28) : v2.uuidv5)
          unique_id = v2.unique_id

          spoke_router = {
            # name   = v2.spoke_router.name != null ? v2.spoke_router.name : v2.spoke_router.uuidv5,
            name   = v2.spoke_router.name != null ? v2.spoke_router.name : (var.generate_random_shortnames ? substr(v2.spoke_router.uuidv5, 0, length(v2.spoke_router.uuidv5) - 28) : v2.spoke_router.uuidv5)
            uuidv5 = v2.spoke_router.uuidv5,
            bgp = {
              asn = local.spoke_routers[v2.spoke_router.uuidv5].bgp.asn
            }
          }

          project_id   = v2.project_id
          network      = v2.network
          region       = v2.region
          pre_existing = try(v2.pre_existing, null) != null ? v2.pre_existing : false
          interfaces   = []
        }

        bgp_peers = {
          hub_ipv4_address   = try(v2.advanced_tunnel_configuration[i].hub_ipv4_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].hub_ipv4_address, null) : null,
          hub_ipv6_address   = try(v2.advanced_tunnel_configuration[i].hub_ipv6_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].hub_ipv6_address, null) : null,
          spoke_ipv4_address = try(v2.advanced_tunnel_configuration[i].spoke_ipv4_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].spoke_ipv4_address, null) : null,
          spoke_ipv6_address = try(v2.advanced_tunnel_configuration[i].spoke_ipv6_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].spoke_ipv6_address, null) : null,

          ## If spoke_router.bgp.advanced_tunnel_configuration[i].disabled is true then set enabled `false` so that the bgp_peer is disabled
          enabled                   = try(v2.advanced_tunnel_configuration[i].bgp_advertisement_disabled, false) != true
          advertised_route_priority = try(v2.advanced_tunnel_configuration[i].advertised_route_priority, null)

          ipv6_enabled = try(v2.advanced_tunnel_configuration[i].ipv6_enabled, local.default_bgp_peers.ipv6_enabled),
        }

        custom_routing = v2.custom_routing
      }
      ]
    ],
    ### Spoke VPN Gateway -- TO --> External
    [for v2 in v1.spoke_vpn_gateways_external : [
      for i in range(v2.tunnel_count) : {
        region      = v1.region
        label       = v1.label
        prefix      = v1.prefix
        environment = v1.environment

        tunnel_index = i
        ike_version  = v2.ike_version

        pre_shared_secret_method  = try(v2.advanced_tunnel_configuration[i].pre_shared_secret_method, "DYNAMIC")
        pre_shared_secret_manager = try(v2.advanced_tunnel_configuration[i].secret_manager_pre_shared_secret, null)

        pre_shared_secret = (
          v2.advanced_tunnel_configuration[i].pre_shared_secret_method == "STATIC" ? v2.advanced_tunnel_configuration[i].static_pre_shared_secret :
          v2.advanced_tunnel_configuration[i].pre_shared_secret_method == "TERRAFORM_VARIABLE" ? var.variable_pre_shared_secret[v2.advanced_tunnel_configuration[i].terraform_variable_pre_shared_secret] :
          null
        )

        ## Assigns hub & spoke interface numbers counting from 0 to N where N equal the number of interfaces assigned
        ### First Example 2 hub & 2 spoke interfaces
        ### Example Tunnel 0 maps to hub nic0 and spoke nic0
        ### Example Tunnel 3 maps to hub nic1 and spoke nic1
        ### Second Example 2 hub & 4 spoke interfaces
        ### Example Tunnel 0 maps to hub nic0 and spoke nic0
        ### Example Tunnel 3 maps to hub nic1 and spoke nic3
        vpn_gateway_interface = ceil(i % 2)

        peer_external_gateway_interface = (
          v2.redundancy_type == "SINGLE_IP_INTERNALLY_REDUNDANT" ? ceil(i % 1) :
          v2.redundancy_type == "TWO_IPS_REDUNDANCY" ? ceil(i % 2) :
          v2.redundancy_type == "FOUR_IPS_REDUNDANCY" ? ceil(i % 4) :
          0
        )

        hub_vpn_gateway = {
          # name       = v1.hub_vpn_gateway.name != null ? v1.hub_vpn_gateway.name : v1.hub_vpn_gateway.uuidv5
          name       = v1.hub_vpn_gateway.name != null ? v1.hub_vpn_gateway.name : (var.generate_random_shortnames ? substr(v1.hub_vpn_gateway.uuidv5, 0, length(v1.hub_vpn_gateway.uuidv5) - 28) : v1.hub_vpn_gateway.uuidv5)
          uuidv5     = v1.hub_vpn_gateway.uuidv5
          unique_id  = v1.hub_vpn_gateway.unique_id
          project_id = v1.project_id
          network    = v1.network
          stack_type = v1.hub_vpn_gateway.stack_type

          hub_router = {
            uuidv5 = v1.hub_router.uuidv5
            # name   = v1.hub_router.name != null ? v1.hub_router.name : v1.hub_router.uuidv5
            name = v1.hub_router.name != null ? v1.hub_router.name : (var.generate_random_shortnames ? substr(v1.hub_router.uuidv5, 0, length(v1.hub_router.uuidv5) - 28) : v1.hub_router.uuidv5)
            bgp = {
              asn = local.hub_routers[v1.hub_router.uuidv5].bgp.asn
            }
          }
        }

        spoke_vpn_gateway = {
          type = "external"

          uuidv5 = v2.uuidv5
          # name      = v2.name != null ? v2.name : v2.uuidv5
          name      = v2.name != null ? v2.name : (var.generate_random_shortnames ? substr(v2.uuidv5, 0, length(v2.uuidv5) - 28) : v2.uuidv5)
          unique_id = v2.unique_id

          spoke_router = {
            name = null

            bgp = {
              asn = v2.spoke_router.bgp.asn
            }
          }

          project_id   = v2.project_id
          network      = null
          region       = null
          pre_existing = true
          interfaces   = v2.interfaces
        }

        bgp_peers = {
          hub_ipv4_address   = try(v2.advanced_tunnel_configuration[i].hub_ipv4_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].hub_ipv4_address, null) : null,
          hub_ipv6_address   = try(v2.advanced_tunnel_configuration[i].hub_ipv6_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].hub_ipv6_address, null) : null,
          spoke_ipv4_address = try(v2.advanced_tunnel_configuration[i].spoke_ipv4_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].spoke_ipv4_address, null) : null,
          spoke_ipv6_address = try(v2.advanced_tunnel_configuration[i].spoke_ipv6_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].spoke_ipv6_address, null) : null,

          ## If spoke_router.bgp.advanced_tunnel_configuration[i].disabled is true then set enabled `false` so that the bgp_peer is disabled
          enabled                   = try(v2.advanced_tunnel_configuration[i].bgp_advertisement_disabled, false) != true
          advertised_route_priority = try(v2.advanced_tunnel_configuration[i].advertised_route_priority, null)

          ipv6_enabled = try(v2.bgp_peers[i].ipv6_enabled, local.default_bgp_peers.ipv6_enabled),
        }
        custom_routing = v2.custom_routing
      }
      ]
    ])
  ])

  kv_hub_vpn_tunnels = { for v1 in local._vpn_tunnels : format("vpn-%s-tunnel-%s",
    lookup({ "external" = "hub-peer", "gcp" = "hub-spoke" }, v1.spoke_vpn_gateway.type, "hub-unk"),
    uuidv5("x500", join(",", [for k2, v2 in {
      NAME                         = null,
      PREFIX                       = v1.prefix,
      ENVIRONMENT                  = v1.environment,
      LABEL                        = v1.label,
      REGION                       = null,
      VPN_GATEWAY_TYPE             = v1.spoke_vpn_gateway.type,
      TUNNEL_INDEX                 = v1.tunnel_index,
      HUB_VPN_GATEWAY_NAME         = v1.hub_vpn_gateway.name,
      HUB_VPN_GATEWAY_UNIQUE_ID    = v1.hub_vpn_gateway.unique_id,
      HUB_VPN_GATEWAY_PROJECT_ID   = v1.hub_vpn_gateway.project_id,
      HUB_VPN_GATEWAY_NETWORK      = v1.hub_vpn_gateway.network,
      HUB_VPN_GATEWAY_UUIDV5       = v1.hub_vpn_gateway.uuidv5,
      HUB_ROUTER_NAME              = v1.hub_vpn_gateway.hub_router.name,
      SPOKE_VPN_GATEWAY_NAME       = v1.spoke_vpn_gateway.name,
      SPOKE_VPN_GATEWAY_UNIQUE_ID  = v1.spoke_vpn_gateway.unique_id,
      SPOKE_VPN_GATEWAY_PROJECT_ID = v1.spoke_vpn_gateway.project_id,
      SPOKE_VPN_GATEWAY_NETWORK    = v1.spoke_vpn_gateway.network,
      SPOKE_VPN_GATEWAY_UUIDV5     = v1.spoke_vpn_gateway.uuidv5,
      SPOKE_ROUTER_NAME            = v1.spoke_vpn_gateway.spoke_router.name,
    } : format("%s=%s", k2, v2) if v2 != null]))) => v1
  }
}

## Generate random binary string to be converted to subnet range within 169.254.0.0/16
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "subnet_binary" {
  for_each         = { for k1, v1 in local.kv_hub_vpn_tunnels : k1 => "" if v1.bgp_peers.hub_ipv4_address == null }
  lower            = false
  upper            = false
  numeric          = false
  special          = true
  override_special = "01"

  length = 14
}

## Generate random string that can be used as the shared-secret for vpn tunnel creation
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "pre_shared_secret" {
  for_each = toset([for k1, v1 in local.kv_hub_vpn_tunnels : k1 if v1.pre_shared_secret_method == "DYNAMIC"])
  length   = 32
  upper    = true
  lower    = true
  numeric  = true
  special  = false

  lifecycle {
    ignore_changes = [
      length,
      lower,
      special,
      numeric,
      upper,
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret_version
data "google_secret_manager_secret_version" "secret_manager_secret" {
  for_each = { for k1, v1 in local.kv_hub_vpn_tunnels : k1 => v1 if v1.pre_shared_secret_method == "SECRET_MANAGER" }

  project = each.value.hub_vpn_gateway.project_id
  secret  = each.value.pre_shared_secret_manager
}

locals {
  map_hub_vpn_tunnels = { for k1, v1 in local.kv_hub_vpn_tunnels : k1 => merge(
    v1,
    {
      bgp_peers = merge(v1.bgp_peers, {
        _hub_ipv4_address : v1.bgp_peers.hub_ipv4_address,
        hub_ipv4_address : (
          v1.bgp_peers.hub_ipv4_address != null ? v1.bgp_peers.hub_ipv4_address : cidrhost(cidrsubnet("169.254.0.0/16", 14, parseint(random_string.subnet_binary[k1].result, 2)), 2)
        ),
        _spoke_ipv4_address : v1.bgp_peers.spoke_ipv4_address,
        spoke_ipv4_address : (
          v1.bgp_peers.spoke_ipv4_address != null ? v1.bgp_peers.spoke_ipv4_address : cidrhost(cidrsubnet("169.254.0.0/16", 14, parseint(random_string.subnet_binary[k1].result, 2)), 1)
        ),
      }),
      pre_shared_secret = contains(["STATIC", "TERRAFORM_VARIABLE"], v1.pre_shared_secret_method) ? v1.pre_shared_secret : (
        v1.pre_shared_secret_method == "DYNAMIC" ? random_string.pre_shared_secret[k1].result :
        v1.pre_shared_secret_method == "SECRET_MANAGER" ? nonsensitive(data.google_secret_manager_secret_version.secret_manager_secret[k1].secret_data) : null
      )
    })
  }

  hub_vpn_tunnels = { for k1, v1 in local.map_hub_vpn_tunnels : k1 => merge(v1, {
    name = try(v1.name, null) != null ? v1.name : (var.generate_random_shortnames ? substr(k1, 0, length(k1) - 28) : k1)
  }) }

  kv_spoke_vpn_tunnels = { for k1, v1 in local.map_hub_vpn_tunnels : format("vpn-spoke-hub-tunnel-%s", uuidv5("x500", join(",",
    [for k2, v2 in {
      NAME                         = null,
      PREFIX                       = v1.prefix,
      ENVIRONMENT                  = v1.environment,
      LABEL                        = v1.label,
      REGION                       = null,
      VPN_GATEWAY_TYPE             = v1.spoke_vpn_gateway.type,
      TUNNEL_INDEX                 = v1.tunnel_index,
      HUB_VPN_GATEWAY_NAME         = v1.spoke_vpn_gateway.name,
      HUB_VPN_GATEWAY_UNIQUE_ID    = v1.spoke_vpn_gateway.unique_id,
      HUB_VPN_GATEWAY_PROJECT_ID   = v1.spoke_vpn_gateway.project_id,
      HUB_VPN_GATEWAY_NETWORK      = v1.spoke_vpn_gateway.network,
      HUB_VPN_GATEWAY_UUIDV5       = v1.spoke_vpn_gateway.uuidv5,
      HUB_ROUTER_NAME              = v1.spoke_vpn_gateway.spoke_router.name,
      SPOKE_VPN_GATEWAY_NAME       = v1.hub_vpn_gateway.name,
      SPOKE_VPN_GATEWAY_UNIQUE_ID  = v1.hub_vpn_gateway.unique_id,
      SPOKE_VPN_GATEWAY_PROJECT_ID = v1.hub_vpn_gateway.project_id,
      SPOKE_VPN_GATEWAY_NETWORK    = v1.hub_vpn_gateway.network,
      SPOKE_VPN_GATEWAY_UUIDV5     = v1.hub_vpn_gateway.uuidv5,
      SPOKE_ROUTER_NAME            = v1.hub_vpn_gateway.hub_router.name,
    } : format("%s=%s", k2, v2) if v2 != null]))) => v1
  }

  spoke_vpn_tunnels = { for k1, v1 in local.kv_spoke_vpn_tunnels : k1 => merge(v1, {
    name = try(v1.name, null) != null ? v1.name : (var.generate_random_shortnames ? substr(k1, 0, length(k1) - 28) : k1)
  }) }
}

## Used for interface configuration tracking to signal when tunnel should be re-created
resource "null_resource" "hub_vpn_tunnels" {
  for_each = local.hub_vpn_tunnels
  triggers = {
    interfaces               = md5(jsonencode(each.value.spoke_vpn_gateway.interfaces))
    hub_router_uuidv5        = each.value.hub_vpn_gateway.hub_router.uuidv5
    spoke_vpn_gateway_uuidv5 = each.value.spoke_vpn_gateway.uuidv5

  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel
resource "google_compute_vpn_tunnel" "hub_vpn_tunnels" {
  provider = google-beta

  for_each = local.hub_vpn_tunnels

  name = each.value.name

  project = each.value.hub_vpn_gateway.project_id
  region  = each.value.region

  labels = {
    prefix                               = each.value.prefix,
    environment                          = each.value.environment,
    label                                = each.value.label,
    tunnel_index                         = each.value.tunnel_index,
    hub_vpn_gateway_unique_id            = each.value.hub_vpn_gateway.unique_id,
    spoke_gcp_vpn_gateway_unique_id      = each.value.spoke_vpn_gateway.type == "gcp" ? each.value.spoke_vpn_gateway.unique_id : null,
    spoke_external_vpn_gateway_unique_id = each.value.spoke_vpn_gateway.type == "external" ? each.value.spoke_vpn_gateway.unique_id : null,
    peer_external_gateway_interface      = each.value.spoke_vpn_gateway.type == "external" ? each.value.peer_external_gateway_interface : null,
    vpn_gateway_interface                = each.value.spoke_vpn_gateway.type == "external" ? each.value.vpn_gateway_interface : each.value.tunnel_index,
  }

  router = format("https://www.googleapis.com/compute/v1/projects/%s/regions/%s/routers/%s",
    each.value.hub_vpn_gateway.project_id,
    each.value.region,
    each.value.hub_vpn_gateway.hub_router.name,
  )

  vpn_gateway = format("https://www.googleapis.com/compute/v1/projects/%s/regions/%s/vpnGateways/%s",
    each.value.hub_vpn_gateway.project_id,
    each.value.region,
    each.value.hub_vpn_gateway.name,
  )

  peer_gcp_gateway = each.value.spoke_vpn_gateway.type == "gcp" ? format("https://www.googleapis.com/compute/v1/projects/%s/regions/%s/vpnGateways/%s",
    each.value.spoke_vpn_gateway.project_id,
    each.value.region,
    each.value.spoke_vpn_gateway.name,
  ) : null

  peer_external_gateway = each.value.spoke_vpn_gateway.type == "external" ? format("https://www.googleapis.com/compute/v1/projects/%s/global/externalVpnGateways/%s",
    each.value.spoke_vpn_gateway.project_id,
    each.value.spoke_vpn_gateway.name,
  ) : null

  vpn_gateway_interface           = each.value.spoke_vpn_gateway.type == "external" ? each.value.vpn_gateway_interface : each.value.tunnel_index
  peer_external_gateway_interface = each.value.spoke_vpn_gateway.type == "external" ? each.value.peer_external_gateway_interface : null

  ike_version   = each.value.ike_version
  shared_secret = each.value.pre_shared_secret

  depends_on = [
    random_integer.random_bgp_asn,
    random_string.pre_shared_secret,
    random_string.subnet_binary,
    google_compute_router.cloud_routers,
    google_compute_ha_vpn_gateway.ha_hub_vpn_gateways,
    google_compute_ha_vpn_gateway.ha_spoke_vpn_gateways_gcp,
    google_compute_external_vpn_gateway.ha_spoke_vpn_gateways_external,
  ]

  lifecycle {
    replace_triggered_by = [
      null_resource.hub_vpn_tunnels[each.key].id
    ]
  }
}

resource "null_resource" "spoke_vpn_tunnels" {
  for_each = { for k1, v1 in local.spoke_vpn_tunnels : k1 => v1 if v1.spoke_vpn_gateway.pre_existing == false }
  triggers = {
    spoke_router_uuidv5 = each.value.spoke_vpn_gateway.spoke_router.uuidv5
  }
}

resource "google_compute_vpn_tunnel" "spoke_vpn_tunnels" {
  provider = google-beta

  for_each = { for k1, v1 in local.spoke_vpn_tunnels : k1 => v1 if v1.spoke_vpn_gateway.pre_existing == false }

  name = each.value.name

  project = each.value.spoke_vpn_gateway.project_id
  region  = each.value.region

  labels = {
    prefix                      = each.value.prefix,
    environment                 = each.value.environment,
    label                       = each.value.label,
    tunnel_index                = each.value.tunnel_index,
    hub_vpn_gateway_unique_id   = each.value.hub_vpn_gateway.unique_id,
    spoke_vpn_gateway_unique_id = each.value.spoke_vpn_gateway.unique_id,
  }

  router = each.value.spoke_vpn_gateway.spoke_router.name

  vpn_gateway = format("https://www.googleapis.com/compute/v1/projects/%s/regions/%s/vpnGateways/%s",
    each.value.spoke_vpn_gateway.project_id,
    each.value.region,
    each.value.spoke_vpn_gateway.name,
  )

  peer_gcp_gateway = format("https://www.googleapis.com/compute/v1/projects/%s/regions/%s/vpnGateways/%s",
    each.value.hub_vpn_gateway.project_id,
    each.value.region,
    each.value.hub_vpn_gateway.name,
  )

  vpn_gateway_interface = each.value.tunnel_index
  ike_version           = each.value.ike_version
  shared_secret         = each.value.pre_shared_secret

  depends_on = [
    random_integer.random_bgp_asn,
    random_string.pre_shared_secret,
    random_string.subnet_binary,
    google_compute_router.cloud_routers,
    google_compute_ha_vpn_gateway.ha_hub_vpn_gateways,
    google_compute_ha_vpn_gateway.ha_spoke_vpn_gateways_gcp,
  ]

  lifecycle {
    replace_triggered_by = [
      null_resource.spoke_vpn_tunnels[each.key].id
    ]
  }
}

# # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface
resource "google_compute_router_interface" "hub_router_interfaces" {
  for_each = local.hub_vpn_tunnels
  project  = each.value.hub_vpn_gateway.project_id
  region   = each.value.region

  name       = each.value.name
  router     = each.value.hub_vpn_gateway.hub_router.name
  ip_range   = format("%s/30", each.value.bgp_peers.hub_ipv4_address)
  vpn_tunnel = each.value.name

  depends_on = [
    random_integer.random_bgp_asn,
    random_string.subnet_binary,
    google_compute_vpn_tunnel.hub_vpn_tunnels
  ]
}

resource "google_compute_router_interface" "spoke_router_interfaces" {
  for_each = { for k1, v1 in local.spoke_vpn_tunnels : k1 => v1 if v1.spoke_vpn_gateway.pre_existing == false }
  project  = each.value.spoke_vpn_gateway.project_id
  region   = each.value.spoke_vpn_gateway.region

  name       = each.value.name
  router     = each.value.spoke_vpn_gateway.spoke_router.name
  ip_range   = format("%s/30", each.value.bgp_peers.spoke_ipv4_address)
  vpn_tunnel = each.value.name

  depends_on = [
    random_integer.random_bgp_asn,
    random_string.subnet_binary,
    google_compute_router.cloud_routers,
    google_compute_ha_vpn_gateway.ha_hub_vpn_gateways,
    google_compute_ha_vpn_gateway.ha_spoke_vpn_gateways_gcp,
    google_compute_vpn_tunnel.spoke_vpn_tunnels,
  ]
  lifecycle {
    replace_triggered_by = []
  }
}

# # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer
resource "google_compute_router_peer" "hub_bgp_peers" {
  provider = google-beta

  for_each = local.hub_vpn_tunnels

  project = each.value.hub_vpn_gateway.project_id
  region  = each.value.region

  name   = each.value.name
  router = each.value.hub_vpn_gateway.hub_router.name

  advertised_route_priority = each.value.bgp_peers.advertised_route_priority

  advertise_mode    = each.value.custom_routing.hub_advertise_mode
  advertised_groups = each.value.custom_routing.hub_advertised_groups

  dynamic "advertised_ip_ranges" {
    for_each = (
      (each.value.custom_routing.hub_advertised_ip_ranges != null && each.value.custom_routing.hub_advertise_mode != "DEFAULT")
      ? each.value.custom_routing.hub_advertised_ip_ranges
      : []
    )
    content {
      range = advertised_ip_ranges.value
    }
  }

  peer_asn = each.value.spoke_vpn_gateway.spoke_router.bgp.asn

  enable          = each.value.bgp_peers.enabled
  peer_ip_address = each.value.bgp_peers.spoke_ipv4_address

  enable_ipv6 = each.value.hub_vpn_gateway.stack_type == "IPV4_IPV6" ? each.value.bgp_peers.ipv6_enabled : null

  interface = google_compute_router_interface.hub_router_interfaces[each.key].name

  depends_on = [
    google_compute_router_interface.hub_router_interfaces
  ]

  lifecycle {
    replace_triggered_by = [
      google_compute_router_interface.hub_router_interfaces[each.key].ip_range
    ]
  }
}

resource "google_compute_router_peer" "spoke_bgp_peers" {
  provider = google-beta

  for_each = { for k1, v1 in local.spoke_vpn_tunnels : k1 => v1 if v1.spoke_vpn_gateway.pre_existing == false }

  project = each.value.spoke_vpn_gateway.project_id
  region  = each.value.spoke_vpn_gateway.region

  name   = each.value.name
  router = each.value.spoke_vpn_gateway.spoke_router.name

  advertised_route_priority = each.value.bgp_peers.advertised_route_priority

  advertise_mode    = each.value.custom_routing.spoke_advertise_mode
  advertised_groups = each.value.custom_routing.spoke_advertised_groups

  dynamic "advertised_ip_ranges" {
    for_each = (
      (each.value.custom_routing.spoke_advertised_ip_ranges != null && each.value.custom_routing.spoke_advertise_mode != "DEFAULT")
      ? each.value.custom_routing.spoke_advertised_ip_ranges
      : []
    )
    content {
      range = advertised_ip_ranges.value
    }
  }

  peer_asn = each.value.hub_vpn_gateway.hub_router.bgp.asn

  enable          = each.value.bgp_peers.enabled
  peer_ip_address = each.value.bgp_peers.hub_ipv4_address

  enable_ipv6 = each.value.hub_vpn_gateway.stack_type == "IPV4_IPV6" ? each.value.bgp_peers.ipv6_enabled : null

  interface = google_compute_router_interface.spoke_router_interfaces[each.key].name

  depends_on = [
    google_compute_router.cloud_routers,
    google_compute_ha_vpn_gateway.ha_hub_vpn_gateways,
    google_compute_ha_vpn_gateway.ha_spoke_vpn_gateways_gcp,
    google_compute_vpn_tunnel.spoke_vpn_tunnels,
    google_compute_router_interface.spoke_router_interfaces,
  ]

  lifecycle {
    replace_triggered_by = [
      google_compute_router_interface.spoke_router_interfaces[each.key].ip_range
    ]
  }
}
