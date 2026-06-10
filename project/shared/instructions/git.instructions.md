---
description: "Git/GitHub 操作ルール。コミット・プッシュ時に適用。"
---
# Git ルール

## 禁止オプション

- `--no-verify` — hook をスキップするため禁止
- `--force` — リモート履歴を上書きするため禁止

## GitHub リポジトリアクセス

- 読み取り: MCP（推奨）or `gh` コマンド。WebFetch 禁止
- 書き込み: `gh` コマンド（推奨）。MCP・WebFetch 禁止

## GH コマンド

- 非推奨警告が出たら即座にそのコマンドの利用を停止する
- 編集操作は `gh api` REST 呼び出しを優先する

## PR ルール

<!-- TODO: プロジェクトに合わせて編集 -->

- タイトル: `[TicketID] <type>: <Summary>`（英語）
- ブランチ名: 英語
- マージ: squash merge
- テンプレート: `.github/pull_request_template.md`

type: `feat` / `fix` / `docs` / `style` / `refactor` / `perf` / `test` / `chore` / `ci`
