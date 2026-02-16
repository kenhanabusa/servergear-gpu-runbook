#!/usr/bin/env bash
set -euo pipefail

# ===== config =====
TOOL_NAME="sg-qe-gpu-src-u"
DEFAULT_PREFIX="${HOME}/.local/sg/qe-gpu-src"
DEFAULT_WORKDIR="${HOME}/.cache/sg/qe-gpu-src-u"
DEFAULT_LOGDIR="${HOME}/.cache/sg/logs/${TOOL_NAME}"
DEFAULT_JOBS="$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 8)"

# Exit codes (normalized)
# 0 ok
# 20 user/action required (missing deps, etc.)
# 40 internal/tool error
EC_OK=0
EC_ACTION=20
EC_INTERNAL=40

ts() { date +"%Y-%m-%dT%H:%M:%S%z"; }
log() { echo "[$(ts)] [$TOOL_NAME] $*" >&2; }
die() { local code="$1"; shift; log "ERROR: $*"; exit "$code"; }

mkdirp() { mkdir -p "$1"; }

# Safe prefix guard: only allow under $HOME/.local/sg/ by default
safe_prefix_or_die() {
  local p="$1"
  case "$p" in
    "$HOME/.local/sg/"* ) return 0 ;;
    * )
      die "$EC_ACTION" "PREFIX must be under \$HOME/.local/sg/ for safety (got: $p). Set PREFIX explicitly if you know what you're doing."
      ;;
  esac
}

# Detect NVHPC
detect_nvhpc() {
  # If user set NVHPC_ROOT, prefer it (optional)
  if command -v nvc >/dev/null 2>&1; then
    echo "$(dirname "$(command -v nvc)")"
    return 0
  fi
  return 1
}

# Detect CUDA toolkit
detect_nvcc() {
  if command -v nvcc >/dev/null 2>&1; then
    command -v nvcc
    return 0
  fi
  return 1
}

# Write doctor JSONL record
doctor_record() {
  local prefix="$1" workdir="$2" logdir="$3" status="$4" step="$5" hint="$6" next_cmds="$7"
  mkdirp "$logdir"
  local out="${logdir}/doctor.jsonl"

  # 正しい heredoc + 追記リダイレクト（ここが壊れていた）
  python3 - "$prefix" "$workdir" "$logdir" "$status" "$step" "$hint" "$next_cmds" >>"$out" <<'PY'
import json, time, sys, os
prefix, workdir, logdir, status, step, hint, next_cmds = sys.argv[1:8]
rec = {
  "ts": int(time.time()),
  "tool": os.environ.get("TOOL_NAME","sg-qe-gpu-src-u"),
  "prefix": prefix,
  "workdir": workdir,
  "logdir": logdir,
  "status": status,
  "step": step,
  "hint": hint,
  "next_cmds": next_cmds.splitlines() if next_cmds.strip() else [],
}
print(json.dumps(rec, ensure_ascii=False))
PY
}


# Auto-detect NVHPC user install env and source it (no-op if absent)
source_nvhpc_env_if_present() {
  local env="${NVHPC_ENV_SH:-$HOME/.local/sg/nvhpc/env.sh}"
  if [ -f "$env" ]; then
    # shellcheck disable=SC1090
    source "$env"
    return 0
  fi
  return 1
}

