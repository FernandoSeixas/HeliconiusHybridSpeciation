#!/bin/bash
#SBATCH -n 4    # Number of cores requested
#SBATCH -N 1    # Ensure that all cores are on one machine
#SBATCH -t 180 # Runtime in minutes
#SBATCH -p serial_requeue  # Partition to submit to
#SBATCH --mem=8000 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o simGPhocs_%j.out # Standard out goes to this file
#SBATCH -e simGPhocs_%j.err # Standard err goes to this filehostname


## RUN gPhocs ===============================================================
ctrl=$1
export OMP_NUM_THREADS=4

# run gphocs
/n/home12/fseixas/software/G-PhoCS/bin/G-PhoCS $ctrl -n 4

