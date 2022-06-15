variable "name" {
  type        = string
  description = "Name of the instance database"
}

variable "database_version" {
  type        = string
  default     = "POSTGRES_14"
  description = "Database version of the instance"
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
  type        = map(object({ name = string, username = string }))
  description = "List of sql databases"
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
