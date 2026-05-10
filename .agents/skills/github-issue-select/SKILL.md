# GitHub Issue Select Skill

## Purpose

対象リポジトリの Issue を取得し、ユーザーに選択可能な一覧として提示する。

## When To Use

- ユーザーが「issue から着手したい」と依頼したとき
- 実装対象がまだ決まっていないとき

## Steps

1. GitHub MCP で対象リポジトリの open issues を取得する。
2. `番号 / タイトル / ラベル / 更新日時` を 10〜20 件で一覧化する。
3. ユーザーに「どの issue 番号で進めるか」を確認する。
4. 回答が曖昧なら候補を再提示して再確認する。

## Output Format

- 先頭に対象リポジトリ名を明記
- 箇条書きで issue 一覧を提示
- 最後に 1 行で選択質問を入れる

## Guardrails

- 勝手に issue を決めて実装を始めない
- close 済み issue は混ぜない
- issue 本文が長い場合は要約して表示する
