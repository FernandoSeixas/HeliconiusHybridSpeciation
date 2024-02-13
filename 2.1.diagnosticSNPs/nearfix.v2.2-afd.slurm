#!/bin/bash
#SBATCH -n 4                            # Number of cores requested
#SBATCH -N 1                            # Ensure that all cores are on one machine
#SBATCH -t 5                            # Runtime in minutes
#SBATCH -p serial_requeue               # Partition to submit to
#SBATCH --mem-per-cpu 2000              # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o nearfix_%j.out               # Standard out goes to this file
#SBATCH -e nearfix_%j.err               # Standard err goes to this filehostname


chrom=$1                                    ; echo $chrom
pair=$2                                     ; echo $pair
bspace=$3                                   ; echo $bspace
afd=$4; afdcode=`echo $afd | sed 's,\.,,g' `; echo $afdcode


popName1="melspp"; export popName1=$popName1
popName2="elesym"; export popName2=$popName2

melPop=`grep mel $pair.inds | sed -z 's/\n/,/g;s/,$/\n/'`; export melPop=$melPop
elePop=`grep ele $pair.inds | sed -z 's/\n/,/g;s/,$/\n/'`; export elePop=$elePop
grep mel $pair.inds | wc -l 
grep ele $pair.inds | wc -l 


## Get variable sites with almost no missing data in the dataset ************
~/software/plink_1.9/plink \
    --allow-extra-chr \
    --vcf /n/holyscratch01/mallet_lab/fseixas/2.elepar/2.3.merge/${chrom}.hmelv25.simplify.vcf.gz \
    --keep ${pair}.list \
    --geno 0.10 \
    --maf 0.25 \
    --recode vcf-iid \
    --out 1.varSites/${chrom}.varsites.maf025



## Convert to geno format ***************************************************
#/ load modules
module load python/3.10.12-fasrc01
# convert
python /n/home12/fseixas/software/popgen/genomics_general/VCF_processing/parseVCF.py \
    -i 1.varSites/${chrom}.varsites.maf025.vcf \
    --skipIndels |
    ~/software/samtools-1.17/htslib-1.17/bgzip > 2.genofrtm/${chrom}.hmelv25.geno.gz


## Select sites with allele frequency difference between ele/par >= ${afd} 
#/ change the number of popCalls/pop according to the selected populations!
python ~/software/genomics_general/filterGenotypes.py \
    --threads 4 \
    --keepAllSamples \
    --infile 2.genofrtm/${chrom}.hmelv25.geno.gz \
    --outfile 3.afd_nfix/${chrom}.afd_${afdcode}_bp${bspace}.geno \
    --nearlyFixedDiff ${afd} \
    --thinDist ${bspace} \
    --minPopCalls 20 20 \
    -p $popName1 $melPop \
    -p $popName2 $elePop
egrep -v "N/N" 3.afd_nfix/${chrom}.afd_${afdcode}_bp${bspace}.geno > 3.afd_nfix/${chrom}.afd_${afdcode}_bp${bspace}.nomiss.geno
wc -l 3.afd_nfix/${chrom}.afd_${afdcode}_bp${bspace}.nomiss.geno

## Reconvert to vcf and "binary"
fasref="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/Heliconius_melpomene_melpomene_Hmel2.5.scaffolds.fa"
export fasref=$fasref
python ~/software/genomics_general/VCF_processing/genoToVCF.py \
    -f phased \
    --genoFile 3.afd_nfix/${chrom}.afd_${afdcode}_bp${bspace}.nomiss.geno \
    --outFile  3.afd_nfix/${chrom}.afd_${afdcode}_bp${bspace}.nomiss.vcf \
    --reference ${fasref}
# convert to 00,01,11
~/software/samtools-1.17/bcftools-1.17/bcftools \
    query --print-header -f '%CHROM %POS [%GT ]\n' 3.afd_nfix/${chrom}.afd_${afdcode}_bp${bspace}.nomiss.vcf | \
    sed 's,/,,g' | sed 's,#,,g' | sed 's,\.,,g' | sed 's,\:GT,,g' | sed 's,\[,,g' | sed 's,\],_,g' \
    > 3.afd_nfix/${chrom}.afd_${afdcode}_bp${bspace}.nomiss.gt.txt
cat 3.afd_nfix/${chrom}.afd_${afdcode}_bp${bspace}.nomiss.gt.txt
wc -l 3.afd_nfix/${chrom}.afd_${afdcode}_bp${bspace}.nomiss.gt.txt


