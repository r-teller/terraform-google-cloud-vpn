variable "project_id" {
  description = "Default Project id that holds the network."
  type        = string
  default     = null
}

variable "network" {
  description = "Name of the default network this set of cloud vpn applies to."
  type        = string
  default     = null
}

variable "peer_network" {
  description = "Name of the peer network this set of cloud vpn applies to. (This can only be passed once per module)"
  type        = string
  default     = null
}

variable "peer_project_id" {
  description = "Name of the peer project_id this set of cloud vpn applies to. (This can only be passed once per module)"
  type        = string
  default     = null
}

variable "region" {
  description = "Name of the default region this set of cloud vpn applies to."
  type        = string
  default     = null
}

variable "cloud_vpns" {
  description = "Collection of Cloud_VPN configurations described in JSON"
  type        = any
  default     = null
}

variable "variable_pre_shared_secret" {
  type    = map(any)
  default = null
}

variable "generate_random_shortnames" {
  type    = bool
  default = false
}
