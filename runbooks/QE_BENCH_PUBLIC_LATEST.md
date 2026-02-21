# QE Bench Public Latest

公開用の最新値（ベンチ基準日: 2026-02-20）です。

## Summary
- native/NGC比較の最新ソース: `epw_metal_vs_ngc_20260220_163805`
- verify(single/multi) は `BENCH-QE-001` の既存最新値（2026-02-14）を継続利用

| Metric | Native QE 7.5 | NGC QE 7.3.1 | Note |
|---|---:|---:|---|
| bench np1 / nk1 WALL | 30.84s | 35.07s | native speedup vs NGC: 1.14x |
| bench np4 / nk4 WALL | 9.92s | 11.53s | native speedup vs NGC: 1.16x |
| verify single WALL | 0.68s | - | source date: 2026-02-14 |
| verify multi np1 WALL | 20.17s | - | source date: 2026-02-14 |
| verify multi np4 WALL | 6.97s | - | source date: 2026-02-14 |
| verify speedup (np1->np4) | 2.89x | - | efficiency: 72.3% |

## Evidence ZIP
- `BENCH-QE-001_LATEST_evidence.zip`
- `BENCH-QE-001_LATEST_evidence.zip.sha256`

## Sources
- `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260220_163805/summary.txt`
- `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_vs_ngc_20260220_163805/summary_all.txt`
- `/home/dl/bench/BENCH-QE-001/20260214_164232/logs/native_single_wall.log`
- `/home/dl/bench/BENCH-QE-001/20260214_164232/logs/native_multi_wall.log`
