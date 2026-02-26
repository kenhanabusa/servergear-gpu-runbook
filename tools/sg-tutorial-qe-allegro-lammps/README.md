# Tutorial T1: QE + Allegro + LAMMPS(+Allegro) を10分で理解

## 1. 何が動いているか（役割）
- QE: 量子計算（最小SCF）
- Allegro: 機械学習ポテンシャルの推論
- LAMMPS(+Allegro): Allegroポテンシャルで短いMDを回す

## 2. データの流れ（テキスト図）
`QE input -> QE log`  
`Model zip -> Allegro compile/infer -> infer log`  
`LAMMPS input + model.pth -> thermo/log.lammps`

## 3. 最短実行
```bash
# Proof runbookでinstall/verify済み前提
tools/sg-tutorial-qe-allegro-lammps/run/01_overview.sh
tools/sg-tutorial-qe-allegro-lammps/run/02_what_to_check.sh
```

## 4. どこを見ればよいか
- QE: `tools/sg-bundle-qe-allegro-lammps/out/logs/<ts>/qe_single.log`
- Allegro: `tools/sg-bundle-qe-allegro-lammps/out/logs/<ts>/allegro_infer.log`
- LAMMPS: `tools/sg-bundle-qe-allegro-lammps/out/logs/<ts>/lammps_short.log`
- KPI: `tools/sg-bundle-qe-allegro-lammps/out/kpi/e2e_metrics.csv`
- Proofpack: `tools/sg-bundle-qe-allegro-lammps/out/proofpack/*.zip`

## 5. 前提
- A100x4
- apptainer/mpirun/nvcc/nvc 利用可
- `/opt/sg/qa` 書き込み可
