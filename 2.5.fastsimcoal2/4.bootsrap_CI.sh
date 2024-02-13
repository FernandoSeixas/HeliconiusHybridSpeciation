#!/bin/bash
#SBATCH -J fsc                              # A single job name for the array
#SBATCH -n 1                                # Number of cores requested
#SBATCH -N 1                                # Ensure that all cores are on one machine
#SBATCH -t 600                              # Runtime in minutes
#SBATCH -p shared                           # Partition to submit to
#SBATCH--mem-per-cpu=500                    # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append                  #
#SBATCH -o logs/sfsBoot_%A_%a.out           # Standard out goes to this file
#SBATCH -e logs/sfsBoot_%A_%a.err           # Standard err goes to this filehostname


## Variables
prefix=$1; export prefix=$prefix
bmodel=$2; export bmodel=$bmodel


## Confidence intervals from bootstraping ******************************************************************************
mkdir 3.bootstrap
cd 3.bootstrap
# Get the sites
zgrep -v "^#" ../1.vcf/${prefix}.vcf.gz > ${prefix}.allSites
# Get the header
zgrep "^#" ../1.vcf/${prefix}.vcf.gz > header
# Get 100 files with 4338 sites each (number 101 removed due to only 90 sites)
nsites=`wc -l ${prefix}.allSites | awk '{print $1}'`
bsizes=$((nsites / 100))
split -l $bsizes ${prefix}.allSites ${prefix}.sites.
# remove last block if less than the number of sites of other files
ls ${prefix}.sites.?? | tail -n 1 | xargs -n 1 sh -c 'rm $0'
# move to blocks folder
mkdir blockSites
mv *.sites.* blockSites

## Generate 50 files each with randomly concatenated blocks and compute the SFS for each *******************************
for i in {1..50}; do
    echo $i
    # rm -r bs${i}
    sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/3.Demography/demographicModelling/bootstrap_prepsfs.slurm \
    $prefix \
    $bmodel \
    $i
done


## run the bootstrap replicates ****************************************************************************************
for bs in {2..50}; do
    # change to dir copy fsc input files
    cd bs$bs
    mkdir logs
    cp ../../${bmodel}/${bmodel}.tpl ./${bmodel}.bs.${bs}.tpl
    cp ../../${bmodel}/${bmodel}.est ./${bmodel}.bs.${bs}.est
    # Run fastsimcoal 100 times:
    sbatch --array=1-100%100 ~/code/heliconius_seixas/2.elevatus_pardalinus/3.Demography/demographicModelling/4.runfscBoot.slurm $bmodel $bs
    cd ..
done
#/ Find the best run for each of the bootstrap datasets 
for bs in {1..50}; do
    cd bs${bs}
    echo bs${bs}
    bash ~/code/heliconius_seixas/2.elevatus_pardalinus/3.Demography/demographicModelling/fsc-selectbestrun.sh
    cd ..
done
#/ Collect best estimates
head -n 1 bs1/bestrun/4pops_tree1_AMpSC_complex1.bs.1.bestlhoods > bootstrap.bestEstimates.txt
for bs in {1..50}; do
    tail -n 1 bs${bs}/bestrun/4pops_tree1_AMpSC_complex1.bs.${bs}.bestlhoods >> bootstrap.bestEstimates.txt
done
less bootstrap.bestEstimates.txt 



## If runs fail for some reason ****************************************************************************************
prefix="wgenome.dsites.pruned_1kb";  export prefix=$prefix;
bmodel="4pops_tree1_AMpSC_complex1"; export bmodel=$bmodel;
#/ Check progress
for bs in {1..50}; do
    echo $bs 
    printf "%s\t" bs${bs}
    for rep in  {1..100}; do
        file="bs${bs}/run${rep}/${bmodel}.bs.${bs}/${bmodel}.bs.${bs}.brent_lhoods"
        awk '{if ($1 == 0) print}' $file | wc -l
    done | sort | uniq -c 
done > progress.txt
#/ Re-launch failed runs
for bs in {1..50}; do
    for rep in  {1..100}; do
        file="bs${bs}/run${rep}/${bmodel}.bs.${bs}/${bmodel}.bs.${bs}.brent_lhoods"
        count=`awk '{if ($1 == 0) print}' $file | wc -l`
        if [ ${count} -lt 40 ]; then 
            printf "%s\t%s\n" ${bs} ${rep}
            sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/3.Demography/demographicModelling/4.runfscResume.slurm ${bmodel} ${bs} ${rep}
        fi
    done
done

bmodel="4pops_tree1_AMpSC_complex1"; export bmodel=$bmodel;
for bs in {1..50}; do
    printf "%s\t" bs.${bs};
    for repl in `seq 1 100`; do
        file="bs${bs}/run${repl}/${bmodel}.bs.${bs}/${bmodel}.bs.${bs}.brent_lhoods"
        awk '{if ($1 == 0) print}' $file | wc -l
    done | sort -n | uniq -c | egrep 40 
done