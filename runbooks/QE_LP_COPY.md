# QE LP Copy (Draft)

## タイトル
Quantum ESPRESSO GPU Runbook（配布版）

## 誰向けか
- GPUサーバで QE 実行環境を再現可能に整えたい運用担当者
- install/verify/bench の手順を短時間で共有したいチーム

## 何ができるか
- QE 7.5 GPU build（ユーザー領域）を install / verify / remove で運用
- 無引数入口の安全動作（Usage/SAFE BLOCK）で初回利用を簡素化
- native-only を既定にしたベンチ実行（NGC比較は任意）
- 証跡（summary/log/zip）を残して結果共有

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
