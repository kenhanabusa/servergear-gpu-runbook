# HANDOFF: QE Official Test-suite Scope (PW/PH/PP)

## Goal
- Runbookの価値を維持したまま「公式 test-suite 実行済み」を再現可能にする。
- ただし主張は「全件PASS」ではなく、Runbook対象範囲（PW/PH/PP）のサブセットPASS確認。
- CPV (`cp.x`) など対象外は FAIL ではなく SKIP として明示する。

## Scope
- 対象（保証対象）:
  - `pw.x`, `ph.x`, `q2r.x`, `matdyn.x`, `pp.x`, `projwfc.x` など
  - test-suite サブセット: `pw_*`, `ph_*`, `pp_*`
- 非対象（SKIP）:
  - CPV (`cp.x`) 系など、Runbookスコープ外またはバイナリ未提供

## Script
- `tools/sg-qe-gpu-src/sg-qe-run-test-suite`
- 主要機能:
  - `--subset all|pw|ph|pp|...`
  - `--include-glob 'pw_*'`
  - 必要バイナリ不足を `SKIP` で集計（理由記録）
  - `summary.txt` に `PASS/FAIL/SKIP` 件数と代表エラーを出力

## Result Interpretation
- `PASS`: 対象サブセットが比較通過
- `FAIL`: 対象サブセットで差分/実行エラー
- `SKIP`: スコープ外、または必要バイナリ不足（例: `cp.x missing`）

## Baseline Full Run (NPROCS=1, all)
- command:
- `tools/sg-qe-gpu-src/sg-qe-run-test-suite --qe-build /home/dl/.local/sg/qe-gpu-src/qe-7.5 --nprocs 1`
- summary:
- `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_131000/summary.txt`
- zip:
- `/home/dl/bench/BENCH-QE-TESTSUITE-001/qe_testsuite_20260220_131000.zip`
- interpretation:
- `cp.x` 不在で CP サブセットが失敗するため、all はマーケ主張の根拠に使わない。

## Scope-Pass Spot Checks (NPROCS=1)
- `pw`:
- `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_130424/summary.txt`
- result: `PASS_COUNT=6`, `FAIL_COUNT=0`, `STATUS=PASS`
- `pw_dft`:
- `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_130447/summary.txt`
- result: `PASS_COUNT=11`, `FAIL_COUNT=0`, `STATUS=PASS`
- `pw_berry`:
- `/home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_130511/summary.txt`
- result: `PASS_COUNT=3`, `FAIL_COUNT=0`, `STATUS=PASS`

## Re-run Commands
```bash
# 推奨: スコープ内 PW のみ
tools/sg-qe-gpu-src/sg-qe-run-test-suite \
  --qe-build /home/dl/.local/sg/qe-gpu-src/qe-7.5 \
  --subset pw \
  --nprocs 1

# PH のみ
tools/sg-qe-gpu-src/sg-qe-run-test-suite \
  --qe-build /home/dl/.local/sg/qe-gpu-src/qe-7.5 \
  --subset ph \
  --nprocs 1

# PP のみ
tools/sg-qe-gpu-src/sg-qe-run-test-suite \
  --qe-build /home/dl/.local/sg/qe-gpu-src/qe-7.5 \
  --subset pp \
  --nprocs 1

# カスタム（pw_* ディレクトリ）
tools/sg-qe-gpu-src/sg-qe-run-test-suite \
  --qe-build /home/dl/.local/sg/qe-gpu-src/qe-7.5 \
  --include-glob 'pw_*' \
  --nprocs 1
```

## Deliverables
- `summary.txt`: PASS/FAIL/SKIP と代表エラー
- `suite_results.tsv`: サブセット別結果
- `run-tests.log`: 生ログ
- `failures.txt`: 失敗候補行
- `command.txt`: 実行条件
- `qe_testsuite_*.zip`: work/logs のアーカイブ
