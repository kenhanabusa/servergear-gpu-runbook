#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

HERE="$(cd "$(dirname "$0")" && pwd)"
BUNDLE_DIR="$(cd "$HERE/../../sg-bundle-qe-allegro-lammps" && pwd)"
LAST="$(ls -1dt "$BUNDLE_DIR"/out/logs/* 2>/dev/null | head -n 1 || true)"

if [[ -z "$LAST" ]]; then
  echo "No bundle logs found. Run: tools/sg-bundle-qe-allegro-lammps/sg-verify-bundle-qe-allegro-lammps"
  exit 20
fi

echo "== Tutorial T1 Overview =="
echo "latest log dir: $LAST"
echo

echo "[1/3] QE (最小SCF)"
rg -n "JOB DONE|convergence|total cpu time" "$LAST/qe_single.log" -S || true
echo

echo "[2/3] Allegro (推論)"
rg -n "INFER_OK_COMPILED|cuda_available|PASS" "$LAST/allegro_infer.log" -S || true
echo

echo "[3/3] LAMMPS(+Allegro) 短MD"
rg -n "Step|Loop time|Performance|pair_style|allegro" "$LAST/lammps_short.log" -S || true
echo

echo "KPI summary: $BUNDLE_DIR/out/kpi/latest_summary.md"
