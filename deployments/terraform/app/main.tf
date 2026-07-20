provider "google" {
  project = var.project_id
  region  = var.region
}

module "application" {
  source = "./modules/application"

  project_id               = var.project_id
  region                   = var.region
  rails_env                = var.rails_env
  github_repository        = var.github_repository
  bootstrap_image          = var.bootstrap_image
  database_name            = var.database_name
  rails_master_key_version = var.rails_master_key_version
  cloud_run_max_instances  = var.cloud_run_max_instances
  cloud_run_concurrency    = var.cloud_run_concurrency
  rails_max_threads        = var.rails_max_threads
  migration_task_timeout   = var.migration_task_timeout
  cloud_sql_edition        = var.cloud_sql_edition
  cloud_sql_tier           = var.cloud_sql_tier
}
