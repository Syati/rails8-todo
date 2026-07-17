# Cloud Run デプロイ

[English](README.md)

このディレクトリは GitHub Actions、Cloud SQL for PostgreSQL、Artifact
Registry、Secret Manager を使って Rails アプリケーションを Cloud Run に
デプロイします。従来の App Engine 構成を、コンテナベースの Cloud Run Service
と GitHub Actions OIDC デプロイ用サービスアカウントに置き換えます。

## 初期設定

1. Terraform Cloud は環境ごとに workspace を分けます。両 workspace の
   Working Directory は `deployments/terraform` とし、Terraform Cloud の
   `rails8-todo` Project 配下に置いて `rails8-todo` tag を付与します。

   | 環境 | workspace | Working Directory |
   | --- | --- | --- |
   | staging | `rails8-todo-stg` | `deployments/terraform` |
   | production | `rails8-todo-prod` | `deployments/terraform` |

   各 workspace に、機密ではない Terraform 変数
   `project_id`、`github_repository`（例: `OWNER/REPOSITORY`）を設定します。
   `DATABASE_URL` を Terraform 変数には
   設定しません。Terraform state に DB 認証情報を保持しないためです。
   ローカルで値の形を確認する場合は、`terraform.tfvars.example` を参照してください。

2. Terraform Cloud workspace で targeted plan/apply を実行し、Secret
   Manager の Secret コンテナ、Cloud SQL instance、database、Artifact
   Registry repository を作成します。CLI-driven workspace では次を実行します。

   ```sh
   terraform init
   terraform apply -target=google_secret_manager_secret.rails_master_key -target=google_secret_manager_secret.database_url -target=google_sql_database_instance.primary -target=google_sql_database.primary -target=google_artifact_registry_repository.application
   ```

3. PostgreSQL のアプリケーションユーザーは Terraform 管理外で作成し、実行時に
   利用する 2 つの値を Secret Manager に登録します。
   `SETTINGS__DATABASE__URL` 内のパスワードは URL エンコードしてください。
   Unix socket の host は Cloud SQL 接続名と一致する必要があります。

   ```sh
   printf %s "$(cat ../../config/master.key)" | gcloud secrets versions add rails-master-key --data-file=-
   gcloud sql users create rails8_todo --instance rails8-todo-postgres --password 'YOUR_DATABASE_PASSWORD'
   printf %s 'postgresql://rails8_todo:URL_ENCODED_PASSWORD@/rails8_todo?host=/cloudsql/YOUR_PROJECT_ID:asia-northeast1:rails8-todo-postgres' | gcloud secrets versions add database-url --data-file=-
   ```

   Terraform Cloud では `rails_master_key_version` と
   `database_url_version` を登録した Secret version（初回は両方 `1`）に設定
   します。Secret をローテーションする際は、これらの値も更新します。

4. 初回の Terraform Cloud apply を実行します。Terraform は公開済みの Cloud Run
   sample image を初回の Service / Job revision 作成にだけ使い、Cloud Run Service /
   Job と GitHub Actions の Workload Identity Federation を作成します。GitHub
   Actions が更新できるのは image フィールドだけです。

5. GitHub の `staging` / `production` Environment に、それぞれ対応する
   Terraform Cloud workspace の output を使って、次の機密ではない Variables を
   設定します。

   - `GCP_PROJECT_ID`: Terraform の `project_id`
   - `GCP_WORKLOAD_IDENTITY_PROVIDER`:
     `github_actions_workload_identity_provider`
   - `GCP_DEPLOY_SERVICE_ACCOUNT`: `github_actions_service_account`

   staging workflow は `main` に対する `CI` workflow 成功後に実行されます。
   production は手動 deploy とし、必要な承認ルールで Environment を保護します。
   両 workflow は deploy を直列化し、`docker/app/Dockerfile` を build して
   Artifact Registry に push します。1 task の Cloud Run Job で `db:migrate` を
   実行・完了待ちした後、同一 image を公開済みの Cloud Run Service に deploy します。
   Job は runtime image を使うため、build 中に gem install や Cloud SQL Auth Proxy
   のダウンロードは行いません。

Cloud Run は instance 起動時に `rails-master-key` と `database-url` を Secret
Manager から直接読み取ります。Secret を含むデプロイ設定ファイルや build
workspace はリポジトリに作成しません。
