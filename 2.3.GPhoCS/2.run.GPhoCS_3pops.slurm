#!/bin/bash
#SBATCH -n 1   # Number of cores requested
#SBATCH -N 1   # Ensure that all cores are on one machine
#SBATCH -t 5   # Runtime in minutes
#SBATCH -p serial_requeue,shared # Partition to submit to
#SBATCH --mem=4000 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o prepGPhocs_%j.out # Standard out goes to this file
#SBATCH -e prepGPhocs_%j.err # Standard err goes to this filehostname


# variables 
pop1=$1                   ; export pop1=$pop1
pop2=$2                   ; export pop2=$pop2
pop3=$3                   ; export pop3=$pop3
setloc=$4                 ; export setloc=$setloc
ctrfil=$5                 ; export ctrlfl=$ctrlfl
setdat=$6                 ; export setdat=$setdat
trio=$pop1"_"$pop2"_"$pop3; export trio=$trio


## run Gphocs ===================================
mkdir $trio
cd $trio

pop1list=`grep $pop1 ../snpset2.samples.list | xargs -n 1 sh -c ' printf "%s\t%s\t" $0 d' `
pop2list=`grep $pop2 ../snpset2.samples.list | xargs -n 1 sh -c ' printf "%s\t%s\t" $0 d' `
pop3list=`grep $pop3 ../snpset2.samples.list | xargs -n 1 sh -c ' printf "%s\t%s\t" $0 d' `
export pop1list=$pop1list
export pop2list=$pop2list
export pop3list=$pop3list

rm -r $setdat
mkdir $setdat
for i in `seq 1 3`; do
    mkdir $setdat/rep$i; 
    cd $setdat/rep$i;
    # seqs files
    head -n 1 /n/holyscratch01/mallet_lab/fseixas/gphocs.v2/$setloc/$setdat.seqs.txt > $setdat.seqs.txt
    egrep "Hmel|$pop1|$pop2|$pop3" /n/holyscratch01/mallet_lab/fseixas/gphocs.v2/$setloc/$setdat.seqs.txt >> $setdat.seqs.txt
    perl ~/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/upgphocs.pl $setdat.seqs.txt > tmp; mv tmp $setdat.seqs.txt
    # ctl file
    cp ~/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/$ctrfil .
    sed -i "s,pop1samples,$pop1list,g" $ctrfil
    sed -i "s,pop2samples,$pop2list,g" $ctrfil
    sed -i "s,pop3samples,$pop3list,g" $ctrfil
    sed -i "s,alignment,$setdat,g" $ctrfil
    # run
    sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/runGphocs.slurm $ctrfil
    cd ../../
done 
