#!/usr/bin/env bash
set -euo pipefail

# normalized return codes
RC_OK=0
RC_SKIP=20
RC_FAIL=40

SG_LOG_DIR="${SG_LOG_DIR:-/var/log/sg-runbook}"
SG_TASK="${SG_TASK:-STK-011}"
SG_TS="${SG_TS:-$(date +%Y%m%d_%H%M%S)}"
SG_LOG_TXT="${SG_LOG_TXT:-$SG_LOG_DIR/${SG_TASK}_${SG_TS}.log}"
SG_LOG_JSONL="${SG_LOG_JSONL:-$SG_LOG_DIR/${SG_TASK}_${SG_TS}.jsonl}"
sg_init_logs() {
  # Try without sudo first
  mkdir -p "$SG_LOG_DIR" 2>/dev/null || true
  touch "$SG_LOG_TXT" "$SG_LOG_JSONL" 2>/dev/null || true

  if test -w "$SG_LOG_DIR" && test -w "$SG_LOG_TXT" && test -w "$SG_LOG_JSONL"; then
    return 0
  fi

  # Try sudo only if non-interactive is allowed (no password prompt)
  if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    sudo -n mkdir -p "$SG_LOG_DIR" || true
    sudo -n touch "$SG_LOG_TXT" "$SG_LOG_JSONL" || true
    sudo -n chown -R "$(id -un)":"$(id -gn)" "$SG_LOG_DIR" || true

    if test -w "$SG_LOG_DIR" && test -w "$SG_LOG_TXT" && test -w "$SG_LOG_JSONL"; then
      return 0
    fi
  fi

  # Fallback to HOME (always writable)
  SG_LOG_DIR="${HOME}/sg-runbook-log"
  mkdir -p "$SG_LOG_DIR"
  SG_LOG_TXT="$SG_LOG_DIR/${SG_RUNBOOK_ID}_${SG_RUN_TS}.log"
  SG_LOG_JSONL="$SG_LOG_DIR/${SG_RUNBOOK_ID}_${SG_RUN_TS}.jsonl"
  touch "$SG_LOG_TXT" "$SG_LOG_JSONL"
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

# --- SG_RESULT_EMIT_BEGIN ---
# Structured result emission (jsonl) + trap
SG_RUNBOOK_ID="${SG_RUNBOOK_ID:-STK-011}"
SG_RUNBOOK_VER="${SG_RUNBOOK_VER:-0.1.0}"
SG_LOG_DIR="${SG_LOG_DIR:-/var/log/sg-runbook}"

sg__can_write_logdir() {
  mkdir -p "$SG_LOG_DIR" 2>/dev/null && test -w "$SG_LOG_DIR"
}

sg__init_log_paths() {
  local ts
  ts="$(date +%Y%m%d_%H%M%S)"
  if ! sg__can_write_logdir; then
    SG_LOG_DIR="${HOME}/sg-runbook-log"
    mkdir -p "$SG_LOG_DIR"
  fi
  SG_RUN_TS="$ts"
  SG_LOG_TXT="$SG_LOG_DIR/${SG_RUNBOOK_ID}_${SG_RUN_TS}.log"
  SG_LOG_JSONL="$SG_LOG_DIR/${SG_RUNBOOK_ID}_${SG_RUN_TS}.jsonl"
}

# minimal classifier (best-effort)
sg__classify_from_txt() {
  local tail
  tail="$(tail -n 200 "${SG_LOG_TXT:-/dev/null}" 2>/dev/null || true)"
  if echo "$tail" | grep -qi "pseudo_dir missing"; then
    echo "E_PSEUDO_DIR_MISSING|Set pseudo_dir to actual UPF path."
    return 0
  fi
  if echo "$tail" | grep -qiE "LAMMPS sample input/data missing|E_INPUT_NOT_FOUND"; then
    echo "E_LMP_SAMPLE_MISSING|Place sample input+data (and model) or point to published zip; then re-run verify."
    return 0
  fi
  if echo "$tail" | grep -qiE "model.*missing"; then
    echo "E_MODEL_MISSING|Provide model.nequip.pth (or change MODEL path) and retry."
    return 0
  fi
  if echo "$tail" | grep -qiE "QE not installed"; then
    echo "E_QE_NOT_INSTALLED|Run sg-install-qe then retry."
    return 0
  fi
  if echo "$tail" | grep -qiE "lmp: not found|LAMMPS.*not installed"; then
    echo "E_LMP_NOT_INSTALLED|Run sg-install-lammps-allegro then retry."
    return 0
  fi
  echo "-|no obvious failure"
}

sg__emit_jsonl_result() {
  python3 - "${SG_LOG_JSONL}" <<'PYIN'
import json, os, sys, time
path=sys.argv[1]
rec={
  "ts": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
  "type": "result",
  "runbook": os.environ.get("SG_RUNBOOK_ID",""),
  "version": os.environ.get("SG_RUNBOOK_VER",""),
  "step": os.environ.get("SG_STEP","UNKNOWN"),
  "rc": int(os.environ.get("SG_RC","0")),
  "err": os.environ.get("SG_ERR",""),
  "hint": os.environ.get("SG_HINT",""),
  "log_txt": os.environ.get("SG_LOG_TXT",""),
  "log_jsonl": os.environ.get("SG_LOG_JSONL",""),
}
with open(path,"a",encoding="utf-8") as f:
  f.write(json.dumps(rec,ensure_ascii=False)+"\n")
PYIN
}

sg__on_exit_emit() {
  local rc="$1" errhint err hint
  export SG_RC="$rc"
  if [ -z "${SG_STEP:-}" ]; then SG_STEP="UNKNOWN"; fi
  if [ -z "${SG_ERR:-}" ]; then
    errhint="$(sg__classify_from_txt || true)"
    err="${errhint%%|*}"
    hint="${errhint#*|}"
    export SG_ERR="$err"
    export SG_HINT="$hint"
  fi
  : >> "${SG_LOG_TXT}" 2>/dev/null || true
  : >> "${SG_LOG_JSONL}" 2>/dev/null || true
  export SG_RUNBOOK_ID SG_RUNBOOK_VER SG_LOG_DIR SG_LOG_TXT SG_LOG_JSONL SG_STEP
  sg__emit_jsonl_result || true
}

sg_begin() {
  SG_STEP="${1:-UNKNOWN}"
  sg__init_log_paths
  export SG_RUNBOOK_ID SG_RUNBOOK_VER SG_LOG_DIR SG_LOG_TXT SG_LOG_JSONL SG_STEP
  if command -v sg_log >/dev/null 2>&1; then
    sg_log "BEGIN step=$SG_STEP"
  else
    echo "[begin] step=$SG_STEP" >> "$SG_LOG_TXT"
  fi
  trap 'sg__on_exit_emit $?' EXIT
}
# --- SG_RESULT_EMIT_END ---

