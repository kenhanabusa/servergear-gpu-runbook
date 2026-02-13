#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[smoke] Phase A: import-only should PASS"
VERIFY_MODE=import-only "$ROOT/sg-verify-allegro" | tail -n 40 || true

echo
echo "[smoke] Phase B: infer should FAIL with E_MODEL_MISSING (no model) and doctor suggests fetch-model"
set +e
VERIFY_MODE=infer "$ROOT/sg-verify-allegro" >/tmp/stk015_verify_B.out 2>&1
rc=$?
set -e
echo "[smoke] rcB=$rc"
tail -n 80 /tmp/stk015_verify_B.out || true
"$ROOT/sg-allegro-doctor" | tail -n 80

echo "[smoke] done"
