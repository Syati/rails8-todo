# Terraform 構成

このディレクトリは、Cloud Run デプロイに必要な Terraform を責務別に分けています。

```text
terraform/
├─ bootstrap/ # GCS backend、Terraform Cloud 用 WIF、実行サービスアカウント
└─ app/       # Cloud Run、Cloud SQL、Secret Manager、GitHub Actions 用 WIF
```

## 実行順序

1. [bootstrap/README.ja.md](bootstrap/README.ja.md) に従い、環境ごとの GCS state bucket と
   Terraform Cloud 用認証を作成します。
2. Terraform Cloud の `rails8-todo` Project に app workspace を作成します。

   | 環境 | workspace | Working Directory | tag |
   | --- | --- | --- | --- |
   | staging | `rails8-todo-stg` | `deployments/terraform/app` | `rails8-todo` |
   | production | `rails8-todo-prod` | `deployments/terraform/app` | `rails8-todo` |

3. bootstrap の output で得た `TFC_GCP_*` Environment Variables を対応する app
   workspace に設定します。
4. [app/README.ja.md](app/README.ja.md) に従って、アプリ基盤を apply します。
