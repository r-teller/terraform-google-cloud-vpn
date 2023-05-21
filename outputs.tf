output "local_values" {
  value = {
    cloud_routers = {
      local  = local._local_routers,
      remote = local._remote_routers,
    },
    #     ha_vpn_gateways = {

    #       local  = local.map_ha_local_vpn_gateways,
    #       remote = local.map_ha_remote_vpn_gateways,
    #     },
    #     vpn_tunnels = {
    #       local                      = local.local_vpn_tunnels,
    #       remote                     = local.remote_vpn_tunnels,
    #       map_local_vpn_tunnels      = local.map_local_vpn_tunnels,
    #       subnet_ranges_managed      = local.subnet_ranges_managed,
    #       _vpn_tunnels_ranges        = local._vpn_tunnels_ranges,
    #       vpn_tunnel_ranges_assigned = local.vpn_tunnel_ranges_assigned,
    #     },
    #     _endpoints = local._endpoints
  }
}

# output "cloud_routers" {
#   value = google_compute_router.cloud_router
# }

# output "ha_vpn_gateways" {
#   value = {
#     local  = google_compute_ha_vpn_gateway.ha_local_vpn_gateways,
#     remote = google_compute_ha_vpn_gateway.ha_remote_vpn_gateways,
#   }
# }

# # output "vpn_tunnels" {
# #   value = {
# #     local  = google_compute_vpn_tunnel.local_vpn_tunnels,
# #     remtoe = google_compute_vpn_tunnel.remote_vpn_tunnels,
# #   }
# # }

# # output "router_interfaces" {
# #   value = {
# #     local  = google_compute_router_interface.local_router_interface,
# #     remote = google_compute_router_interface.remote_router_interface,
# #   }
# # }

# # output "router_peers" {
# #   value = {
# #     local  = google_compute_router_peer.local_bgp_peer,
# #     remote = google_compute_router_peer.remote_bgp_peer,
# #   }
# # }
