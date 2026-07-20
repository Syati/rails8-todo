# Cloud Run アプリ基盤

この root は Cloud Run Service / migration Job、Cloud SQL、Secret Manager、Artifact
Registry、GitHub Actions 用 Workload Identity Federation を管理します。

## Terraform Cloud

Terraform Cloud の `rails8-todo` Project に environment ごとの VCS-driven workspace を
作成します。Working Directory は `deployments/terraform/app`、workspace tag は
`rails8-todo` です。

| 環境 | workspace | `rails_env` |
| --- | --- | --- |
| staging | `rails8-todo-stg` | `staging` |
| production | `rails8-todo-prod` | `production` |

各 workspace に Terraform Variables を設定します。

```text
project_id=<環境ごとの GCP project ID>
github_repository=mizuki-y/rails8-todo
rails_env=staging または production
```

`DATABASE_URL` と Rails master key は Terraform Cloud に設定しません。Secret Manager の
`database-url` と `rails-master-key` を Cloud Run に紐付けます。変数の形は
`terraform.tfvars.example` を参照してください。

bootstrap で作成した output を Environment Variables として設定します。

```text
TFC_GCP_PROVIDER_AUTH=true
TFC_GCP_PROJECT_NUMBER=<project_number>
TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL=<service_account_email>
TFC_GCP_WORKLOAD_POOL_ID=<workload_pool_id>
TFC_GCP_WORKLOAD_PROVIDER_ID=<workload_provider_id>
```

## GitHub Actions

Terraform apply 後、GitHub Environments に Terraform output を設定します。

| GitHub Environment | workflow | 実行方法 |
| --- | --- | --- |
| `staging` | `deploy.yml` | `main` の CI 成功後に自動実行 |
| `production` | `deploy-production.yml` | 手動実行 |

両 Environment に次の Variables を設定します。

```text
GCP_PROJECT_ID
GCP_WORKLOAD_IDENTITY_PROVIDER
GCP_DEPLOY_SERVICE_ACCOUNT
```

workflow は image を Artifact Registry に push し、migration Job の完了を待ってから同じ
image を Cloud Run Service に deploy します。
