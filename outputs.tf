output "locals" {
  value = {
    cloud_routers = {
      hub   = local.hub_routers,
      spoke = local.spoke_routers,
    },
    vpn_tunnels = {
      hub   = local.hub_vpn_tunnels
      spoke = local.spoke_vpn_tunnels
    },
    ha_vpn_gateways = {
      hub      = local.map_ha_hub_vpn_gateways,
      spoke    = local.map_ha_spoke_vpn_gateways_gcp,
      external = local.map_ha_spoke_vpn_gateways_external
    },
  }
}

output "routers" {
  value = resource.google_compute_router.cloud_routers
}

output "interfaces" {
  value = {
    hub_interfaces   = resource.google_compute_router_interface.hub_router_interfaces
    spoke_interfaces = resource.google_compute_router_interface.spoke_router_interfaces
  }
}

output "tunnels" {
  value = {
    hub_vpn_tunnels   = resource.google_compute_vpn_tunnel.hub_vpn_tunnels
    spoke_vpn_tunnels = resource.google_compute_vpn_tunnel.spoke_vpn_tunnels
  }
}


output "gateways" {
  value = {
    hub_vpn_gateways       = resource.google_compute_ha_vpn_gateway.ha_hub_vpn_gateways
    gcp_spoke_vpn_gateways = resource.google_compute_ha_vpn_gateway.ha_spoke_vpn_gateways_gcp
    ext_spoke_vpn_gateways = resource.google_compute_external_vpn_gateway.ha_spoke_vpn_gateways_external
  }
}
