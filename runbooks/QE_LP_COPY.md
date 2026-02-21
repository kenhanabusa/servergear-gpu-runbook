# QE LP Copy (Draft)

## タイトル
Quantum ESPRESSO GPU Runbook（配布版）

## 誰向けか
- 企業R&D: GPUサーバで QE 実行環境を短期間で再現したいチーム
- 大学/研究室: 検証手順と証跡を残しながら導入したい利用者
- 運用/検収: install/verify/bench の確認フローを標準化したい担当者

## 何ができるか
- QE 7.5 GPU build（ユーザー領域）を install / verify / remove で運用
- 無引数入口の安全動作（Usage/SAFE BLOCK）で初回利用を簡素化
- native-only を既定にしたベンチ実行（NGC比較は任意）
- 証跡（summary/log/zip）を残して結果共有

## なぜ QE 7.5 固定版か
- 運用側の再現性を優先し、native は QE 7.5 を固定して検証しています。
- 比較対象としては NGC の QE 7.3.1 が使われるケースが多いため、公開ベンチはこの組み合わせを基準にしています。

## 前提
- Ubuntu系 Linux
- NVIDIA GPU / driver / CUDA が利用可能
- `git`, `zip`, `sha256sum`, `mpirun` など基本コマンドが利用可能

## できないこと（この配布の範囲外）
- 複数ユーザー共有インストールの標準サポート
- notesサーバ側のMkDocs反映や公開作業
- NGC比較の常時実行（必要時のみ有効化）

## 導入手順（最短）
```bash
cd /home/<user>/work
unzip qe_runbook_*.zip
cd qe_runbook_*
tools/sg-qe-gpu-src-u/sg-doctor-qe-gpu-src-u
tools/sg-qe-gpu-src-u/sg-install-qe-gpu-src-u
tools/sg-qe-gpu-src/sg-qe-verify-scf --mode short
tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc
```

## 最新ベンチ（公開基準: 2026-02-20）
Source: `epw_metal_vs_ngc_20260220_163805`

| Condition | Native QE 7.5 WALL | NGC QE 7.3.1 WALL | Native speedup vs NGC |
|---|---:|---:|---:|
| np1 / nk1 | 30.84s | 35.07s | 1.14x |
| np4 / nk4 | 9.92s | 11.53s | 1.16x |

注記:
- 当社検証環境の一例（A100 80GB PCIe x4 / Driver 580.105.08）での測定値です。
- 環境差により同一値を保証するものではありません。

## FAQ
Q. NGC比較は毎回必要ですか？  
A. 必須ではありません。既定は native-only です。必要時のみ `--with-ngc --ngc-image ...` を指定します。

Q. 無引数で失敗しませんか？  
A. 入口は `PASS/PASS(start)/SAFE BLOCK` の方針で、依存不足時は安全にブロックします。

Q. 共有運用はできますか？  
A. 可能ですが標準機能にはしていません。個別相談メニューで設計します。

## サポート導線
- 最小証跡（doctor/verify/bench/summary/zip）を添えて連絡してください。
- 詳細は `runbooks/QE_SUPPORT.md` を参照してください。

## notes URLひな形
- LP: `/lp/qe-gpu-runbook/`
- Benchmarks: `/benchmarks/qe-gpu-runbook/`
- Free DL: `/lp/qe-gpu-runbook-free-dl/`
