# QE Support

目的:
- サポート依頼時に必要な最小証跡を揃え、切り分け時間を短縮する。

## 最小証跡（必須）
1. doctor:
   - `tools/sg-qe-gpu-src-u/sg-doctor-qe-gpu-src-u`
   - 出力ログ: `~/.cache/sg/logs/sg-qe-gpu-src-u/doctor.jsonl`
2. verify:
   - `tools/sg-qe-gpu-src/sg-qe-verify-scf --mode short`
   - 出力ログ: `<qe-prefix>/.sg-logs/verify-scf_*.log`
3. bench:
   - `tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc`
   - 出力ログ: `summary.txt`, `summary_all.txt`（存在する場合）
4. zip:
   - ベンチ成果物ZIP（`bench-root/*.zip`）

## 「遅い」報告で必須の追加情報
- 実行コマンド全文（引数付き）
- `summary.txt` の該当行（`JOB DONE` / `PWSCF ... WALL` / `rc`）
- GPU枚数、`np`、`-nk`、入力ファイル名
- 実行時刻（開始/終了）とホスト名

## NGC比較について
- NGCは optional（デフォルトOFF）。
- 未指定または利用不可時は `summary` に `NGC: SKIP (image not provided / docker not available)` が記録される。
- サポート時は native結果を必須とし、NGC結果は任意提出でよい。
