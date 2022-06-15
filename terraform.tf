terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
