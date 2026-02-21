# QE Entrypoint Smoke (20260221_072958)

対象:
- tools/sg-qe-gpu-src
- tools/sg-qe-gpu-src-u

判定:
- PASS: 無引数で正常終了、またはUsage表示（クラッシュ無し）
- PASS(start): 無引数で処理開始を確認（timeoutで打ち切り）
- SAFE BLOCK: 無引数では安全にブロック（Usage/次アクション案内）し、クラッシュしない

| Command | Mode | Exit | Result | Note |
|---|---|---:|---|---|
| tools/sg-qe-gpu-src/sg-qe-verify-scf | no-args | 0 | SAFE BLOCK | Usage + no-args安全ブロック |
| timeout 8 tools/sg-qe-gpu-src/sg-qe-run-test-suite | no-args | 124 | PASS(start) | heavy start check; == sg-qe-run-test-suite == |
| timeout 8 tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc | no-args | 124 | PASS(start) | heavy start check; == sg-qe-bench-qe-vs-ngc == |
| tools/sg-qe-gpu-src-u/sg-doctor-qe-gpu-src-u | no-args | 0 | PASS | doctor; [2026-02-21T07:30:14+0900] [sg-qe-gpu-src-u] PREFIX=/home/dl/.local/sg/qe-gpu-src |
| tools/sg-qe-gpu-src-u/sg-verify-qe-gpu-src-u | no-args | 0 | SAFE BLOCK | Usage + no-args安全ブロック |
| PREFIX=/home/dl/.local/sg/smoke-qe-20260221_072958 WORKDIR=/home/dl/.cache/sg/smoke-qe-work-20260221_072958 LOGDIR=/home/dl/.cache/sg/smoke-qe-log-20260221_072958 tools/sg-qe-gpu-src-u/sg-remove-qe-gpu-src-u | no-args | 0 | PASS | safe prefix; [2026-02-21T07:30:14+0900] [sg-qe-gpu-src-u] Nothing to remove: /home/dl/.local/sg/smoke-qe-20260221_072958/qe-7.5 |
| PREFIX=/home/dl/.local/sg/smoke-qe-20260221_072958 WORKDIR=/home/dl/.cache/sg/smoke-qe-work-20260221_072958 LOGDIR=/home/dl/.cache/sg/smoke-qe-log-20260221_072958 timeout 12 tools/sg-qe-gpu-src-u/sg-install-qe-gpu-src-u | no-args | 124 | PASS(start) | install start check; [2026-02-21T07:30:14+0900] [sg-qe-gpu-src-u] PREFIX=/home/dl/.local/sg/smoke-qe-20260221_072958 |

## 旧FAILの1行判定（20260221_064552 -> 20260221_072958）
- `tools/sg-qe-gpu-src/sg-qe-verify-scf`: 改善が必要（無引数で実行本体に入って依存不足で失敗していたため、Usage+SAFE BLOCKに変更）
- `tools/sg-qe-gpu-src-u/sg-verify-qe-gpu-src-u`: 改善が必要（Usageより先にUPFチェックで失敗していたため、無引数時は即Usageへ変更）

## Notes
- safe_prefix: /home/dl/.local/sg/smoke-qe-20260221_072958
- safe_work: /home/dl/.cache/sg/smoke-qe-work-20260221_072958
- safe_log: /home/dl/.cache/sg/smoke-qe-log-20260221_072958
- verify note: `sg-qe-verify-scf` は実行時に MPI/CUDA 関連 env の自動補完あり（明示設定は非上書き）
- smoke_raw: /tmp/qe_entry_smoke_20260221_072958.tsv
- generated_at: 2026-02-21T07:30:26+09:00
