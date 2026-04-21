---
name: git-workflow
description: "コミットとブランチ作成を実行する。"
argument-hint: "commit / branch"
---
# Git ワークフロー

## 利用する場面
- コード変更をコミットするとき
- 作業ブランチを作成するとき

## Commit

1. `git diff --staged` で変更内容を確認する
2. 変更内容から適切な type を決める：
   | type | 目的 |
   |---|---|
   | `feat` | 新機能 |
   | `fix` | バグ修正 |
   | `docs` | ドキュメントのみの変更 |
   | `style` | コードの意味に影響しない変更 |
   | `refactor` | バグ修正でも新機能追加でもないコード変更 |
   | `perf` | パフォーマンス改善 |
   | `test` | テストの追加または変更 |
   | `chore` | ビルドプロセスや補助ツールの変更 |
   | `ci` | CI 設定の変更 |
3. 次の形式でコミットメッセージを作成する
   <!-- TODO: プロジェクトのコミットメッセージ規約に合わせて編集してください -->
   ```
   <type>: <English summary>
   ```
4. コミットは意味のある最小単位、または PR レビューコメント単位で行う
5. 複数行メッセージは `personal_workspace/commit_msg.txt` に記述し、`git commit -F personal_workspace/commit_msg.txt` を使う
6. `--no-verify` は絶対に使わない

## ブランチ作成

<!-- TODO: プロジェクトのブランチ命名規約に合わせて編集してください -->

1. ブランチ名形式：`<type>-<summary>`（kebab-case）
   - 例：`feat-add-chat-history`、`fix-api-timeout`
2. デフォルトブランチ（main / master）から作成する
   ```bash
   git checkout -b <branch-name> main
   ```

## 出力ルール

ファイル（ドラフト本文、コミットメッセージなど）を作成または編集したら、ユーザーがすぐ開けるよう、チャット末尾に必ず Markdown リンクでファイルパスを表示します。
