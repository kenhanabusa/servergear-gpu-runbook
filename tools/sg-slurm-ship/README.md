# sg-slurm-ship

a100x4 出荷向けの Slurm JobSubmit(Lua) Runbook です。  
メモリ無指定ジョブに対して、以下を自動付与します。

- GPU job: `mem_per_gpu = floor(RealMemory * (1 - GPU_MARGIN) / GPU数)`
- CPU-only: `mem_per_cpu = floor(RealMemory * (1 - CPU_MARGIN) / CPUTot)`

加えて `nvidia-smi topo -m` の CPU Affinity から `gres.conf` を生成し、
GPUごとの近接CPU core範囲を `Cores=` に反映できます。

既定値:
- `GPU_MARGIN=0.10`
- `CPU_MARGIN=0.15`

## Quick Start
```bash
cd /home/dl/work/servergear-gpu-runbook

# 1) 事前確認（ノード値と計算値を表示）
tools/sg-slurm-ship/sg-precheck-slurm-ship

# 2) gres.confを生成（CPU Affinity -> Cores）
# 生成先: tools/sg-slurm-ship/out/gres.conf.generated
tools/sg-slurm-ship/sg-generate-gres-conf

# 3) 適用（/etcバックアップ → job_submit.lua配置 → 必要ならgres.conf適用 → reconfigure）
# APPLY_GRES_CONF=1 で /etc/slurm/gres.conf も更新
GPU_MARGIN=0.10 CPU_MARGIN=0.15 APPLY_GRES_CONF=1 \
  tools/sg-slurm-ship/sg-apply-jobsubmit-mem

# 4) 検証（gres.conf整合 + GPU/CPUテストジョブのReqTRES mem）
GPU_MARGIN=0.10 CPU_MARGIN=0.15 \
  tools/sg-slurm-ship/sg-verify-jobsubmit-mem

# 5) 切り戻し（必要時のみ）
tools/sg-slurm-ship/sg-rollback-jobsubmit-mem
```

## Files
- `sg-precheck-slurm-ship`
  - `scontrol show node -o` から `RealMemory/CPUTot/GPU数` を取得
  - 期待 `mem_per_gpu_mb` / `mem_per_cpu_mb` を算出
- `sg-generate-gres-conf`
  - `nvidia-smi topo -m` の `CPU Affinity` を抽出
  - `out/gres.conf.generated` を生成
- `sg-apply-jobsubmit-mem`
  - `templates/job_submit.lua.in` から実体Luaを生成
  - `/etc/slurm/slurm.conf` と `/etc/slurm/job_submit.lua` をバックアップ
  - `APPLY_GRES_CONF=1` の場合は `/etc/slurm/gres.conf` もバックアップ/配置
  - `JobSubmitPlugins=lua` を設定し `scontrol reconfigure`
- `sg-verify-jobsubmit-mem`
  - 生成した期待 `gres.conf` と実際の `/etc/slurm/gres.conf` を照合
  - repo内にテストジョブを生成して `sbatch`
  - `ReqTRES` / `MinMemory` を抽出し期待値と比較
- `sg-rollback-jobsubmit-mem`
  - 直近バックアップを `/etc/slurm` に復元して `reconfigure`
- `templates/job_submit.lua.in`
  - 生成テンプレート

## Environment Variables
- 共通
  - `GPU_MARGIN` (default `0.10`)
  - `CPU_MARGIN` (default `0.15`)
  - `NODE_NAME` (default: 先頭ノード)
- gres generate
  - `GRES_GPU_TYPE` (default `A100-80GB`)
  - `GRES_OUTPUT` (default `tools/sg-slurm-ship/out/gres.conf.generated`)
- apply
  - `APPLY_CHANGES=0` で dry-run（生成のみ）
  - `APPLY_GRES_CONF=1` で `/etc/slurm/gres.conf` も適用
  - `SLURM_CONF_PATH` / `JOB_SUBMIT_PATH` / `GRES_CONF_PATH` でパス上書き
- verify
  - `PARTITION` (default `gpu`)
  - `GPU_COUNT` (default `1`)
  - `CPU_PER_TASK` (default `4`)
  - `TOTAL_MEM_MB` / `TOTAL_CPUS` / `TOTAL_GPUS` で期待値計算元を明示可能
  - `GRES_CONF_PATH` / `GRES_GPU_TYPE`
- rollback
  - `RESTORE_TS=<timestamp>` で特定世代を復元

## Notes
- 明示メモリ指定 (`--mem`, `--mem-per-cpu`, `--mem-per-gpu`, `TRES mem=`) がある場合は上書きしません。
- apply/rollback は `/etc` 更新のため `sudo` 権限が必要です。
- `scontrol reconfigure` で無停止反映します（原則サービス再起動不要）。
- 生成物・検証ログは `tools/sg-slurm-ship/out/` に保存されます。
