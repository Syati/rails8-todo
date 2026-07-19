output "project_number" {
  value = data.google_project.current.number
}

output "service_account_email" {
  value = google_service_account.terraform_cloud.email
}

output "workload_pool_id" {
  value = google_iam_workload_identity_pool.terraform_cloud.workload_identity_pool_id
}

output "workload_provider_id" {
  value = google_iam_workload_identity_pool_provider.terraform_cloud.workload_identity_pool_provider_id
}
