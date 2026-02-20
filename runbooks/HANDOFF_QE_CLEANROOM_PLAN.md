# QE Cleanroom Plan (SSOT extraction)

目的: ユーザー領域の NVHPC/QE をいったん除去し、Runbook だけで再構築して verify/test/bench を通す。

## Scope / SSOT
- NVHPC user toolchain:
  - `tools/sg-nvhpc-u/sg-install-nvhpc-u`
  - `tools/sg-nvhpc-u/sg-verify-nvhpc-u`
  - `tools/sg-nvhpc-u/sg-remove-nvhpc-u`
  - `tools/sg-nvhpc-u/sg-doctor-nvhpc-u`
- QE benchmark/test runner:
  - `tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc`
  - `tools/sg-qe-gpu-src/sg-qe-run-test-suite`
- QE install/verify/remove の実体（同リポ内 user variant）:
  - `tools/sg-qe-gpu-src-u/sg-install-qe-gpu-src-u`
  - `tools/sg-qe-gpu-src-u/sg-verify-qe-gpu-src-u`
  - `tools/sg-qe-gpu-src-u/sg-remove-qe-gpu-src-u`
  - `tools/sg-qe-gpu-src-u/sg-lib.sh`

## 1) インストール先 / cache / log / work
### NVHPC (`tools/sg-nvhpc-u/*`)
- Prefix:
  - default `~/.local/sg/nvhpc`
- Cache:
  - default `~/.cache/sg/nvhpc`
  - tarball default `~/.cache/sg/nvhpc/nvhpc_linux_x86_64.tar.gz`
- Logs / verify:
  - verify logdir default `~/.cache/sg/logs/sg-nvhpc-u`
  - verify workdir default `~/.cache/sg/nvhpc/verify/<timestamp>`
- Trash:
  - default `~/.local/sg/_trash`

### QE user install (`tools/sg-qe-gpu-src-u/*`)
- Prefix:
  - default `~/.local/sg/qe-gpu-src`
  - install dir `~/.local/sg/qe-gpu-src/qe-7.5`
- Work:
  - default `~/.cache/sg/qe-gpu-src-u`
  - source clone `~/.cache/sg/qe-gpu-src-u/qe-src`
  - build work `~/.cache/sg/qe-gpu-src-u/qe-build`
  - verify input `~/.cache/sg/qe-gpu-src-u/inputs`
- Logs:
  - default `~/.cache/sg/logs/sg-qe-gpu-src-u`

### QE bench/test (`tools/sg-qe-gpu-src/*`)
- Bench (`sg-qe-bench-qe-vs-ngc`):
  - `--bench-root` 配下に `work/<run_tag>_<ts>`, `logs/<run_tag>_<ts>`, zip
  - preset `epw_metal_bench_heavy` default bench-root:
    - `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001`
- Test-suite (`sg-qe-run-test-suite`):
  - default bench-root:
    - `/home/dl/bench/BENCH-QE-TESTSUITE-001`

## 2) nvfortran / mpirun / cuda の決定ロジック
### NVHPC
- `sg-install-nvhpc-u` は `~/.local/sg/nvhpc/env.sh` を生成。
- env.sh:
  - `NVHPC_ROOT` は `~/.local/sg/nvhpc/Linux_x86_64/2026` 優先
  - `NVHPC_CUDA_HOME` は `cuda/13.1` 優先
  - `PATH` へ `compilers/bin` を prepend（`nvfortran`）
  - `SG_USE_HPCX_MPI=1` のとき `/opt/.../hpcx.../ompi/bin` を prepend（`mpirun`）
  - `NVHPC_USE_MPI=1` のとき NVHPC MPI を有効化（既定 OFF）
  - `NVCOMPILER_COMM_LIBS_HOME` を `comm_libs` へ設定

### QE install (`sg-install-qe-gpu-src-u`)
- `nvcc` は `detect_nvcc`（PATH上の `nvcc`）
- NVHPC は `detect_nvhpc`（PATH上の `nvc`）を必須化
- `PATH="$NVHPC_BIN:$PATH"` で NVHPC compiler を優先
- `CUDA_HOME` は `NVHPC_CUDA_HOME` を優先し、無ければ `nvcc` から推定
- QE source は `git clone --branch qe-7.5`

### QE test-suite (`sg-qe-run-test-suite`)
- `mpirun` は固定で `/opt/nvidia/hpc_sdk/.../hpcx.../ompi/bin` を PATH 先頭に設定
- `NVCOMPILER_COMM_LIBS_HOME=/opt/nvidia/hpc_sdk/.../comm_libs/12.9`
- `NVHPC_CUDA_HOME=/opt/nvidia/hpc_sdk/.../cuda/12.9`
- QE source/build は引数未指定時に既定候補から autodetect

### QE bench (`sg-qe-bench-qe-vs-ngc`)
- Native `pw.x`: default `~/.local/sg/qe-gpu-src/qe-7.5/bin/pw.x`
- `mpirun`: `command -v mpirun`
- `NVCOMPILER_COMM_LIBS_HOME` / `NVHPC_CUDA_HOME` 未設定時は `/opt/nvidia/hpc_sdk/...` を補完
- NGC MCA default: `ob1-tcp-eth0`（`coll ^hcoll`）

## 3) 削除対象にしてよいパス（ユーザー領域のみ）
- NVHPC:
  - `~/.local/sg/nvhpc`
  - `~/.cache/sg/nvhpc`
  - （必要時）`~/.local/sg/_trash/nvhpc.*`
- QE:
  - `~/.local/sg/qe-gpu-src`
  - `~/.cache/sg/qe-gpu-src-u`
  - `~/.cache/sg/logs/sg-qe-gpu-src-u`
- Optional cleanup candidates (logs only):
  - `~/.cache/sg/logs/sg-nvhpc-u`

## 4) 触ってはいけないパス（削除禁止）
- `/opt/nvidia/hpc_sdk` 以下すべて
- `/opt/sg` 以下すべて
- システム領域:
  - `/usr`, `/etc`, `/var`, `/lib*`, `/bin`, `/sbin`
- Bench成果物ルート（証跡保存先）:
  - `/home/dl/bench/*` は削除せず、証跡追記のみ

## 実施ガード
- 削除前に対象を再掲し、`realpath` で home 配下のみを確認。
- `/opt` を掴む挙動が見えた場合は削除を止め、本メモ更新のうえ相談。
