# sg-bundle-qe-allegro-lammps

QE GPU build + Allegro + LAMMPS(+Allegro) を 1 本の Proof Runbook として実行するオーケストレータです。

## 目的
- install -> verify(E2E) -> remove を再現可能に実行
- 証跡（ログ/KPI/GPU使用/proofpack zip）を `out/` に集約
- 既存runbookを呼び出して重複実装を避ける

## 前提
- A100x4 環境
- `apptainer`, `mpirun`, `nvcc`, `nvc` が利用可能
- `/opt/sg/qa` は書き込み可能（ロック/隔離HOME/CACHE/TMP）
- `/opt/containers/sg-lammps-allegro.sif` が存在するか、`SG_LMPA_SIF_URL` を指定

## 安全設計
- デフォルト prefix: `/opt/sg/qa/prefix/bundles/qe-allegro-lammps/<YYYYMMDD>`
- QE は upstream runbook仕様上 `HOME/.local/sg` 配下に限定されるため、`HOME=/opt/sg/qa/home/...` を強制
- 同時実行防止: `/opt/sg/qa/locks/qa.lock` (`flock`)

## コマンド
```bash
# install
tools/sg-bundle-qe-allegro-lammps/sg-install-bundle-qe-allegro-lammps

# verify (QE最小SCF + Allegro推論 + LAMMPS短MD50step)
tools/sg-bundle-qe-allegro-lammps/sg-verify-bundle-qe-allegro-lammps

# remove
tools/sg-bundle-qe-allegro-lammps/sg-remove-bundle-qe-allegro-lammps

# doctor
tools/sg-bundle-qe-allegro-lammps/sg-doctor-bundle-qe-allegro-lammps
```

## 主要出力
- `out/logs/<ts>/` : step別ログ、wall time、nvidia-smi dmon/pmon
- `out/kpi/e2e_metrics.csv` : step別所要時間
- `out/kpi/latest_summary.md` : 最新結果サマリ
- `out/proofpack/proof_bundle_qe_allegro_lammps_<ts>.zip`
- `out/proofpack/proof_bundle_qe_allegro_lammps_<ts>.sha256`

## KPI
- qe_single / allegro_infer / lammps_short の wall sec
- `nvidia_smi_pre/post.txt`, `nvidia_dmon.log`, `nvidia_pmon.log`

## 注意
- `SG_PREFIX=/opt/sg/bundles/...` はこの環境で権限不足のため既定では使わず、`/opt/sg/qa/prefix/...` を使用
- QE verify は擬ポテンシャル `Si.pz-vbc.UPF` を実行時に取得（ネットワーク必要）
