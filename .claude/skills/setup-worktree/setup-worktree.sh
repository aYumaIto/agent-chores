#!/usr/bin/env bash
# origin/main から作業ブランチ付きの feature worktree を作成し、開発環境を準備する。
#
# 使い方: .claude/skills/setup-worktree/setup-worktree.sh <type> <feature-name>
# 例: .claude/skills/setup-worktree/setup-worktree.sh feat add-chat-history

set -euo pipefail

# ── 関数 ─────────────────────────────────────────────────────

usage() {
  cat <<EOF
使い方: $(basename "$0") <type> <feature-name>

引数:
  type          ブランチ種別（feat, fix, refactor, chore, docs, perf, test, ci, style）
  feature-name  短い kebab-case の機能名（例: add-chat-history）

例:
  $(basename "$0") feat add-chat-history
EOF
  exit 1
}

# ── 引数解析 ─────────────────────────────────────────────────

if [[ $# -lt 2 ]]; then
  usage
fi

TYPE="$1"
FEATURE="$2"
shift 2

# type を検証
VALID_TYPES="feat fix refactor chore docs perf test ci style"
if ! echo "$VALID_TYPES" | grep -qw "$TYPE"; then
  echo "エラー: type '$TYPE' は不正です。指定可能: $VALID_TYPES" >&2
  exit 1
fi

# ── リポジトリルートを解決 ─────────────────────────────────

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

REPO_NAME="$(basename "$REPO_ROOT")"
WORKTREE_BASE="../${REPO_NAME}-worktrees"

# ── 手順1: リポジトリ状態確認 ───────────────────────────────

echo "==> リポジトリ状態を確認中..."
git status --short --branch

# ── 手順2: 最新 main 取得 ─────────────────────────────────

echo "==> origin/main を取得中..."
git fetch origin main

# ── 手順3: worktree 作成 ──────────────────────────────────

BRANCH_NAME="${TYPE}-${FEATURE}"
WORKTREE_PATH="${WORKTREE_BASE}/${FEATURE}"

if [[ -d "$WORKTREE_PATH" ]]; then
  echo "エラー: Worktree パスが既に存在します: $WORKTREE_PATH" >&2
  exit 1
fi

echo "==> ワークツリーを作成中..."
echo "    Path:   $WORKTREE_PATH"
echo "    Branch: $BRANCH_NAME"
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" origin/main

# ── 手順4: .vscode/settings.json を skip-worktree に設定 ──

if [[ -f "${WORKTREE_PATH}/.vscode/settings.json" ]]; then
  echo "==> .vscode/settings.json を skip-worktree に設定中..."
  git -C "$WORKTREE_PATH" update-index --skip-worktree .vscode/settings.json
else
  echo "==> worktree 内に .vscode/settings.json がないため、skip-worktree 設定をスキップします。"
fi

# ── 手順5: 確認 ───────────────────────────────────────────

echo ""
echo "==> ワークツリー一覧:"
git worktree list

echo ""
echo "完了: ワークツリーを準備しました: $(cd "$WORKTREE_PATH" && pwd)"
