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
    # region     = lower(cloud_vpn.region)

    local_router = {
      name      = try(cloud_vpn.local_router.name, null)
      unique_id = try(cloud_vpn.local_router.unique_id, null)


      uuidv5 = format("cr-l-vpn-%s", uuidv5("x500", join(",", [for k, v in {
        NAME        = try(cloud_vpn.local_router.name, null) != null ? cloud_vpn.local_router.name : "UNKNOWN"
        PREFIX      = try(cloud_vpn.prefix, null) != null ? cloud_vpn.prefix : "UNKNOWN"
        ENVIRONMENT = try(cloud_vpn.environment, null) != null ? cloud_vpn.environment : "UNKNOWN"
        LABEL       = try(cloud_vpn.label, null) != null ? cloud_vpn.label : "UNKNOWN"
        UNIQUE_ID   = try(cloud_vpn.local_router.unique_id, null) != null ? cloud_vpn.local_router.unique_id : "UNKNOWN"
        PROJECT_ID  = try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id,
        NETWORK     = try(cloud_vpn.network, null) != null ? cloud_vpn.network : var.network
        REGION      = try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region
        BGP_ASN     = try(cloud_vpn.local_router.bgp.asn, null) != null ? cloud_vpn.local_router.bgp.asn : "UNKNOWN"
        } : "${k}=${v}"])
      ))

      pre_existing = try(cloud_vpn.local_router.pre_existing, false)
      bgp = {
        asn                  = try(cloud_vpn.local_router.bgp.asn, null)
        advertise_mode       = lookup(local.lookups_bgp_advertise_mode, try(cloud_vpn.local_router.bgp.local_subnet_advertisements, "DEFAULT"))
        advertised_groups    = try(cloud_vpn.local_router.bgp.local_subnet_advertisements, "DEFAULT") == "DEFAULT_CUSTOM" ? ["ALL_SUBNETS"] : []
        advertised_ip_ranges = try(cloud_vpn.local_router.bgp.custom_local_subnet_advertisements, [])
      }
    }


    local_vpn_gateway = {
      name      = try(cloud_vpn.local_vpn_gateway.name, null)
      unique_id = try(cloud_vpn.local_vpn_gateway.unique_id, null)

      uuidv5 = format("ha-l-vpn-%s", uuidv5("x500", join(",", [for k, v in {
        NAME        = try(cloud_vpn.local_vpn_gateway.name, null) != null ? cloud_vpn.local_vpn_gateway.name : "UNKNOWN"
        PREFIX      = try(cloud_vpn.prefix, null) != null ? cloud_vpn.prefix : "UNKNOWN"
        ENVIRONMENT = try(cloud_vpn.environment, null) != null ? cloud_vpn.environment : "UNKNOWN"
        LABEL       = try(cloud_vpn.label, null) != null ? cloud_vpn.label : "UNKNOWN"
        UNIQUE_ID   = try(cloud_vpn.local_vpn_gateway.unique_id, null) != null ? cloud_vpn.local_vpn_gateway.unique_id : "UNKNOWN"
        PROJECT_ID  = try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id,
        NETWORK     = try(cloud_vpn.network, null) != null ? cloud_vpn.network : var.network
        REGION      = try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region
        VPN_TYPE    = try(cloud_vpn.vpn_type, null) != null ? cloud_vpn.vpn_type : "HA"
        STACK_TYPE  = try(cloud_vpn.local_vpn_gateway.stack_type, null) != null ? cloud_vpn.local_vpn_gateway.stack_type : local.default_ha_vpn_gateways.stack_type
        } : "${k}=${v}"])
      ))

      stack_type = try(cloud_vpn.local_vpn_gateway.stack_type, null) != null ? cloud_vpn.local_vpn_gateway.stack_type : local.default_ha_vpn_gateways.stack_type

      ## Clean up ##
      # ike_version = try(endpoint.local_vpn_gateway.ike_version, null) != null ? endpoint.local_vpn_gateway.ike_version : local.default_ha_vpn_gateways.ike_version
      # vpn_type   = try(endpoint.local_vpn_gateway.vpn_type, null) != null ? endpoint.local_vpn_gateway.vpn_type : "HA"
      ## Clean up ##

      pre_existing = try(cloud_vpn.local_vpn_gateway.pre_existing, false)
    }

    ### Remote VPN Gateway -- TO --> GCP
    remote_vpn_gateways_gcp = [for v1 in try(cloud_vpn.remote_vpn_gateways, {}) : {
      name      = try(v1.remote_vpn_gateway.name, null)
      unique_id = try(v1.remote_vpn_gateway.unique_id, null)

      project_id = try(v1.remote_vpn_gateway.project_id, null) != null ? v1.project_id : try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id
      network    = try(v1.remote_vpn_gateway.network, null)
      region     = lower(try(v1.remote_vpn_gateway.region, null) != null ? v1.remote_vpn_gateway.region : try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region)

      uuidv5 = format("ha-r-vpn-%s", uuidv5("x500", join(",", [for k, v in {
        NAME        = try(v1.remote_vpn_gateway.name, null) != null ? v1.remote_vpn_gateway.name : "UNKNOWN"
        PREFIX      = try(cloud_vpn.prefix, null) != null ? cloud_vpn.prefix : "UNKNOWN"
        ENVIRONMENT = try(cloud_vpn.environment, null) != null ? cloud_vpn.environment : "UNKNOWN"
        LABEL       = try(cloud_vpn.label, null) != null ? cloud_vpn.label : "UNKNOWN"
        UNIQUE_ID   = try(v1.remote_vpn_gateway.unique_id, null) != null ? v1.remote_vpn_gateway.unique_id : "UNKNOWN"
        PROJECT_ID  = try(v1.remote_vpn_gateway.project_id, null) != null ? v1.remote_vpn_gateway.project_id : try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id
        NETWORK     = v1.remote_vpn_gateway.network
        REGION      = try(v1.remote_vpn_gateway.region, null) != null ? v1.remote_vpn_gateway.region : try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region
        } : "${k}=${v}"])
      ))

      pre_existing = try(v1.remote_vpn_gateway.pre_existing, false)
      ike_version  = try(v1.remote_vpn_gateway.ike_version, null) != null ? v1.remote_vpn_gateway.ike_version : local.default_ha_vpn_gateways.ike_version
      tunnel_count = try(v1.remote_vpn_gateway.tunnel_count, null) != null ? v1.remote_vpn_gateway.tunnel_count : local.defaults_endpoints.tunnel_count

      advanced_tunnel_configuration = try(v1.remote_router.bgp.advanced_tunnel_configuration, null)

      remote_router = {
        name      = try(v1.remote_router.name, null)
        unique_id = try(v1.remote_router.unique_id, null)

        pre_existing = try(v1.remote_router.pre_existing, false),

        uuidv5 = format("cr-r-vpn-%s", uuidv5("x500", join(",", [for k, v in {
          NAME        = try(v1.remote_router.name, null) != null ? v1.remote_router.name : "UNKNOWN"
          PREFIX      = try(cloud_vpn.prefix, null) != null ? cloud_vpn.prefix : "UNKNOWN"
          ENVIRONMENT = try(cloud_vpn.environment, null) != null ? cloud_vpn.environment : "UNKNOWN"
          LABEL       = try(cloud_vpn.label, null) != null ? cloud_vpn.label : "UNKNOWN"
          UNIQUE_ID   = try(v1.remote_router.unique_id, null) != null ? v1.remote_vpn_gateway.remote_router.unique_id : "UNKNOWN",
          PROJECT_ID  = try(v1.remote_vpn_gateway.project_id, null) != null ? v1.project_id : try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id
          PROJECT_ID  = try(v1.remote_vpn_gateway.project_id, null) != null ? v1.remote_vpn_gateway.project_id : try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id
          NETWORK     = v1.remote_vpn_gateway.network
          # REGION      = try(v1.remote_vpn_gateway.region, null) != null ? v1.region : endpoint.region
          REGION  = try(v1.remote_vpn_gateway.region, null) != null ? v1.remote_vpn_gateway.region : try(cloud_vpn.region, null) != null ? cloud_vpn.region : var.region
          BGP_ASN = try(v1.remote_router.bgp.asn, null) != null ? v1.remote_router.bgp.asn : "UNKNOWN",
          } : "${k}=${v}"])
        ))

        bgp = {
          asn                  = try(v1.remote_router.bgp.asn, null)
          advertise_mode       = lookup(local.lookups_bgp_advertise_mode, try(v1.remote_router.bgp.remote_subnet_advertisements, "DEFAULT"))
          advertised_groups    = try(v1.remote_router.bgp.remote_subnet_advertisements, "DEFAULT") == "DEFAULT_CUSTOM" ? ["ALL_SUBNETS"] : []
          advertised_ip_ranges = try(v1.remote_router.bgp.custom_remote_subnet_advertisements, [])
        }

      }

      # router = {
      #   name      = try(lower(v1.remote_vpn_gateway.remote_router.name), null)
      #   unique_id = try(v1.remote_vpn_gateway.remote_router.unique_id, null)

      #   pre_existing = try(v1.remote_router.pre_existing, false),

      #   uuidv5 = format("cr-r-vpn-%s", uuidv5("x500", join(",", [for k, v in {
      #     NAME        = try(v1.remote_router.name, null) != null ? v1.remote_router.name : "UNKNOWN"
      #     PREFIX      = try(endpoint.prefix, null) != null ? endpoint.prefix : "UNKNOWN"
      #     ENVIRONMENT = try(endpoint.environment, null) != null ? endpoint.environment : "UNKNOWN"
      #     LABEL       = try(endpoint.label, null) != null ? endpoint.label : "UNKNOWN"
      #     UNIQUE_ID   = try(v1.remote_router.unique_id, null) != null ? v1.remote_vpn_gateway.remote_router.unique_id : "UNKNOWN",
      #     PROJECT_ID  = try(v1.remote_vpn_gateway.project_id, null) != null ? v1.project_id : try(endpoint.project_id, null) != null ? endpoint.project_id : var.project_id
      #     NETWORK     = try(v1.remote_vpn_gateway.network, null) != null ? v1.remote_vpn_gateway.network : try(endpoint.network, null) != null ? endpoint.network : var.network
      #     REGION      = try(v1.remote_vpn_gateway.region, null) != null ? v1.region : endpoint.region
      #     BGP_ASN     = try(v1.remote_router.bgp.asn, null) != null ? v1.remote_router.bgp.asn : "UNKNOWN",
      #     } : "${k}=${v}"])
      #   ))

      #   bgp = {
      #     asn = try(v1.remote_router.bgp.asn, null)
      #     # advertise_mode    = try(endpoint.remote_vpn_gateway.remote_router.bgp.remote_subnet_advertisements, null)
      #     advertise_mode       = lookup(local.lookups_bgp_advertise_mode, try(v1.remote_router.bgp.remote_subnet_advertisements, "DEFAULT"))
      #     advertised_groups    = try(v1.remote_router.bgp.remote_subnet_advertisements, "DEFAULT") == "DEFAULT_CUSTOM" ? ["ALL_SUBNETS"] : []
      #     advertised_ip_ranges = try(v1.remote_router.bgp.custom_remote_subnet_advertisements, null)
      #   }
      # }
    } if try(v1.remote_vpn_gateway_type, null) == "GCP"]

    ### Remote VPN Gateway -- TO --> External
    remote_vpn_gateways_external = [for v1 in try(cloud_vpn.remote_vpn_gateways, {}) : {
      name      = try(v1.remote_vpn_gateway.name, null)
      unique_id = try(v1.remote_vpn_gateway.unique_id, null)

      project_id = try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id
      # network    = try(cloud_vpn.network, null) != null ? cloud_vpn.network : var.network
      # region     = lower(endpoint.region)

      interfaces      = try(v1.remote_vpn_gateway.interfaces, [])
      redundancy_type = try(lookup(local.lookups_peer_vpn_gateway_redudancy_type, v1.remote_vpn_gateway.redudancy_type), local.defaults_peer_vpn_gateways.redudancy_type)

      uuidv5 = format("ha-e-vpn-%s", uuidv5("x500", join(",", [for k, v in {
        NAME            = try(v1.name, null) != null ? v1.name : "UNKNOWN",
        PREFIX          = try(cloud_vpn.prefix, null) != null ? cloud_vpn.prefix : "UNKNOWN",
        ENVIRONMENT     = try(cloud_vpn.environment, null) != null ? cloud_vpn.environment : "UNKNOWN",
        LABEL           = try(cloud_vpn.label, null) != null ? cloud_vpn.label : "UNKNOWN",
        UNIQUE_ID       = try(v1.unique_id, null) != null ? v1.unique_id : "UNKNOWN",
        PROJECT_ID      = try(cloud_vpn.project_id, null) != null ? cloud_vpn.project_id : var.project_id,
        REDUNDANCY_TYPE = try(lookup(local.lookups_peer_vpn_gateway_redudancy_type, v1.redudancy_type), local.defaults_peer_vpn_gateways.redudancy_type),
        # NETWORK         = try(endpoint.network, null) != null ? endpoint.network : var.network
        # REGION          = endpoint.region
        } : "${k}=${v}"])
      ))

      pre_existing = try(v1.remote_vpn_gateway.pre_existing, false)
      ike_version  = try(v1.remote_vpn_gateway.ike_version, null) != null ? v1.remote_vpn_gateway.ike_version : local.default_ha_vpn_gateways.ike_version
      tunnel_count = try(v1.remote_vpn_gateway.tunnel_count, null) != null ? v1.remote_vpn_gateway.tunnel_count : local.defaults_endpoints.tunnel_count

      advanced_tunnel_configuration = try(v1.remote_router.bgp.advanced_tunnel_configuration, null)

      remote_router = {
        # name      = try(lower(v1.router.name), null)
        # unique_id = try(v1.router.unique_id, null)

        # uuidv5 = format("cr-e-vpn-%s", uuidv5("x500", join(",", [for k, v in {
        #   NAME        = try(v1.router.name, null) != null ? v1.router.name : "UNKNOWN"
        #   PREFIX      = try(endpoint.prefix, null) != null ? endpoint.prefix : "UNKNOWN"
        #   ENVIRONMENT = try(endpoint.environment, null) != null ? endpoint.environment : "UNKNOWN"
        #   LABEL       = try(endpoint.label, null) != null ? endpoint.label : "UNKNOWN"
        #   UNIQUE_ID   = try(v1.router.unique_id, null) != null ? v1.router.unique_id : "UNKNOWN",
        #   BGP_ASN     = try(v1.router.bgp.asn, null) != null ? v1.router.bgp.asn : "UNKNOWN",
        #   } : "${k}=${v}"])
        # ))

        # pre_existing = true,

        bgp = {
          asn                  = v1.remote_router.bgp.asn
          advertise_mode       = lookup(local.lookups_bgp_advertise_mode, try(v1.remote_router.bgp.remote_subnet_advertisements, "DEFAULT"))
          advertised_groups    = try(v1.remote_router.bgp.remote_subnet_advertisements, "DEFAULT") == "DEFAULT_CUSTOM" ? ["ALL_SUBNETS"] : []
          advertised_ip_ranges = try(v1.remote_router.bgp.custom_remote_subnet_advertisements, [])
        }
      }


    } if try(v1.remote_vpn_gateway_type, null) == "EXTERNAL"]

  }]
}
###### ENDPOINTS - END ######


###### CLOUD ROUTERS - START ######
## Cloud Router Quots / Limits
# 5 per vpc / region
locals {
  _local_routers = distinct(flatten([for cloud_vpn in local.cloud_vpns : {

    label       = cloud_vpn.label
    prefix      = cloud_vpn.prefix
    environment = cloud_vpn.environment

    name      = cloud_vpn.local_router.name != null ? cloud_vpn.local_router.name : cloud_vpn.local_router.uuidv5
    unique_id = cloud_vpn.local_router.unique_id
    uuidv5    = cloud_vpn.local_router.uuidv5

    project_id = cloud_vpn.project_id
    region     = cloud_vpn.region
    network    = cloud_vpn.network

    pre_existing = cloud_vpn.local_router.pre_existing

    bgp = {
      asn                  = cloud_vpn.local_router.bgp.asn
      advertise_mode       = cloud_vpn.local_router.bgp.advertise_mode
      advertised_groups    = cloud_vpn.local_router.bgp.advertised_groups
      advertised_ip_ranges = cloud_vpn.local_router.bgp.advertised_ip_ranges
    }
  }]))

  _remote_routers = distinct(flatten([for cloud_vpn in local.cloud_vpns : concat(
    ### Remote VPN Gateway -- TO --> GCP
    [for k1, v1 in cloud_vpn.remote_vpn_gateways_gcp : {
      label       = cloud_vpn.label
      prefix      = cloud_vpn.prefix
      environment = cloud_vpn.environment

      name      = v1.remote_router.name != null ? v1.remote_router.name : v1.remote_router.uuidv5
      unique_id = v1.remote_router.unique_id
      uuidv5    = v1.remote_router.uuidv5

      project_id = v1.project_id
      region     = v1.region
      network    = v1.network

      pre_existing = v1.remote_router.pre_existing
      bgp = {
        asn                  = v1.remote_router.bgp.asn
        advertise_mode       = v1.remote_router.bgp.advertise_mode
        advertised_groups    = v1.remote_router.bgp.advertised_groups
        advertised_ip_ranges = v1.remote_router.bgp.advertised_ip_ranges
      }
      }
    ],
    ### Remote VPN Gateway -- TO --> External
    [for k1, v1 in cloud_vpn.remote_vpn_gateways_external : {
      label       = cloud_vpn.label
      prefix      = cloud_vpn.prefix
      environment = cloud_vpn.environment

      # name      = v1.remote_router.name != null ? v1.router.name : v1.router.uuidv5
      # unique_id = v1.router.unique_id
      # uuidv5    = v1.router.uuidv5

      project_id = v1.project_id
      region     = v1.region
      network    = v1.network

      # pre_existing = v1.router.pre_existing
      bgp = {
        asn               = v1.remote_router.bgp.asn
        advertise_mode    = v1.remote_router.bgp.advertise_mode
        advertised_groups = v1.remote_router.bgp.advertised_groups
      }
      }
    ]
  )]))

  map_local_routers  = { for local_routers in local._local_routers : local_routers.uuidv5 => local_routers }
  map_remote_routers = { for remote_routers in local._remote_routers : remote_routers.uuidv5 => remote_routers if can(remote_routers.uuidv5) }
}
## Un comment below
resource "random_integer" "random_bgp_asn" {
  for_each = { for k1, v1 in merge(local.map_local_routers, local.map_remote_routers) : k1 => v1 if v1.bgp.asn == null && v1.pre_existing == false }
  min      = 4200000000
  max      = 4294967293
  seed     = each.key
}

## Local Cloud Router logic to assign randomly generated BGP ASNs as needed
locals {
  # Update Cloud Routers to include random bgp asn if none is specified
  local_routers = { for k1, v1 in local.map_local_routers : k1 => merge(
    v1,
    {
      bgp = merge(v1.bgp, {
        asn : v1.bgp.asn != null ? v1.bgp.asn : random_integer.random_bgp_asn[k1].result
      })
    }
  ) } #if v1.pre_existing == false }

  remote_routers = { for k1, v1 in local.map_remote_routers : k1 => merge(
    v1,
    {
      bgp = merge(v1.bgp, {
        asn : v1.bgp.asn != null ? v1.bgp.asn : random_integer.random_bgp_asn[k1].result
      })
    }
  ) } #if v1.pre_existing == false }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router
resource "google_compute_router" "cloud_router" {
  for_each = { for k1, v1 in merge(local.local_routers, local.remote_routers) : k1 => v1 if v1.pre_existing == false }
  # for_each = { for k1, v1 in local.local_routers : k1 => v1 if v1.pre_existing == false }

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
    # advertised_ip_ranges = each.value.advertised_ip_ranges
  }
}

###### CLOUD ROUTERS - END ######

###### VPN GATEWAYS - START ######
## VPN Gateway Quotas / Limits
# 125 Int / Ext Gateways
locals {
  _ha_local_vpn_gateways = distinct(flatten([for cloud_vpn in local.cloud_vpns : {
    label       = cloud_vpn.label
    prefix      = cloud_vpn.prefix
    environment = cloud_vpn.environment

    name      = cloud_vpn.local_vpn_gateway.name != null ? cloud_vpn.local_vpn_gateway.name : cloud_vpn.local_vpn_gateway.uuidv5
    unique_id = cloud_vpn.local_vpn_gateway.unique_id
    uuidv5    = cloud_vpn.local_vpn_gateway.uuidv5

    project_id = cloud_vpn.project_id
    region     = cloud_vpn.region
    network    = cloud_vpn.network

    # vpn_type   = endpoint.local_vpn_gateway.vpn_type
    stack_type = cloud_vpn.local_vpn_gateway.stack_type

    pre_existing = cloud_vpn.local_vpn_gateway.pre_existing
  }]))

  map_ha_local_vpn_gateways = { for ha_local_vpn_gateways in local._ha_local_vpn_gateways : ha_local_vpn_gateways.uuidv5 => ha_local_vpn_gateways }

  _ha_remote_vpn_gateways_gcp = distinct(flatten([for cloud_vpn in local.cloud_vpns : [
    for k1, v1 in cloud_vpn.remote_vpn_gateways_gcp : {
      label       = cloud_vpn.label
      prefix      = cloud_vpn.prefix
      environment = cloud_vpn.environment

      unique_id = v1.unique_id
      name      = try(v1.name, null) != null ? v1.name : v1.uuidv5

      uuidv5 = v1.uuidv5

      project_id = v1.project_id
      region     = v1.region
      network    = v1.network

      # vpn_type   = endpoint.local_vpn_gateway.vpn_type
      stack_type = cloud_vpn.local_vpn_gateway.stack_type

      pre_existing = v1.pre_existing
    }
  ]]))

  map_ha_remote_vpn_gateways_gcp = { for v1 in local._ha_remote_vpn_gateways_gcp : v1.uuidv5 => v1 }

  _ha_remote_vpn_gateways_external = distinct(flatten([for cloud_vpn in local.cloud_vpns : [
    for k1, v1 in cloud_vpn.remote_vpn_gateways_external : {
      label       = cloud_vpn.label
      prefix      = cloud_vpn.prefix
      environment = cloud_vpn.environment

      unique_id = v1.unique_id
      name      = try(v1.name, null) != null ? v1.name : v1.uuidv5

      uuidv5 = v1.uuidv5

      project_id = v1.project_id
      region     = v1.region
      network    = v1.network

      interfaces      = v1.interfaces
      redundancy_type = v1.redundancy_type
      # vpn_type   = endpoint.local_vpn_gateway.vpn_type
      # stack_type = endpoint.local_vpn_gateway.stack_type

      pre_existing = v1.pre_existing
    }
  ]]))

  map_ha_remote_vpn_gateways_external = { for key in local._ha_remote_vpn_gateways_external : key.uuidv5 => key }

  ha_local_vpn_gateways = local.map_ha_local_vpn_gateways
  local_vpn_gateways    = local.ha_local_vpn_gateways
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway
resource "google_compute_ha_vpn_gateway" "ha_local_vpn_gateways" {
  provider = google-beta

  for_each = { for k1, v1 in local.map_ha_local_vpn_gateways : k1 => v1 if v1.pre_existing == false }

  name    = each.value.name
  project = each.value.project_id

  network = each.value.network
  region  = each.value.region

  stack_type = each.value.stack_type
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway
resource "google_compute_ha_vpn_gateway" "ha_remote_vpn_gateways_gcp" {
  provider = google-beta

  for_each = { for k1, v1 in local.map_ha_remote_vpn_gateways_gcp : k1 => v1 if v1.pre_existing == false }

  name    = each.value.name
  project = each.value.project_id

  network = each.value.network
  region  = each.value.region

  stack_type = each.value.stack_type
}

resource "google_compute_external_vpn_gateway" "ha_remote_vpn_gateways_external" {
  provider = google-beta

  for_each = { for k1, v1 in local.map_ha_remote_vpn_gateways_external : k1 => v1 if v1.pre_existing == false }

  name    = each.value.name
  project = each.value.project_id

  redundancy_type = each.value.redundancy_type

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
    [for v2 in v1.remote_vpn_gateways_gcp : [
      for i in range(v2.tunnel_count) :
      {
        region      = v1.region
        label       = v1.label
        prefix      = v1.prefix
        environment = v1.environment

        tunnel_index = i

        ike_version              = v2.ike_version
        pre_shared_secret        = try(v2.advanced_tunnel_configuration[i].static_pre_shared_secret, null)
        pre_shared_secret_method = try(v2.advanced_tunnel_configuration[i].pre_shared_secret_method, "DYNAMIC")
        # pre_shared_secret = try(v1.remote_vpn_gateway.pre_shared_secret, null)
        # try(v2.advanced_tunnel_configuration[i].local_ipv4_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].local_ipv4_address, null) : null,

        local_vpn_gateway = {
          name       = v1.local_vpn_gateway.name != null ? v1.local_vpn_gateway.name : v1.local_vpn_gateway.uuidv5
          unique_id  = v1.local_vpn_gateway.unique_id
          project_id = v1.project_id
          network    = v1.network
          stack_type = v1.local_vpn_gateway.stack_type

          local_router = {
            uuidv5 = v1.local_router.uuidv5
            name   = v1.local_router.name != null ? v1.local_router.name : v1.local_router.uuidv5
            bgp = {
              asn = local.local_routers[v1.local_router.uuidv5].bgp.asn
            }
          }
        }

        remote_vpn_gateway = {
          type = "gcp"

          uuidv5    = v2.uuidv5
          name      = v2.name != null ? v2.name : v2.uuidv5
          unique_id = v2.unique_id

          remote_router = {
            name   = v2.remote_router.name != null ? v2.remote_router.name : v2.remote_router.uuidv5,
            uuidv5 = v2.remote_router.uuidv5,
            bgp = {
              asn = local.remote_routers[v2.remote_router.uuidv5].bgp.asn
            }
          }

          project_id   = v2.project_id
          network      = v2.network
          region       = v2.region
          pre_existing = try(v2.pre_existing, null) != null ? v2.pre_existing : false
          interfaces   = []
        }


        bgp_peers = {
          local_ipv4_address  = try(v2.advanced_tunnel_configuration[i].local_ipv4_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].local_ipv4_address, null) : null,
          local_ipv6_address  = try(v2.advanced_tunnel_configuration[i].local_ipv6_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].local_ipv6_address, null) : null,
          remote_ipv4_address = try(v2.advanced_tunnel_configuration[i].remote_ipv4_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].remote_ipv4_address, null) : null,
          remote_ipv6_address = try(v2.advanced_tunnel_configuration[i].remote_ipv6_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].remote_ipv6_address, null) : null,

          ## If remote_router.bgp.advanced_tunnel_configuration[i].disabled is true then set enabled `false` so that the bgp_peer is disabled
          enabled                   = try(v2.advanced_tunnel_configuration[i].bgp_advertisement_disabled, false) != true
          advertised_route_priority = try(v2.advanced_tunnel_configuration[i].advertised_route_priority, null)

          ipv6_enabled = try(v2.advanced_tunnel_configuration[i].ipv6_enabled, local.default_bgp_peers.ipv6_enabled),
        }
      }
      ]
    ],
    ### Remote VPN Gateway -- TO --> External
    [for v2 in v1.remote_vpn_gateways_external : [
      for i in range(v2.tunnel_count) : {
        region      = v1.region
        label       = v1.label
        prefix      = v1.prefix
        environment = v1.environment

        # ike_version       = v1.local_vpn_gateway.ike_version
        ike_version = v2.ike_version
        # pre_shared_secret = v2.pre_shared_secret
        pre_shared_secret        = try(v2.advanced_tunnel_configuration[i].static_pre_shared_secret, null)
        pre_shared_secret_method = try(v2.advanced_tunnel_configuration[i].pre_shared_secret_method, "DYNAMIC")

        local_vpn_gateway = {
          name       = v1.local_vpn_gateway.name != null ? v1.local_vpn_gateway.name : v1.local_vpn_gateway.uuidv5
          unique_id  = v1.local_vpn_gateway.unique_id
          project_id = v1.project_id
          network    = v1.network
          stack_type = v1.local_vpn_gateway.stack_type

          local_router = {
            uuidv5 = v1.local_router.uuidv5
            name   = v1.local_router.name != null ? v1.local_router.name : v1.local_router.uuidv5
            bgp = {
              asn = local.local_routers[v1.local_router.uuidv5].bgp.asn
            }
          }
        }

        remote_vpn_gateway = {
          uuidv5    = v2.uuidv5
          name      = v2.name != null ? v2.name : v2.uuidv5
          unique_id = v2.unique_id

          type = "external"
          remote_router = {
            # name   = v2.router.name != null ? v2.router.name : v2.router.uuidv5,
            # uuidv5 = v2.router.uuidv5,
            bgp = {
              asn = v2.remote_router.bgp.asn #local.remote_routers[v2.router.uuidv5].bgp.asn
            }
          }

          project_id   = v2.project_id
          network      = v2.network
          region       = v2.region
          pre_existing = true

          interfaces = v2.interfaces
        }

        # ike_version = try(v1.local_vpn_gateway.ike_version, null) != null ? v1.local_vpn_gateway.ike_version : local.default_ha_vpn_gateways.ike_version

        tunnel_index = i

        bgp_peers = {
          local_ipv4_address  = try(v2.advanced_tunnel_configuration[i].local_ipv4_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].local_ipv4_address, null) : null,
          local_ipv6_address  = try(v2.advanced_tunnel_configuration[i].local_ipv6_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].local_ipv6_address, null) : null,
          remote_ipv4_address = try(v2.advanced_tunnel_configuration[i].remote_ipv4_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].remote_ipv4_address, null) : null,
          remote_ipv6_address = try(v2.advanced_tunnel_configuration[i].remote_ipv6_address, null) != "" ? try(v2.advanced_tunnel_configuration[i].remote_ipv6_address, null) : null,

          ## If remote_router.bgp.advanced_tunnel_configuration[i].disabled is true then set enabled `false` so that the bgp_peer is disabled
          enabled                   = try(v2.advanced_tunnel_configuration[i].bgp_advertisement_disabled, false) != true
          advertised_route_priority = try(v2.advanced_tunnel_configuration[i].advertised_route_priority, null)

          ipv6_enabled = try(v2.bgp_peers[i].ipv6_enabled, local.default_bgp_peers.ipv6_enabled),
        }
      }
      ]
    ])
  ])

  map_local_vpn_tunnels = { for vpn_tunnel in local._vpn_tunnels : format("vpn-%s-tunnel-%s",
    lookup({ "external" = "l-e", "gcp" = "l-r" }, vpn_tunnel.remote_vpn_gateway.type, "l-u")
    , uuidv5("x500", join(",", [for k, v in {
      PREFIX                        = try(vpn_tunnel.prefix, null) != null ? vpn_tunnel.prefix : "UNKNOWN",
      ENVIRONMENT                   = try(vpn_tunnel.environment, null) != null ? vpn_tunnel.environment : "UNKNOWN",
      LABEL                         = try(vpn_tunnel.label, null) != null ? vpn_tunnel.label : "UNKNOWN",
      PROJECT_ID                    = vpn_tunnel.local_vpn_gateway.project_id,
      NETWORK                       = vpn_tunnel.local_vpn_gateway.network,
      ROUTER_NAME                   = vpn_tunnel.local_vpn_gateway.local_router.name,
      LOCAL_VPN_GATEWAY_NAME        = vpn_tunnel.local_vpn_gateway.name,
      LOCAL_VPN_GATEWAY_UNIQUE_ID   = try(vpn_tunnel.local_vpn_gateway.unique_id, null) != null ? vpn_tunnel.local_vpn_gateway.unique_id : "UNKNOWN",
      TUNNEL_INDEX                  = vpn_tunnel.tunnel_index,
      REMOTE_VPN_GATEWAY_UUIDV5     = vpn_tunnel.remote_vpn_gateway.uuidv5,
      REMOTE_VPN_GATEWAY_TYPE       = vpn_tunnel.remote_vpn_gateway.type,
      REMOTE_VPN_GATEWAY_PROJECT_ID = try(vpn_tunnel.remote_vpn_gateway.project_id) != null ? vpn_tunnel.remote_vpn_gateway.project_id : "UNKNOWN",
      REMOTE_VPN_GATEWAY_NETWORK    = try(vpn_tunnel.remote_vpn_gateway.network, null) != null ? vpn_tunnel.remote_vpn_gateway.network : "UNKNOWN",
      REMOTE_VPN_GATEWAY_NAME       = try(vpn_tunnel.remote_vpn_gateway.name, null) != null ? vpn_tunnel.remote_vpn_gateway.name : "UNKNOWN",
      REMOTE_VPN_GATEWAY_UNIQUE_ID  = try(vpn_tunnel.remote_vpn_gateway.unique_id, null) != null ? vpn_tunnel.remote_vpn_gateway.unique_id : "UNKNOWN",
    } : "${k}=${v}"]))) => vpn_tunnel
  }
}

## Generate random binary string to be converted to subnet range within 169.254.0.0/16
resource "random_string" "subnet_binary" {
  for_each         = { for k1, v1 in local.map_local_vpn_tunnels : k1 => "" if v1.bgp_peers.local_ipv4_address == null }
  lower            = false
  upper            = false
  numeric          = false
  special          = true
  override_special = "01"

  length = 14
}

resource "random_string" "pre_shared_secret" {
  for_each = toset([for k1, v1 in local.map_local_vpn_tunnels : k1 if v1.pre_shared_secret_method == "DYNAMIC"])
  length   = 32
  special  = false
}

locals {
  local_vpn_tunnels = { for k1, v1 in local.map_local_vpn_tunnels : k1 => merge(
    v1,
    {
      bgp_peers = merge(v1.bgp_peers, {
        _local_ipv4_address : v1.bgp_peers.local_ipv4_address,
        local_ipv4_address : (
          v1.bgp_peers.local_ipv4_address != null ? v1.bgp_peers.local_ipv4_address : cidrhost(cidrsubnet("169.254.0.0/16", 14, parseint(random_string.subnet_binary[k1].result, 2)), 1)
        ),
        _remote_ipv4_address : v1.bgp_peers.remote_ipv4_address,
        remote_ipv4_address : (
          v1.bgp_peers.remote_ipv4_address != null ? v1.bgp_peers.remote_ipv4_address : cidrhost(cidrsubnet("169.254.0.0/16", 14, parseint(random_string.subnet_binary[k1].result, 2)), 2)
        ),
      }),
      # pre_shared_secret = v1.pre_shared_secret != null ? v1.pre_shared_secret : random_string.pre_shared_secret[k1].result,
      pre_shared_secret = v1.pre_shared_secret_method == "STATIC" ? v1.pre_shared_secret : random_string.pre_shared_secret[k1].result
    }
  ) }

  remote_vpn_tunnels = { for k1, v1 in local.local_vpn_tunnels : format("vpn-r-l-tunnel-%s", uuidv5("x500", join(",",
    [for k2, v2 in {
      PREFIX                      = try(v1.prefix, null) != null ? v1.prefix : "UNKNOWN",
      ENVIRONMENT                 = try(v1.environment, null) != null ? v1.environment : "UNKNOWN",
      LABEL                       = try(v1.label, null) != null ? v1.label : "UNKNOWN",
      PROJECT_ID                  = try(v1.remote_vpn_gateway.project_id) != null ? v1.remote_vpn_gateway.project_id : "UNKNOWN",     ## vpn_tunnel.local_vpn_gateway.project_id,
      NETWORK                     = try(v1.remote_vpn_gateway.network, null) != null ? v1.remote_vpn_gateway.network : "UNKNOWN",     ## vpn_tunnel.local_vpn_gateway.network,
      ROUTER_NAME                 = try(v1.remote_vpn_gateway.remote_router.name, "UNKNOWN"),                                         ## vpn_tunnel.local_vpn_gateway.router.name,
      LOCAL_VPN_GATEWAY_NAME      = try(v1.remote_vpn_gateway.name, null) != null ? v1.remote_vpn_gateway.name : "UNKNOWN",           ## try(v1.remote_vpn_gateway.name, null) != null ? v1.remote_vpn_gateway.name : "UNKNOWN", ## vpn_tunnel.local_vpn_gateway.name,
      LOCAL_VPN_GATEWAY_UNIQUE_ID = try(v1.remote_vpn_gateway.unique_id, null) != null ? v1.remote_vpn_gateway.unique_id : "UNKNOWN", ## try(vpn_tunnel.local_vpn_gateway.unique_id, null) != null ? vpn_tunnel.local_vpn_gateway.unique_id : "UNKNOWN",
      TUNNEL_INDEX                = v1.tunnel_index,
      # BGP_LOCAL_IP_ADDRESS        = v1.bgp_peers._remote_ipv4_address
      # BGP_LOCAL_IP_ADDRESS          = try(local.map_local_vpn_tunnels[k1].bgp_peers.remote_ipv4_address, null) != null ? local.map_local_vpn_tunnels[k1].bgp_peers.remote_ipv4_address : "UNKNOWN", ## try(vpn_tunnel.bgp_peers.local_ipv4_address, null) != null ? vpn_tunnel.bgp_peers.local_ipv4_address : "UNKNOWN",
      REMOTE_VPN_GATEWAY_UUIDV5     = v1.remote_vpn_gateway.uuidv5,
      REMOTE_VPN_GATEWAY_TYPE       = v1.remote_vpn_gateway.type,
      REMOTE_VPN_GATEWAY_PROJECT_ID = v1.local_vpn_gateway.project_id,                                                               ## try(vpn_tunnel.remote_vpn_gateway.project_id) != null ? vpn_tunnel.remote_vpn_gateway.project_id : "UNKNOWN",
      REMOTE_VPN_GATEWAY_NETWORK    = v1.local_vpn_gateway.network,                                                                  ## try(vpn_tunnel.remote_vpn_gateway.network, null) != null ? vpn_tunnel.remote_vpn_gateway.network : "UNKNOWN",
      REMOTE_VPN_GATEWAY_NAME       = v1.local_vpn_gateway.name,                                                                     ## try(vpn_tunnel.remote_vpn_gateway.name, null) != null ? vpn_tunnel.remote_vpn_gateway.name : "UNKNOWN",
      REMOTE_VPN_GATEWAY_UNIQUE_ID  = try(v1.local_vpn_gateway.unique_id, null) != null ? v1.local_vpn_gateway.unique_id : "UNKNOWN" ## try(vpn_tunnel.remote_vpn_gateway.unique_id, null) != null ? vpn_tunnel.remote_vpn_gateway.unique_id : "UNKNOWN",
    } : "${k2}=${v2}"]))) => v1
  }

  # # Checks to see if there is a conflict in specified cloud router naming && bgp asn numbers
  # vpn_tunnels_error_check = lookup(
  #   { false = "PASS", true = "FAIL" },
  #   contains(
  #     {
  #       for key, value in local.map_vpn_tunnels : key => value if can(index([0, 2], length(compact(distinct(values(value.tunnel_addresses))))))
  #     }
  #   )
  # )
}

resource "null_resource" "local_vpn_tunnels" {
  for_each = local.local_vpn_tunnels
  triggers = {
    interfaces = md5(jsonencode(each.value.remote_vpn_gateway.interfaces))
  }
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel
resource "google_compute_vpn_tunnel" "local_vpn_tunnels" {
  provider = google-beta

  for_each = local.local_vpn_tunnels

  name = each.key

  project = each.value.local_vpn_gateway.project_id
  region  = each.value.region

  labels = {
    tunnel_index                           = each.value.tunnel_index,
    local_vpn_gateway_unique_id            = each.value.local_vpn_gateway.unique_id,
    remote_gcp_vpn_gateways_unique_id      = each.value.remote_vpn_gateway.type == "gcp" ? each.value.remote_vpn_gateway.unique_id : null,
    remote_external_vpn_gateways_unique_id = each.value.remote_vpn_gateway.type == "external" ? each.value.remote_vpn_gateway.unique_id : null,
    environment                            = each.value.environment,
    label                                  = each.value.label,
    prefix                                 = each.value.prefix,
  }

  router = format("https://www.googleapis.com/compute/v1/projects/%s/regions/%s/routers/%s",
    each.value.local_vpn_gateway.project_id,
    each.value.region,
    each.value.local_vpn_gateway.local_router.name,
  )

  vpn_gateway = format("https://www.googleapis.com/compute/v1/projects/%s/regions/%s/vpnGateways/%s",
    each.value.local_vpn_gateway.project_id,
    each.value.region,
    each.value.local_vpn_gateway.name,
  )

  peer_gcp_gateway = each.value.remote_vpn_gateway.type == "gcp" ? format("https://www.googleapis.com/compute/v1/projects/%s/regions/%s/vpnGateways/%s",
    each.value.remote_vpn_gateway.project_id,
    each.value.region,
    each.value.remote_vpn_gateway.name,
  ) : null

  peer_external_gateway = each.value.remote_vpn_gateway.type == "external" ? format("https://www.googleapis.com/compute/v1/projects/%s/global/externalVpnGateways/%s",
    each.value.remote_vpn_gateway.project_id,
    each.value.remote_vpn_gateway.name,
  ) : null

  peer_external_gateway_interface = each.value.remote_vpn_gateway.type == "external" ? each.value.tunnel_index : null

  # peer_external_gateway_interface = each.value.remote_vpn_gateway.type == "external" ? ceil(each.value.tunnel_index % 1) : null

  vpn_gateway_interface = each.value.remote_vpn_gateway.type == "external" ? ceil(each.value.tunnel_index % 1) : each.value.tunnel_index

  ike_version   = each.value.ike_version
  shared_secret = each.value.pre_shared_secret

  depends_on = [
    random_integer.random_bgp_asn,
    random_string.pre_shared_secret,
    random_string.subnet_binary,
    google_compute_router.cloud_router,
    google_compute_ha_vpn_gateway.ha_local_vpn_gateways,
    google_compute_external_vpn_gateway.ha_remote_vpn_gateways_external,
  ]
  # local.local_vpn_tunnels["vpn-l-e-tunnel-e80997ab-bf76-5b0e-925f-4e7716738116"].remote_vpn_gateway.name
  # https://www.googleapis.com/compute/v1/projects/rteller-demo-hst-e265-aaaa/global/externalVpnGateways/ha-e-vpn-130d0aca-a18c-5268-963b-e63426619578
  # "vpn-l-e-tunnel-e80997ab-bf76-5b0e-925f-4e7716738116"
  # lifecycle {
  #   replace_triggered_by = [
  #     google_compute_router_interface.remote_router_interfaces[each.key].ip_range
  #   ]
  # }

  lifecycle {
    replace_triggered_by = [
      null_resource.local_vpn_tunnels[each.key].id
      # google_compute_external_vpn_gateway.ha_remote_vpn_gateways_external[each.value.remote_vpn_gateway.name].interface
      # google_compute_external_vpn_gateway.ha_remote_vpn_gateways_external["${local.local_vpn_tunnels[each.key].remote_vpn_gateway.name}"].interface
    ]
  }
}

resource "google_compute_vpn_tunnel" "remote_vpn_tunnels" {
  provider = google-beta

  for_each = { for k1, v1 in local.remote_vpn_tunnels : k1 => v1 if v1.remote_vpn_gateway.pre_existing == false }

  name = each.key

  project = each.value.remote_vpn_gateway.project_id
  region  = each.value.region

  labels = {
    tunnel_index                      = each.value.tunnel_index,
    local_vpn_gateway_unique_id       = each.value.remote_vpn_gateway.unique_id,
    remote_gcp_vpn_gateways_unique_id = each.value.local_vpn_gateway.unique_id,
  }

  router = each.value.remote_vpn_gateway.remote_router.name

  vpn_gateway = format("https://www.googleapis.com/compute/v1/projects/%s/regions/%s/vpnGateways/%s",
    each.value.remote_vpn_gateway.project_id,
    each.value.region,
    each.value.remote_vpn_gateway.name,
  )

  peer_gcp_gateway = format("https://www.googleapis.com/compute/v1/projects/%s/regions/%s/vpnGateways/%s",
    each.value.local_vpn_gateway.project_id,
    each.value.region,
    each.value.local_vpn_gateway.name,
  )

  vpn_gateway_interface = each.value.tunnel_index
  ike_version           = each.value.ike_version
  shared_secret         = each.value.pre_shared_secret

  depends_on = [
    random_integer.random_bgp_asn,
    random_string.pre_shared_secret,
    random_string.subnet_binary,
    google_compute_router.cloud_router,
    google_compute_ha_vpn_gateway.ha_local_vpn_gateways,
    google_compute_ha_vpn_gateway.ha_remote_vpn_gateways_gcp,
  ]
}

# # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface
resource "google_compute_router_interface" "local_router_interfaces" {
  for_each = local.local_vpn_tunnels
  project  = each.value.local_vpn_gateway.project_id
  region   = each.value.region

  name       = each.key
  router     = each.value.local_vpn_gateway.local_router.name
  ip_range   = format("%s/30", each.value.bgp_peers.local_ipv4_address)
  vpn_tunnel = each.key

  depends_on = [
    random_integer.random_bgp_asn,
    random_string.subnet_binary,
    google_compute_vpn_tunnel.local_vpn_tunnels
  ]
}

resource "google_compute_router_interface" "remote_router_interfaces" {
  for_each = { for k1, v1 in local.remote_vpn_tunnels : k1 => v1 if v1.remote_vpn_gateway.pre_existing == false }
  project  = each.value.remote_vpn_gateway.project_id
  region   = each.value.remote_vpn_gateway.region

  name       = each.key
  router     = each.value.remote_vpn_gateway.remote_router.name
  ip_range   = format("%s/30", each.value.bgp_peers.remote_ipv4_address)
  vpn_tunnel = each.key

  depends_on = [
    random_integer.random_bgp_asn,
    random_string.subnet_binary,
    google_compute_router.cloud_router,
    google_compute_ha_vpn_gateway.ha_local_vpn_gateways,
    google_compute_ha_vpn_gateway.ha_remote_vpn_gateways_gcp,
    google_compute_vpn_tunnel.remote_vpn_tunnels,
  ]
  lifecycle {
    replace_triggered_by = [
      # google_compute_vpn_tunnel.remote_vpn_tunnels
    ]
  }
}

# # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer
resource "google_compute_router_peer" "local_bgp_peers" {
  provider = google-beta

  for_each = local.local_vpn_tunnels

  project = each.value.local_vpn_gateway.project_id
  region  = each.value.region

  name   = each.key
  router = each.value.local_vpn_gateway.local_router.name

  advertised_route_priority = each.value.bgp_peers.advertised_route_priority

  peer_asn = each.value.remote_vpn_gateway.remote_router.bgp.asn

  enable          = each.value.bgp_peers.enabled
  peer_ip_address = each.value.bgp_peers.remote_ipv4_address

  enable_ipv6 = each.value.local_vpn_gateway.stack_type == "IPV4_IPV6" ? each.value.bgp_peers.ipv6_enabled : null

  interface = google_compute_router_interface.local_router_interfaces[each.key].name

  depends_on = [
    google_compute_router_interface.local_router_interfaces
  ]

  lifecycle {
    replace_triggered_by = [
      google_compute_router_interface.local_router_interfaces[each.key].ip_range
    ]
  }
}

resource "google_compute_router_peer" "remote_bgp_peers" {
  provider = google-beta

  for_each = { for k1, v1 in local.remote_vpn_tunnels : k1 => v1 if v1.remote_vpn_gateway.pre_existing == false }
  project  = each.value.remote_vpn_gateway.project_id
  region   = each.value.remote_vpn_gateway.region

  name   = each.key
  router = each.value.remote_vpn_gateway.remote_router.name

  peer_asn = each.value.local_vpn_gateway.local_router.bgp.asn

  enable          = each.value.bgp_peers.enabled
  peer_ip_address = each.value.bgp_peers.local_ipv4_address

  enable_ipv6 = each.value.local_vpn_gateway.stack_type == "IPV4_IPV6" ? each.value.bgp_peers.ipv6_enabled : null

  interface = google_compute_router_interface.remote_router_interfaces[each.key].name

  depends_on = [
    google_compute_router.cloud_router,
    google_compute_ha_vpn_gateway.ha_local_vpn_gateways,
    google_compute_ha_vpn_gateway.ha_remote_vpn_gateways_gcp,
    google_compute_vpn_tunnel.remote_vpn_tunnels,
    google_compute_router_interface.remote_router_interfaces,
  ]

  lifecycle {
    replace_triggered_by = [
      google_compute_router_interface.remote_router_interfaces[each.key].ip_range
    ]
  }
}
