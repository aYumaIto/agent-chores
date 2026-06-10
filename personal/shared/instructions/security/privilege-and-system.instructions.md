# 特権昇格・システム改変の制御

## 原則

ユーザー以外への影響範囲が大きい操作 (特権昇格 / システム領域改変 / 常駐影響) は、**自律的に実行しない**。
明示的な指示があった場合のみ、影響範囲を提示してから実行する。

## ルール

### 1. sudo を自律的に使わない

`sudo` を含むコマンドは、ユーザーが明示的に指示した場合のみ実行する。
インストール手順や設定変更で sudo が必要そうな場合でも、まずユーザーに確認:

| NG (自律実行) | OK |
|---|---|
| `sudo apt install foo` | 「sudo が必要です。実行してよいか」確認後 |
| `sudo chown ...` | 同上 |
| `sudo systemctl restart ...` | 同上 |

`sudo -n` (non-interactive) も同様に確認必須。

### 2. システムディレクトリへの書き込み禁止

明示許可なしに以下に書かない:

- `/etc/`, `/usr/`, `/System/`, `/Library/` (macOS のシステム領域)
- `/private/`, `/var/`, `/opt/`
- `/Applications/` 配下の既存アプリ内部
- 他ユーザーの `$HOME`

ユーザーの個人領域 (`~/`) でも以下は **常駐影響が大きい** ため確認必須:

- `~/Library/LaunchAgents/`, `~/Library/LaunchDaemons/` (常駐プロセス追加)
- `~/.ssh/authorized_keys` (SSH アクセス権変更)
- `~/.bashrc`, `~/.zshrc`, `~/.bash_profile`, `~/.zprofile`, `~/.profile` (shell 起動スクリプト)
- `~/.config/fish/config.fish`, `~/.config/nushell/`
- crontab 全般 (`crontab -e`, `crontab <file>`)

### 3. パーミッション緩和の禁止

以下はユーザーが明示的に指示した場合のみ:

- `chmod 777`, `chmod -R 777`, `chmod a+w` (世界書き込み許可)
- `chmod +s`, `chmod g+s`, `chmod u+s` (setuid / setgid)
- `chown root`, `chown -R` (所有者一括変更)
- `setfacl` での広い ACL 付与

### 4. 危険な rm パターンの禁止

以下は実行しない (typo / 変数未定義事故防止):

- `rm -rf /`
- `rm -rf ~`, `rm -rf $HOME`, `rm -rf ~/`
- `rm -rf .` / `rm -rf ./` (cwd が想定外の可能性)
- `rm -rf $VAR/` (`VAR` が未定義だと `rm -rf /` 相当)
- `rm -rf ..` / `rm -rf ../`

破壊的削除を行うとき:

- 対象は **絶対パスで明示** する (相対パスは cwd 取り違えで事故りやすい)
- 変数を含む場合は **`${VAR:?VAR is required}`** で未定義時に失敗させる:

  ```bash
  rm -rf "${BUILD_DIR:?BUILD_DIR is required}"
  ```

- `--preserve-root` (rm のデフォルト) を `--no-preserve-root` で外さない

### 5. システムサービス・設定の変更はユーザー確認必須

以下はシステム挙動を変える可能性があり、いずれもユーザー確認後:

- `launchctl load/unload/bootstrap/bootout`
- `systemctl` (Linux)
- `defaults write` (macOS のアプリ設定変更)
- `networksetup`, `scutil` (ネットワーク設定変更)
- `pmset`, `nvram` (電源 / NVRAM 設定)
- `dscl`, `dseditgroup` (ユーザー / グループ管理)
- `csrutil` (SIP 制御 — そもそも recovery でしか動かないが)

### 6. パッケージマネージャの大域操作

ユーザー範囲の `brew install <pkg>`, `npm install <pkg>` 等は通常可。ただし以下は確認必須:

- `brew uninstall --force`, `brew cleanup -s` (キャッシュ含む大域削除)
- `npm install -g`, `npm uninstall -g` (グローバル領域変更)
- `pip install --user` 以外の system-wide install
- `apt`, `dnf`, `yum`, `pacman` 系すべて (sudo が必要なため §1 で既に確認必須)
