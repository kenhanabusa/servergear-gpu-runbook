# SLURM Ship ToDo (SSOT)

## Checklist
- [ ] `/etc/slurm/slurm.conf` をバックアップした
- [ ] `/etc/slurm/job_submit.lua` を配置した（権限 `0644`）
- [ ] `slurm.conf` に `JobSubmitPlugins=lua` を設定した（既存値があれば競合解決）
- [ ] `scontrol reconfigure` を実行した（無停止反映）
- [ ] GPUジョブ（mem無指定）で `ReqTRES` の `mem` が自動付与されることを確認
- [ ] CPU-onlyジョブ（mem無指定）で `ReqTRES` の `mem` が自動付与されることを確認
- [ ] `nvidia-smi topo -m` 由来の CPU Affinity で `gres.conf` を生成/適用し、GPUごとの `Cores=` が一致することを確認
- [ ] 問題時の切り戻し（plugin無効化＋reconfigure）手順を確認

## Policy
- GPU job (gpus > 0):
  - `mem_per_gpu_mb = floor(515649 * 0.90 / 4) = 116021 MB`
  - `req_mem_mb = gpus * mem_per_gpu_mb`
- CPU-only job:
  - `mem_per_cpu_mb = floor(515649 * 0.85 / 64) = 6848 MB`
  - `req_mem_mb = cpus * mem_per_cpu_mb`
- 明示指定 (`--mem`, `--mem-per-cpu`, `--mem-per-gpu`, `TRES mem=`) がある場合は上書きしない。

- GRES CPU affinity:
  - `nvidia-smi topo -m` の `CPU Affinity` を `gres.conf` の `Cores=` に反映
  - 例(a100x4): `GPU0/1 -> 0-31`, `GPU2/3 -> 32-63`

## Backup / Apply
```bash
sudo cp -a /etc/slurm/slurm.conf /etc/slurm/slurm.conf.bak.$(date +%Y%m%d_%H%M%S)
sudo cp -a /etc/slurm/job_submit.lua /etc/slurm/job_submit.lua.bak.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
```

```bash
sudo install -m 0644 /home/dl/work/servergear-gpu-runbook/out/slurm_ship/job_submit.lua /etc/slurm/job_submit.lua
# slurm.conf に JobSubmitPlugins=lua を追記（既存設定がある場合は置換）
sudo sed -i 's/^JobSubmitPlugins=.*/JobSubmitPlugins=lua/' /etc/slurm/slurm.conf
if ! grep -q '^JobSubmitPlugins=' /etc/slurm/slurm.conf; then
  echo 'JobSubmitPlugins=lua' | sudo tee -a /etc/slurm/slurm.conf
fi
sudo scontrol reconfigure
```

## Verify (GPU / CPU)
```bash
# GPU: mem無指定
cat > /tmp/slurm_gpu_memcheck.sh <<'EOF'
#!/usr/bin/env bash
sleep 60
EOF
jid=$(sbatch --parsable --partition=gpu --gpus=1 /tmp/slurm_gpu_memcheck.sh)
scontrol show job "$jid" | rg -n 'ReqTRES|TRES|MinMemory|NumCPUs|Gres'
```

```bash
# CPU-only: mem無指定
cat > /tmp/slurm_cpu_memcheck.sh <<'EOF'
#!/usr/bin/env bash
sleep 60
EOF
jid=$(sbatch --parsable --partition=gpu --cpus-per-task=4 /tmp/slurm_cpu_memcheck.sh)
scontrol show job "$jid" | rg -n 'ReqTRES|TRES|MinMemory|NumCPUs|Gres'
```

## Rollback
```bash
# pluginを無効化してreconfigure
sudo sed -i '/^JobSubmitPlugins=/d' /etc/slurm/slurm.conf
sudo mv /etc/slurm/job_submit.lua /etc/slurm/job_submit.lua.disabled.$(date +%Y%m%d_%H%M%S)
sudo scontrol reconfigure
```

## Array Requeue Guidance
- 既存配列は原則止めない。
- 失敗タスクだけ再投入:
```bash
# 例: 失敗index 17,42 を再実行
sbatch --array=17,42 <same-array-script.sbatch>
```

## Status Update (FIX-004)
- 本番で有効化済み（FIX-004, 2026-02-28）。
- `job_submit.lua` は以下方針で運用中:
  - GPU (`--gpus=1`): `ReqTRES mem=116021M`
  - CPU-only (`--cpus-per-task=4`): `ReqTRES mem=27392M` (`MinMemoryCPU=6848M`)
- ログ表示も正規化済み:
  - `applied cpu_mem_per_cpu=6848M cpus=4 est_mem_node=27392M ...`

### Verification Example
```text
gpu_jid=6396
ReqTRES=cpu=1,mem=116021M,node=1,billing=1
MinMemoryNode=116021M

cpu_jid=6397
ReqTRES=cpu=4,mem=27392M,node=1,billing=4
MinMemoryCPU=6848M
```
