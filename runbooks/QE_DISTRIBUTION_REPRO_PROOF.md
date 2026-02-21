# QE Distribution Repro Proof (A100x4)

目的:
- 配布ZIPが A100x4 上で「展開 → install/verify/bench」を再現できることを、Phase A/B の証跡で示す。

## 使用した配布ZIP
- zip: `dist/qe_runbook_20260221_084319_3ace43a.zip`
- sha256: `dbb769ae916143a579b288b96a350c119cbcec4198db21c4c9f22ab1d83e3e99`

## 実行ベース
- repro root: `/home/dl/bench/BENCH-QE-RUNBOOK-REPRO-001/20260221_085957`

## Phase A（非破壊）実行コマンド
1. `tools/sg-qe-gpu-src-u/sg-doctor-qe-gpu-src-u`
2. `tools/sg-qe-gpu-src-u/sg-install-qe-gpu-src-u`
3. `tools/sg-qe-gpu-src/sg-qe-verify-scf --require-gpu`
4. `tools/sg-qe-gpu-src/sg-qe-run-test-suite --include-glob pw_atom --nprocs 1`
5. `tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc`
6. (最小追試)  
   `SG_QE_OMPI_ROOT=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/comm_libs/12.9/hpcx/hpcx-2.22.1/ompi NVCOMPILER_COMM_LIBS_HOME=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/comm_libs/12.9 NVHPC_CUDA_HOME=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/cuda/12.9 tools/sg-qe-gpu-src/sg-qe-verify-scf --require-gpu`

### Phase A 主要結果
- doctor: `rc=0`
- install: `rc=0`
- verify(初回): `rc=1`  
  - 理由: MPI/CUDA 組み合わせ未指定（`verify.err` に `set NVCOMPILER_COMM_LIBS_HOME`）
- verify(最小追試): `rc=0`
- pw_atom: `rc=0`（`PASS_COUNT=6`, `FAIL_COUNT=0`, `SKIP_COUNT=0`）
- bench(無引数): `rc=0`  
  - native-only + auto-scale 実行  
  - `NGC: SKIP (image not provided / docker not available)`

## Phase B（クリーン/破壊的）実行コマンド
1. pre証跡採取（`pre_env.txt`, `pre_ldd_pw.txt`）
2. `tools/sg-qe-gpu-src-u/sg-remove-qe-gpu-src-u`
3. fallback削除（ユーザー領域のみ）
   - `~/.local/sg/qe-gpu-src/qe-7.5`
   - `~/.cache/sg/qe-gpu-src`
   - `~/.cache/sg/qe-gpu-src-u`
   - `~/.cache/sg/logs/sg-qe-gpu-src-u`
4. `tools/sg-qe-gpu-src-u/sg-doctor-qe-gpu-src-u`
5. `tools/sg-qe-gpu-src-u/sg-install-qe-gpu-src-u`
6. `tools/sg-qe-gpu-src/sg-qe-verify-scf --require-gpu`
7. `tools/sg-qe-gpu-src/sg-qe-run-test-suite --include-glob pw_atom --nprocs 1`
8. `tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc`
9. (最小追試)  
   `SG_QE_OMPI_ROOT=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/comm_libs/12.9/hpcx/hpcx-2.22.1/ompi NVCOMPILER_COMM_LIBS_HOME=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/comm_libs/12.9 NVHPC_CUDA_HOME=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/cuda/12.9 tools/sg-qe-gpu-src/sg-qe-verify-scf --require-gpu`
10. post証跡採取（`post_env.txt`, `post_ldd_pw.txt`, `pre_post_*.diff`）

### Phase B 主要結果
- remove_runbook: `rc=0`
- doctor_after_remove: `rc=0`
- install_clean: `rc=0`
- verify_clean(初回): `rc=1`（Phase A と同理由）
- verify_clean_retry_env: `rc=0`
- pw_atom_clean: `rc=0`（`PASS_COUNT=6`, `FAIL_COUNT=0`, `SKIP_COUNT=0`）
- bench_default_clean: `rc=0`（native-only、NGCはSKIP）

## 証跡ファイル
### Phase A
- summary: `/home/dl/bench/BENCH-QE-RUNBOOK-REPRO-001/20260221_085957/phaseA/logs/summary_phaseA.txt`
- proof zip: `/home/dl/bench/BENCH-QE-RUNBOOK-REPRO-001/20260221_085957/phaseA_proof_20260221_085957.zip`
- verify log: `/home/dl/.local/sg/qe-gpu-src/qe-7.5/.sg-logs/verify-scf_20260221_090226.log`
- test-suite summary: `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260221_090226/summary.txt`
- bench summary: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260221_090245/summary.txt`
- bench zip: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/epw_metal_vs_ngc_20260221_090245.zip`

### Phase B
- pre env: `/home/dl/bench/BENCH-QE-RUNBOOK-REPRO-001/20260221_085957/phaseB/logs/pre_env.txt`
- pre ldd: `/home/dl/bench/BENCH-QE-RUNBOOK-REPRO-001/20260221_085957/phaseB/logs/pre_ldd_pw.txt`
- post env: `/home/dl/bench/BENCH-QE-RUNBOOK-REPRO-001/20260221_085957/phaseB/logs/post_env.txt`
- post ldd: `/home/dl/bench/BENCH-QE-RUNBOOK-REPRO-001/20260221_085957/phaseB/logs/post_ldd_pw.txt`
- pre/post diff: `/home/dl/bench/BENCH-QE-RUNBOOK-REPRO-001/20260221_085957/phaseB/logs/pre_post_env.diff`
- summary: `/home/dl/bench/BENCH-QE-RUNBOOK-REPRO-001/20260221_085957/phaseB/logs/summary_phaseB.txt`
- proof zip: `/home/dl/bench/BENCH-QE-RUNBOOK-REPRO-001/20260221_085957/phaseB_proof_20260221_085957.zip`
- verify log: `/home/dl/.local/sg/qe-gpu-src/qe-7.5/.sg-logs/verify-scf_20260221_091441.log`
- test-suite summary: `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260221_091013/summary.txt`
- bench summary: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260221_091300/summary.txt`
- bench zip: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/epw_metal_vs_ngc_20260221_091300.zip`

## 注意点（壊す範囲）
- Phase B の削除対象はユーザー領域のみ（`~/.local/sg`, `~/.cache/sg` のQE関連）。
- `/opt` やシステム領域は変更しない。
- NGC比較は default OFF。未指定時はSKIP記録で正常終了。

## 復旧方法（最短）
1. `tools/sg-qe-gpu-src-u/sg-doctor-qe-gpu-src-u`
2. `tools/sg-qe-gpu-src-u/sg-install-qe-gpu-src-u`
3. `tools/sg-qe-gpu-src/sg-qe-verify-scf --require-gpu`
4. 必要なら最小環境変数（`SG_QE_OMPI_ROOT`, `NVCOMPILER_COMM_LIBS_HOME`, `NVHPC_CUDA_HOME`）を付与して verify 再実行
