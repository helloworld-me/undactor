#!/usr/bin/env bash
set -euo pipefail

E_REPO_URL="${E_REPO_URL:-https://github.com/artischocki/epstein-studio.git}"
U_REPO_URL="${U_REPO_URL:-https://github.com/undacted/undacted_v2.git}"
WORKDIR="${WORKDIR:-$(pwd)/build}"
E_DIR="$WORKDIR/epstein-studio"
U_DIR="$WORKDIR/undacted_v2"
MERGED_DIR="$WORKDIR/merged-app"
REPORT_PATH="$WORKDIR/merge-report.md"
CORE_PATHS_FILE="${CORE_PATHS_FILE:-$(pwd)/config/undacted-core-paths.txt}"

log() {
  printf '[merge] %s\n' "$*"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

clone_or_refresh() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ -d "$target_dir/.git" ]]; then
    log "Refreshing existing repo: $target_dir"
    git -C "$target_dir" fetch --all --prune
    git -C "$target_dir" reset --hard origin/HEAD
    return
  fi

  log "Cloning $repo_url -> $target_dir"
  rm -rf "$target_dir"
  git clone "$repo_url" "$target_dir"
}

copy_with_parents() {
  local src_root="$1"
  local dst_root="$2"
  local rel_path="$3"

  local src="$src_root/$rel_path"
  local dst="$dst_root/$rel_path"

  if [[ ! -e "$src" ]]; then
    echo "- ⚠️ Skipped (missing): \\`$rel_path\\`" >> "$REPORT_PATH"
    return
  fi

  mkdir -p "$(dirname "$dst")"
  rm -rf "$dst"
  cp -R "$src" "$dst"
  echo "- ✅ Copied: \\`$rel_path\\`" >> "$REPORT_PATH"
}

main() {
  require_cmd git
  require_cmd cp

  mkdir -p "$WORKDIR"
  : > "$REPORT_PATH"

  clone_or_refresh "$E_REPO_URL" "$E_DIR"
  clone_or_refresh "$U_REPO_URL" "$U_DIR"

  log "Preparing merged app directory"
  rm -rf "$MERGED_DIR"
  mkdir -p "$MERGED_DIR"
  cp -R "$E_DIR"/. "$MERGED_DIR"

  {
    echo "# Merge report"
    echo
    echo "Base: Epstein-Studio"
    echo "Overlay: UNDACTED v2 core paths"
    echo
    echo "## Overlay results"
  } >> "$REPORT_PATH"

  while IFS= read -r rel_path; do
    [[ -z "$rel_path" || "$rel_path" =~ ^# ]] && continue
    copy_with_parents "$U_DIR" "$MERGED_DIR" "$rel_path"
  done < "$CORE_PATHS_FILE"

  log "Done. Merged app at: $MERGED_DIR"
  log "Report: $REPORT_PATH"
}

main "$@"
