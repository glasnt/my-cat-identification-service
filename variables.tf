variable "project" {
  type        = string
  description = "Google Cloud Platform Project ID"
}

variable "region" {
  default = "us-central1"
  type    = string
}

locals {
  function_folder = "function"
  function_name   = "processing"

  service_folder = "service"
  service_name   = "cats"

  bucket_folder = "media"
  bucket_name   = "${var.project}-media"

  deployment_name = "cats"
  cats_worker_sa  = "serviceAccount:${google_service_account.cats_worker.email}"
}