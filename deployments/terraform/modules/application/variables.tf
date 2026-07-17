variable "project_id" {
  type        = string
  description = "Google Cloud project ID."
}

variable "region" {
  type        = string
  description = "Region for Cloud Run, Cloud SQL, and Artifact Registry resources."
  default     = "asia-northeast1"
}

variable "rails_env" {
  type        = string
  description = "Rails environment for this deployment."
}

variable "github_repository" {
  type        = string
  description = "GitHub repository allowed to deploy, in OWNER/REPOSITORY form."
}

variable "bootstrap_image" {
  type        = string
  description = "Image used only for Terraform's first Cloud Run Service and Job revisions. GitHub Actions replaces it on the first deployment."
}

variable "database_name" {
  type        = string
  description = "PostgreSQL database name."
  default     = "rails8_todo"
}

variable "rails_master_key_version" {
  type        = string
  description = "Pinned Secret Manager version for rails-master-key."
  default     = "1"
}

variable "database_url_version" {
  type        = string
  description = "Pinned Secret Manager version for database-url."
  default     = "1"
}

variable "cloud_run_max_instances" {
  type        = number
  description = "Maximum Cloud Run instances. Keep this aligned with Cloud SQL capacity."
  default     = 2
}

variable "cloud_run_concurrency" {
  type        = number
  description = "Maximum concurrent requests per Cloud Run instance. Keep this aligned with Rails thread and database-pool capacity."
  default     = 20
}

variable "rails_max_threads" {
  type        = number
  description = "Puma and Active Record connection-pool size per Cloud Run instance."
  default     = 5
}

variable "migration_task_timeout" {
  type        = string
  description = "Maximum execution time for a migration Job task."
  default     = "1800s"
}

variable "cloud_sql_tier" {
  type        = string
  description = "Cloud SQL machine tier."
  default     = "db-f1-micro"
}
