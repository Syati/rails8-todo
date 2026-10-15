# Cloud Run アプリ基盤

この root は Cloud Run Service / migration Job、Cloud SQL、Secret Manager、Artifact
Registry、GitHub Actions 用 Workload Identity Federation を管理します。

## 1. Terraform Cloud

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
terraform_cloud_runner_service_account_email=<bootstrap の service_account_email output>
```

Rails master key は Terraform Cloud に設定しません。アプリケーションの秘密情報は環境別 Rails
credentials で管理します。`rails-master-key` だけを各 GCP project の Secret Manager に登録し、
Cloud Run Service と migration Job に渡します。

環境別 credentials は次のように作成します。生成される `.yml.enc` は commit し、対応する
`.key` は 1Password と各環境の `rails-master-key` Secret Manager secret のみに保管します。

```sh
bin/rails credentials:edit --environment staging
bin/rails credentials:edit --environment production
```

各 credentials には、少なくとも次を設定します。

```yml
database:
  password: DATABASE_PASSWORD
```

Cloud SQL の Unix socket host は Terraform が
`SETTINGS__DATABASE__HOST` として Service と migration Job の両方に渡します。project ID を
credentials に重複して設定する必要はありません。

bootstrap で作成した output を Environment Variables として設定します。

```text
TFC_GCP_PROVIDER_AUTH=true
TFC_GCP_PROJECT_NUMBER=<project_number>
TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL=<service_account_email>
TFC_GCP_WORKLOAD_POOL_ID=<workload_pool_id>
TFC_GCP_WORKLOAD_PROVIDER_ID=<workload_provider_id>
```

## 2. PostgreSQL アプリユーザー

Terraform は Cloud SQL instance と `rails8_todo` database を作成します。アプリケーション用の
PostgreSQL user は、database 作成後に `postgres` で接続して作成します。

まず `postgres` の管理用パスワードを設定し、1Password にのみ保管します。

```sh
gcloud sql users set-password postgres \
  --instance=rails8-todo \
  --prompt-for-password
```

`gcloud sql connect` で `postgres` として `rails8_todo` database に接続します。

```sh
gcloud sql connect rails8-todo \
  --project=YOUR_ENVIRONMENT_PROJECT_ID \
  --user=postgres \
  --database=rails8_todo
```

接続後に次を実行します。`\password` は対話入力のため、パスワードを SQL history に残しません。
入力するパスワードは環境別 Rails credentials の `database.password` と同じ値にします。

```sql
CREATE ROLE rails8_todo LOGIN;
\password rails8_todo

GRANT ALL PRIVILEGES ON DATABASE rails8_todo TO rails8_todo;
GRANT ALL PRIVILEGES ON SCHEMA public TO rails8_todo;
```

`gcloud sql users create rails8_todo` は、custom database role を明示しない限り
`cloudsqlsuperuser` を付与します。アプリケーション user には上記の PostgreSQL native role と
database / schema の権限を使います。新規 table は migration Job が `rails8_todo` 所有者として
作成するため、追加の table 権限は不要です。

## 3. GitHub Actions

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
