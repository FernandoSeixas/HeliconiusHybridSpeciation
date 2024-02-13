#!/bin/bash
#SBATCH --cpus-per-task=1
#SBATCH --cores-per-socket=1
#SBATCH -t 600                       # Runtime in minutes
#SBATCH -p unrestricted,shared       # Partition to submit to
#SBATCH --mem-per-cpu=2000           # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append           #
#SBATCH -o logs/BPP_%j.out           # Standard out goes to this file
#SBATCH -e logs/BPP_%j.err           # Standard err goes to this filehostname

pre=$1;
rep=$2;

~/software/bpp.v4.6.2/src/bpp --cfile 5.2.bpp/$pre.$rep/$pre.$rep.ctl;