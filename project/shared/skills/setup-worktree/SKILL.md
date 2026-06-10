---
name: setup-worktree
description: "origin/main から作業ブランチ付き worktree を作成する。"
argument-hint: "<type> <feature-name>"
---
# Worktree セットアップ

## 利用する場面
- 並行開発するとき

## 使い方

リポジトリルートで実行：

```bash
.claude/skills/setup-worktree/setup-worktree.sh <type> <feature-name>
```

- type: `feat`/`fix`/`refactor`/`chore`/`docs`/`perf`/`test`/`ci`/`style`
- feature-name: kebab-case

## 条件

- リポジトリルートで実行する
- 既存と重複するパス名は使用しない
