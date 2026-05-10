---
description: rails8-todo 全体に適用するコマンド運用ルール
applyTo: "**/*"
---

# Command Instructions (rails8-todo)

このファイルは、本リポジトリで利用するコマンド実行ルールです。

## 1. コマンド実行ルール（rtk優先）

ローカル実行コマンドは可能な限り `rtk` プレフィックスを使う。

- `rtk` のサブコマンドやオプションは推測で使わず、MCP Context7 の RTK ドキュメント（`/rtk-ai/rtk`）を参照して確認する。
- `rtk` の構文に確信がない場合は断定せず、確認できた範囲を明示する。

- `rtk git status`
- `rtk ls`
- `rtk find`
- `rtk grep "keyword" .`
- `rtk rspec`
- `rtk rubocop`

### 1.1 rtk grep の注意

`rtk grep` の基本構造:

`rtk grep [OPTIONS] <PATTERN> [PATH] [EXTRA_ARGS]...`

- 行番号はデフォルトで有効（`-n` 不要）
- `rg` 由来オプションは `--` の後ろに置く
  - 例: `rtk grep "admin" . -- -i -A 3`

## 2. テスト実行例

- `rtk rspec`
- `rtk rspec spec/models/admin_spec.rb`

## 3. 品質チェック実行例

- `rtk rspec`
- `bundle exec rubocop`
- `bundle exec brakeman`
- `bin/rails db:migrate`
