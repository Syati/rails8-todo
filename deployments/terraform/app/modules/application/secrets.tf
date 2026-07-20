resource "google_secret_manager_secret" "rails_master_key" {
  secret_id = "rails-master-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.required]
}
