# STK-014: Quantum ESPRESSO GPU build runbook (Ubuntu 24.04) v0.1.0

目的:
- GPUが使えるQEを「最新版（release tag）ソース取得→NVHPC+CUDAでビルド→検証」まで再現する。
- H200 NVL (1/4/8 GPU) のバンドル販売に価値がある“難しい手順”をrunbook化する。

前提:
- Ubuntu 24.04
- NVIDIA driver が動作（nvidia-smi）
- NVHPC が導入済み（nvfortran/nvc が PATH）
- NVHPC_CUDA_HOME が設定済み（CUDA toolkit path）

スクリプト:
- sg-install-qe-gpu-src
- sg-verify-qe-gpu-src
- sg-remove-qe-gpu-src

verify はSiの小さなSCFを走らせ、JOB DONE を確認（擬ポテンシャルはQE公式サイトから取得）。

GPU build の configure オプション例:
  ./configure --enable-openacc --with-cuda=$NVHPC_CUDA_HOME --with-cuda-cc=90
