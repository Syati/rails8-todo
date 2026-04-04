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
   - Front Matter から `document_id` を抽出（未定義ならファイル名 slug を仮採用）
   - Front Matter から `title` を抽出（未定義なら `document_id` を仮採用）
   - Markdown のスコープリストから対象スコープを抽出
   - 関連シナリオを検索

2. **Issue テンプレートを生成**
   - Title: `[${title}] ${scope_title}`
   - 同期キー: `${document_id}:${scope_id}`（重複回避・更新判定用）
   - Body: 
     - **親スコープのみの場合（例: `1`, `2`）**: タイトルのみまたはミニマル本文（子スコープ一覧のみ）
     - **サブスコープの場合（例: `1-1`, `1-2`）**: 詳細本文
       - 親スコープへのリンク（該当する場合）
       - シナリオ仕様（Gherkin 形式）
       - 実装要件・チェックリスト
       - 影響範囲・参考リンク
       - 同期用 metadata（`document_id`, `scope_id`, `sync_key`）

3. **GitHub MCP サーバーへの依頼内容を組み立てる**
   - リクエスト先: `io.github.github/github-mcp-server`
   - まず `sync_key=${document_id}:${scope_id}` 一致で既存 Issue 検索する
   - 見つからない場合のみ `[${title}] ${scope_title}` タイトル一致検索をフォールバックで行う
   - 0 件なら create、1 件なら update、複数件なら自動更新せず確認事項として返す
   - **サブスコープの場合**、親 Issue を relationships で `parent` として add する

4. **親 Issue との関連付け方針を決める（オプション）**
   - 親スコープ Issue を GitHub MCP サーバー経由で検索し、本文内リンクまたはサブ Issue 関連付け方針を併記する

## 出力ルール

- **親スコープ Issue（`scope_id` が親のみの場合）は最小限の本文で OK**
  - タイトルのみ、または「子スコープ」セクション付きのみで十分
  - 詳細な「シナリオ仕様」「実装要件」は書かない（子スコープに委譲）
- **サブスコープ Issue は詳細本文を必須**
  - シナリオ仕様、実装要件、チェックリスト、影響範囲を全て含める
  - **親 Issue を relationships で `parent` として設定する**（存在する場合）
- Issue 本文は Markdown 形式で構成
- GitHub への反映は `io.github.github/github-mcp-server` への依頼を前提とする
- 必ず以下セクションを含める（サブスコープのみ）：
  - **親スコープ** （ネストされている場合）
  - **シナリオ仕様** （ドキュメント内の Gherkin から抽出）
  - **実装要件** （ドキュメントの確定事項から関連部分を記載）
  - **チェックリスト** （手作業で定義 or テンプレート）
  - **影響範囲** （推定）
  
- 同一 `document_id + scope_id` の Issue は重複作成を避ける（`sync_key` 一致確認を必須とする）
- 検索結果が 2 件以上ある場合は create / update を実行せず、候補一覧を返して確認を促す
- ドキュメント内に既に `[completed]` 印がある場合は、Issue 作成を提案のみにする
- 出力には `create` / `update` / `manual_confirmation_required` のいずれかの判定を必ず含める

## 例

**入力:**
- Doc Path: `docs/requirements/admin-crud.md`
- Document ID: `admin-crud`（Front Matter より）
- Title: `管理者CRUD`（Front Matter より）
- Scope ID: `1-2`

**処理:**
1. `admin-crud.md` を読み込む
2. Front Matter から `document_id=admin-crud` を取得する
3. Front Matter から `title=管理者CRUD` を取得する
4. スコープ ID `1-2` を検索 → "id/email で検索できる"
5. `sync_key=admin-crud:1-2` を組み立てる
6. GitHub MCP サーバーで既存 Issue を検索
7. Issue テンプレートと create / update 方針を生成

**生成される Issue:**
```markdown
# [管理者CRUD] id/email で検索できる

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

<!-- sync_metadata
document_id: admin-crud
scope_id: 1-2
sync_key: admin-crud:1-2
-->
```

**GitHub MCP サーバーへの依頼方針:**
- リクエスト先: `io.github.github/github-mcp-server`
- 検索キー: `sync_key=admin-crud:1-2`
- フォールバック検索クエリ: `repo:<owner>/<repo> is:issue in:title "[管理者CRUD] id/email で検索できる"`
- 判定: 既存 Issue がなければ create、1 件あれば update

## 実行方法

### 方法 1: 単一スコープの Issue 同期（GitHub MCP サーバー）
1. 要件ドキュメントの Front Matter から `document_id` を読み取る
2. スコープ ID が親のみか、サブスコープかを判定する（ハイフン含有で判定）
3. 要件ドキュメントから対象スコープと関連シナリオを抽出する
4. `io.github.github/github-mcp-server` で同一 `document_id + scope_id` の既存 Issue を検索する
5. 0 件なら Issue を新規作成し、1 件なら既存 Issue を更新する
6. **サブスコープの場合**、親 Issue を `io.github.github/github-mcp-server` で検索して、relationships で `parent` として add する
7. 2 件以上ヒットした場合は自動反映を止め、候補一覧を出して確認を求める

### 方法 2: 複数スコープの順次同期（GitHub MCP サーバー）
1. Markdown ドキュメントをパースする
2. Front Matter から `document_id` を抽出する
3. スコープリスト（`## スコープ`）から全アイテムを抽出する
3. 親スコープ（1, 2, 3 等）を先に同期する
4. その後、サブスコープ（1-1, 1-2 等）を順序に従って同期する
5. 各スコープごとに `document_id + scope_id` で既存 Issue を検索し、存在すれば update、なければ create する

**期待する結果例:**
```text
📋 スコープ抽出開始: docs/requirements/admin-crud.md
✅ 抽出されたスコープ: 23 件

🔎 既存 Issue 検索: admin-crud:1
🔨 create: [管理者CRUD] 一覧（Read）
✓ Issue #1 作成完了

🔎 既存 Issue 検索: admin-crud:1-1
♻️ update: #2 [管理者CRUD] 管理者一覧を表示できる
✓ Issue #2 更新完了

✨ Issue 同期完了！
```


## Notes

- 要件ドキュメント自体が Single Source of Truth
- 親スコープ Issue は「タイトルのみ」で作成すると冗長性が避けられる
- 子スコープが作成されると、その中に詳細が記載されるため、親スコープの本文は最小化するのが実用的
- 新しい要件ドキュメント（例: `faq-crud.md`）が出来たら、同じ prompt で流用可能
- 同一 `document_id + scope_id` の Issue は GitHub MCP サーバー経由で事前確認し、create / update を切り分ける
- `gh` CLI コマンドの生成ではなく、GitHub MCP サーバーへの依頼内容と実行方針を返す

## 参考リンク
- [admin-crud.md 要件](/docs/requirements/admin-crud.md)
