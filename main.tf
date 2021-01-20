terraform {
  required_version = "~> 0.14.4"
  backend "gcs" {
    bucket = "glasnt-tfthrow-0602-tfstate" # REPLACE ME
    prefix = "test"
  }
}

provider "google" {
  project = var.project
}
