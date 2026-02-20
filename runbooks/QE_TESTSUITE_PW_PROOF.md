# QE test-suite proof (PW subset)

目的: Runbook配布前の sanity として、Quantum ESPRESSO 公式 test-suite の PW 系サブセットを実行し、
同梱の reference（Benchmark: git）と一致することを確認。

実行条件:
- QE_BUILD: /home/dl/.local/sg/qe-gpu-src/qe-7.5
- NPROCS: 1
- runner: tools/sg-qe-gpu-src/sg-qe-run-test-suite

結果（summaryへのリンク）:
- pw_atom : /home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_141944/summary.txt
- pw_dft  : /home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_142119/summary.txt
- pw_berry: /home/dl/bench/BENCH-QE-TESTSUITE-001/logs/qe_testsuite_20260220_142440/summary.txt

注意:
- 本Runbookは「GPU build の verify/bench」を主眼とし、test-suite 全体（cp/ph/pp などの全実行）を常に保証するものではない。
- ただし PW 系の代表サブセットは reference 一致を確認済み（上記 summary を参照）。
