resource "google_sql_database_instance" "primary" {
  name                = "rails8-todo"
  database_version    = "POSTGRES_18"
  region              = var.region
  deletion_protection = true

  settings {
    edition           = var.cloud_sql_edition
    tier              = var.cloud_sql_tier
    availability_type = "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = 10
    disk_autoresize   = true

    backup_configuration {
      enabled = true
    }

    database_flags {
      name  = "timezone"
      value = "Asia/Tokyo"
    }
  }

  depends_on = [google_project_service.required]
}

resource "google_sql_database" "application" {
  name     = var.database_name
  instance = google_sql_database_instance.primary.name
}
