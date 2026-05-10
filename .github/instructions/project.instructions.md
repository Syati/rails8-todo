---
description: rails8-todo 全体に適用するプロジェクト共通指示
applyTo: "**/*"
---

# Project Instructions (rails8-todo)

このファイルは、本リポジトリで利用する AI エージェント全般に適用する共通ルールです。
対象: Ruby / Rails 8 / PostgreSQL / RSpec / Devise / OmniAuth

## 0. 正本と生成物

- `.apm/instructions/*.instructions.md` を正本とする。
- `.github/*` 配下の互換資産は `apm compile -t copilot` で生成し、生成物だが commit 管理する。

## 1. 基本方針

- 回答・解説は日本語で行う。
- 変更は最小差分を優先し、既存設計を尊重する。
- 不明点は推測で実装せず、前提を明示して提案する。
- 破壊的変更（DB削除、API仕様変更、認証フロー変更）は理由と影響範囲を書く。

## 2. Rails 実装規約

### 2.1 変更方針

- 先に既存コード（モデル、ルーティング、初期化設定、テスト）を確認する。
- Rails の慣習（命名、責務分離、コールバック最小化）に従う。
- Fat Controller を避け、業務ロジックはモデルまたはサービスに寄せる。

### 2.2 マイグレーション

- 既存テーブル前提の `change_table` を使う前に、テーブル存在前提を確認する。
- 新規環境で落ちる migration を避ける。
- 破壊的操作（`drop_table`, `remove_column`）はロールバック可否を明示する。

### 2.3 認証（Devise / OmniAuth）

- `Admin` 認証の変更時は `app/models/admin.rb` と `config/routes.rb` の整合を確認する。
- セキュリティ関連設定の変更時は、影響（ログイン・登録・ロック・確認メール）を明記する。
- CSRF、callback URL、provider 設定の取り扱いを明示する。

## 3. テスト規約（RSpec）

- 仕様追加・不具合修正時は、原則テストを追加または更新する。
- `describe` / `context` / `it` など RSpec の記述ラベルは英語で記述してよい。
- `FactoryBot` を使い、重複したデータ構築を避ける。
- 境界値・バリデーション・認証系の失敗ケースを優先してテストする。

## 4. 品質チェック

変更後は可能な範囲で `cmd.instructions.md` に示す品質チェックを実行する。

実行できない場合は、未実施項目と理由を明記する。

## 5. RuboCop 方針

`.rubocop.yml` に従う。

- `TargetRubyVersion: 4.0`
- `rubocop-rspec`, `rubocop-factory_bot`, `rubocop-rbs_inline` を利用
- RSpec の目安
  - `RSpec/NestedGroups: Max 4`
  - `RSpec/MultipleExpectations: Max 5`
  - `RSpec/ExampleLength: Max 10`

## 6. Annotate 運用

- `.annotaterb.yml` の設定に従い、必要に応じて注釈を更新する。
- 注釈のみの差分コミットは避け、関連機能変更とセットで扱う。

## 7. 出力フォーマット（AIへの期待）

- 先に「何を変更するか」を短く示す。
- 変更ファイルごとに理由を明記する。
- 最後に次アクション候補を 1〜3 個提示する。
- 長いコード全文は避け、要点を示す。

## 8. 禁止事項

- 秘密情報（鍵、トークン、資格情報）を生成・コミットしない。
- 根拠のない断定をしない。
- ユーザーが作成した未関連差分を勝手に戻さない。
