# QE Proof Pack Index

目的:
- 配布時に渡す証跡の参照先を1ページで示す。

## 1) verify（GPU実行確認）
- 例:
  - `/home/dl/.local/sg/qe-gpu-src/qe-7.5/.sg-logs/verify-scf_20260220_163532.log`
  - `/home/dl/.local/sg/qe-gpu-src/qe-7.5/.sg-logs/verify-scf_gpu_20260220_163532.txt`
- 見る点:
  - `JOB DONE`
  - `PWSCF ... WALL`
  - GPU関連行（timing/利用痕跡）

## 2) PW subset test-suite（スコープ内）
- summary:
  - `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_163603/summary.txt`
  - `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_163714/summary.txt`
  - `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_163746/summary.txt`
- 補足:
  - `PASS/FAIL/SKIP` の区別を summary で確認する。
  - スコープ外は `SKIP` として扱う。

## 3) epw_metal bench（native-only default）
- summary:
  - `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260221_073036/summary.txt`
- zip:
  - `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/epw_metal_vs_ngc_20260221_073036.zip`
- 見る点:
  - `bench2_native_np*` の `JOB DONE` と `PWSCF ... WALL`
  - NGC未指定時の `NGC: SKIP (image not provided / docker not available)`

## 4) 入口スモーク（無引数UX）
- `runbooks/QE_ENTRYPOINT_SMOKE.md`
- 見る点:
  - `FAIL` を残さず、`PASS / PASS(start) / SAFE BLOCK` で整理されていること
