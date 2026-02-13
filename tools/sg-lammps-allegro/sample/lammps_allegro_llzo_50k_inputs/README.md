# LAMMPS + Allegro input example (LLZO bulk 51,840 atoms)

このzipは「相談前に見せられる最小セット」です（機微情報なし）。

## 含まれるもの
- `in.bench1_throughput` : Allegro推論スループット測定用（warmup 2000 / measure 20000）
- `llzo_51840.data` : 51,840 atoms の初期構造

## モデルについて（同梱しません）
`in.bench1_throughput` では `model.nequip.pth` を参照しますが、
この環境では symlink で別パスを指しているため、zipには含めていません。
相談時に、モデル配布（または再学習/置き換え）方法を案内します。

## 注意（これは“物理MD”ではありません）
入力内で `fix HOLD ... setforce 0` により座標固定し、
毎ステップの推論コスト（スループット）を測定する目的です。
