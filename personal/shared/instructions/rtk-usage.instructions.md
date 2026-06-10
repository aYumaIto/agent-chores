# RTK - Rust Token Killer

Token-optimized CLI proxy (60-90% savings on dev operations)

## 基本ルール

- Bash で外部コマンドを実行するときは、原則として常に `rtk <cmd>` 形式にする（`git`, `gh`, `npm`, `pnpm`, `adb`, `android`, `find`, `ls` などの直呼びをしない）
- `&&` / `||` / `;` を含む複合コマンドでも同様に、各サブコマンドを個別に `rtk` 経由にする（例: `test -f <path> && rtk git --no-pager status --short --branch`）
- shell builtin（`test`, `cd`, `export` など）はそのままでよいが、同じ行の外部コマンド部分は必ず `rtk` を付ける

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

## Hook-Based Usage

All other commands are automatically rewritten by the Claude Code hook.
Example: `git status` → `rtk git status` (transparent, 0 tokens overhead)

## Copilot CLI Strict Usage

Copilot CLI では hook が deny を返して再実行になることがあるため、最初の試行から手動で `rtk` を付ける。

```bash
# NG
git --no-pager status --short --branch

# OK
rtk git --no-pager status --short --branch
```

複合コマンドでも外部コマンド部分は必ず `rtk` を使う。

```bash
# NG
test -f /path/to/file && git --no-pager status --short --branch

# OK
test -f /path/to/file && rtk git --no-pager status --short --branch
```

## Manual Pipe Patterns

Hook が自動書き換えしないコマンドは、手動で `rtk` にパイプして使う。

| コマンド | 推奨パターン |
|---|---|
| `adb logcat` (ログ確認) | `adb [flags] logcat [filters] \| rtk log` |
| `adb logcat` (エラーのみ) | `adb [flags] logcat [filters] \| rtk err` |

**例:**
```bash
# 直近 200 行のログをフィルタ
adb -s <device> logcat -d -t 200 | rtk log

# エラー・警告のみ
adb -s <device> logcat -d | rtk err

# grep で絞り込んでから rtk log
adb -s <device> logcat -d | grep -iE "chromium|console" | rtk log
```
