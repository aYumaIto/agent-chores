# agent-chores

AI エージェント向けのルール・スキル・設定をまとめたリポジトリです。
ツール非依存の構成で、各ツールへの配置はシンボリックリンクやコピーで行います。

## ディレクトリ構成

```
agent-chores/
├── project/              # プロジェクト（リポジトリ）に配置するテンプレート
│   ├── instructions/     # 常時適用ルール
│   ├── skills/           # ワークフロー定義
│   └── github/           # GitHub 関連テンプレート
├── personal/             # 個人設定（~/.config/agents 等に配置）
│   ├── instructions/     # 個人ルール
│   └── skills/           # 個人スキル
└── README.md
```

## 使い方

### プロジェクト向け

1. `project/instructions/` と `project/skills/` の内容をリポジトリにコピーする
2. 各ファイル内の `<!-- TODO: ... -->` をプロジェクトに合わせて編集する
3. `project/github/` の内容を `.github/` に配置する

### 個人設定

1. `personal/` の内容を `~/.config/agents/` にコピーまたはリンクする
2. エージェントのスキル読み込みパスにシンボリックリンクを張る

### ツール別の配置先

| ツール | instructions | skills |
|--------|-------------|--------|
| Claude Code | `.claude/rules/` | `.claude/skills/` |
| Copilot CLI | `~/.copilot/instructions/` | `~/.copilot/skills/` |
| 共通原本 | `~/.config/agents/instructions/` | `~/.config/agents/skills/` |

## ライセンス

[MIT](LICENSE)
