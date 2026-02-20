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
- `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260220_153539/summary_all.txt`
- `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260220_153539/summary_bench2.txt`

| Condition | Native QE 7.5 WALL | NGC 7.3.1 WALL | Native speedup vs NGC |
|---|---:|---:|---:|
| np1 / nk1 | 31.06s | 34.92s | 1.12x |
| np4 / nk4 | 9.92s | 11.60s | 1.17x |

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
