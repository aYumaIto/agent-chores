---
name: git-workflow
description: "コミットとブランチ作成を実行する。"
argument-hint: "commit / branch"
---
# Git ワークフロー

## 利用する場面
- コミットまたはブランチ作成するとき

## Commit

1. `git diff --staged` で変更確認
2. type 決定（`feat`/`fix`/`docs`/`style`/`refactor`/`perf`/`test`/`chore`/`ci`）
3. メッセージ形式:
   <!-- TODO: プロジェクトに合わせて編集 -->
   ```
   <type>: <English summary>
   ```
4. 意味のある最小単位でコミットする
5. 複数行メッセージは `personal_workspace/commit_msg.txt` 経由で `-F` を使う
6. `--no-verify` 禁止

## ブランチ作成

<!-- TODO: プロジェクトに合わせて編集 -->

- 形式: `<type>-<summary>`（kebab-case）
- デフォルトブランチから作成する
