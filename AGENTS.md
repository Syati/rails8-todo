# Agents Definition (rails8-todo)

このファイルは AI 作業を役割分担し、品質と速度を両立するための定義です。

## このファイルの位置づけ

- `AGENTS.md` は、6エージェント定義の単一参照元（Single Source of Truth）とする。
- `.github/agents/*.md` は、各エージェントの性格・使用モデル・実行時メモを定義する。
- 役割の解釈が衝突した場合は、`AGENTS.md` の定義を優先する。

## プロジェクト共通言語（全エージェント共通）

- 回答・報告は日本語で行う。
- RSpec の `describe` / `context` / `it` などテスト記述ラベルは英語を許容する。
- 変更理由を必ず添える。
- 不確実性は仮説として明示する。
- 未関連差分は触らない。
- コマンドは可能な限り `rtk` を使う。
- `rtk err` は必須にしない。

### rtk 運用ルール

- 基本例: `rtk git status`, `rtk ls`, `rtk grep "keyword" .`, `rtk test bundle exec rspec`
- `rtk grep` 構文: `rtk grep [OPTIONS] <PATTERN> [PATH] [EXTRA_ARGS]...`
- `rg` 由来オプションは `--` の後ろに置く（例: `rtk grep "admin" . -- -i -A 3`）
- ツール実行時は `~/.local/share/mise/shims` 経由のコマンドを優先して利用する。
- `make` コマンドを使う場合も、実行内容と前提条件（依存サービス起動の要否）を明示する。
- 少なくとも DB を利用するコマンド（`db:migrate` / test 等）実行前は `docker compose` で DB コンテナを起動しておく。

### make 運用ルール

- テスト実行は `make app/test` を使う（特定ファイルは `make app/test ARGS=spec/requests/admins/index_spec.rb`）。
- Lint 実行は `make app/lint` を使う。
- Lint 自動修正は `make app/lint/fix` を使う。
- `make app/test` 実行前は、必要に応じて `make up/service` で DB コンテナを起動する。

## エージェント定義（要約）

詳細な性格・実行メモ・運用手順は `.github/agents/*.md` を正本として参照する。
`AGENTS.md` では、全体方針とプロジェクト固有の必須条件のみを保持する。

### Agent 1: Planner（計画担当）
- 役割: 要件分解、影響範囲整理、実装計画作成。
- 参照: `.github/agents/planner.md`

### Agent 2: Rails Implementer（実装担当）
- 役割: Rails 慣習に沿った最小差分実装。
- 必須確認: `Admin` 認証変更時は `app/models/admin.rb` と `config/routes.rb` をセット確認。
- 参照: `.github/agents/implementer.md`

### Agent 3: Migration Guardian（DB担当）
- 役割: migration の安全性・再現性検証。
- 必須条件: `db/migrate/20260319165213_add_devise_to_admins.rb` が `IrreversibleMigration` 前提である点を踏まえ、追補 migration では巻き戻し方針を明示する。
- 参照: `.github/agents/migration-guardian.md`

### Agent 4: Test Writer（テスト担当）
- 役割: 最小十分な回帰防止テストの追加。
- 参照: `.github/agents/test-writer.md`

### Agent 5: Security Reviewer（セキュリティ担当）
- 役割: 認証/認可/入力値/秘密情報のリスクレビュー。
- 参照: `.github/agents/security-reviewer.md`

### Agent 6: Quality Runner（実行確認担当）
- 役割: テスト/Lint/セキュリティチェックの実行計画・結果整理。
- 推奨実行: `make app/test` / `make app/lint` / `make app/lint/fix`
- 参照: `.github/agents/quality-runner.md`

## 推奨連携フロー

1. Planner が計画作成
2. Rails Implementer が実装
3. Migration Guardian が DB 変更検証
4. Test Writer がテスト追加
5. Security Reviewer が認証・安全性レビュー
6. Quality Runner が最終実行確認

## 共通ルール

- 日本語で簡潔に報告する。
- 変更理由を必ず添える。
- 不確実性は仮説として明示する。
- 未関連差分は触らない。
- コマンドは可能な限り `rtk` を使う。
- `rtk err` は必須にしない。

## 個別エージェントファイル対応

- Agent 1: `.github/agents/planner.md`
- Agent 2: `.github/agents/implementer.md`
- Agent 3: `.github/agents/migration-guardian.md`
- Agent 4: `.github/agents/test-writer.md`
- Agent 5: `.github/agents/security-reviewer.md`
- Agent 6: `.github/agents/quality-runner.md`

## モデル割り当て方針

- Planner: `Claude Opus 4.6`
- Rails Implementer: `Claude Sonnet 4.6`
- Test Writer: `Claude Sonnet 4.6`
- Security Reviewer: `Claude Opus 4.6`
- Quality Runner: `GPT-5-Codex`（コマンド実行・簡易業務）
- Migration Guardian: 現状は個別ファイル定義に従う（必要に応じて見直し）
