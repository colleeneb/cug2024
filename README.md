# GAMESS input and runscripts for CUG2024

This contains:
- water.inp: water cluster input for the single-GPU/single-tile case
  To adjust for more devices, `ngroup` should be changed to equal the number of GPUs or tiles to run on.
- run_aurora.sh: runscript for Aurora for the single-GPU/single-tile case
  For more devices, the number of MPI ranks launched should be adjusted
- run_polaris.sh: runscript for Polaris for the single-GPU/single-tile case
  For more devices, the number of MPI ranks launched should be adjusted

