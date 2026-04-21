# agent-chores

AI エージェント（GitHub Copilot / Claude）向けのルール・スキル・設定をまとめたテンプレートリポジトリです。

## 使い方

1. このリポジトリをフォークまたはテンプレートとして使用する
2. 各ファイル内の `<!-- TODO: ... -->` コメントをプロジェクトに合わせて編集する
3. プロジェクト固有のルールやスキルを追加する

## 含まれるもの

- `.claude/rules/` — アーキテクチャ、コーディング規約、Git 運用、セキュリティなどのルール定義
- `.claude/skills/` — ビルド、Issue/PR 作成、レビュー返信などのスキル定義
- `.github/copilot-instructions.md` — Copilot コードレビュー時のプレフィックス指示
- `.github/pull_request_template.md` — PR テンプレート

## ライセンス

[MIT](LICENSE)
