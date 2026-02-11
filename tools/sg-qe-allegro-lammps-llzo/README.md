# STK-011 QE→Allegro→LAMMPS（LLZO）Runbook + Doctor (v0.1.0)

目的：LP流入（QE/LAMMPS/Allegro）に直結する「最小の一気通貫 Runbook」を、
**LLMで失敗対応しやすい設計**（step_id / エラー分類 / 差分パッチ）で提供する。

## 収録
- install/verify/remove（雛形）
- pipeline verify（雛形）
- sg-runbook-doctor（ログ→原因分類→修正案テンプレ出力）

## 重要（v0.1の方針）
- **verifyは安全側（重い計算は回さない）**
- ただし「失敗を分類できる」ことを優先し、典型エラーを再現できる
