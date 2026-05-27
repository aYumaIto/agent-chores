---
description: "編集禁止ファイル。"
---
# 編集禁止ファイル

以下は直接編集しない：

- `build/`、`dist/`、`out/` 等のビルド出力
- コード生成ツールの出力ファイル
- ロックファイル（`package-lock.json`、`yarn.lock`、`Gemfile.lock` 等）
- `.env`、`.env.*` 等の環境変数ファイル
- `local.properties` 等ローカル固有設定
- 秘密鍵、証明書、トークンを含むファイル
