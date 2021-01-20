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

resource "google_service_account" "cats_worker" {
  account_id   = "cats-worker"
  display_name = "Cats Worker SA"
}

resource "google_project_iam_binding" "service_permissions" {
  for_each = toset([
    "run.invoker", "cloudfunctions.invoker"
  ])

  role       = "roles/${each.key}"
  members    = [local.cats_worker_sa]
  depends_on = [google_service_account.cats_worker]
}
