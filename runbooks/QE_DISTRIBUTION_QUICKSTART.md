# QE Distribution Quick Start

目的:
- 配布ZIP展開後に、最短で install / verify / bench を実行する。

## 0) 展開
```bash
cd /home/<user>/work
unzip qe_runbook_*.zip
cd qe_runbook_*
```

## 1) install（QE 7.5 GPU build）
```bash
tools/sg-qe-gpu-src-u/sg-doctor-qe-gpu-src-u
tools/sg-qe-gpu-src-u/sg-install-qe-gpu-src-u
```

## 2) verify（short）
```bash
tools/sg-qe-gpu-src/sg-qe-verify-scf --mode short
```

## 3) bench（デフォルト: native-only）
```bash
tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc
```

補足:
- 無引数時の既定は native-only + auto-scale。
- NGC比較は optional。実行時のみ下記を指定する:
```bash
tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc --with-ngc --ngc-image nvcr.io/hpc/quantum_espresso:qe-7.3.1
```

## 無引数UX（入口）
- `sg-qe-verify-scf`: 無引数は Usage + SAFE BLOCK（依存前提で暴走しない）
- `sg-verify-qe-gpu-src-u`: 無引数は Usage + SAFE BLOCK
- `sg-qe-bench-qe-vs-ngc`: 無引数で開始可能（native-only）

## 主な成果物
- verify log: `~/.local/sg/qe-gpu-src/qe-7.5/.sg-logs/verify-scf_*.log`
- bench summary: `/home/<user>/bench/.../summary.txt`
- bench zip: `/home/<user>/bench/.../*.zip`
