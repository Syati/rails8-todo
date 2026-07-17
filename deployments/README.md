# Cloud Run deployment

[日本語版](README.ja.md)

This directory deploys the Rails application to Cloud Run with GitHub Actions,
Cloud SQL for PostgreSQL, Artifact Registry, and Secret Manager. It replaces
the former App Engine configuration with a container-based Cloud Run service
and a GitHub Actions OIDC deployer service account.

## Bootstrap

1. Use separate Terraform Cloud workspaces for each environment. Both use the
   `deployments/terraform` working directory, belong to the `rails8-todo`
   Terraform Cloud Project, and have the `rails8-todo` workspace tag:

   | Environment | Workspace | Working directory |
   | --- | --- | --- |
   | Staging | `rails8-todo-stg` | `deployments/terraform` |
   | Production | `rails8-todo-prod` | `deployments/terraform` |

   In each workspace, set the non-secret Terraform variables
   `project_id` and `github_repository` (for example, `OWNER/REPOSITORY`). Do
   not add `DATABASE_URL` as a Terraform variable:
   Terraform state must not hold the database credential.
   For local value examples, see `terraform.tfvars.example`.
   Set `rails_env` to `staging` in the staging workspace and `production` in
   the production workspace.

2. Create the Secret Manager containers, Cloud SQL instance, database, and
   Artifact Registry repository with a targeted plan and apply in the
   Terraform Cloud workspace. For a CLI-driven workspace run, execute:

   ```sh
   terraform init
   terraform apply -target=google_secret_manager_secret.rails_master_key -target=google_secret_manager_secret.database_url -target=google_sql_database_instance.primary -target=google_sql_database.primary -target=google_artifact_registry_repository.application
   ```

3. Create the PostgreSQL application user outside Terraform, then add the two
   runtime secrets to Secret Manager. Use a URL-encoded password in
   `SETTINGS__DATABASE__URL`; the Unix-socket host must match the Cloud SQL
   connection name.

   ```sh
   printf %s "$(cat ../../config/master.key)" | gcloud secrets versions add rails-master-key --data-file=-
   gcloud sql users create rails8_todo --instance rails8-todo-postgres --password 'YOUR_DATABASE_PASSWORD'
   printf %s 'postgresql://rails8_todo:URL_ENCODED_PASSWORD@/rails8_todo?host=/cloudsql/YOUR_PROJECT_ID:asia-northeast1:rails8-todo-postgres' | gcloud secrets versions add database-url --data-file=-
   ```

   Set `rails_master_key_version` and `database_url_version` to the added
   version numbers (initially both `1`) in Terraform Cloud. Update those
   values as part of every secret rotation.

4. Run the initial Terraform Cloud apply. Terraform uses the public Cloud Run
   sample image only to create the first Service and Job revisions, then creates
   the GitHub Actions
   Workload Identity Federation resources; GitHub Actions can update only the
   image fields.
5. In both GitHub `staging` and `production` Environments, configure these
   non-secret variables from the matching Terraform Cloud workspace outputs:

   - `GCP_PROJECT_ID`: the Terraform `project_id` value
   - `GCP_WORKLOAD_IDENTITY_PROVIDER`: `github_actions_workload_identity_provider`
   - `GCP_DEPLOY_SERVICE_ACCOUNT`: `github_actions_service_account`

   The staging workflow runs after the `CI` workflow succeeds on `main`.
   Production is deployed manually and should be protected by approval rules.
   Both workflows serialize deployments, build `docker/app/Dockerfile`, push
   the image to Artifact Registry, run `db:migrate` in a one-task Cloud Run
   Job, and then deploy the same image to the publicly accessible Cloud Run
   service. The Job uses the runtime image, so it does not install gems or
   download Cloud SQL Auth Proxy during a build.

Cloud Run reads `rails-master-key` and `database-url` directly from Secret
Manager at instance startup. No secret-bearing deployment descriptor is written
to the repository or build workspace.
