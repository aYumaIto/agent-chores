# ネットワーク取得時の検証

## 原則

外部から取得した内容は、**LLM の知識ベースで組み立てた URL** ではなく、ユーザー or 公式ドキュメントから明示的に提供された URL のみを対象とする。
取得後の検証なしに実行・展開しない。

## ルール

### 1. URL の出所制限

base prompt の「URL を推測・生成しない」ルールを fetch 系コマンドにも適用する。
以下のコマンドの URL は **ユーザー提示 or 公式ドキュメント記載のもの** のみ:

- `curl`, `wget`, `httpie`, `xh`
- `git clone <url>`, `git remote add <name> <url>`
- `npm install <git/tarball-url>`, `pip install <url>`, `cargo install --git <url>`
- `gh repo clone <owner/repo>`, `gh release download <tag>`
- `go install <module>`, `go get <module>`
- WebFetch ツール経由の取得

LLM の記憶ベースで「たぶん `https://github.com/xxx/yyy` だろう」と推測しない。
不明な場合はユーザーに正確な URL を確認する。

### 2. ダウンロードしたファイルの即実行禁止

`shell-execution-safety` の install script ルールと整合:

| NG | OK |
|---|---|
| `curl ... \| sh` | DL → 内容確認 → ユーザー判断 → 実行 |
| `bash <(curl ...)` | 同上 (process substitution も禁止) |
| `eval "$(curl ...)"` | 同上 |
| `pip install --index-url https://untrusted/...` | 公式 PyPI 以外の index 使用はユーザー確認 |
| `npm install ./local-dir-from-fetch.tgz` | `tar -tzf` 等で中身確認後にユーザー判断 |

### 3. パッケージ取得時の検証

新規依存追加を提案するとき:

- パッケージ名は **公式ドキュメント** で確認した正確な名前にする (typo-squatting 対策: 例 `colors` vs `colorss`, `requests` vs `request`)
- バージョンを明示する。`latest` / バージョン未指定を避ける (`^1.2.3` / `~1.2.3` / 完全固定 のいずれか)
- 出所が公式 registry でない場合 (GitHub URL 指定 / プライベートレジストリ等) は **どこから取るか** を明示してユーザー確認
- 可能なら公式リポジトリの URL を併記して、ユーザーが検証できるようにする

### 4. fetch 結果の取り扱い

WebFetch / `curl` で取得した内容を:

- そのまま `eval`, `bash`, `sh`, `source` に渡さない
- shell コマンドの引数として未クオートで渡さない (interpolation 経路: `shell-execution-safety` §5 と整合)
- 一旦ファイルに保存して内容確認してから利用
- JSON/YAML パーサ (`jq`, `yq`) を通すなど、構造化された形で扱う

### 5. プライベートエンドポイントの推測禁止

`localhost`, `127.0.0.1`, `0.0.0.0`, `::1`, 内部 IP (`10.*`, `172.16-31.*`, `192.168.*`), `*.internal`, `*.local` への fetch は、**用途・ポート・パスを LLM が推測しない**。
ユーザー or 設定ファイル (`.env`, `package.json` の scripts, `docker-compose.yml`, `vite.config.*`, `next.config.*` 等) に記載された実値のみ使用する。

例:
- NG: 「開発サーバーは `localhost:3000` だろう」と推測してアクセス
- OK: `package.json` の scripts や `.env` の値を読んで、実際のポートを確認してからアクセス

### 6. プロキシ・MITM 警告

`HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY` 環境変数が設定されている場合や、
`curl --insecure`, `wget --no-check-certificate`, `NODE_TLS_REJECT_UNAUTHORIZED=0`, `PYTHONHTTPSVERIFY=0` を **生成しない**。
TLS 検証を無効化する必要がある場合は、ユーザーに理由と影響範囲を提示して判断を仰ぐ。
