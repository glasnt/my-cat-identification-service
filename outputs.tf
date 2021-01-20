output "service_url" {
  value = <<EOF
  Service deployed to ${google_cloud_run_service.cats.status[0].url} 🐈
  EOF
}