terraform {
  required_version = "~> 0.14.4"
  backend "gcs" {
    bucket = "glasnt-tfthrow-0602-tfstate" # REPLACE ME
    prefix = "test"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.53.0"
    }
  }
}

provider "google" {
  project = var.project
}
