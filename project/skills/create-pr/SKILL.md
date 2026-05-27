---
name: create-pr
description: "ドラフト作成 → ユーザー承認 → PR作成の順で実行する。"
---
# PR 作成

## 利用する場面
- 作業ブランチの変更を PR として提出するとき

## 必須ワークフロー

1. ドラフトファイルを作成する（`gh` は先に実行しない）
2. ユーザーに提示し明示承認を得る
3. 承認後に `gh pr create` を実行する

**承認なしで投稿禁止。**

## 手順

1. `git log --oneline origin/main..HEAD` でコミット確認
2. type を決定する（`feat`/`fix`/`docs`/`style`/`refactor`/`perf`/`test`/`chore`/`ci`）
3. タイトル: `[TicketID] <type>: <Summary>` or `<type>: <Summary>`
4. `.github/pull_request_template.md` に従い `personal_workspace/pr_body_<branch-name>.md` を作成
   <!-- TODO: プロジェクトの記述言語に合わせて編集 -->
   - クローズ参照は本文最後尾のみ
   - Changes: 何を・なぜ変更したか（実装詳細は diff で見えるので不要）
5. ユーザー承認を得る
6. `gh pr create --title "<title>" --body-file personal_workspace/pr_body_<branch-name>.md`

## 条件

- 実際のコミットに基づいて記述（含まれない変更を追加しない）
- 不足があれば追加前にユーザー確認
- ファイル作成後はパスを表示する
