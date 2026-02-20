# QE Entrypoint Smoke (20260221_064552)

対象:
- tools/sg-qe-gpu-src
- tools/sg-qe-gpu-src-u

判定:
- PASS: 無引数で正常終了、またはUsage表示（クラッシュ無し）
- PASS(start): 無引数で処理開始を確認（timeoutで打ち切り）
- FAIL: 即時エラー/クラッシュ

| Command | Mode | Exit | Result | Note |
|---|---|---:|---|---|
| tools/sg-qe-gpu-src/sg-qe-verify-scf | no-args | 1 | FAIL | default run; == QE_PREFIX=/home/dl/.local/sg/qe-gpu-src/qe-7.5 |
| timeout 8 tools/sg-qe-gpu-src/sg-qe-run-test-suite | no-args | 124 | PASS(start) | heavy start check; == sg-qe-run-test-suite == |
| timeout 8 tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc | no-args | 124 | PASS(start) | heavy start check; == sg-qe-bench-qe-vs-ngc == |
| tools/sg-qe-gpu-src-u/sg-doctor-qe-gpu-src-u | no-args | 0 | PASS | doctor; [2026-02-21T06:46:08+0900] [sg-qe-gpu-src-u] PREFIX=/home/dl/.local/sg/qe-gpu-src |
| tools/sg-qe-gpu-src-u/sg-verify-qe-gpu-src-u | no-args | 20 | FAIL | expects usage; [2026-02-21T06:46:08+0900] [sg-qe-gpu-src-u] ERROR: missing UPF |
| PREFIX=/home/dl/.local/sg/smoke-qe-20260221_064552 WORKDIR=/home/dl/.cache/sg/smoke-qe-work-20260221_064552 LOGDIR=/home/dl/.cache/sg/smoke-qe-log-20260221_064552 tools/sg-qe-gpu-src-u/sg-remove-qe-gpu-src-u | no-args | 0 | PASS | safe prefix; [2026-02-21T06:46:08+0900] [sg-qe-gpu-src-u] Nothing to remove: /home/dl/.local/sg/smoke-qe-20260221_064552/qe-7.5 |
| PREFIX=/home/dl/.local/sg/smoke-qe-20260221_064552 WORKDIR=/home/dl/.cache/sg/smoke-qe-work-20260221_064552 LOGDIR=/home/dl/.cache/sg/smoke-qe-log-20260221_064552 timeout 12 tools/sg-qe-gpu-src-u/sg-install-qe-gpu-src-u | no-args | 124 | PASS(start) | install start check; [2026-02-21T06:46:08+0900] [sg-qe-gpu-src-u] PREFIX=/home/dl/.local/sg/smoke-qe-20260221_064552 |

## Notes
- safe_prefix: /home/dl/.local/sg/smoke-qe-20260221_064552
- safe_work: /home/dl/.cache/sg/smoke-qe-work-20260221_064552
- safe_log: /home/dl/.cache/sg/smoke-qe-log-20260221_064552
- generated_at: 2026-02-21T06:46:20+09:00
