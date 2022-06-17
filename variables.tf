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

variable "user_labels" {
  type    = map(string)
  default = {}
}

locals {
  database_version     = "POSTGRES_14"
  user_password_length = 32
}
