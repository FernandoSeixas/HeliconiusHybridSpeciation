#!/bin/bash
#SBATCH -n 1                      # Number of cores requested
#SBATCH -N 1                      # Ensure that all cores are on one machine
#SBATCH -t 5                      # Runtime in minutes
#SBATCH -p serial_requeue         # Partition to submit to
#SBATCH --mem-per-cpu 4000        # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append        #
#SBATCH -o easySFS_%j.out         # Standard out goes to this file
#SBATCH -e easySFS_%j.err         # Standard err goes to this filehostname

# Arguments
prefix=$1
bmodel=$2
i=$3

# load modules
module load python/3.10.12-fasrc01
mamba activate easysfs
# Make a new folder for each bootstrapping iteration
mkdir bs${i}
cd bs${i}
# Add the header to our new bootstrapped vcf file
cat ../header > ${prefix}.bs.${i}.vcf
# Suffle SNPs in each block, randomly choose one and add to block
for r in {1..100}; do cat `shuf -n1 -e ../blockSites/${prefix}.sites.*` >> ${prefix}.bs.${i}.vcf; done
# Compress the vcf file again
~/software/samtools-1.17/htslib-1.17/bgzip ${prefix}.bs.${i}.vcf
# Make an SFS from the new bootstrapped file
~/software/demographicModelling/easySFS/easySFS.py \
    -f \
    -a \
    --unfolded \
    -i ${prefix}.bs.${i}.vcf.gz \
    -p ../../support/pruned.pops_file.txt \
    --proj 8,40,40,20 \
    -o ${prefix}.bs.${i}.multiSFS
# Copy the observed SFS file into this folder renaming it to match the .tpl prefix
cp ${prefix}.bs.${i}.multiSFS/fastsimcoal2/wgenome_MSFS.obs ${bmodel}.bs.${i}_DSFS.obs
# Say that it is finished with iteration ${i}
echo bs${i}" ready"
cd ..

mamba deactivate 
