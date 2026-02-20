# QE Update

目的:
- 配布後の更新手順を、ZIP運用（標準）とGit運用（任意）で整理する。

## 標準: ZIP運用
1. 配布ZIPを取得する。
2. 既存ディレクトリを退避する（例: `servergear-gpu-runbook.bak_YYYYmmdd_HHMMSS`）。
3. 新しいZIPを展開して置き換える。
4. 無引数入口で最小確認する。

```bash
cd /home/<user>/work/servergear-gpu-runbook
tools/sg-qe-gpu-src-u/sg-doctor-qe-gpu-src-u
tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc
```

## 任意: Git運用
- Git利用環境では `git pull` で更新してよい。
- 運用標準はZIPのため、Gitは任意機能として扱う。

## 版確認（どちらの運用でも共通）
```bash
cd /home/<user>/work/servergear-gpu-runbook
git rev-parse --short HEAD 2>/dev/null || echo "non-git zip deployment"
```

補足:
- NGC比較は optional（デフォルトOFF）。
- `sg-qe-bench-qe-vs-ngc` 無引数では native-only + auto-scale が既定。
