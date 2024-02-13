#!/bin/bash
#SBATCH -n 1                                 # Number of cores requested
#SBATCH -N 1                                 # Ensure that all cores are on one machine
#SBATCH -t 4320                              # Runtime in minutes
#SBATCH -p shared                            # Partition to submit to
#SBATCH --mem-per-cpu=32000                  # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append                   #
#SBATCH -o runBPP_%j.out                # Standard out goes to this file
#SBATCH -e runBPP_%j.err                # Standard err goes to this filehostname



#/ Variables
slocus=$1;
sgroup=$2;
tmodel=$3;
iA=$4;
iB=$5;
iC=$6;
rep=$7;


## Run BPP ****************************************************************************************************************
mkdir ${sgroup}-${slocus}/${tmodel}/${rep}
cd ${sgroup}-${slocus}/${tmodel}/${rep}
cp ../../${sgroup}.seqs.txt .


#/ Copy imap file
cp /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/msci/${sgroup}.imap.txt .

#/ Update control file
cp /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/msci/msci.${tmodel}.ctl .
sed -i "s,seqs,${sgroup}.seqs,g" msci.${tmodel}.ctl
sed -i "s,imap,${sgroup}.imap,g" msci.${tmodel}.ctl
sed -i "s,outp,${sgroup}.outp,g" msci.${tmodel}.ctl
sed -i "s,mcmc.txt,${sgroup}.mcmc.txt,g" msci.${tmodel}.ctl
#/ number of loci 
nloci=`ls ../../4.bppFormat/* | wc -l`
sed -i "s,numberLoci,$nloci,g" msci.${tmodel}.ctl
#/ number of individuals
sed -i "s,ipopA,$iA,g" msci.${tmodel}.ctl
sed -i "s,ipopB,$iB,g" msci.${tmodel}.ctl
sed -i "s,ipopC,$iC,g" msci.${tmodel}.ctl


#/ run bpp 
~/software/bpp.v4.6.2/src/bpp --cfile msci.${tmodel}.ctl




