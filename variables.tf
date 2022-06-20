variable "name" {
  type        = string
  description = "Name of the instance database"
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

variable "availability_type" {
  type        = string
  default     = "REGIONAL"
  description = "Database availability (ZONAL or REGIONAL)"
}

variable "public" {
  type        = bool
  description = "Database public ip enabled"
  default     = false
}

variable "authorized_networks" {
  type        = map(any)
  description = "Networks allowed to connect to this instance"
  default     = {}
}

variable "builtin_users" {
  type        = set(string)
  description = "List of sql users allowed to connect to this instance"
  default     = []
}

variable "iam_users" {
  type        = set(string)
  description = "List of sql users allowed to connect to this instance"
  default     = []
}

variable "iam_service_accounts" {
  type        = set(string)
  description = "List of service accounts allowed to connect to this instance"
  default     = []
}

variable "deletion_protection" {
  type        = bool
  description = "Set deletion_protection to false if this instance needs to be deleted"
  default     = true
}

variable "vpc_peering_enabled" {
  type        = bool
  description = "Create a VPC peering between the instance and the compute network"
  default     = false
}

variable "compute_network_id" {
  type        = string
  description = "Compute network id (must be set if vpc_peering=true)"
  default     = null
}

variable "network_prefix_length" {
  type        = number
  description = "Network prefix length"
  default     = 16
}

variable "backup_enabled" {
  type    = bool
  default = true
}

variable "backup_point_in_time_recovery_enabled" {
  type    = bool
  default = false
}

variable "backup_start_time" {
  type    = string
  default = "23:00"
}

variable "backup_transaction_log_retention_days" {
  type    = number
  default = 7
}

variable "backup_retained_backups" {
  type    = number
  default = 7
}

variable "maintenance_window_day" {
  type    = number
  default = 1
}

variable "maintenance_window_hour" {
  type    = number
  default = 6
}

variable "maintenance_window_update_track" {
  type    = string
  default = "stable"
}

variable "user_labels" {
  type    = map(string)
  default = {}
}

locals {
  database_version     = "POSTGRES_14"
  user_password_length = 32
  module_name          = basename(abspath(path.module))
}
