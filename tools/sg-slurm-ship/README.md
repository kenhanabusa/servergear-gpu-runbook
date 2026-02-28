# sg-slurm-ship

a100x4 出荷向け Slurm 設定 Runbook です。  
`job_submit.lua` による mem auto（GPU10% / CPU15%）と、`gres.conf` の CPU Affinity をまとめて適用します。

## Quick Start (3入口)
```bash
cd /home/dl/work/servergear-gpu-runbook

# 1) install: precheck + apply（既定で APPLY_GRES_CONF=1）
tools/sg-slurm-ship/sg-install

# 2) verify: ReqTRES/MinMemory と gres整合を検証
tools/sg-slurm-ship/sg-verify

# 3) uninstall: rollback
tools/sg-slurm-ship/sg-uninstall
```

- install/uninstall は `/etc/slurm/*` を更新するため `sudo` が必要です。
- 反映は `scontrol reconfigure` で無停止です（原則 service restart 不要）。

## Detailed Commands
- `sg-precheck-slurm-ship`
- `sg-generate-gres-conf`
- `sg-apply-jobsubmit-mem`
- `sg-verify-jobsubmit-mem`
- `sg-rollback-jobsubmit-mem`

## Environment Variables
- 共通: `GPU_MARGIN` (default `0.10`), `CPU_MARGIN` (default `0.15`), `NODE_NAME`
- install/apply: `APPLY_GRES_CONF=1`（default）, `APPLY_CHANGES=0`（dry-run）
- verify: `PARTITION`, `GPU_COUNT`, `CPU_PER_TASK`
- rollback: `RESTORE_TS`

## Notes
- 明示メモリ指定 (`--mem`, `--mem-per-cpu`, `--mem-per-gpu`, `TRES mem=`) がある場合は上書きしません。
- 生成物・検証ログは `tools/sg-slurm-ship/out/` に保存されます。
