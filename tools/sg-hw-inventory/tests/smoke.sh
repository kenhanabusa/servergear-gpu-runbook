#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

OUT="${1:-/tmp/sg-hw-inventory-smoke}"
rm -rf "$OUT"
mkdir -p "$OUT"

./sg-hw-inventory --out "$OUT" --overwrite >/dev/null

test -f "$OUT/report.md"
test -f "$OUT/report.json"
test -f "$OUT/report.csv"

python3 - <<'PY'
import json,sys
j = json.load(open(sys.argv[1],'r',encoding='utf-8'))
assert j['metadata']['redaction']['serial'] is True
print('OK: default redaction on')
PY "$OUT/report.json"
