variable "project_id" {
  type    = string
  default = null
}

variable "network" {
  type    = string
  default = null
}

variable "region" {
  type    = string
  default = null
}

variable "variable_pre_shared_secret" {
  type    = map(any)
  default = null
}
