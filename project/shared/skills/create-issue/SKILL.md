---
name: create-issue
description: "ドラフト作成 → ユーザー承認 → Issue 作成の順で実行する。"
---
# Issue 作成

## 利用する場面
- GitHub Issue を新規作成・編集するとき

## 必須ワークフロー

1. ドラフトファイルを作成する（`gh` は先に実行しない）
2. ユーザーに提示し明示承認を得る
3. 承認後に `gh issue create` を実行する

**承認なしで投稿禁止。**

## 手順

1. タイトルと内容を決める
2. `personal_workspace/` にドラフトファイルを作成する
   <!-- TODO: プロジェクトの記述言語に合わせて編集 -->
3. ユーザー承認を得る
4. 作成: `gh issue create --title "<title>" --body-file <draft-file>`
5. 編集: `gh api repos/{owner}/{repo}/issues/{number} -X PATCH --raw-field body="$(cat <draft-file>)"`

## 条件

- 問題点とあるべき姿（または目的）のみ記載する
- 要求されていない機能・受け入れ条件・実装詳細を勝手に追加しない
- 不足があれば追加前にユーザー確認
- ファイル作成後はパスを表示する
