#!/bin/bash
#SBATCH -n 1                                 # Number of cores requested
#SBATCH -N 1                                 # Ensure that all cores are on one machine
#SBATCH -t 7200                              # Runtime in minutes
#SBATCH -p shared                            # Partition to submit to
#SBATCH --mem-per-cpu=32000                  # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append                   #
#SBATCH -o bppResume_%j.out          # Standard out goes to this file
#SBATCH -e bppResume_%j.err          # Standard err goes to this filehostname


# input variables
sgroup=$1
slocus=$2
tmodel=$3
replNb=$4

cd ${sgroup}-${slocus}/${tmodel}/${replNb}/

# get last checkpoint file
checkp=`ls ${sgroup}*.chk | sort -V | tail -n 1`;
echo $checkp

# resume run
~/software/bpp.v4.6.2/src/bpp --resume $checkp
