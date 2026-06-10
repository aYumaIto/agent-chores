# Subagent 委譲方針

軽量タスクは Subagent に委譲し、メインモデル (Opus) は判断・対話・高リスクな変更に集中させる。

## 委譲先の選択
- **単一ソースの軽量参照** → `light-lookup` (Haiku)
- **複数ソース横断調査** → `external-research` (Sonnet)
- **ドキュメント草稿生成** → `doc-writer` (Sonnet)
- **コードベース探索** → `Explore` (Haiku, 組み込み)
- **Sonnet/Haiku で済む多ステップタスク** → `general-purpose` (model 引数で明示)

## 強制委譲リスト (main 直叩き禁止)

以下のツール / 作業は **main (Opus) から直接呼ばず、必ず対応する subagent 経由で実行する**。
ユーザーが「`mcp__chrome-devtools__list_pages` を呼んで」のようにツール名を直接指定してきた場合も、
「`chrome-driver` 経由で実行します」と一言述べてから Agent tool で委譲すること (拒否や確認待ちにしない)。

| 対象 | 委譲先 |
|---|---|
| `mcp__chrome-devtools__*` (全 tool) | `chrome-driver` (sonnet) |
| Android 開発タスク全般 (`android` CLI、`adb`、`./gradlew`、エミュレータ操作、`android-cli` skill 呼び出し等) | `android-runner` (haiku) |

理由: これらは返却データが大きく (DOM snapshot、logcat、ビルドログ)、main の Opus トークンで処理するとコストが爆発するため。安価モデルの subagent で前処理 / 要約してから main に戻すのが既定。

### 例外
- 設計判断や複数仮説検証が必要で subagent の出力だけでは進められないとき → 一旦 subagent に状況サマリだけ作らせてから main に戻す
- 1 コマンドの単発確認 (例: `adb devices` 1 回だけ) で委譲オーバーヘッドが明らかに上回る場合のみ、ユーザーに「main で直接実行して良いか」確認した上で実行

## 出力サイズ・判断要否で線引き (コマンド種別での一律委譲を避ける)

線引きの軸は **コマンド種別ではなく「予想出力サイズ + Opus の判断要否」** に置く。

### 委譲する (低モデル subagent)
- 長尺出力が予想される情報取得: `git log` の長尺出力、大規模 `git diff`、`git blame`、`git show <sha>`、`find` ツリー走査、`grep -r` の広範囲検索、ビルドログ参照
- 判断不要な状態確認・履歴調査

委譲先の選び方: 単発参照は `light-lookup`、複数ファイル横断や軽い解析を伴うものは `general-purpose` (sonnet)。

### 委譲しない (main 維持)
- 短く判断不要な操作: `git status`, 単発の短い `git diff`, ブランチ切替, 単発 commit/push
  - 理由: subagent 起動オーバーヘッド (プロンプト構築・返却サマリ生成) が節約分を上回る
- Opus の判断が要る操作: コミットメッセージ作成、コンフリクト解消、リベース戦略決定
  - 理由: 低モデルでは文脈読解が浅くなり、main で書き直す二度手間になる

## 委譲しない場面 (メインで処理)
- Opus の判断が必要な設計・アーキテクチャ選択
- ユーザーとの対話的なやり取り
- 高リスクな変更 (コード修正、コミット作成、外部送信)
- 1〜2 ファイル確認等、委譲オーバーヘッドが上回る作業

## 注意
- カスタム subagent は CLAUDE.md とそこから `@`-import されたファイル群、および `<INSTRUCTIONS_DIR>` を自動ロードする
- 組み込み Explore / Plan は CLAUDE.md をスキップするため、独自ルールはプロンプトで明示する必要がある
- Subagent は会話履歴を引き継がない → プロンプトに前提・出典・期待出力形式を全て含める
