#!/bin/bash
#SBATCH -J fscBoot                     # A single job name for the array
#SBATCH -n 8                           # Number of cores requested
#SBATCH -N 1                           # Ensure that all cores are on one machine
#SBATCH -t 1200                        # Runtime in minutes
#SBATCH -p serial_requeue              # Partition to submit to
#SBATCH--mem-per-cpu=500               # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append             #
#SBATCH -o logs/fscBoot_%A_%a.out      # Standard out goes to this file
#SBATCH -e logs/fscBoot_%A_%a.err      # Standard err goes to this filehostname


## load modules **********
module load gcc/10.2.0-fasrc01 openmpi/4.1.0-fasrc01


## variables *************
bmodel=$1
bs=$2
replic=${SLURM_ARRAY_TASK_ID}
export bmodel=$bmodel
export bs=$bs
export replic=$replic

## copy fsc input files **
mkdir run$replic
cp ${bmodel}.bs.$bs* run$replic

# run fastsimcoal / unfolded sfs (dsfs)
cd run$replic
# ~/software/demographicModelling/fsc27_linux64/fsc2702 \
#     --cores 8 \
#     --numBatches 16 \
#     -t ${bmodel}.bs.$bs.tpl \
#     -e ${bmodel}.bs.$bs.est \
#     --multiSFS --dsfs \
#     -n 100000 \
#     --removeZeroSFS \
#     --minSFSCount 1 \
#     -L 40 -s 0 -M
~/software/demographicModelling/fsc27_linux64/fsc2702 \
    --cores 8 \
    --numBatches 16 \
    -t ${bmodel}.bs.$bs.tpl \
    -e ${bmodel}.bs.$bs.est \
    --multiSFS --dsfs \
    -n 100000 \
    --minSFSCount 1 \
    -L 40 -s 0 -M
cd ../
