# agent-chores

AI エージェント向けのルール・スキル・設定をまとめたリポジトリ。
各ツールのディレクトリだけ見れば必要なファイルが揃う構成にしている。
共通ファイルは `shared/` に実体を置き、ツール別ディレクトリから symlink で参照する。

## ディレクトリ構成

```
agent-chores/
├── personal/                       # 個人マシン向け
│   ├── shared/                     # ツール非依存（実体）
│   │   ├── instructions/           # ルール
│   │   └── skills/                 # スキル
│   ├── claude/                     # Claude Code 専用
│   │   ├── agents/                 # Subagent 定義（~/.claude/agents/ に配置）
│   │   ├── instructions -> ../shared/instructions
│   │   └── skills -> ../shared/skills
│   └── copilot/                    # Copilot CLI 専用
│       ├── agents/                 # .agent.md（Copilot Custom Agent）
│       └── instructions -> ../shared/instructions
├── project/                        # リポジトリに配置するテンプレート
│   ├── shared/                     # ツール非依存（PR template 等）
│   │   ├── instructions/
│   │   ├── skills/
│   │   └── pull_request_template.md
│   ├── claude/                     # .claude/ に配置する Claude 専用
│   └── copilot/                    # Copilot 専用
│       └── copilot-instructions.md # .github/copilot-instructions.md に配置
└── README.md
```

## 使い方

Claude Code を使う場合は `personal/claude/` 、Copilot CLI を使う場合は `personal/copilot/` の中身を参照する。
symlink 経由で `shared/` の instructions・skills も含まれる。

**注意**: ファイル内には `<INSTRUCTIONS_DIR>`、`<SKILLS_DIR>` などのプレースホルダーを使っている箇所がある。そのまま配置しても動作しないため、自身の環境に合わせて実パスに書き換えること。`grep -rn '<[A-Z_]*>' personal/` でプレースホルダーの一覧を確認できる。

## ツール固有 vs 共通の判断基準

| 性質 | 配置先 |
|---|---|
| エージェント挙動の一般原則（回答スタイル、安全性等） | `shared/` |
| ツール固有のファイル書式・設定（frontmatter、tool 名等） | `claude/` or `copilot/` |
| ツール固有の機能を前提とする skill | `claude/` or `copilot/` |
| 迷ったとき | まず `shared/` に置き、ツール固有差分が出たら分離 |

## 外部依存

一部のスキル・エージェントは外部ツールを前提としている。

| ツール | 用途 | 参照先 |
|---|---|---|
| [RTK](https://github.com/rtk-ai/rtk) | トークン最適化 CLI プロキシ | `instructions/rtk-usage.instructions.md` |
| [android CLI](https://developer.android.com/tools/agents/android-cli) | Android ビルド・デプロイ・SDK 管理 | `skills/android-cli/`、`agents/android-runner.*` |

## ライセンス

[MIT](LICENSE)
