# QE Bench Handoff State (native QE 7.5 vs NGC qe-7.3.1)

## TL;DR（結論）
- k=1（gamma / `-nk 1`固定）の同条件比較では、native は np=1→4 で約1.7〜1.8x（50s→29s前後）まで伸びるが、NGC（ob1+tcp eth0固定）は np=4 が遅くなるケースがある（56.97s→4m44.68s）。
- k=2x2x2（k222, スケーリング用）では、native は np=1→4 で 2.936x（6m23.67s→2m10.67s）まで改善。NGC は npool=4 と4GPU同時使用を満たしても 1.194x（6m50.74s→5m43.91s）に留まり、GPU util も低め（各GPU平均~21%）で通信/同期待ち疑い。
- 方針は明確化済み:
- 「同条件比較」は k=1（`-nk 1`固定）で実施。
- 「スケーリング検証」は k222（`-nk 4`活用）で実施。

## Goal（最終目的）
- QEベンチを同条件で再現可能に回し、native QE 7.5 と NGC qe-7.3.1 の比較を継続可能にする。
- LLZO96 を主対象に、k=1（Gamma系）と k=2x2x2（k点分割あり）を分離評価する。
- 指標は固定:
- `JOB DONE`
- `PWSCF ... WALL`
- `nvidia-smi`（util/memory）

## Current Status（今どこまでできているか）
- 実行スクリプト `tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc` は実装済み・運用中。
- 同スクリプトの実運用仕様:
- native `mpirun` を固定優先（HPC-X 25.7/12.9）し、無ければ `/usr/bin/mpirun` fallback。
- nativeで `NVCOMPILER_COMM_LIBS_HOME` / `NVHPC_CUDA_HOME` を明示 export。
- NGC デフォルト MCA は `ob1-tcp-eth0`（`coll ^hcoll`）を採用。
- `--pin none|core` を持ち、完走優先時は `none`。
- 各runで `which mpirun` / `mpirun --version` / `PATH` をログへ記録。
- run単位で `nvidia-smi -l 1` を取り、trapで停止処理。
- 失敗しても次runへ進み、`summary.txt` に `rc / last 50 lines / PWSCF / JOB DONE` を残す。

## Key Findings（数値つき）
### LLZO96 k=1（同条件比較）
- Source:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/logs/bench_qe_vs_ngc_20260220_101801/summary.txt`
- native np1: `PWSCF : 50.03s WALL`, `JOB DONE`
- native np4 (`-nk 1`): `PWSCF : 29.25s WALL`, `JOB DONE`
- native speedup: `1.710x`
- NGC np1 (`ob1-tcp-eth0`): `PWSCF : 56.97s WALL`, `JOB DONE`
- NGC np4 (`ob1-tcp-eth0`, `-nk 1`): `PWSCF : 4m44.68s WALL`, `JOB DONE`
- NGC speedup: `0.200x`（np4が悪化）

### native tune（k=1, 最終測定）
- Source:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/logs/native_scale_tune_20260220_110705/summary.txt`
- final np1: `49.42s WALL`
- final np2: `43.58s WALL`
- final np4: `27.86s WALL`
- np2 speedup/efficiency: `1.134x / 0.567`
- np4 speedup/efficiency: `1.774x / 0.443`

### LLZO96 k222（スケーリング用）native
- Source:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/logs/native_scale_tune_20260220_110705/k22_nk_scale_20260220_111818/summary_k222.txt`
- np1 nk1: `6m23.67s WALL`, `JOB DONE`
- np4 nk4: `2m10.67s WALL`, `JOB DONE`
- speedup: `2.936x`
- `number of k points = 8`
- `gamma-point specific algorithms` は出ていない（Gamma専用経路ではない）

### LLZO96 k222（スケーリング用）NGC
- Source:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/logs/ngc_k222_20260220_113437/summary.txt`
- np1 nk1: `6m50.74s WALL`
- np4 nk4: `5m43.91s WALL`
- speedup: `1.194x`
- ログで `npool=4`, `k points=8`, `MPI processes=4` を確認済み。
- `nvidia-smi` 集計:
- np1: 実質 GPU0 のみ高util（avg ~72%）
- np4: GPU0-3 使用だが avg util は各 ~21%、mem は各 ~22GB
- 解釈: 4GPU使用自体は成立、ただし通信/同期待ち優勢。

### NGC k222 追加候補（np4）
- Source:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/logs/ngc_k222_20260220_113437/summary.txt`
- baseline `ob1+tcp(eth0)`: `5m43.91s WALL`
- `ob1 + self,vader,tcp`: `5m17.06s WALL`
- `pml=ucx (UCX_TLS=tcp,self,sm,cuda_copy,cuda_ipc)`: `4m59.95s WALL`

### 参考: Si long NGC（20260218）
- Root:
- `/home/dl/bench/BENCH-QE-NGC-001/20260218_190207`
- `si_long_np1.ngc.out`: `12.07s WALL`
- `si_long_np4.ngc.out`: `4.30s WALL`
- `si_long_equiv_np1.ngc.out`: `5m4.28s WALL`
- `si_long_equiv_np4.ngc.out`: `1m29.47s WALL`
- `ngc_run.log` に `cuMemHostRegister`/`smcuda` 初期化失敗の痕跡あり。

## Known Good Commands（コピペ実行）
### 共通
```bash
BENCH_ROOT=/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728
INPUT=$BENCH_ROOT/work/llzo96.in
NATIVE_PREFIX=/home/dl/.local/sg/qe-gpu-src/qe-7.5
NGC_IMAGE=nvcr.io/hpc/quantum_espresso:qe-7.3.1
```

### 同条件比較（k=1, 安定優先）
```bash
cd /home/dl/work/servergear-gpu-runbook
tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc \
  --bench-root "$BENCH_ROOT" \
  --input "$INPUT" \
  --np1 1 \
  --np4 4 \
  --native-qe-prefix "$NATIVE_PREFIX" \
  --ngc-image "$NGC_IMAGE" \
  --mca-profile ob1-tcp-eth0 \
  --pin none
```

### native単体（np1/np4, `-nk 1`固定）
```bash
MPIRUN=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/comm_libs/12.9/hpcx/hpcx-2.22.1/ompi/bin/mpirun
PW=/home/dl/.local/sg/qe-gpu-src/qe-7.5/bin/pw.x
WORK=/path/to/workdir
cd "$WORK"

export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 FFTW_NUM_THREADS=1
export OMP_PROC_BIND=close OMP_PLACES=cores
export NVCOMPILER_COMM_LIBS_HOME=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/comm_libs/12.9
export NVHPC_CUDA_HOME=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/cuda/12.9

$MPIRUN -np 1 "$PW" -nk 1 -in input.in
$MPIRUN -np 4 "$PW" -nk 1 -in input.in
```

### NGC単体（安定優先）
```bash
docker run --rm --gpus all --ipc=host --network=host -w /work \
  -v "$WORK:/work" \
  -e OMP_NUM_THREADS=1 \
  -e OPENBLAS_NUM_THREADS=1 \
  -e MKL_NUM_THREADS=1 \
  -e FFTW_NUM_THREADS=1 \
  -e OMP_PROC_BIND=close \
  -e OMP_PLACES=cores \
  -e OMPI_MCA_coll=^hcoll \
  -e OMPI_MCA_pml=ob1 \
  -e OMPI_MCA_btl=self,tcp \
  -e OMPI_MCA_btl_tcp_if_include=eth0 \
  -e OMPI_MCA_oob_tcp_if_include=eth0 \
  "$NGC_IMAGE" \
  bash -lc 'which mpirun; mpirun --version | sed -n "1,5p"; echo PATH=$PATH; mpirun -np 4 /usr/local/qe/bin/pw.x -nk 1 -in input.in'
```

### k222 スケーリング確認（NGC）
```bash
WORK_K222=/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/work/ngc_k222_20260220_113437
# np=1: mpirun -np 1 /usr/local/qe/bin/pw.x -nk 1 -in llzo96_k222.in
# np=4: mpirun -np 4 /usr/local/qe/bin/pw.x -nk 4 -in llzo96_k222.in
# （MCA/env は上記と同一）
```

## Known Bad / Pitfalls
- NGC np4 で `mca_btl_vader.so` segfault が出るパターンあり。
- `smcuda` 使用時に `cuMemHostRegister ... during init failed` が発生しうる。
- `ob1+tcp(eth0)` は安定寄りだが速度は遅くなりやすい（特に k222 np4）。
- k=1（Gamma-only）では pool並列の恩恵が薄い。
- `-nk` 指定と入力の k点設定が噛み合わないと期待した分割にならない。
- nativeで想定外の `mpirun` を掴むと NVHPC/CUDA ミスマッチで失敗する。
- `hcoll` 初期化エラー文字列があっても `JOB DONE` するケースがある（判定は `rc` と `JOB DONE`）。
- READMEとスクリプト引数のズレ（`--mca-profile auto` 記載など）は都度確認する。

## Artifacts & Paths
- LLZO root:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728`
- 入力:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/work/llzo96.in`
- pseudo:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/work/pseudos/`
- k=1比較 summary:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/logs/bench_qe_vs_ngc_20260220_101801/summary.txt`
- native tune summary:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/logs/native_scale_tune_20260220_110705/summary.txt`
- native k222 summary:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/logs/native_scale_tune_20260220_110705/k22_nk_scale_20260220_111818/summary_k222.txt`
- NGC k222 summary:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/logs/ngc_k222_20260220_113437/summary.txt`
- 主要zip:
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/bench_qe_vs_ngc_20260220_101801.zip`
- `/home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/native_scale_tune_20260220_110705.zip`

## Next Steps（最短 1〜3 手）
- 1. NGC k222 を2候補だけ再測定し、安定を崩さず最速を決める。
- 候補A: `pml=ucx + UCX_TLS=tcp,self,sm,cuda_copy,cuda_ipc`
- 候補B: `ob1 + self,vader,tcp`
- 2. `sg-qe-bench-qe-vs-ngc` の README記載と実装引数を一致させる。
- 3. runbook上で「k=1 同条件比較」と「k222 スケーリング検証」を分離明記し、混同を防ぐ。

## Decisions（決めた方針）
- 同条件比較の定義:
- 同一入力
- 同一スレッド設定（OMP/BLAS=1）
- 同一 `np`
- 同一ログ形式（`PWSCF`, `JOB DONE`, `rc`, `nvidia-smi`）
- k=1同条件比較では np=4 でも `-nk 1` 固定。
- k222 はスケーリング検証専用入力（`-nk 4`活用）として分離運用。
- NGC の初期デフォルトは安定優先（ob1+tcp+eth0, coll^hcoll）。
- 速度探索（ucx/vader/smcuda）はオプションとして段階的に実施。

## Speedup一覧（ログ由来）
- LLZO k=1 native: `50.03s -> 29.25s` = `1.710x`
- LLZO k=1 NGC ob1-tcp-eth0: `56.97s -> 284.68s` = `0.200x`
- LLZO k=1 native final: `49.42s -> 27.86s` = `1.774x`
- LLZO k222 native: `383.67s -> 130.67s` = `2.936x`
- LLZO k222 NGC baseline: `410.74s -> 343.91s` = `1.194x`
- LLZO k222 NGC ucx candidate: `410.74s -> 299.95s` = `1.369x`（np1 baseline基準）
- LLZO k222 NGC vader candidate: `410.74s -> 317.06s` = `1.296x`（np1 baseline基準）

## Cleanroom Final (2026-02-20)
- SSOTメモ:
  - `runbooks/HANDOFF_QE_CLEANROOM_PLAN.md`
- pre/rm/post proof:
  - `/home/dl/bench/_proof_pre_20260220_155751.txt`
  - `/home/dl/bench/_proof_rm_20260220_155825.txt`
  - `/home/dl/bench/_proof_post_20260220_163516.txt`
- verify (`sg-qe-verify-scf --require-gpu`):
  - np1: `/home/dl/.local/sg/qe-gpu-src/qe-7.5/.sg-logs/verify-scf_20260220_163532.log`
  - np1 GPU: `/home/dl/.local/sg/qe-gpu-src/qe-7.5/.sg-logs/verify-scf_gpu_20260220_163532.txt`
  - np4: `/home/dl/.local/sg/qe-gpu-src/qe-7.5/.sg-logs/verify-scf_20260220_163549.log`
  - np4 GPU: `/home/dl/.local/sg/qe-gpu-src/qe-7.5/.sg-logs/verify-scf_gpu_20260220_163549.txt`
- test-suite (pw atom/dft/berry, `--nprocs 1`):
  - pw_atom: `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_163603/summary.txt`
  - pw_dft: `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_163714/summary.txt`
  - pw_berry: `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_163746/summary.txt`
- bench preset (`epw_metal_bench_heavy`):
  - summary: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260220_163805/summary.txt`
  - summary_all: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260220_163805/summary_all.txt`
  - summary_bench2: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260220_163805/summary_bench2.txt`
  - zip: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/epw_metal_vs_ngc_20260220_163805.zip`

## Update (2026-02-21)
- entrypoint smoke report:
  - `runbooks/QE_ENTRYPOINT_SMOKE.md`
- QE install (cc auto + sm log):
  - install log dir: `/home/dl/.cache/sg/logs/sg-qe-gpu-src-u`
  - sm proof: `/home/dl/.cache/sg/logs/sg-qe-gpu-src-u/pw_sm_arch.txt` (`sm_80`)
  - cc policy: `--cuda-cc-policy min|max`（default=min, 互換優先）
- no-args bench run (default native-only + auto-scale):
  - summary: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260221_073036/summary.txt`
  - zip: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/epw_metal_vs_ngc_20260221_073036.zip`
  - summary note: `NGC: SKIP (image not provided / docker not available)`
