# QE Testcase Shortlist (GPU Scaling Candidates)

## Selection Criteria
- Source: QE official `test-suite` / `PW/examples` inputs under local trees.
- Prefer high k-point load: `K_POINTS automatic` with large `kx*ky*kz` (kprod).
- Prefer PW-SCF/NSCF style workloads that map to `pw.x` and allow `-nk 4`.
- Prefer non-gamma-only cases (`kprod > 1`) so pool parallel (`-nk`) can help.
- Prefer moderate `nat` and available pseudopotentials (single-node A100x4で回しやすい)。

Scoring emphasis (used for `runbooks/QE_TESTCASE_CANDIDATES.tsv`):
- `kprod` (high priority), `code` (`pw`優先), `calculation=scf|nscf`, `occupations=smearing`,
- gamma-only penalty, too-large/missing pseudo penalty.

## Top Candidates (5-10)
1. `epw_metal/scf.in` (from test-suite)
- Why: `k=12x12x12 (kprod=1728)`, `nat=1`, `scf`, `smearing`; pool parallelが効きやすい。
- Expectation: `np=4, -nk 4` で明確な短縮が出やすい。

2. `epw_base/scf.in`
- Why: `k=6x6x6 (216)`, `nat=2`, `scf`, `smearing`; 軽すぎず重すぎない。
- Expectation: 比較的安定して `nk=4` 効果を観測しやすい。

3. `epw_super/scf.in`
- Why: `k=6x6x6 (216)`, `nat=3`, `scf`, `smearing`; `epw_*` 系の中で計算量が少し増える。
- Expectation: `np=1 -> 4` の傾向比較に向く。

4. `epw_soc/scf.in`
- Why: `k=6x6x6 (216)`, `nat=1`, `scf`, `smearing`; SOC系の前処理として使える。
- Expectation: k点並列効率と安定性のバランス確認に向く。

5. `pw_vdw/vdW-DF3-opt2.in`
- Why: `k=4x4x4 (64)`, `nat=4`, `scf`; FFT/汎関数コストが乗りやすい。
- Expectation: gamma-only回避で `-nk 4` の有効性を確認可能。

6. `pw_lda+U/lda+U+V_noncol_ortho.in`
- Why: `k=4x4x1 (16)`, `nat=2`, `scf`, `smearing`; U/V + noncollinear で負荷特性が変わる。
- Expectation: 単純金属系と異なるスケーリング挙動の比較に有効。

7. `pw_uspp/uspp-hyb-k.in`
- Why: `k=5x2x1 (10)`, `nat=2`, `scf`; hybrid寄りで1ケースとして有用。
- Expectation: `nk=4` 効果は中程度、計算重さ寄与の観察向け。

8. `pw_dipole/2dcutoff.in`
- Why: `k=3x3x1 (9)`, `nat=6`, `scf`, `smearing`; 2D系寄りの実運用に近い。
- Expectation: pool並列効果は限定的だが再現性検証向け。

## First Validation Done (native QE 7.5)
Target: `epw_metal/scf.in` portable copy
- `np=1, nk=1`: `PWSCF : 3.56s WALL`, `JOB DONE`
- `np=4, nk=4`: `PWSCF : 1.41s WALL`, `JOB DONE`
- Logs:
- `/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001/logs/epw_metal_scf_20260220_143444/summary_native.txt`

## Portableization and Benchmark Flow
Use `runbooks/QE_TESTCASE_RUN_TEMPLATE.md` for copy/portable steps and native+NGC commands.
- Core rule:
- `pseudo_dir='./pseudos/'`, `outdir='./tmp/'` に揃えてから実行。
- k点が多いケースは `np=1/-nk 1` と `np=4/-nk 4` をセット比較。

## Pseudopotential Notes
- Prefer reusing local QE pseudo caches:
- `<QE_SRC>/pseudo/` or `<QE_SRC>/test-suite/pp/`
- If missing, official URL used by QE test-suite:
- `https://pseudopotentials.quantum-espresso.org/upf_files/`
