---
agent: 'planner'
description: '要件ドキュメントのスコープから GitHub Issue を自動生成する'
---

# 要件ドキュメントから Issue を同期（作成/更新）

要件ドキュメント（Markdown）のスコープ項目から、GitHub Issue を作成/更新で同期します。

## 入力

**要件ドキュメントのパス:**
${input:doc_path:要件ドキュメントのパスを入力してください（例: docs/requirements/admin-crud.md）}

**スコープ ID:**
${input:scope_id:生成対象のスコープ ID を入力してください（例: 1-2, 3-1）}

## 処理

1. **要件ドキュメントを読み込む**
   - ファイル: `${doc_path}`
   - Markdown のスコープリストから対象スコープを抽出
   - 関連シナリオを検索

2. **Issue テンプレートを生成**
   - Title: `[${scope_id}] ${scope_title}`
   - Body: 
     - 親スコープへのリンク（該当する場合）
     - シナリオ仕様（Gherkin 形式）
     - 実装要件・チェックリスト
     - 影響範囲・参考リンク

3. **GitHub MCP サーバーへの依頼内容を組み立てる**
   - リクエスト先: `io.github.github/github-mcp-server`
   - まず `[${scope_id}]` をタイトル前方一致で既存 Issue 検索する
   - 0 件なら create、1 件なら update、複数件なら自動更新せず確認事項として返す

4. **親 Issue との関連付け方針を決める（オプション）**
   - 親スコープ Issue を GitHub MCP サーバー経由で検索し、本文内リンクまたはサブ Issue 関連付け方針を併記する

## 出力ルール

- Issue 本文は Markdown 形式で構成
- GitHub への反映は `io.github.github/github-mcp-server` への依頼を前提とする
- 必ず以下セクションを含める：
  - **親スコープ** （ネストされている場合）
  - **シナリオ仕様** （ドキュメント内の Gherkin から抽出）
  - **実装要件** （ドキュメントの確定事項から関連部分を記載）
  - **チェックリスト** （手作業で定義 or テンプレート）
  - **影響範囲** （推定）
  
- 同一 scope_id の Issue は重複作成を避ける（`[scope_id]` のタイトル前方一致で事前確認必須）
- 検索結果が 2 件以上ある場合は create / update を実行せず、候補一覧を返して確認を促す
- ドキュメント内に既に `[completed]` 印がある場合は、Issue 作成を提案のみにする
- 出力には `create` / `update` / `manual_confirmation_required` のいずれかの判定を必ず含める

## 例

**入力:**
- Doc Path: `docs/requirements/admin-crud.md`
- Scope ID: `1-2`

**処理:**
1. `admin-crud.md` を読み込む
2. スコープ ID `1-2` を検索 → "id/email で検索できる"
3. 関連シナリオ `[1-2] 一覧でIDとメールアドレス検索を行う` を抽出
4. GitHub MCP サーバーで既存 Issue を検索
5. Issue テンプレートと create / update 方針を生成

**生成される Issue:**
```markdown
# [1-2] id/email で検索できる

## 親スコープ
#XX - [1. 一覧（Read）]

## シナリオ仕様
\`\`\`gherkin
Scenario: [1-2] 一覧でIDとメールアドレス検索を行う
  Given 複数の管理者が登録済みである
  When ユーザーが \`ransack\` を使って \`id\` または \`email\` で検索する
  Then 条件に一致する管理者だけが一覧に表示される
\`\`\`

## 実装要件
- ransack で id_eq, email_cont スコープを実装
- 検索フォームを管理者一覧に追加
- 一覧は ransack を利用し、id / email で検索可能とする（確定事項より）

## チェックリスト
- [ ] Ransack スコープ定義（id_eq, email_cont）
- [ ] 検索フォーム UI 実装
- [ ] strong_parameters 調整
- [ ] RSpec テスト追加

## 影響範囲
- ファイル: app/controllers/admins_controller.rb, app/models/admin.rb, app/views/admins/index.html.erb
- テスト: spec/requests/admins/index_spec.rb

## 参考
- [admin-crud.md 要件](/docs/requirements/admin-crud.md)
```

**GitHub MCP サーバーへの依頼方針:**
- リクエスト先: `io.github.github/github-mcp-server`
- 検索クエリ: `repo:<owner>/<repo> is:issue in:title "[1-2]"`
- 判定: 既存 Issue がなければ create、1 件あれば update

## 実行方法

### 方法 1: 単一スコープの Issue 同期（GitHub MCP サーバー）
1. 要件ドキュメントから対象スコープと関連シナリオを抽出する
2. `io.github.github/github-mcp-server` で同一 `scope_id` の既存 Issue を検索する
3. 0 件なら Issue を新規作成し、1 件なら既存 Issue を更新する
4. 2 件以上ヒットした場合は自動反映を止め、候補一覧を出して確認を求める

### 方法 2: 複数スコープの順次同期（GitHub MCP サーバー）
1. Markdown ドキュメントをパースする
2. スコープリスト（`## スコープ`）から全アイテムを抽出する
3. 親スコープ（1, 2, 3 等）を先に同期する
4. その後、サブスコープ（1-1, 1-2 等）を順序に従って同期する
5. 各スコープごとに GitHub MCP サーバーで既存 Issue を検索し、存在すれば update、なければ create する

**期待する結果例:**
```text
📋 スコープ抽出開始: docs/requirements/admin-crud.md
✅ 抽出されたスコープ: 23 件

🔎 既存 Issue 検索: [1] 一覧（Read）
🔨 create: [1] 一覧（Read）
✓ Issue #1 作成完了

🔎 既存 Issue 検索: [1-1] 管理者一覧を表示できる
♻️ update: #2 [1-1] 管理者一覧を表示できる
✓ Issue #2 更新完了

✨ Issue 同期完了！
```


## Notes

- 要件ドキュメント自体が Single Source of Truth
- 新しい要件ドキュメント（例: `faq-crud.md`）が出来たら、同じ prompt で流用可能
- 同一 scope_id の Issue は GitHub MCP サーバー経由で事前確認し、create / update を切り分ける
- `gh` CLI コマンドの生成ではなく、GitHub MCP サーバーへの依頼内容と実行方針を返す

## 参考リンク
- [admin-crud.md 要件](/docs/requirements/admin-crud.md)
