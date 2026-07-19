# Terraform Cloud 認証 bootstrap

この root は Terraform Cloud が Google Cloud を操作するための Workload Identity
Federation と実行サービスアカウントを作成します。初回はローカルで作成します。

```sh
cd deployments/bootstrap
gcloud auth application-default login
cp terraform.tfvars.example terraform.tfvars
# project_id と tfc_workspaces を環境に合わせて変更する
terraform init -reconfigure
terraform apply
```

`terraform output` の値を、対応する Terraform Cloud workspace の Environment
Variables に設定します。

```text
TFC_GCP_PROVIDER_AUTH=true
TFC_GCP_PROJECT_NUMBER=<project_number>
TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL=<service_account_email>
TFC_GCP_WORKLOAD_POOL_ID=<workload_pool_id>
TFC_GCP_WORKLOAD_PROVIDER_ID=<workload_provider_id>
```

`terraform.tfvars` と local state は commit しません。state ファイルは暗号化した
バックアップに保管してください。Terraform Cloud への state 移管は、初回 apply と
Terraform Cloud 用 WIF の設定が完了した後に別変更として行います。
