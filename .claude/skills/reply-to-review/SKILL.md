---
name: reply-to-review
description: "PR レビューコメントへ返信する。コミットリンク付きの返信を作成し、ユーザー承認後に gh API で投稿する。"
---
# PR レビューコメントへの返信

## 利用する場面
- PR レビューコメントへ対応し、修正を push した後
- レビュアーの質問やフィードバックへ返信するとき

## 手順

### 1. レビューコメントを特定する

アクティブ PR から未解決のレビューコメントを取得します。

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '.[] | select(.in_reply_to_id == null) | "\(.id) \(.path): \(.body)"'
```

### 2. 修正コミットを特定する

レビューコメントに対応したコミットを確認します。

```bash
git log --oneline origin/main..HEAD
```

### 3. 返信文を作成する

各返信は以下の形式で作成します。

<!-- TODO: プロジェクトの返信フォーマットに合わせて編集してください -->
<!-- 例: 英日バイリンガルの場合 -->
<!-- <English reply> -->
<!-- --- -->
<!-- <日本語の返信> -->

```
<返信本文>

[<short-hash>](https://github.com/{owner}/{repo}/commit/<full-hash>)
```

- コミットリンクは短縮ハッシュを表示テキストとして使う
- コード変更がない場合（質問回答のみなど）はコミットリンクを省略する

### 4. ユーザー承認を得る

**必須**：返信を投稿する前に、全ドラフト返信をユーザーに提示し、明示承認を待ちます。承認なしで投稿してはいけません。

提示形式：

```
**File: <path>**
Original comment: <summary of reviewer's comment>
Reply:
> <draft reply content>
```

### 5. 返信を投稿する

ユーザー承認後、`gh api` で各返信を投稿します。

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  -f "body=<reply content>" \
  -F in_reply_to=<comment_id> --jq '.id'
```

## 注意

- 返信の言語は上記フォーマットに従う
  - 指定のない場合、コメントと同じ言語で返信する
- コード変更がある場合は末尾に必ずコミットリンクを付ける
- ユーザー承認なしで返信を投稿しない

## 出力ルール

ファイルを作成または編集したら、ユーザーがすぐ開けるよう、チャット末尾に必ず Markdown リンクでファイルパスを表示します。
