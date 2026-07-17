output "cloud_run_service_name" {
  value = google_cloud_run_v2_service.application.name
}

output "cloud_run_service_url" {
  value = google_cloud_run_v2_service.application.uri
}

output "artifact_registry_repository" {
  value = google_artifact_registry_repository.application.name
}

output "cloud_sql_connection_name" {
  value = google_sql_database_instance.primary.connection_name
}

output "github_actions_service_account" {
  value = google_service_account.github_actions_deployer.email
}

output "github_actions_workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github_actions.name
}
