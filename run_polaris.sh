#!/bin/sh

module swap nvhpc nvhpc/23.3
module load cray-libsci
module unload perftools-base
export CRAY_ACC_REUSE_MEM_LIMIT=0
export NVCOMPILER_ACC_MEM_MANAGE=0

echo Jobid: $PBS_JOBID
echo Running on host `hostname`
echo Running on nodes `cat $PBS_NODEFILE`

NNODES=`wc -l < $PBS_NODEFILE`
export RANKS_PER_NODE=2           # Number of MPI ranks per node
NRANKS=$(( NNODES * RANKS_PER_NODE ))

echo "NUM_OF_NODES=${NNODES}  TOTAL_NUM_RANKS=${NRANKS}  RANKS_PER_NODE=${RANKS_PER_NODE}"

export DDI_LOGICAL_NODE_SIZE=1

name=water
inp=${name}.inp
log=${name}.log
ulimit -s unlimited

export OMP_DISPLAY_ENV=T
export OMP_NUM_THREADS=8
export OMP_STACKSIZE=500M

export SCR=/tmp/
mpiexec -n ${NNODES} -ppn 1 cp ${inp} $SCR/JOB.$PBS_JOBID.F05
echo ${inp} JOB.$PBS_JOBID.F05

export JOB=JOB.$PBS_JOBID

export USERSCR=/tmp/
export GMSPATH=$PWD
export AUXDATA=$GMSPATH/auxdata/
source $GMSPATH/gms-files.bash
export OUTPUT=$USERSCR/${JOB}.F06

export FI_CXI_DEFAULT_CQ_SIZE=131072

mpiexec -n ${NRANKS} -ppn ${RANKS_PER_NODE} \
    --cpu-bind verbose,list:0-7:32-39:8-15:40-47:16-23:48-55:24-31:56-63 \
      ./set_gpu_affinity_logical.sh $GMSPATH/gamess.00.x &> $name.log
