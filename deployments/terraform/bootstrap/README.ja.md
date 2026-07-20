# Terraform Cloud 認証 bootstrap

この root は Terraform Cloud が Google Cloud を操作するための Workload Identity
Federation と実行サービスアカウントを作成します。state は環境ごとの bootstrap 専用
GCS bucket で管理します。以下は staging の例です。production では `stg` を `prod` に
読み替えてください。

1. ローカルの Application Default Credentials を設定します。

   ```sh
   gcloud auth application-default login
   ```

2. state 用 GCS bucket を一度だけ作成します。bucket 名は全 GCP で一意にします。
   この時点では backend の置き場所を作るだけで、bucket 設定は次の Terraform import
   後に管理します。

   ```sh
   gcloud storage buckets create gs://YOUR_STAGING_PROJECT_ID-rails8-todo-bootstrap-tfstate --location=asia-northeast1
   ```

3. bootstrap directory に移動し、環境固有の設定ファイルを作成します。

   ```sh
   cd deployments/terraform/bootstrap
   cp terraform.tfvars.example terraform.tfvars
   cp backend.stg.hcl.example backend.stg.hcl
   ```

   `terraform.tfvars` の `project_id`、`state_bucket_name`、`tfc_workspaces` と、
   `backend.stg.hcl` の bucket 名を設定します。`state_bucket_name` と backend の
   bucket 名は同じ値にします。これらのファイルは commit しません。

4. backend を初期化します。既に local state がある場合は `-migrate-state` を付けて
   GCS へ移管します。

   ```sh
   terraform init -migrate-state -backend-config=backend.stg.hcl
   ```

   local state がない最初の実行では、`-migrate-state` を外します。

5. bootstrap を apply します。

   ```sh
   terraform import google_storage_bucket.bootstrap_state YOUR_STAGING_PROJECT_ID-rails8-todo-bootstrap-tfstate
   terraform apply
   ```

   import 後、Terraform が bucket の Object Versioning、Uniform bucket-level access、
   Public Access Prevention、削除防止を管理します。必要な管理者だけに bucket IAM を
   付与してください。

6. `terraform output` の値を、対応する Terraform Cloud workspace の Environment
   Variables に設定します。

   ```text
   TFC_GCP_PROVIDER_AUTH=true
   TFC_GCP_PROJECT_NUMBER=<project_number>
   TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL=<service_account_email>
   TFC_GCP_WORKLOAD_POOL_ID=<workload_pool_id>
   TFC_GCP_WORKLOAD_PROVIDER_ID=<workload_provider_id>
   ```

WIF、Terraform Cloud 実行サービスアカウント、IAM 権限の変更はこの root で管理します。
