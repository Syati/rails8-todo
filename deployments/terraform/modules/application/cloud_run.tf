locals {
  cloud_run_environment = {
    RAILS_ENV         = "production"
    RAILS_MAX_THREADS = tostring(var.rails_max_threads)
  }
}

resource "google_cloud_run_v2_service" "application" {
  name     = "rails8-todo"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account                  = google_service_account.cloud_run.email
    max_instance_request_concurrency = var.cloud_run_concurrency

    scaling {
      max_instance_count = var.cloud_run_max_instances
    }

    containers {
      image = var.bootstrap_image

      ports {
        container_port = 80
      }

      dynamic "env" {
        for_each = local.cloud_run_environment

        content {
          name  = env.key
          value = env.value
        }
      }

      env {
        name = "RAILS_MASTER_KEY"

        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.rails_master_key.secret_id
            version = var.rails_master_key_version
          }
        }
      }

      env {
        name = "SETTINGS__DATABASE__URL"

        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.database_url.secret_id
            version = var.database_url_version
          }
        }
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    volumes {
      name = "cloudsql"

      cloud_sql_instance {
        instances = [google_sql_database_instance.primary.connection_name]
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }

  depends_on = [
    google_project_iam_member.cloud_run_runtime_roles,
    google_secret_manager_secret.rails_master_key,
    google_secret_manager_secret.database_url
  ]
}

resource "google_cloud_run_v2_job" "migrate" {
  name     = "rails8-todo-migrate"
  location = var.region

  template {
    template {
      service_account = google_service_account.cloud_run.email
      max_retries     = 0
      timeout         = var.migration_task_timeout

      containers {
        image   = var.bootstrap_image
        command = ["bundle"]
        args    = ["exec", "rails", "db:migrate"]

        dynamic "env" {
          for_each = local.cloud_run_environment

          content {
            name  = env.key
            value = env.value
          }
        }

        env {
          name = "RAILS_MASTER_KEY"

          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.rails_master_key.secret_id
              version = var.rails_master_key_version
            }
          }
        }

        env {
          name = "SETTINGS__DATABASE__URL"

          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.database_url.secret_id
              version = var.database_url_version
            }
          }
        }

        volume_mounts {
          name       = "cloudsql"
          mount_path = "/cloudsql"
        }
      }

      volumes {
        name = "cloudsql"

        cloud_sql_instance {
          instances = [google_sql_database_instance.primary.connection_name]
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].template[0].containers[0].image]
  }

  depends_on = [
    google_project_iam_member.cloud_run_runtime_roles,
    google_secret_manager_secret.rails_master_key,
    google_secret_manager_secret.database_url
  ]
}
