# STK-016 Bundle (Policy 2: ship-with-server)

This folder describes the on-server bundle layout:

/opt/sg/bundles/lammps-allegro/
  sg-lammps-allegro.sif
  SIF_SHA256.txt
  SOURCE_MANIFEST.json
  THIRD_PARTY_NOTICES/
    NOTICE.md
    LICENSES/   (optional: license texts you include)
  BUILD_RECIPES/
    apptainer.def (optional)
    build.sh      (optional)
  sample/
    in.bench1_throughput
    llzo_51840.data
  models/
    Allegro-OAM-L-0.1.nequip.zip        (optional)
    compiled_allegro.nequip.pth         (optional)
    model.nequip.pth                    (optional; runtime model for LAMMPS)
