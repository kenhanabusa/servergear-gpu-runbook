# Test Matrix - STK-010 v0.1.1

| Date (JST) | OS | Slurm | oneAPI | Intel MPI | PMI lib | ntasks | Result | Notes |
|---|---|---|---|---|---|---|---|---|
| 2026-02-06 | Ubuntu 24.04 | yes | intel-basekit+intel-hpckit | yes | libpmi2.so | 1/2/4 | OK | sbatch hello + himeno-mini |
| 2026-02-06 | Ubuntu 24.04 | no  | installed | yes | - | - | SKIP | Slurm missing |
