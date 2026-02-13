#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
TOOL_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "[smoke] Phase A: expect E_LMP_SAMPLE_MISSING (no sample) or E_SIF_MISSING (no container)"
set +e
"$TOOL_DIR/sg-verify-lammps-allegro" >/tmp/stk016_A.out 2>&1
rcA=$?
set -e
echo "[smoke] rcA=$rcA"
tail -n 40 /tmp/stk016_A.out || true
"$TOOL_DIR/sg-lammps-allegro-doctor" | tail -n 80

echo
echo "[smoke] Phase B: fetch sample then verify; expect E_MODEL_MISSING if model not present"
set +e
"$TOOL_DIR/sg-fetch-sample-lammps" >/tmp/stk016_fetch_sample.out 2>&1 || true
"$TOOL_DIR/sg-verify-lammps-allegro" >/tmp/stk016_B.out 2>&1
rcB=$?
set -e
echo "[smoke] rcB=$rcB"
tail -n 40 /tmp/stk016_B.out || true
"$TOOL_DIR/sg-lammps-allegro-doctor" | tail -n 80

echo "[smoke] done"
