#!/usr/bin/env bash
# install.sh — Unpack opencode-conventions-config into a target repository.
#
# Usage:
#   ./install.sh [TARGET_DIR]
#
# TARGET_DIR defaults to the current working directory.
#
# What it does:
#   1. Copies .opencode/instructions/, .opencode/prompts/, .opencode/skills/
#      into TARGET_DIR, preserving directory structure.
#   2. Deep-merges opencode.json from this repo into TARGET_DIR/opencode.json:
#        - Scalar fields (model, small_model, …): consumer wins on conflict.
#        - Arrays (plugin, instructions): union — duplicates removed.
#        - agent map: consumer agent entries win; missing agents are added.
#        - permission map: consumer entries win; missing keys are added.
#
# Requirements: bash 3+, jq (https://jqlang.github.io/jq/)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$PWD}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

info()  { printf '\033[0;34m[install]\033[0m %s\n' "$*"; }
ok()    { printf '\033[0;32m[install]\033[0m %s\n' "$*"; }
warn()  { printf '\033[0;33m[install]\033[0m %s\n' "$*"; }
die()   { printf '\033[0;31m[install]\033[0m %s\n' "$*" >&2; exit 1; }

require_jq() {
  if ! command -v jq &>/dev/null; then
    die "jq is required but not found. Install it: https://jqlang.github.io/jq/download/"
  fi
}

# ---------------------------------------------------------------------------
# Step 1 — Copy .opencode sub-directories
# ---------------------------------------------------------------------------

copy_opencode_dirs() {
  local src_opencode="$SCRIPT_DIR/.opencode"
  local dst_opencode="$TARGET_DIR/.opencode"

  for subdir in instructions prompts skills; do
    local src="$src_opencode/$subdir"
    local dst="$dst_opencode/$subdir"

    if [[ ! -d "$src" ]]; then
      warn "Source directory $src does not exist — skipping."
      continue
    fi

    info "Copying .opencode/$subdir/ → $dst/"
    mkdir -p "$dst"

    # rsync if available (preserves timestamps, handles nested dirs cleanly);
    # fall back to cp -r.
    if command -v rsync &>/dev/null; then
      rsync -a --no-owner --no-group "$src/" "$dst/"
    else
      cp -r "$src/." "$dst/"
    fi
  done

  ok ".opencode sub-directories copied."
}

# ---------------------------------------------------------------------------
# Step 2 — Merge opencode.json
# ---------------------------------------------------------------------------

merge_opencode_json() {
  local src_json="$SCRIPT_DIR/opencode.json"
  local dst_json="$TARGET_DIR/opencode.json"

  if [[ ! -f "$src_json" ]]; then
    warn "Source opencode.json not found — skipping JSON merge."
    return
  fi

  if [[ ! -f "$dst_json" ]]; then
    info "No opencode.json in target — copying as-is."
    cp "$src_json" "$dst_json"
    ok "opencode.json created."
    return
  fi

  info "Merging opencode.json into $dst_json …"

  # Merge strategy (jq):
  #   base  = source (conventions defaults)
  #   patch = consumer (wins on conflict for scalars)
  #
  #   - plugin[]       : union of both arrays (deduplicated)
  #   - instructions[] : union of both arrays (deduplicated)
  #   - agent{}        : base entries filled in where consumer has none
  #   - permission{}   : base entries filled in where consumer has none
  #   - all other keys : consumer wins (patch overwrites base)
  local merged
  merged=$(jq -s '
    .[0] as $base |
    .[1] as $patch |

    # union helper: combine two arrays and deduplicate
    def union(a; b): (a + b) | unique;

    $base
    # Merge scalar/object keys: patch wins
    * $patch
    # Re-apply array unions (the * above would have let patch win entirely)
    | .plugin       = union(($base.plugin       // []);  ($patch.plugin       // []))
    | .instructions = union(($base.instructions // []);  ($patch.instructions // []))
    # agent: base provides defaults; patch entries override
    | .agent        = (($base.agent // {}) + ($patch.agent // {}))
    # permission: base provides defaults; patch entries override
    | .permission   = (($base.permission // {}) + ($patch.permission // {}))
  ' "$src_json" "$dst_json")

  # Write back with a trailing newline
  printf '%s\n' "$merged" > "$dst_json"
  ok "opencode.json merged."
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  require_jq

  if [[ ! -d "$TARGET_DIR" ]]; then
    die "Target directory does not exist: $TARGET_DIR"
  fi

  info "Installing opencode conventions into: $TARGET_DIR"
  copy_opencode_dirs
  merge_opencode_json
  ok "Done. Review the changes and commit them to your repository."
}

main "$@"
