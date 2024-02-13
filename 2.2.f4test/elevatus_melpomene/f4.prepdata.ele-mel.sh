#!/bin/bash
#SBATCH -n 16                                  # Number of cores requested
#SBATCH -N 1                                   # Ensure that all cores are on one machine
#SBATCH -t 180                                 # Runtime in minutes
#SBATCH -p serial_requeue,shared               # Partition to submit to
#SBATCH --mem-per-cpu=1000                     # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o logs/f4test_%j.out                  # Standard out goes to this file
#SBATCH -e logs/f4test_%j.err                  # Standard err goes to this filehostname


#/ arguments
pgroup="ele_mel"; export pgroup=$pgroup
pexpan="simple";  export pexpan=$pexpan
mafmin=0.02     ; export mafmin=$mafmin
maxmis=0.2      ; export maxmis=$maxmis

#/ create directories
mkdir ${pgroup}
mkdir ${pgroup}/${pexpan}
cd ${pgroup}/${pexpan}
mkdir 1.byScaff

#/ Select individuals, filter sites with no missing data and biallelic
cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaffolds.txt | \
    egrep -v Hmel200 | xargs -n 1 -P 8 sh -c '
    ~/software/plink_1.9/plink \
    --threads 2 \
    --vcf /n/holyscratch01/mallet_lab/fseixas/2.elepar/2.3.merge/$0.hmelv25.simplify.vcf.gz \
    --keep ~/code/heliconius_seixas/2.elevatus_pardalinus/5.GlobalStats/f4-test/${pgroup}.${pexpan}.txt \
    --double-id --allow-extra-chr \
    --geno ${maxmis} \
    --maf ${mafmin} \
    --recode vcf-iid \
    --out 1.byScaff/$0.hmelv25.geno${maxmis}.maf${mafmin}
'

#/ Concatenate vcf files
ls 1.byScaff/Hmel*.hmelv25.geno${maxmis}.maf${mafmin}.vcf > vcflist.txt
bcftools concat --threads 16 --file-list vcflist.txt -O z -o autosomes.hmelv25.geno${maxmis}.maf${mafmin}.vcf.gz

#/ recode to plink format
~/software/plink_1.9/plink \
    --threads 16 \
    --double-id --allow-extra-chr \
    --vcf autosomes.hmelv25.geno${maxmis}.maf${mafmin}.vcf.gz \
    --make-bed \
    --out autosomes.hmelv25.geno${maxmis}.maf${mafmin}

#/ sample every 1-kb
~/software/plink_1.9/plink \
    --threads 16 \
    --double-id --allow-extra-chr \
    --vcf autosomes.hmelv25.geno${maxmis}.maf${mafmin}.vcf.gz \
    --bp-space 1000 \
    --make-bed \
    --out autosomes.hmelv25.geno${maxmis}.maf${mafmin}.prune01kb

cp /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/5.GlobalStats/f4-test/${pgroup}.${pexpan}.popmap.txt autosomes.hmelv25.geno${maxmis}.maf${mafmin}.fam
cp /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/5.GlobalStats/f4-test/${pgroup}.${pexpan}.popmap.txt autosomes.hmelv25.geno${maxmis}.maf${mafmin}.prune01kb.fam