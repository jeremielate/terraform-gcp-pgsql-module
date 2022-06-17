variable "gcp_region" {
  type    = string
  default = "europe-west1"
}

variable "gcp_zone" {
  type    = string
  default = "d"
}

variable "gcp_subnetworks" {
  type = map(string)
  default = {
    "europe-west1" = "10.80.0.0/16"
  }
}
