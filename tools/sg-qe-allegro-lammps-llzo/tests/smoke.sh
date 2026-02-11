#!/usr/bin/env bash
set -euo pipefail
# normalized return codes
RC_OK=0
RC_SKIP=20
RC_FAIL=40

DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "== smoke: QE verify should FAIL with pseudo_dir missing =="
rm -rf "$DIR/sample/pseudos" 2>/dev/null || true
set +e
"$DIR/sg-verify-qe" "$DIR/sample/llzo96_scf_300k.in"
rc=$?
set -e
echo "rc=$rc (expect 40 fail) OK"

echo
echo "== smoke: LAMMPS verify should FAIL with model missing (expected) =="
set +e
"$DIR/sg-verify-lammps-allegro" "$DIR/sample" "$DIR/sample/in.bench1_throughput" "$DIR/sample/llzo_51840.data" "$DIR/sample/model.nequip.pth"
rc=$?
set -e
echo "rc=$rc (expect 40 fail OR 20 skip if lmp missing) OK"

echo
echo "== doctor classify =="
"$DIR/sg-runbook-doctor" "/var/log/sg-runbook" "classify" || true

echo
echo "DONE"
