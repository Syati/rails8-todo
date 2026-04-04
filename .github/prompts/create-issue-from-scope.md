# Prompt: スコープから GitHub Issue を自動生成

## 目的
`admin-crud.md` などの要件ドキュメントのスコープ項目から、GitHub Issue を自動生成する。

## 入力フォーマット
ユーザーが以下の形式で要求を提示：

```
1-2. `id` / `email` で検索できる（シナリオ11）
```

## 処理フロー

### 1. スコープ項目を解析
- ID（例: 1-2）を抽出
- 親スコープ ID（例: 1）を判定 → Feature として扱う
- タイトルと説明を抽出

### 2. Issue テンプレートを生成
- Title: `[1-2] 管理者一覧で id/email 検索`
- Body: シナリオ仕様 + 実装要件 + チェックリスト

### 3. GitHub CLI コマンド出力
```bash
gh issue create \
  --title "[1-2] 管理者一覧で id/email 検索" \
  --body "..." \
  --project "rails8-todo"
```

### 4. 親 Issue との関連付け（オプション）
- 親スコープ Issue ID を取得 → 関連付け

## 出力ルール
- Issue 本文は Markdown 形式
- チェックリストを必ず含める
- 実装要件を明記（gem、スコープ名、パラメータ等）
- Related Issues として親スコープ Issue を記載

## 使用例

### 入力:
```
1-2. `id` / `email` で検索できる
```

### 出力:
```bash
gh issue create \
  --title "[1-2] 管理者一覧で id/email 検索" \
  --body "## 親スコープ
[Feature: 1. 一覧（Read）](https://github.com/...)

## 要件
- ransack で id_eq, email_cont スコープを実装
- 検索フォームを管理者一覧に追加
- パラメータ: q[id_eq], q[email_cont]

## シナリオ仕様
\`\`\`gherkin
Scenario: [1-2] 一覧でIDとメールアドレス検索を行う
  Given 複数の管理者が登録済みである
  When ユーザーが \`ransack\` を使って \`id\` または \`email\` で検索する
  Then 条件に一致する管理者だけが一覧に表示される
\`\`\`

## チェックリスト
- [ ] Ransack スコープ定義（id_eq, email_cont）
- [ ] 検索フォーム UI 実装
- [ ] strong_parameters 調整
- [ ] RSpec テスト追加
- [ ] 統合テスト実施

## 影響範囲
- ファイル: app/controllers/admins_controller.rb, app/models/admin.rb, app/views/admins/index.html.erb
- テスト: spec/requests/admins/index_spec.rb

## 参考リンク
- [ransack ドキュメント](https://activerecord-hackery.github.io/ransack/)
- [親 Feature Issue](https://github.com/...)" \
  --project "rails8-todo" \
  --label "feature,read,search"
```

## Integration

### 方法 1: 手動で gh CLI から実行
```bash
# 1-2 の Issue を作成
gh issue create \
  --title "[1-2] 管理者一覧で id/email 検索" \
  --body "$(cat docs/requirements/admin-crud.md | grep -A 5 '1-2')" \
  --project "rails8-todo" \
  --label "feature,read"
```

### 方法 2: スクリプト化（Ruby）
```ruby
# script/create_issues_from_scope.rb
require 'json'

config = JSON.parse(File.read('.github/prompts/scope-to-issues.json'))
config['scope_mapping'].each do |scope_id, attrs|
  title = "[#{scope_id}] #{attrs['title']}"
  parent = attrs['parent'] ? " (parent: ##{attrs['parent']})" : ""
  system("gh issue create --title '#{title}' --project 'rails8-todo' --label '#{attrs['label'].join(',')}'")
end
```

### 方法 3: GitHub Actions ワークフロー
```yaml
# .github/workflows/create-issues.yml
name: Create Issues from Scope
on:
  workflow_dispatch:
jobs:
  create-issues:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Create GitHub Issues
        run: |
          ruby script/create_issues_from_scope.rb
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Notes

- 同一 scope_id の Issue は重複作成を避ける（事前チェック必須）
- 親 Feature Issue は先に作成すること
- ラベルは project の設定に合わせてカスタマイズ
