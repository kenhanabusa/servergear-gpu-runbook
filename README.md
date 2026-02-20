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
採用ベンチは `epw_metal` + `input_bench_heavy.in` です。
Onepager: `runbooks/QE_BENCH_ONEPAGER.md`

Handoff（再開用要約）: `runbooks/HANDOFF_QE_BENCH_STATE.md`

運用ガイド:
- Install layout: `runbooks/QE_INSTALL_LAYOUT.md`
- Update（ZIP標準 / Git任意）: `runbooks/QE_UPDATE.md`
- Support（最小証跡）: `runbooks/QE_SUPPORT.md`

運用ルール（重要）:
- `k=1` は **同条件比較** 用（native/NGCの横比較）
- `k=2x2x2` は **スケーリング検証** 用（`-nk` を使った並列効率確認）

### 実行例
```bash
tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc
```

- 無引数で起動可能（既定: `--preset epw_metal_bench_heavy`）。
- 既定は native-only（NGC未実行）。
- NGC比較は optional（デフォルトOFF）。
- 既定で `--auto-scale` 有効（`1,2,4,8...` をGPU枚数上限まで、最大8）。
- `--no-auto-scale` で従来の `np1/np4` 実行に固定可能。
- NGCを回す場合のみ `--with-ngc --ngc-image <image>` を指定。
- NGC未指定/利用不可時は `summary.txt` に `NGC: SKIP (image not provided / docker not available)` を記録して正常終了。

```bash
# 明示例
tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc --with-ngc --ngc-image nvcr.io/hpc/quantum_espresso:qe-7.3.1 --no-auto-scale --np1 1 --np4 4
```

### MCA プロファイル
- 既定は `ob1-tcp-eth0`（`ob1 + tcp + eth0固定 + coll ^hcoll`）です。
- `ob1-tcp` / `ucx` / `smcuda` は明示指定時のみ使用します。

### QE Build（cc自動）
- `tools/sg-qe-gpu-src-u/sg-install-qe-gpu-src-u` は `nvidia-smi` から複数GPUの compute capability を取得し、`--cuda-cc-policy` で選択します。
- 既定は `--cuda-cc-policy min`（互換優先: 最小ccを採用）。性能優先が必要な場合のみ `--cuda-cc-policy max` を指定します。
- ビルド後に `pw.x` の `sm_XX` を `LOGDIR/pw_sm_arch.txt` に記録します。

### 出力構造
- work: `bench-root/work/bench_qe_vs_ngc_YYYYmmdd_HHMMSS/`
  - `native_np1/`, `native_np4/`（auto-scale時は `native_np2/` なども生成）
  - NGC有効時のみ `ngc_np1_*`, `ngc_np4_*`
  - 各ケースの `*.out`, `*.err`, `input.in`, `pseudos/`
- logs: `bench-root/logs/bench_qe_vs_ngc_YYYYmmdd_HHMMSS/`
  - `summary.txt`（JOB DONE / PWSCF WALL / rc）
  - `*_nvidia_smi.csv`（1s 間隔）
  - `*.log`（実行コマンドと環境）
- zip: `bench-root/bench_qe_vs_ngc_YYYYmmdd_HHMMSS.zip`

---

## QE Test-suite (Official PASS/FAIL)
本Runbookの対象範囲（PW/PH/PP）の公式test-suiteを実行し、PASSを確認しています。さらにRunbook独自のGPU verifyでGPU動作証跡を取得します。  
再開用メモ: `runbooks/HANDOFF_QE_TESTSUITE.md`

### スコープ宣言
- 対象範囲（このRunbookが保証する領域）:
  - `pw.x` / `ph.x` / `q2r.x` / `matdyn.x` / `pp.x` / `projwfc.x` など PW/PH/PP 系
- 公式 test-suite の実行範囲:
  - 上記に対応するサブセット（例: `pw_*` / `ph_*` / `pp_*`）を実行して PASS/FAIL を確認
- 非対象（SKIP 扱い）:
  - `cp.x` を使う CPV 系など、Runbookスコープ外またはバイナリ未提供の系
  - 例: `cp.x missing` は FAIL 主因ではなく「スコープ外SKIP」として記録

### 結果の読み方
- `PASS`: 対象サブセットの比較が通過
- `FAIL`: 対象サブセットで差分・実行失敗が発生
- `SKIP`: スコープ外、または必要バイナリ欠如（理由を summary に明記）

### 実行例（NPROCS=1）
```bash
# 対象範囲の代表: PW サブセット
tools/sg-qe-gpu-src/sg-qe-run-test-suite \
  --qe-build /home/dl/.local/sg/qe-gpu-src/qe-7.5 \
  --subset pw \
  --nprocs 1
```

### 主な引数
- `--qe-src DIR`: QE source tree（`test-suite/Makefile` を含む）
- `--qe-build DIR`: QE build/prefix（`bin/pw.x` 等を含む）
- `--subset ...`: `pw|ph|pp|all`（`,` 区切り可）
- `--include-glob`: `pw_*` のような test-suite ディレクトリ指定
- `--bench-root DIR`: 出力先（既定: `/home/dl/bench/BENCH-QE-TESTSUITE-001`）
- `--nprocs N`: `make NPROCS=N ...` の N（既定: `1`）

### 成果物
- work: `bench-root/work/qe_testsuite_YYYYmmdd_HHMMSS/`
- logs: `bench-root/logs/qe_testsuite_YYYYmmdd_HHMMSS/`
  - `run-tests.log`（生ログ）
  - `summary.txt`（PASS/FAIL/SKIP件数・代表エラー）
  - `suite_results.tsv`（サブセット別集計）
  - `failures.txt`（失敗候補）
  - `command.txt`（実行条件）
- zip: `bench-root/qe_testsuite_YYYYmmdd_HHMMSS.zip`

### Runbook独自 GPU Verify（第2層）
- GPUビルド証跡: `readelf` / `ldd` でリンク確認
- 実行証跡: stdout の GPU 関連行（`GPU` timing 等）
- デバイス証跡: `nvidia-smi` csv（util/memory）

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

- PW subset proof: runbooks/QE_TESTSUITE_PW_PROOF.md
