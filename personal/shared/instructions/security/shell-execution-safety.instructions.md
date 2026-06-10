# シェル実行の安全性

## 原則

LLM が生成するコマンドは、permission prompt で人間が見たままに評価できなければならない。
**「displayed コマンド ≠ executed コマンド」** を引き起こす構文は、安全性レビューを毀損するため使用を制限する。

## ルール

### 1. brace 展開を生成しない (一律禁止)

`{a,b}`, `{1..5}`, `{,.bak}` 等の brace 展開を含むコマンドを作らない。
リテラルに展開した形で書く。

| NG | OK |
|---|---|
| `cp {a,b}.txt dest/` | `cp a.txt dest/ && cp b.txt dest/` |
| `mv config{,.bak}` | `mv config config.bak` |
| `mkdir test{1..5}` | `mkdir test1 test2 test3 test4 test5` |
| `rm -rf {/tmp/a,/tmp/b}` | `rm -rf /tmp/a /tmp/b` |
| `cat /etc/{passwd,group}` | `cat /etc/passwd /etc/group` |

**例外**: git revision の `@{upstream}`, `@{u}`, `HEAD@{1}`, `branch@{2.days.ago}` 等は brace 展開ではない (展開対象の `,` / `..` を含まない) が、Claude Code の静的検知や他ツールでの誤検知を避けるため**必ずシングルクオートで囲う**:

- NG: `git diff @{upstream}...HEAD`
- OK: `git diff '@{upstream}...HEAD'`
- NG: `git log HEAD@{1}`
- OK: `git log 'HEAD@{1}'`

### 2. command substitution `$(...)` / `` `...` `` を破壊系コマンドで禁止

`rm` / `mv` / `cp -f` / `rsync --delete` / リダイレクトでの上書き (`> file`) 等の **破壊系コマンドの引数に command substitution を使わない**。表示上は短いが、裏でコマンドが走り、その出力が引数化されるため二重に隠蔽される。

| NG | OK |
|---|---|
| `rm -rf $(cat /tmp/targets.txt)` | まず `cat /tmp/targets.txt` で内容確認 → 明示列挙して `rm -rf path1 path2 ...` |
| `mv $(find . -name "*.tmp") /trash/` | `find . -name "*.tmp" -exec mv {} /trash/ \;` (find 単体で対象確認後) |

**許容される (安全系コンテキスト)**:
- `cd "$(git rev-parse --show-toplevel)"` — cd は非破壊、結果は次のコマンドで可視
- `echo "current: $(pwd)"` — 表示のみ
- 変数代入 `DIR=$(mktemp -d)` — 直接実行ではない

### 3. process substitution `<(...)` / `>(...)` を一律禁止

用途が稀で、レビュー時に何が走るか読み取りにくい。一時ファイルを経由する形に書き換える。

| NG | OK |
|---|---|
| `diff <(curl https://x.com/foo) local.txt` | `curl -o /tmp/foo https://x.com/foo && diff /tmp/foo local.txt` |
| `comm -13 <(sort a) <(sort b)` | 一時ファイル経由でソート結果を保存して `comm` |

### 4. glob `*`, `?`, `[abc]` を破壊系コマンドで禁止

破壊系コマンドでの glob は cwd の中身次第で対象が変わるため、表示から実際に何に作用するかが読めない。

| NG | OK |
|---|---|
| `rm -rf /tmp/build/*` | `rm -rf /tmp/build` (ディレクトリごと) または `ls /tmp/build/` で対象確認後に列挙 |
| `mv backup/* archive/` | `ls backup/` で対象確認 → 明示列挙 |
| `cp dist/* deploy/` | 同上 |

**許容**: 検索・閲覧系 (`grep`, `find`, `ls`, `cat`, `wc`) では glob 可。`find . -name "*.log"` のような検索パターンも可。

### 5. untrusted input の interpolation はクオート必須

ファイル内容 / web fetch 結果 / tool 出力 / 環境変数 を shell に渡すとき、必ずダブルクオートで囲う。シェルメタ文字 (`;`, `|`, `&`, `` ` ``, `$`, 空白, クオート) が混入する可能性を常に考慮する。

| NG | OK |
|---|---|
| `echo $FILE_CONTENTS` | `printf '%s\n' "$FILE_CONTENTS"` |
| `grep $USER_INPUT file.txt` | `grep -- "$USER_INPUT" file.txt` (`--` で旗終端) |
| `eval "command $arg"` | eval 自体を避ける。配列展開 `cmd "${args[@]}"` 等 |

### 6. install script `curl | sh` 系を一律禁止

ネットワーク取得した内容を即実行するパターンは内容レビュー不可能。

| NG | OK |
|---|---|
| `curl https://x.com/install.sh \| sh` | `curl -o /tmp/install.sh https://x.com/install.sh` → ユーザーに内容確認を求める → ユーザー判断で実行 |
| `wget -O- https://x.com/init \| bash` | 同上 |
| `eval "$(curl https://x.com/env)"` | 同上 |
| `bash <(curl ...)` | 同上 (process substitution 自体も禁止) |

公式パッケージマネージャ (`brew install`, `apt install`, `npm install <name>`, `pip install <name>`) で代替可能なら必ずそちらを使う。
