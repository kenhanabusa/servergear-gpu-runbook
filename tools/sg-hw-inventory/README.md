# sg-hw-inventory（STK-009）— Hardware BOM / Inventory（Lead Magnet）

Version: **v0.1.1**

sg-hw-inventory は、GPUサーバ出荷/検収/サポートで使える「ハードウェア台帳（BOM）」を **read-only** で一括収集し、  
**report.md / report.json / report.csv** を出力するツールです。

## ✅ 安全性（重要）
- 本ツールは **read-only**（破壊的変更なし）です。
- ただし、収集結果には **機微情報（シリアル/UUID/MAC等）** が含まれ得ます。
- 既定では識別子は **マスク** されます（末尾4桁等）。
- **フル出力は明示オプション時のみ**：
  - `--include-serial` または `--redact-serial=off`
- 社外共有前に必ず内容を確認してください（鍵/パスワード/個人情報等が含まれていないか）。

## インストール
```bash
sudo install -m 0755 tools/sg-hw-inventory/sg-hw-inventory /usr/local/sbin/sg-hw-inventory
```

## 使い方
```bash
# 既定：識別子マスクON
sg-hw-inventory --out ./hw-inventory-$(hostname)-$(date +%Y%m%d_%H%M%S)

# フル出力（⚠️共有前に必ず確認）
sudo sg-hw-inventory --include-serial --out ./hw-inventory-$(hostname)-$(date +%Y%m%d_%H%M%S) --overwrite
```

生成物：
- `report.md`（人間向け：1枚で要点）
- `report.json`（機械可読：集計用）
- `report.csv`（台帳貼り付け用：1行）

## 欠落ツールでも落ちない
- `dmidecode` / `nvidia-smi` / `ipmitool` 等が無くても **落ちません**。
- 取れない項目は `missing_tools` に記録します。

## サンプル
- `sample/report.md`（マスクON例）

## ライセンス
- `LICENSE`（MIT）
