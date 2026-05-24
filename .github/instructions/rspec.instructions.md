---
description: spec 配下に適用する RSpec 運用ルール
applyTo: "spec/**/*"
---

# RSpec Instructions (rails8-todo)

このファイルは、`spec/**` に適用する RSpec 関連ルールです。

## 1. テスト規約（RSpec）

- 仕様追加・不具合修正時は、原則テストを追加または更新する。
- `describe` / `context` / `it` など RSpec の記述ラベルは英語で記述してよい。
- `FactoryBot` を使い、重複したデータ構築を避ける。
- 境界値・バリデーション・認証系の失敗ケースを優先してテストする。

## 2. RuboCop RSpec 目安

- `RSpec/NestedGroups: Max 4`
- `RSpec/MultipleExpectations: Max 5`
- `RSpec/ExampleLength: Max 10`
