---
description: .apm 配下の変更に適用する運用ルール
applyTo: ".apm/**/*"
---

# APM Instructions

このファイルは、`.apm/**` を変更したときの運用ルールです。

## 0. コンパイル運用

- `.apm/**` を変更した場合は、作業完了前に `apm compile` を実行する。
- `apm compile` で生成された差分は、元の変更と同一コミットに含める。

