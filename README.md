# servergear-gpu-runbook

GPUサーバー向け「install / verify / remove」Runbook集（Public / 無償公開）です。  
目的は **“試して戻せる”** 形で、GPUスタックの導入・検収・切り分けを再現可能にすることです。

---

## できること（無料）
- Runbookは **install / verify / remove** の3本セット（ロールバックしやすい）
- `sg-step` による **PRE → GOOD** 運用（変更前スナップショット → 作業 → 検証）
- シングルノードSlurmで **1GPU/ジョブ** の実行確認（`--gres=gpu:1`）
- Apptainer + PyTorch（SIF）+ GenAIデモを **Docker不要** で試せる

> Optional：CUDA Toolkit / Docker GPU / NVHPC は環境差が大きいので「任意」扱いです（`runbooks/optional/`）。

---

## 対象（想定）
- OS：Ubuntu 24.04系（推奨）
- GPU：NVIDIA GPU
- 主要スタック：NVIDIA driver / Apptainer / PyTorch(SIF) / Slurm(single-node)

---

## Quickstart（最短）
> まずは **verify から**（破壊的変更を避ける）

```bash
git clone https://github.com/kenhanabusa/servergear-gpu-runbook.git
cd servergear-gpu-runbook

# 例：runbookを配置（必要ならパスを変えてください）
sudo install -m 0755 runbooks/core/* /usr/local/sbin/
sudo install -m 0755 runbooks/gpu/* /usr/local/sbin/
sudo install -m 0755 runbooks/containers/* /usr/local/sbin/
sudo install -m 0755 runbooks/pytorch/* /usr/local/sbin/
sudo install -m 0755 runbooks/slurm/* /usr/local/sbin/

# 最小の確認
sg-verify-gpu
```

---

## ディレクトリ構成
- `runbooks/core/`：運用の核（`sg-step` / `sg-precheck` / `sg-collect-info` / `sg-verify-gpu` など）
- `runbooks/gpu/`：NVIDIA driver（install/verify/remove）
- `runbooks/containers/`：Apptainer / GenAI demo（install/verify/remove）
- `runbooks/pytorch/`：PyTorch (Apptainer SIF)
- `runbooks/slurm/`：Slurm single-node / Slurm GenAI demo
- `runbooks/optional/`：CUDA Toolkit / Docker GPU / NVHPC（任意）

---

## QE Bench (Native vs NGC)
ネイティブ QE 7.5 と NGC QE 7.3.1 を **同条件** で比較するためのベンチ実行スクリプトです。
np=4 は **必ず `-nk 1`** で統一し、pinning は `mpirun --bind-to core --map-by slot` に固定します。

Handoff（再開用要約）: `runbooks/HANDOFF_QE_BENCH_STATE.md`

運用ルール（重要）:
- `k=1` は **同条件比較** 用（native/NGCの横比較）
- `k=2x2x2` は **スケーリング検証** 用（`-nk` を使った並列効率確認）

### 実行例
```bash
tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc \
  --bench-root /home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728 \
  --input /home/dl/bench/BENCH-QE-LLZO-SCF-001/20260219_092728/work/llzo96.in \
  --np1 1 \
  --np4 4 \
  --native-qe-prefix /home/dl/.local/sg/qe-gpu-src/qe-7.5 \
  --ngc-image nvcr.io/hpc/quantum_espresso:qe-7.3.1 \
  --mca-profile auto
```

### MCA プロファイル
- `auto` は **安定優先** の fallback を実施します。
  1. `ob1-tcp-eth0`
  2. `ob1-tcp`
- `ucx` / `smcuda` は **実験扱い** で、明示指定時のみ使用します。

### 出力構造
- work: `bench-root/work/bench_qe_vs_ngc_YYYYmmdd_HHMMSS/`
  - `native_np1/`, `native_np4/`, `ngc_np1_*`, `ngc_np4_*`
  - 各ケースの `*.out`, `*.err`, `input.in`, `pseudos/`
- logs: `bench-root/logs/bench_qe_vs_ngc_YYYYmmdd_HHMMSS/`
  - `summary.txt`（JOB DONE / PWSCF WALL / rc）
  - `*_nvidia_smi.csv`（1s 間隔）
  - `*.log`（実行コマンドと環境）
- zip: `bench-root/bench_qe_vs_ngc_YYYYmmdd_HHMMSS.zip`

---

## 相談が早いケース（有償）
- 本番環境で失敗できない / 期限がある
- Secure Boot / DKMS / Kernel差分で詰まる
- Slurm運用（multi-node、運用設計、監査/検収）まで固めたい
- ハード選定（GPU/メモリ/ストレージ）を根拠付きで決めたい

→ 相談窓口（統一）
https://notes.server-gear.com/lp/h200-nvl-1gpu-runbook/

---

## Security / Keys
- NGC/HFなどのトークンは **このリポジトリに含めません**
- ログに秘密情報を出さない運用を推奨します
- Public repoです。鍵・トークン・顧客固有情報が混入しないよう注意してください。

---

## License
MIT（または Apache-2.0）

---

## Disclaimer
本リポジトリは「現状のまま」提供します。環境差により動作しない可能性があります。  
安全のため、まずは検証環境で試してください。
