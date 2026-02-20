# QE Testcase Run Template (Native + NGC, Same Conditions)

## 1) Copy Input and Make Portable
```bash
# required vars
CASE_NAME=epw_metal_scf
SRC_IN=/home/dl/.cache/sg/qe-gpu-src-u/qe-src/test-suite/epw_metal/scf.in
SRC_PSEUDO_DIR=/home/dl/.cache/sg/qe-gpu-src-u/qe-src/pseudo
REQ_UPF="pb_s.UPF"

BENCH_ROOT=/home/dl/bench/BENCH-QE-TESTCASE-PILOT-001
TS=$(date +%Y%m%d_%H%M%S)
CASE_DIR=$BENCH_ROOT/work/${CASE_NAME}_${TS}
LOG_DIR=$BENCH_ROOT/logs/${CASE_NAME}_${TS}
mkdir -p "$CASE_DIR/pseudos" "$CASE_DIR/tmp" "$LOG_DIR"

cp "$SRC_IN" "$CASE_DIR/input.in"
for f in $REQ_UPF; do cp "$SRC_PSEUDO_DIR/$f" "$CASE_DIR/pseudos/"; done

# portable paths
sed -i "s#pseudo_dir\s*=\s*'[^']*'#pseudo_dir      = './pseudos/'#" "$CASE_DIR/input.in"
sed -i "s#outdir\s*=\s*'[^']*'#outdir          = './tmp/'#" "$CASE_DIR/input.in"
```

Bench-heavy variant example (target np1 ~30s+):
```bash
cp "$CASE_DIR/input.in" "$CASE_DIR/input_bench_heavy.in"
sed -i "s/^\\s*ecutwfc\\s*=.*/    ecutwfc         = 80/" "$CASE_DIR/input_bench_heavy.in"
sed -i "s/^12 12 12 0 0 0/30 30 30 0 0 0/" "$CASE_DIR/input_bench_heavy.in"
```

## 2) Same Conditions (Threads/Env)
```bash
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export FFTW_NUM_THREADS=1
export OMP_PROC_BIND=close
export OMP_PLACES=cores
```

## 3) Native QE 7.5
```bash
MPIRUN=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/comm_libs/12.9/hpcx/hpcx-2.22.1/ompi/bin/mpirun
PW=/home/dl/.local/sg/qe-gpu-src/qe-7.5/bin/pw.x
export NVCOMPILER_COMM_LIBS_HOME=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/comm_libs/12.9
export NVHPC_CUDA_HOME=/opt/nvidia/hpc_sdk/Linux_x86_64/25.7/cuda/12.9

cd "$CASE_DIR"
$MPIRUN -np 1 "$PW" -nk 1 -in input.in > "$LOG_DIR/native_np1_nk1.out" 2> "$LOG_DIR/native_np1_nk1.err"
$MPIRUN -np 4 "$PW" -nk 4 -in input.in > "$LOG_DIR/native_np4_nk4.out" 2> "$LOG_DIR/native_np4_nk4.err"
```

## 4) NGC QE 7.3.1 (Stable MCA)
Default stable profile:
- `--mca coll ^hcoll --mca pml ob1 --mca btl self,tcp --mca btl_tcp_if_include eth0 --mca oob_tcp_if_include eth0`

Notes:
- Start from the stable profile above (完走優先) and only then try faster profiles.
- `ob1+tcp` without `eth0` pinning can hang/fail on this host in `np=4` cases.

```bash
NGC_IMAGE=nvcr.io/hpc/quantum_espresso:qe-7.3.1
cd "$CASE_DIR"

docker run --rm --gpus all --ipc=host --network=host -w /work \
  -v "$CASE_DIR:/work" \
  -e OMP_NUM_THREADS=1 \
  -e OPENBLAS_NUM_THREADS=1 \
  -e MKL_NUM_THREADS=1 \
  -e FFTW_NUM_THREADS=1 \
  -e OMP_PROC_BIND=close \
  -e OMP_PLACES=cores \
  -e OMPI_MCA_coll=^hcoll \
  -e OMPI_MCA_pml=ob1 \
  -e OMPI_MCA_btl=self,tcp \
  -e OMPI_MCA_btl_tcp_if_include=eth0 \
  -e OMPI_MCA_oob_tcp_if_include=eth0 \
  "$NGC_IMAGE" \
  bash -lc 'mpirun -np 1 /usr/local/qe/bin/pw.x -nk 1 -in input.in' \
  > "$LOG_DIR/ngc_np1_nk1.out" 2> "$LOG_DIR/ngc_np1_nk1.err"

docker run --rm --gpus all --ipc=host --network=host -w /work \
  -v "$CASE_DIR:/work" \
  -e OMP_NUM_THREADS=1 \
  -e OPENBLAS_NUM_THREADS=1 \
  -e MKL_NUM_THREADS=1 \
  -e FFTW_NUM_THREADS=1 \
  -e OMP_PROC_BIND=close \
  -e OMP_PLACES=cores \
  -e OMPI_MCA_coll=^hcoll \
  -e OMPI_MCA_pml=ob1 \
  -e OMPI_MCA_btl=self,tcp \
  -e OMPI_MCA_btl_tcp_if_include=eth0 \
  -e OMPI_MCA_oob_tcp_if_include=eth0 \
  "$NGC_IMAGE" \
  bash -lc 'mpirun -np 4 /usr/local/qe/bin/pw.x -nk 4 -in input.in' \
  > "$LOG_DIR/ngc_np4_nk4.out" 2> "$LOG_DIR/ngc_np4_nk4.err"
```

## 5) Quick Summary
```bash
for f in native_np1_nk1 native_np4_nk4 ngc_np1_nk1 ngc_np4_nk4; do
  echo "== $f =="
  rg "PWSCF|JOB DONE" "$LOG_DIR/$f.out" | tail -n 2
done
```

## 6) Use Existing Bench Wrapper
If testcase is copied as portable `input.in` with local `pseudos/`, you can also run:
```bash
tools/sg-qe-gpu-src/sg-qe-bench-qe-vs-ngc \
  --bench-root "$BENCH_ROOT" \
  --input "$CASE_DIR/input.in" \
  --np1 1 --np4 4 \
  --native-qe-prefix /home/dl/.local/sg/qe-gpu-src/qe-7.5 \
  --ngc-image nvcr.io/hpc/quantum_espresso:qe-7.3.1 \
  --mca-profile ob1-tcp-eth0 --pin none
```
