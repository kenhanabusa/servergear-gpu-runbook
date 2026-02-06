# STK-010: Intel oneAPI + Intel MPI + Slurm Runbook（Ubuntu 24.04 v0.1.1）

## 対象
- OS：**Ubuntu 24.04 固定**
- MPI：**Intel MPI（oneAPI付属）**（OpenMPIではない）
- verifyの核：**Slurm上で MPIジョブ（sbatch）を回す**

## 成果物
- `sg-install-oneapi-mpi`
- `sg-verify-oneapi-mpi`
- `sg-remove-oneapi-mpi`

ログ：`/var/log/sg-runbook/`（stdout/stderr/スコアも含む）

---

## install
```bash
sudo ./sg-install-oneapi-mpi --yes
```

---

## verify（推奨：sudoなし）
sudoでverifyするとジョブ所有者がrootになり、一般ユーザーで `scancel` できず運用が面倒になります。

### 事前に一度だけ（推奨権限設定）
```bash
sudo groupadd -f sg-runbook
sudo usermod -aG sg-runbook <YOUR_USER>

sudo mkdir -p /var/log/sg-runbook
sudo chgrp sg-runbook /var/log/sg-runbook
sudo chmod 2775 /var/log/sg-runbook

sudo mkdir -p /opt/sg-demos/oneapi-mpi
sudo chgrp -R sg-runbook /opt/sg-demos/oneapi-mpi
sudo chmod 2775 /opt/sg-demos/oneapi-mpi
```
設定後はログアウト→ログイン（または `newgrp sg-runbook`）してから verify。

### 実行
```bash
./sg-verify-oneapi-mpi --keep-workdir
```

### よくある SKIP と対処
#### 1) libpmi2 が無い
`SKIP: Could not find Slurm PMI library (libpmi2.so/libpmi.so)` の場合：
```bash
sudo apt-get update -y
sudo apt-get install -y libpmi2-0t64
```

#### 2) ノードが DOWN/DRAIN（PENDINGが続く）
```bash
sinfo -o "%P %a %l %D %T %N"
sudo scontrol update NodeName=$(hostname -s) State=RESUME
```

---

## remove
```bash
sudo ./sg-remove-oneapi-mpi --yes
```

---

## 相談トリガー（有料サポートになりやすい）
- 複数ノード、PMIx、RDMA/OFI、ピニング最適化
- Slurm partition/優先度/予約/アカウント設計
- Intel MPI がハングする、性能が出ない（NUMA/ピニング/通信設定）
