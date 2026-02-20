# QE Install Layout

目的:
- 配布ZIPを展開して、エンドユーザーが無引数入口を迷わず使える配置を示す。

## 標準レイアウト（単一ユーザー）
- リポジトリ: `/home/<user>/work/servergear-gpu-runbook`
- QE install prefix: `/home/<user>/.local/sg/qe-gpu-src/qe-7.5`
- 作業キャッシュ: `/home/<user>/.cache/sg/`
- ベンチ出力: `/home/<user>/bench/`

## 最短フロー（無引数入口）
```bash
cd /home/<user>/work/servergear-gpu-runbook
tools/sg-qe-gpu-src-u/sg-doctor-qe-gpu-src-u
tools/sg-qe-gpu-src-u/sg-install-qe-gpu-src-u
tools/sg-qe-gpu-src/sg-qe-verify-scf --mode short
tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc
```

補足:
- `sg-qe-bench-qe-vs-ngc` は既定で native-only（NGC比較は optional）。
- NGC比較を行う場合のみ `--with-ngc --ngc-image <image>` を付与する。

## 共有運用（複数ユーザー）
- 本Runbookの標準機能は単一ユーザー運用を前提とする。
- 共有インストール/権限設計が必要な場合は、別メニュー（個別相談）として扱う。
