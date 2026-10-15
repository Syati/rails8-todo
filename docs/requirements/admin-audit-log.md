---
document_id: admin-audit-log
title: 管理者操作ログ方針
issue_sync_key: document_id + scope_id
---

# 管理者操作ログ方針

管理者CRUD（`admin-crud`）の 7-1 で定義する、作成・更新・削除の操作ログの方針。
ログは DB の専用テーブルに保存し、アプリケーションのサービス層で明示的に記録する。

## 対象操作

| 操作 | エンドポイント | `action` の値 |
| --- | --- | --- |
| 作成 | `POST /admins` | `create` |
| 更新 | `PATCH /admins/:id` | `update` |
| 論理削除 | `DELETE /admins/:id` | `destroy` |

失敗した操作（バリデーションエラー、403）は記録しない。403 はアプリケーションログで追う。

## 記録する情報

| カラム | 型 | 内容 |
| --- | --- | --- |
| `actor_id` | bigint, not null | 操作した管理者（`admins.id`） |
| `target_id` | bigint, not null | 操作された管理者（`admins.id`） |
| `action` | string, not null | `create` / `update` / `destroy` |
| `changeset` | jsonb, not null | 変更されたカラムの変更前後（`saved_changes`） |
| `request_id` | string | `request.request_id`。アプリケーションログとの突き合わせ用 |
| `remote_ip` | string | 操作元の IP アドレス |
| `created_at` | datetime, not null | 操作日時 |

- `changeset` には `encrypted_password`、各種 token、`updated_at` を含めない。パスワード変更は `{"password": "changed"}` とだけ記録する。
- 管理者は論理削除なので、`actor_id` / `target_id` の外部キーは削除後も有効なまま残る。
- ログは追記のみとし、更新・削除する画面や API は作らない。

## 保存先と実装方式

- **保存先は DB**（`admin_audit_logs` テーブル）。管理画面から検索・表示でき、外部サービスの追加が要らない。
- **記録はコントローラから呼ぶサービス（`AdminAuditLogger`）で明示的に行う。** 対象が3操作だけなので、PaperTrail などの gem は入れない。
- ActiveRecord callback は使わない。callback では操作者（`current_admin`）とリクエスト情報を受け取れないため。
- 記録は本体の保存と同じトランザクションで行い、ログだけが欠けることがないようにする。

## 保持期間

- 1年間保持する。期限切れの削除は Solid Queue の定期ジョブで行う。

## 未確定事項

- [ ] 保持期間 1年で良いか（法令・社内規程による要件の有無）
- [ ] 管理画面にログ一覧を出すか（出す場合は super_admin のみ閲覧可とする案）
- [ ] ログイン・ログアウト・ロックなど Devise 側のイベントも記録するか
