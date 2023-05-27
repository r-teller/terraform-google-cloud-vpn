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