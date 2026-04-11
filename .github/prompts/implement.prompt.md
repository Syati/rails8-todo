---
agent: 'implementer'
description: '要件ドキュメントのスコープを1つ最小差分で実装する'
---

# スコープ実装

要件ドキュメントのスコープを1つ、Rails 慣習に沿って最小差分で実装します。

## 入力

**要件ドキュメントのパス:**
${input:doc_path:要件ドキュメントのパスを入力してください（例: docs/requirements/admin-crud.md）}

**スコープ ID:**
${input:scope_id:実装対象のスコープ ID を入力してください（例: 1-1, 3-2）}

## 処理

1. **要件ドキュメントを読み込む**
   - ファイル: `${doc_path}`
   - Front Matter から `document_id` / `title` を取得
   - スコープ ID `${scope_id}` に対応するタイトル・シナリオ・確定事項を抽出
   - 上限: **1スコープ + 対応シナリオ1つ**まで。複数ある場合は最初の1つのみ対象とし、残りを明示する

2. **対応 Issue の status を「In Progress」に設定する**
   - `sync_key=${document_id}:${scope_id}` で Issue を検索
   - GitHub Projects の status フィールドを「In Progress」に更新
   - Issue が存在しない場合は `create-issue-from-scope` prompt の実行を先に促す

3. **既存コードを確認する**
   - 認証変更の場合は `app/models/admin.rb` と `config/routes.rb` の整合を確認
   - 影響範囲（モデル・コントローラ・ビュー・ルーティング）を特定
   - 既存スタイル（命名・責務分離・コールバック方針）を把握

4. **実装する（最小差分）**
   - 無関係なリファクタリングを混ぜない
   - Fat Controller を避け、業務ロジックはモデルまたはサービスに寄せる
   - Rails 慣習（命名・strong_parameters・before_action）に従う
   - 認証・認可・入力値・秘密情報に関わる変更は影響範囲を明記する

5. **コミットする**
   - コミットメッセージ例: `impl(${scope_id}): ${scope_title}`
   - スコープ完了のタイミングでコミット（スコープが複数ステップの場合は細分化可）

6. **品質チェックを実行する**
   - DB コンテナ起動: `make up/service`（DB を使う場合）
   - テスト: `make ai/test`
   - Lint: `make ai/lint`
   - エラーがあれば修正してから次へ進む

7. **Issue の status を「Done」に更新する**
   - テスト・Lint が pass してから status を「Done」に変更
   - 認証・認可・入力値・秘密情報に関わる実装は Security Reviewer のチェック後に「Done」にする

8. **次アクションを提示する**
   - テスト設計・追加は `test-writer` へ移譲
   - DB 変更（migration）がある場合は `migration-guardian` へ移譲
   - 認証・認可変更がある場合は `security-reviewer` へ移譲

## 出力ルール

- 実装内容の概要（何を変更したか）を日本語で簡潔に報告する
- 変更ファイルごとに変更理由を明記する
- 不確実性がある場合は仮説として明示する（推測で実装しない）
- 未関連差分は変更しない
- 最後に次アクション候補を 1〜3 個提示する

## 例

**入力:**
- Doc Path: `docs/requirements/admin-crud.md`
- Scope ID: `1-1`

**処理:**
1. `admin-crud.md` を読み込む → スコープ `1-1`: 「管理者一覧を表示できる（シナリオ1）」
2. Issue `admin-crud:1-1` の status を「In Progress」に更新
3. `app/controllers/admins_controller.rb`、`app/views/admins/index.html.erb` を確認
4. `index` アクション + ビューを最小差分で実装
5. コミット: `impl(1-1): 管理者一覧を表示できる`
6. `make ai/test` / `make ai/lint` を実行して pass を確認
7. Issue status を「Done」に更新

**報告例:**
```
## 実装完了: [1-1] 管理者一覧を表示できる

### 変更ファイル
- `app/controllers/admins_controller.rb`: index アクション追加（ransack 未使用、一覧取得のみ）
- `app/views/admins/index.html.erb`: 管理者一覧テーブルを追加

### 品質チェック
- ✅ make ai/test: pass
- ✅ make ai/lint: pass

### 次アクション
1. `test-writer` に spec/requests/admins/index_spec.rb のテスト追加を依頼
2. スコープ 1-2（検索機能）の実装に進む場合は本 prompt を scope_id=1-2 で再実行
```

## Notes

- 1回の実行は「1スコープ + 1シナリオ」まで。複数を一度にやらない
- 実装のみ担当。テスト設計は `test-writer`、DB 変更検証は `migration-guardian`、セキュリティレビューは `security-reviewer` へ移譲
- `make ai/test` / `make ai/lint` が pass するまで「Done」にしない
- 共通ルールは `AGENTS.md` の「プロジェクト共通言語」を優先する
