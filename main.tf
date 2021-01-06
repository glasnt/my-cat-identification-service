provider google {
  project = var.project
}

variable project {
  type        = string
  description = "The Google Cloud Platform project name"
}

variable region {
  default = "us-central1"
  type    = string
}


module services {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 9.0"

  project_id = var.project

  activate_apis = [
    "run.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com",
  ]
}

# Storage Bucket
resource google_storage_bucket media {
  name = "${var.project}-bucket"
}

resource google_storage_bucket_object sample {
  name   = "sample"
  source = "cats/sample.jpg"
  bucket = google_storage_bucket.media.name
}

# Pre-prepared container
data google_container_registry_image cats {
  name = "cats"
}

# Service
resource google_cloud_run_service cats {
  name                       = "cats"
  location                   = var.region
  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = data.google_container_registry_image.cats.image_url
        env {
          name  = "BUCKET_NAME"
          value = google_storage_bucket.media.name
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
