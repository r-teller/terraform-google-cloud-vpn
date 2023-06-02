locals {
  cloud_vpn_path = "./cloud_vpns"
  cloud_vpn_sets = fileset(local.cloud_vpn_path, "*.json")
  cloud_vpns = flatten([for cloud_vpns in local.cloud_vpn_sets : [
    for cloud_vpn in jsondecode(file("${local.cloud_vpn_path}/${cloud_vpns}")) :
    merge(cloud_vpn, { fileName = split(".", cloud_vpns)[0] })
    ]
  ])
}

module "cloud_vpn" {
  source = "r-teller/cloud-vpn/google"
  # source = "../../"

  ## These fields are optional and only required if you want to specify a default value hub value for project_id,network and region if not specified in the JSON file
  ## values specified in JSON override these settings
  # project_id = var.project_id 
  # network    = var.network
  # region     = var.region
  cloud_vpns = local.cloud_vpns

  ### This flag is only needed if you want to pass in tunnel pre-shared secrets using variables instead of through JSON
  variable_pre_shared_secret = var.variable_pre_shared_secret
}

# output "locals" {
#   value = module.cloud_vpn.locals
# }

# output "vpn_tunnels_hub" {
#   value = module.cloud_vpn.locals.vpn_tunnels.hub
# }

# output "vpn_tunnels_spoke" {
#   value = module.cloud_vpn.locals.vpn_tunnels.spoke
# }
