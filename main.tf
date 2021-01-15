terraform {
  backend "gcs" {
    bucket = "glasnt-terraform-3476-tfstate" # REPLACE ME
    prefix = "test"
  }
}

provider "google" {
  project = var.project
}

####
#
# Required Variables
#
####
variable "project" {
  type        = string
  description = "Google Cloud Platform Project ID"
}

variable "region" {
  default = "us-central1"
  type    = string
}

locals {
  function_folder   = "processing-function"
  service_folder    = "web-service"
  sampledata_folder = "sample-data"

  deployment_name = "cats"
}

####
#
# Project setup
#
###

module "services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 10.0"

  project_id = var.project

  activate_apis = [
    "run.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "vision.googleapis.com"
  ]
}


####
#
# sample-data
#
####

# Media Storage Bucket
resource "google_storage_bucket" "media" {
  name = "${var.project}-media"
}

# Upload all sample data objects
resource "google_storage_bucket_object" "cats" {
  for_each = fileset("${path.module}/${local.sampledata_folder}", "*")

  name   = each.value
  source = "${path.module}/${local.sampledata_folder}/${each.value}"
  bucket = google_storage_bucket.media.name
}

# 

# Pre-prepared container
data "google_container_registry_image" "cats" {
  name = local.service_folder
  #  provisioner "local-exec" {
  #    command = "gcloud builds submit web-service --tag gcr.io/${var.project}/cats"
  #  }
}

####
#
# web-service
#
###

# Cloud Run Service
resource "google_cloud_run_service" "cats" {
  name                       = local.deployment_name
  location                   = var.region
  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = "${data.google_container_registry_image.cats.image_url}:latest"
        env {
          name  = "BUCKET_NAME"
          value = google_storage_bucket.media.name
        }
        env {
          name  = "FUNCTION_NAME"
          value = google_cloudfunctions_function.function.https_trigger_url
        }
      }
    }
  }
}

# Public Access IAM
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.cats.location
  project  = google_cloud_run_service.cats.project
  service  = google_cloud_run_service.cats.name

  policy_data = data.google_iam_policy.noauth.policy_data
}


####
#
# processing-function
#
####

# Source Storage Bucket
resource "google_storage_bucket" "source" {
  name = "${var.project}-source"
}

# Upload created zip
# zip -j processing-function.zip processing-function/*
# https://github.com/GoogleCloudPlatform/python-docs-samples/issues/1602#issuecomment-415084417
#
# terraform apply -target google_cloudfunctions_function.function
data "archive_file" "function" {
  type = "zip"
  output_path = "function_code_${timestamp()}.zip"
  source_dir  = local.function_folder
}

resource "google_storage_bucket_object" "archive" {
  name   = "${local.function_folder}_${timestamp()}.zip" # will delete old items

  bucket = google_storage_bucket.source.name
  source = data.archive_file.function.output_path

  depends_on = [data.archive_file.function]
}

resource "google_cloudfunctions_function" "function" {
  name        = local.function_folder
  description = "processing function"
  runtime     = "python37"
  region      = var.region

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.source.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "detect_cat"
}

output "service_url" {
  value = <<EOF
  Service deployed to ${google_cloud_run_service.cats.status[0].url} 🐈
  EOF
}