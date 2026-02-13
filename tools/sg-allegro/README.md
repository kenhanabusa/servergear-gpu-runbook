# STK-015 sg-allegro (v0.1.0 template)

目的:
- Allegro環境（Python/torch/nequip-allegro）で詰まる層向けに、install/verify/remove を出荷品質化。
- v0.1の最小検収は「import が通る」「（モデルがある場合）推論が通る」。

使い方（テンプレ）:
- install: sudo ./sg-install-allegro --yes
- verify:  ./sg-verify-allegro
- doctor:  ./sg-allegro-doctor
- remove:  sudo ./sg-remove-allegro --yes

ログ:
- /var/log/sg-runbook が書けなければ ~/sg-runbook-log にフォールバックします。

---

## Verification model (default)

This runbook uses a **public foundation model** as the default verification model:

- Model: `Allegro-OAM-L-0.1.nequip.zip`
- Source (DOI): `10.5281/zenodo.16980200`
- License: **CC BY 4.0** (Creative Commons Attribution 4.0 International)

### Attribution (example)
If you share results externally, please include attribution similar to:
> NequIP & Allegro Foundation Potentials (Allegro-OAM-L-0.1), Kavanagh, Seán R.; MIR Group @ Harvard, Zenodo, DOI: 10.5281/zenodo.16980200, CC BY 4.0.

### Notes
- The model is downloaded by `sg-fetch-model-allegro` from a public repository.
- For redistribution of the model file itself, ensure you comply with the CC BY 4.0 terms (attribution required).
