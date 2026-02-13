#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

RC_OK=0
RC_SKIP=20
RC_FAIL=40

sg_pick_log_dir() {
  local primary="/var/log/sg-runbook"
  local fallback="${HOME}/sg-runbook-log"
  if mkdir -p "$primary" 2>/dev/null; then
    echo "$primary"
  else
    mkdir -p "$fallback"
    echo "$fallback"
  fi
}

sg_ts() { date -Is; }

sg_log() {
  local file="${1:?}"; shift
  local line="[$(sg_ts)] $*"
  echo "$line" | tee -a "$file" >/dev/null
}

sg_emit_jsonl() {
  local jsonl="${1:?}"
  local payload="${2:?}"
  python3 - <<PY >>"$jsonl"
import json, datetime
obj=json.loads("""$payload""")
obj.setdefault("ts", datetime.datetime.now().astimezone().isoformat())
print(json.dumps(obj, ensure_ascii=False))
PY
}

sg_pass() {
  local txt="${1:?}" step="${2:?}" jsonl="${3:?}" logtxt="${4:?}"
  sg_log "$logtxt" "PASS: $txt"
  sg_emit_jsonl "$jsonl" "{\"task\":\"$STK_ID\",\"step\":\"$step\",\"status\":\"ok\",\"rc\":0,\"err\":\"\",\"hint\":\"$txt\"}"
  exit 0
}

sg_skip() {
  local err="${1:?}" hint="${2:?}" step="${3:?}" jsonl="${4:?}" logtxt="${5:?}"
  sg_log "$logtxt" "SKIP: $hint"
  sg_emit_jsonl "$jsonl" "{\"task\":\"$STK_ID\",\"step\":\"$step\",\"status\":\"skip\",\"rc\":20,\"err\":\"$err\",\"hint\":\"$hint\"}"
  exit 20
}

sg_fail() {
  local err="${1:?}" hint="${2:?}" step="${3:?}" jsonl="${4:?}" logtxt="${5:?}"
  sg_log "$logtxt" "FAIL: $hint"
  sg_emit_jsonl "$jsonl" "{\"task\":\"$STK_ID\",\"step\":\"$step\",\"status\":\"fail\",\"rc\":40,\"err\":\"$err\",\"hint\":\"$hint\"}"
  exit 40
}
