# シークレット情報の取り扱い

## 原則

認証情報・秘密鍵・API トークン・パスワードは **transcript / コマンド引数 / commit / 外部送信** のいずれにも残さない。
一度漏れたら回収不可なため、「読んだら出さない」「コミット前に機械チェック」を徹底する。

## 対象ファイル

以下のパスは「シークレットを含む可能性が高い」として扱う:

- `.env`, `.env.*` (`.env.local`, `.env.production` 等)、`.envrc`
- `~/.aws/credentials`, `~/.aws/config`
- `~/.ssh/id_*` (秘密鍵)、`~/.ssh/*.pem`
  - `~/.ssh/config` の Host エントリ参照は可。`IdentityFile` が指す秘密鍵本体は不可
- `~/.docker/config.json`, `~/.npmrc`, `~/.pypirc`, `~/.netrc`
- `*credentials*.json`, `*service-account*.json`
- `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.jks`
- `~/.claude/.credentials.json` (settings.json で既に deny)
- `~/.config/gcloud/`, `~/.kube/config`

## ルール

### 1. 内容を transcript / chat に貼らない

これらのファイルを読んだ場合でも、**内容を会話に出力しない**。
存在確認・形式確認のみで十分なら以下で代替する:

```bash
# 存在
test -f .env && echo exists

# 行数
wc -l .env

# キー一覧のみ (値なし)
grep -E '^[A-Z_]+=' .env | cut -d= -f1

# 形式チェック (値はマスク)
awk -F= '/^[A-Z_]+=/ { printf "%s=<%d chars>\n", $1, length($2) }' .env
```

### 2. コマンド引数として平文で渡さない

引数は `ps aux` で見え、shell history にも残る。

| NG | OK |
|---|---|
| `curl -H "Authorization: Bearer $(cat token.txt)" ...` | 環境変数経由 (最低限) または `--config` ファイル / `~/.netrc` 経由 |
| `mysql -u root -p$(cat pass.txt) ...` | `mysql --defaults-file=~/.my.cnf ...` |
| `psql "postgres://user:pw@host/db"` | `~/.pgpass` 経由 |

### 3. echo / cat で標準出力に出さない

`cat .env`, `echo $SECRET` は transcript に永続化される。出力が必要な場合は値をマスクする:

```bash
# NG
cat .env

# OK (行数のみ)
grep -c '^' .env

# OK (値をマスク表示)
sed 's/=.*/=<masked>/' .env
```

### 4. git commit 前に機械スキャン

`git add` 後・commit 前に、**ステージング内容を必ず以下でチェック**:

```bash
# 危険なパスが staged にないか
git diff --cached --name-only | grep -E '(^|/)\.env(\.|$)|credentials|/id_[a-z]+$|\.pem$|\.key$|service-account|\.netrc$|\.pypirc$' && echo "BLOCK: secret-like path staged"

# 危険な値パターン
git diff --cached | grep -E 'AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|gho_[A-Za-z0-9]{36}|xox[baprs]-[A-Za-z0-9-]+|-----BEGIN [A-Z ]+PRIVATE KEY-----|AIza[0-9A-Za-z_-]{35}|sk-[A-Za-z0-9]{32,}'
```

ヒットしたら **即停止してユーザーに報告**。

### 5. `--no-verify` で pre-commit を回避しない

pre-commit hook (gitleaks, detect-secrets 等) が落ちたら、`--no-verify` で回避するのではなく、検出された内容をユーザーに報告して判断を仰ぐ。

### 6. 広域 add の禁止

`git add .` / `git add -A` / `git add *` は **使わない** (隠れシークレットが紛れる)。
変更ファイルを **個別に明示指定** する。

### 7. 漏洩発覚時の対応

シークレットを誤って commit / push した場合:

1. **沈黙しない** — 直ちにユーザーに通知
2. **rotate を最優先で促す** — git filter-branch / BFG 等の履歴書き換えだけでは不十分 (push 済みなら既に流出済みと見なす)
3. 履歴書き換えはユーザーが rotate 完了後に判断
4. 流出先 (push 先 / CI ログ / Slack 通知 / PR の checks 出力等) も洗い出して報告
