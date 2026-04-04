---
agent: 'planner'
description: '要件ドキュメントのスコープから GitHub Issue を自動生成する'
---

# 要件ドキュメントから Issue を自動生成

要件ドキュメント（Markdown）のスコープ項目から、GitHub Issue を自動生成します。

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

3. **GitHub CLI コマンドを出力**
   ```bash
   gh issue create \
     --title "[${scope_id}] ${scope_title}" \
     --body "${body}" \
     --project "rails8-todo" \
     --label "${labels}"
   ```

4. **親 Issue との関連付け（オプション）**
   - 親スコープ Issue 番号を GitHub で検索 → 関連付け

## 出力ルール

- Issue 本文は Markdown 形式で構成
- 必ず以下セクションを含める：
  - **親スコープ** （ネストされている場合）
  - **シナリオ仕様** （ドキュメント内の Gherkin から抽出）
  - **実装要件** （ドキュメントの確定事項から関連部分を記載）
  - **チェックリスト** （手作業で定義 or テンプレート）
  - **影響範囲** （推定）
  
- 同一 scope_id の Issue は重複作成を避ける（事前確認必須）
- ドキュメント内に既に `[completed]` 印がある場合は、Issue 作成を提案のみにする

## 例

**入力:**
- Doc Path: `docs/requirements/admin-crud.md`
- Scope ID: `1-2`

**処理:**
1. `admin-crud.md` を読み込む
2. スコープ ID `1-2` を検索 → "id/email で検索できる"
3. 関連シナリオ `[1-2] 一覧でIDとメールアドレス検索を行う` を抽出
4. Issue テンプレートを生成

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
- [admin-crud.md 要件](../../docs/requirements/admin-crud.md)
```

## 実行方法

### 方法 1: 単一スコープの Issue 作成（手動 gh CLI）
```bash
# ドキュメントをパースして Issue 作成
# 要件ドキュメントから手作業で該当スコープの要素を確認し、Issue 作成
gh issue create \
  --title "[1-2] id/email で検索できる" \
  --body "$(cat docs/requirements/admin-crud.md | grep -A 30 '一覧でIDとメール')" \
  --project "rails8-todo" \
  --label "feature,read,search"
```

### 方法 2: Ruby スクリプト（自動一括作成）✨ 推奨
全スコープから一度に Issue を自動生成します。

**前提:**
- `gh` CLI がインストール済み・認証済み

**ドライラン（確認）:**
```bash
ruby script/create_issues_from_doc.rb --dry-run
```

**実行（Issue 作成）:**
```bash
ruby script/create_issues_from_doc.rb --doc docs/requirements/admin-crud.md
```

**オプション:**
```bash
# 他の要件ドキュメントから Issue を作成
ruby script/create_issues_from_doc.rb --doc docs/requirements/faq-crud.md
```

**処理内容:**
1. Markdown ドキュメントをパース
2. スコープリスト（`## スコープ`）から全アイテムを抽出
3. 親スコープ（1, 2, 3 等）を先に作成
4. その後、サブスコープ（1-1, 1-2 等）を順序に従って作成
5. 各スコープに対して Issue 本文を生成

**実行結果例:**
```
📋 スコープ抽出開始: docs/requirements/admin-crud.md
✅ 抽出されたスコープ: 23 件

🔨 作成中: [1] 一覧（Read）
✓ Issue #1 作成完了

🔨 作成中: [1-1] 管理者一覧を表示できる
✓ Issue #2 作成完了

...

✨ Issue 生成完了！
```


## Notes

- 要件ドキュメント自体が Single Source of Truth
- 新しい要件ドキュメント（例: `faq-crud.md`）が出来たら、同じ prompt で流用可能
- 同一 scope_id の Issue は重複作成を避ける（事前に GitHub で確認）

## 参考リンク
- [admin-crud.md 要件](../../docs/requirements/admin-crud.md)
