#!/usr/bin/env bash
set -euo pipefail

SG_LOG_DIR="${SG_LOG_DIR:-/var/log/sg-runbook}"
SG_TASK="${SG_TASK:-STK-011}"
SG_TS="${SG_TS:-$(date +%Y%m%d_%H%M%S)}"
SG_LOG_TXT="${SG_LOG_TXT:-$SG_LOG_DIR/${SG_TASK}_${SG_TS}.log}"
SG_LOG_JSONL="${SG_LOG_JSONL:-$SG_LOG_DIR/${SG_TASK}_${SG_TS}.jsonl}"

sg_init_logs() {
  sudo mkdir -p "$SG_LOG_DIR"
  sudo touch "$SG_LOG_TXT" "$SG_LOG_JSONL"
  sudo chown -R "$(id -un)":"$(id -gn)" "$SG_LOG_DIR"
}

sg_now() { date -Is; }

# JSONはpython無しで雑に（安全側）…値は短い想定
sg_jsonl() {
  local step="$1" status="$2" err="$3" hint="$4" cmd="$5"
  printf '{"ts":"%s","task":"%s","step":"%s","status":"%s","err":"%s","hint":"%s","cmd":"%s"}\n' \
    "$(sg_now)" "$SG_TASK" "$step" "$status" "$err" "$hint" "$cmd" \
    >> "$SG_LOG_JSONL"
}

sg_log() { echo "[$(sg_now)] $*" | tee -a "$SG_LOG_TXT" >&2; }

# 終了コードの統一
# 0=OK, 20=SKIP, 40=FAIL
sg_pass() { sg_log "PASS: $1"; sg_jsonl "$2" "pass" "-" "$1" "${3:-}"; return 0; }
sg_skip() { sg_log "SKIP: $1"; sg_jsonl "$2" "skip" "$3" "$1" "${4:-}"; return 20; }
sg_fail() { sg_log "FAIL: $1"; sg_jsonl "$2" "fail" "$3" "$1" "${4:-}"; return 40; }
