variable "project_id" {
  description = "Project id of the project that holds the network."
  default     = null
}

variable "network" {
  description = "Name of the network this set of firewall rules applies to."
  default     = null
}

variable "region" {
  description = "Name of the network this set of firewall rules applies to."
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
