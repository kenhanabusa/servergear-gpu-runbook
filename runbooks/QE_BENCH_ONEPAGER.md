# QE Bench Onepager (Native 7.5 vs NGC 7.3.1)

採用ベンチ: `epw_metal` + `input_bench_heavy.in` (`ecutwfc=80`, `k=30x30x30`)

## 同条件の定義
- 同一入力: `input_bench_heavy.in`（同一ハッシュ）
- 同一スレッド条件: `OMP/MKL/OPENBLAS/FFTW=1`
- 同一 pinning: `mpirun --bind-to core --map-by slot --rank-by slot`
- 同一 rank→GPU 固定: `CUDA_VISIBLE_DEVICES=$OMPI_COMM_WORLD_LOCAL_RANK`
- 同一判定: `JOB DONE` と `PWSCF ... WALL` を採用
- 同一証跡: `nvidia-smi` 1秒サンプリング
- NGC は安定MCA固定: `ob1 + tcp + eth0 + coll ^hcoll`

## 結果（latest: `summary_all.txt` / `summary_bench2.txt`）
Source:
- `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260220_163805/summary_all.txt`
- `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260220_163805/summary_bench2.txt`

| Condition | Native QE 7.5 WALL | NGC 7.3.1 WALL | Native speedup vs NGC |
|---|---:|---:|---:|
| np1 / nk1 | 30.84s | 35.07s | 1.14x |
| np4 / nk4 | 9.92s | 11.53s | 1.16x |

## 再現コマンド（1行）
Native:
```bash
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1 FFTW_NUM_THREADS=1 OMP_PROC_BIND=close OMP_PLACES=cores; mpirun --bind-to core --map-by slot --rank-by slot -np 4 bash -lc 'export CUDA_VISIBLE_DEVICES=${OMPI_COMM_WORLD_LOCAL_RANK:-0}; exec /home/dl/.local/sg/qe-gpu-src/qe-7.5/bin/pw.x -nk 4 -in input_bench_heavy.in'
```

NGC:
```bash
docker run --rm --gpus all --ipc=host --network=host -w /work -v "$PWD:/work" -e OMP_NUM_THREADS=1 -e OPENBLAS_NUM_THREADS=1 -e MKL_NUM_THREADS=1 -e FFTW_NUM_THREADS=1 -e OMP_PROC_BIND=close -e OMP_PLACES=cores -e OMPI_MCA_coll=^hcoll -e OMPI_MCA_pml=ob1 -e OMPI_MCA_btl=self,tcp -e OMPI_MCA_btl_tcp_if_include=eth0 -e OMPI_MCA_oob_tcp_if_include=eth0 nvcr.io/hpc/quantum_espresso:qe-7.3.1 bash -lc "mpirun --bind-to core --map-by slot --rank-by slot -np 4 bash -lc 'export CUDA_VISIBLE_DEVICES=\${OMPI_COMM_WORLD_LOCAL_RANK:-0}; exec /usr/local/qe/bin/pw.x -nk 4 -in /work/input_bench_heavy.in'"
```

## 注意
- `k=1` は native/NGC の同条件比較用。
- `k=2x2x2` はスケーリング検証用（用途を分離）。
- NGC は MCA profile を固定して比較する（`ob1+tcp+eth0`, `coll ^hcoll`）。
- ベンチコマンドは無引数で起動可能（既定で `epw_metal_bench_heavy`）。
- 既定で `--auto-scale` 有効（`1,2,4,8...` をGPU枚数上限まで、最大8）。
- 既定は native-only。NGCは `--with-ngc --ngc-image <image>` 指定時のみ実行。

## Update (2026-02-21)
- no-args bench (default native-only + auto-scale):
  - summary: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260221_073036/summary.txt`
  - zip: `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/epw_metal_vs_ngc_20260221_073036.zip`
  - summary includes: `NGC: SKIP (image not provided / docker not available)`
