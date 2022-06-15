variable "name" {
  type        = string
  description = "Name of the instance database"
}

variable "availability_type" {
  type        = string
  default     = "ZONAL"
  description = "Database availability (ZONAL or REGIONAL)"
}

variable "region" {
  type        = string
  description = "Database region location"
}

variable "tier" {
  type        = string
  description = "Database tier (instance size)"
}

variable "databases" {
  type        = set(string)
  description = "List of sql databases on this instance"
}

variable "users" {
  type        = set(string)
  description = "List of sql users allowed to connect to this instance"
}

variable "deletion_protection" {
  type        = bool
  description = "Set deletion_protection to false if this instance needs to be deleted"
  default     = true
}

variable "public" {
  type        = bool
  description = "Database public ip enabled"
  default     = false
}

variable "compute_network_id" {
  type        = string
  description = "Compute network id (must be set if public=false)"
  default     = null
}

variable "network_prefix_length" {
  type        = number
  description = "Network prefix length"
  default     = 16
}

variable "user_labels" {
  type    = map(string)
  default = {}
}

locals {
  database_version = "POSTGRES_14"
}
