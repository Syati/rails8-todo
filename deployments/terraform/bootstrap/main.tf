provider "google" {
  project = var.project_id
}

data "google_project" "current" {}

locals {
  tfc_subject_prefixes = [
    for workspace in var.tfc_workspaces :
    "organization:${var.tfc_organization}:project:${var.tfc_project}:workspace:${workspace}:"
  ]
}

resource "google_storage_bucket" "bootstrap_state" {
  name                        = var.state_bucket_name
  location                    = "ASIA-NORTHEAST1"
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_project_service" "required" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "storage.googleapis.com",
    "sts.googleapis.com"
  ])

  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "terraform_cloud" {
  account_id   = "terraform-cloud-runner"
  display_name = "Terraform Cloud infrastructure runner"
}

resource "google_project_iam_member" "terraform_cloud_roles" {
  for_each = toset([
    "roles/artifactregistry.admin",
    "roles/cloudsql.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/run.admin",
    "roles/secretmanager.admin",
    "roles/serviceusage.serviceUsageAdmin"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform_cloud.email}"
}

resource "google_iam_workload_identity_pool" "terraform_cloud" {
  workload_identity_pool_id = "terraform-cloud"
  display_name              = "Terraform Cloud"
}

resource "google_iam_workload_identity_pool_provider" "terraform_cloud" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.terraform_cloud.workload_identity_pool_id
  workload_identity_pool_provider_id = "terraform-cloud"
  display_name                       = "Terraform Cloud"

  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }

  attribute_condition = join(" || ", [
    for prefix in local.tfc_subject_prefixes :
    "assertion.sub.startsWith('${prefix}')"
  ])

  oidc {
    issuer_uri = "https://app.terraform.io"
  }
}

resource "google_service_account_iam_member" "terraform_cloud_workload_identity" {
  service_account_id = google_service_account.terraform_cloud.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.terraform_cloud.name}/*"
}
