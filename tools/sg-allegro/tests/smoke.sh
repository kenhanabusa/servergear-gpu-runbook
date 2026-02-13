#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[smoke] Phase A: import-only should PASS"
"$ROOT/sg-verify-allegro" --import-only | tail -n 40 || true

echo
echo "[smoke] Phase B: infer should FAIL with E_MODEL_MISSING when model missing; doctor suggests fetch-model"
set +e
"$ROOT/sg-verify-allegro" --infer >/tmp/stk015_verify_B.out 2>&1
rc=$?
set -e
echo "[smoke] rcB=$rc"
tail -n 80 /tmp/stk015_verify_B.out || true
"$ROOT/sg-allegro-doctor" | tail -n 80

echo "[smoke] done"
