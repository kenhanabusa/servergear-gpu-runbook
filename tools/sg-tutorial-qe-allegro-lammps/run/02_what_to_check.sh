#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

HERE="$(cd "$(dirname "$0")" && pwd)"
BUNDLE_DIR="$(cd "$HERE/../../sg-bundle-qe-allegro-lammps" && pwd)"
LAST="$(ls -1dt "$BUNDLE_DIR"/out/logs/* 2>/dev/null | head -n 1 || true)"

if [[ -z "$LAST" ]]; then
  echo "No bundle logs found. Run verify first."
  exit 20
fi

echo "== What To Check =="
echo "log dir: $LAST"
echo

echo "QE check points"
echo "- JOB DONE があるか"
echo "- SCF収束や total cpu time が出るか"
rg -n "JOB DONE|total cpu time|convergence" "$LAST/qe_single.log" -S || true

echo
echo "Allegro check points"
echo "- torch cuda_available=True か"
echo "- INFER_OK_COMPILED があるか"
rg -n "cuda_available|INFER_OK_COMPILED|PASS" "$LAST/allegro_infer.log" -S || true

echo
echo "LAMMPS check points"
echo "- Step/Loop time/Performance が出るか"
rg -n "Step|Loop time|Performance|ERROR" "$LAST/lammps_short.log" -S || true

echo
echo "GPU evidence"
ls -1 "$LAST"/nvidia_* 2>/dev/null || true
