---
name: setup-worktree
description: "機能実装用の worktree を作成する。origin/main から作業ブランチ付き worktree を作り、開発環境を準備する。"
argument-hint: "機能名（例: add-chat-history）"
---
# 機能開発用 Worktree セットアップ

機能実装のために `origin/main` から作業ブランチ付きの worktree を作成し、作業ディレクトリの開発環境を準備します。

## 利用する場面
- 新機能や修正を並行開発するとき
- 既存作業を中断せずに別タスクを開始するとき

## 使い方

リポジトリルートで実行します。

```bash
.claude/skills/setup-worktree/setup-worktree.sh <type> <feature-name>
```

### 引数

| 引数 | 説明 |
|----------|-------------|
| `type` | ブランチ種別：`feat`、`fix`、`refactor`、`chore`、`docs`、`perf`、`test`、`ci`、`style` |
| `feature-name` | 短い kebab-case の機能名（例：`add-chat-history`） |

### 例

```bash
.claude/skills/setup-worktree/setup-worktree.sh feat add-chat-history
.claude/skills/setup-worktree/setup-worktree.sh fix api-timeout
```

## スクリプトの実行内容

1. リポジトリ状態を確認する
2. 最新の `origin/main` を取得する
3. `../<repo-name>-worktrees/<feature-name>` に worktree を作成し、ブランチ `<type>-<feature-name>` を作成する
4. `.vscode/settings.json` があれば skip-worktree に設定する
5. 検証のため、全 worktree 一覧を表示する

## 注意

- 既存と重複するパス名は使用しない
- スクリプトは必ずリポジトリルートディレクトリで実行する
