# STK-016 sg-lammps-allegro (v0.1.0, container-based)

目的:
- 「LAMMPSをAllegroペアスタイルが使える状態」で提供し、LP流入（LAMMPS）を取りこぼさない。
- v0.1の最小検収は「入力が最後まで回る」。性能測定は v0.2。

方式（推奨）: Apptainer(SIF)
- 依存が重い LAMMPS+Allegro をコンテナで固定し、出荷品質（再現性・壊れにくさ）を優先。
- SIF は /opt/containers/sg-lammps-allegro.sif に配置（installがDLまたは既存パスを採用）。

コマンド（最短）
1) install（root）
   sudo tools/sg-lammps-allegro/sg-install-lammps-allegro --yes
2) sample取得（ユーザー）
   tools/sg-lammps-allegro/sg-fetch-sample-lammps
3) model取得（ユーザー）
   tools/sg-lammps-allegro/sg-fetch-model
4) verify（ユーザー / sudo不要）
   tools/sg-lammps-allegro/sg-verify-lammps-allegro
5) doctor（ユーザー）
   tools/sg-lammps-allegro/sg-lammps-allegro-doctor
6) remove（root）
   sudo tools/sg-lammps-allegro/sg-remove-lammps-allegro --yes

環境変数（必要時のみ）
- SIF 配布:
  - SG_LMPA_SIF_URL=...   : SIFをDLするURL（未指定なら「既にあるSIF」を期待）
  - SG_LMPA_SIF_PATH=...  : 既存SIFパス（指定があれば最優先）
- sample 配布:
  - SG_LMP_SAMPLE_URL=... : サンプルzip URL（未指定ならデフォルトURLを使う）
- model 配布:
  - MODEL_URL=...         : 既にcompiled済みの model.nequip.pth をURLで配布する場合
  - （未指定なら）STK-015で作った compiled を流用、または OAM zip を nequip-compile で作成（ホスト側 nequip-compile が必要）

ログ
- /var/log/sg-runbook が書けなければ ~/sg-runbook-log にフォールバック。
- verify の最後は必ず `PASS:` / `FAIL:` を表示（機械判定可能）

v0.1の意図
- 「迷わず回る」ことを最優先にし、LAMMPS+Allegroの配布（SIF URL）は別途運用で決められるようにしている。
