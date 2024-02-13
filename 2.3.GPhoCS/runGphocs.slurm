#!/bin/bash
#SBATCH -n 16    # Number of cores requested
#SBATCH -N 1    # Ensure that all cores are on one machine
#SBATCH -t 1200 # Runtime in minutes
#SBATCH -p unrestricted,shared # Partition to submit to
#SBATCH --mem=8000 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o runGPhocs_%j.out # Standard out goes to this file
#SBATCH -e runGPhocs_%j.err # Standard err goes to this filehostname


## RUN gPhocs ===============================================================
export OMP_NUM_THREADS=16

ctrl=$1

# run gphocs
/n/home12/fseixas/software/G-PhoCS/bin/G-PhoCS $ctrl -n 16

# create Trace file
#module load G-PhoCS/1.2.3-fasrc01
#readTrace mcmc.log -b 1000 > trace.log


#head -n 1000000 mcmc.log > test.log
#readTrace test.log -b 1000 > trace.log


#head -n 1 mcmc.log > mcmc-sub.log
#tail -n+2 mcmc.log | awk 'NR % 1000 == 0' >> mcmc-sub.log
#head mcmc-sub.log

