#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
TOOL_DIR="$(cd "$(dirname "$0")" && pwd)"

bash "$TOOL_DIR/sg-verify-lammps-allegro" || true
bash "$TOOL_DIR/sg-verify-qe" || true

out="$(bash "$TOOL_DIR/sg-runbook-doctor")"
echo "$out"

echo "$out" | grep -q 'err=E_MODEL_MISSING' || { echo "FAIL: expected E_MODEL_MISSING"; exit 1; }
echo "$out" | grep -q 'sg-fetch-model' || { echo "FAIL: expected sg-fetch-model"; exit 1; }

echo "OK: doctor prioritizes LMP failure"
