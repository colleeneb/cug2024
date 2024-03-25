#!/bin/sh
module use /soft/modulefiles
module load oneapi/release/2023.12.15.001

echo Jobid: $PBS_JOBID
echo Running on host `hostname`
echo Running on nodes `cat $PBS_NODEFILE`

NNODES=`wc -l < $PBS_NODEFILE`
export RANKS_PER_NODE=4           # Number of MPI ranks per node
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

export ZES_ENABLE_SYSMAN=1
export FI_CXI_DEFAULT_CQ_SIZE=131072

export MPIR_CVAR_ENABLE_GPU=0

mpiexec -n ${NRANKS} -ppn ${RANKS_PER_NODE}  \
	--cpu-bind verbose,list:0-7:104-111:8-15:112-119:16-23:120-127:24-31:128-135:32-39:136-143:40-47:144-151:52-59:156-163:60-67:164-171:68-75:172-179:76-83:180-187:84-91:188-195:92-99:196-203 \
         ./gpu_tile_compact_logical.sh  $GMSPATH/gamess.00.x
