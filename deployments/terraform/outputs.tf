output "cloud_run_service_name" {
  value = module.application.cloud_run_service_name
}

output "cloud_run_service_url" {
  value = module.application.cloud_run_service_url
}

output "artifact_registry_repository" {
  value = module.application.artifact_registry_repository
}

output "cloud_sql_connection_name" {
  value = module.application.cloud_sql_connection_name
}

output "github_actions_service_account" {
  value = module.application.github_actions_service_account
}

output "github_actions_workload_identity_provider" {
  value = module.application.github_actions_workload_identity_provider
}
