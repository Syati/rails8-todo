---
description: Dependabot の open PR を安全に確認し、順次マージする
---

# Dependabot PR を順次マージ

この prompt は、リポジトリ内の Dependabot PR を一覧化し、マージ可能なものを順次マージします。

## 入力

**対象 ecosystem:**
${input:ecosystem:対象を入力してください（all / bundler / github-actions）}

**マージ方法:**
${input:merge_method:マージ方法を入力してください（squash / merge / rebase）}

## 処理

1. **Dependabot 設定を確認する**
   - ファイル: `.github/dependabot.yml`
   - `updates` から有効な ecosystem を確認する
   - `${ecosystem}` が `all` 以外の場合は、設定済み ecosystem のみを対象にする

2. **open な Dependabot PR を収集する**
   - 対象は `author: dependabot[bot]` の pull request のみ
   - Draft は対象外とする
   - `${ecosystem}` が `bundler` の場合は `dependencies` + `ruby` ラベルを優先して抽出する
   - `${ecosystem}` が `github-actions` の場合は `dependencies` + `github_actions` ラベルを優先して抽出する
   - `${ecosystem}` が `all` の場合は、`.github/dependabot.yml` に含まれる ecosystem をすべて対象にする

3. **各 PR のマージ可否を確認する**
   - CI / check run / status が取得できる場合は確認する
   - `mergeable` か、`mergeable_state` を確認する
   - 次の条件を満たす PR のみ自動マージ候補にする
     - Dependabot PR である
     - Draft ではない
     - 競合していない
     - 必要な status / check が成功している、または status が存在しない

4. **順次マージする**
   - `${merge_method}` に従ってマージする
   - 未入力または不正値の場合は `squash` を既定値とする
   - 1件ずつ実行し、成功 / 失敗を記録する

5. **競合 PR をフォローする**
   - `update branch` で解消可能なら更新を試みる
   - 競合で更新できない場合は `@dependabot recreate` をコメントする
   - それでも未解消なら「手動対応が必要」として残す

6. **結果を整理して報告する**
   - マージ成功 PR
   - 再作成依頼済み PR
   - 手動対応が必要な PR
   - 実行できなかった確認項目（例: CI 状態を取得できなかった）

## 出力ルール

- 先に対象件数を示す
- PR ごとに `番号 / タイトル / URL / 変更サマリー / 結果` を簡潔に記載する
- 変更サマリーは PR 本文・リリースノート・Changelog から以下の観点で要約する
  - セキュリティ修正（CVE番号があれば記載）
  - 破壊的変更の有無
  - 主なバグ修正・新機能（簡潔に）
  - 取得できない場合は「詳細不明」と記載する
- 失敗した場合は理由を明記する
- `@dependabot recreate` や branch update を実行した場合は、その事実を明記する
- 最後に残件の有無を明記する

## 例

**入力:**
- ecosystem: `all`
- merge_method: `squash`

**処理:**
1. `.github/dependabot.yml` を確認し、`bundler` と `github-actions` が有効であることを確認する
2. open な Dependabot PR を一覧化する
3. CI / mergeable 状態を確認する
4. マージ可能な PR を `squash` で順次マージする
5. 競合 PR には `@dependabot recreate` をコメントする

**報告例:**
```markdown
## Dependabot PR マージ結果

対象: 6件

### マージ成功
- #29 Bump `thruster` from 0.1.16 to 0.1.17
  - https://github.com/<owner>/<repo>/pull/29
  - 変更サマリー: メモリリークのバグ修正。破壊的変更なし
- #28 Bump `kamal` from 2.8.2 to 2.10.1
  - https://github.com/<owner>/<repo>/pull/28
  - 変更サマリー: deploy コマンドに `--skip-hooks` オプション追加。破壊的変更なし

### 再作成依頼済み
- #22 Bump `sqlite3` from 2.8.0 to 2.8.1
  - https://github.com/<owner>/<repo>/pull/22
  - 変更サマリー: CVE-2025-XXXX 対応のセキュリティ修正
  - 対応: `@dependabot recreate`

### 手動対応が必要
- #23 Bump `rubocop-rails` from 2.33.4 to 2.34.2
  - https://github.com/<owner>/<repo>/pull/23
  - 変更サマリー: 新 Cop 追加により既存コードで offense が増加する可能性あり（要確認）
  - 理由: merge conflict
```

## Notes

- 対象は Dependabot PR のみ。通常の開発 PR は触らない
- `all` 指定時も、`.github/dependabot.yml` に存在しない ecosystem は対象外
- 安全のため、競合 PR を無理にマージしない
- CI 状態が取れない場合は、その事実を報告に残した上で判断理由を明記する
- 共通ルールは `AGENTS.md` と `.github/copilot-instructions.md` を優先する