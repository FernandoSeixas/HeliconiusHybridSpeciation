#!/bin/bash
#SBATCH -n 32                         # Number of cores requested
#SBATCH -N 1                          # Ensure that all cores are on one machine
#SBATCH -t 360                        # Runtime in minutes
#SBATCH -p shared                     # Partition to submit to
#SBATCH --mem-per-cpu=1000            # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append           
#SBATCH -o prepBPP_%j.out             # Standard out goes to this file
#SBATCH -e prepBPP_%j.err             # Standard err goes to this filehostname



## Prepare files for bpp ***********************************************************************************************
mkdir/1.vcfRegions
mkdir/2.vcf2fas
mkdir/3.fltFasta
mkdir/4.bppFormat

## Define variables & export
slocus=$1; export slocus=$slocus
sgroup=$2; export sgroup=$sgroup
refnam="hmelv25"; export refnam=$refnam
tomask="/n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/1.analyses/4.GlobalStats/gphocs.v2/repeatANDgcrich.merge.bed"; export tomask=$tomask


## create directories
mkdir ${sgroup}-${slocus}
mkdir ${sgroup}-${slocus}/1.vcfRegions
mkdir ${sgroup}-${slocus}/2.vcf2fas
mkdir ${sgroup}-${slocus}/3.fltFasta
mkdir ${sgroup}-${slocus}/4.bppFormat


## Extract vcfs 
# extract regions from vcf [and mask repeat regions]
rm ${sgroup}-${slocus}/1.vcfRegions/*.vcf.gz
cat bedFiles/wgenome.$slocus.bed | egrep -v "Hmel221" | xargs -n 3 -P 32 sh -c '
    ~/software/samtools-1.17/bcftools-1.17/bcftools view \
    -r $0:$1-$2 \
    --samples-file /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/msci/${sgroup}.pset.txt \
    --targets-file ^${tomask} \
    /n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/0.data/2.3.merge/$0.$refnam.merge.vcf.gz \
    --output-type z \
    --output-file ${sgroup}-${slocus}/1.vcfRegions/$0.$1.$2.vcf.gz
    check if file as enough lines
    nsnps=`~/software/samtools-1.17/bcftools-1.17/bcftools view -H ${sgroup}-${slocus}/1.vcfRegions/$0.$1.$2.vcf.gz | wc -l`
    if [ $nsnps -lt 500 ] 
    then 
        rm ${sgroup}-${slocus}/1.vcfRegions/$0.$1.$2.vcf.gz
    fi
'

## Simplify vcf 
rm ${sgroup}-${slocus}/1.vcfRegions/*.simple.vcf
for scaffold in `cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt`; do
    echo $scaffold;
    ls ${sgroup}-${slocus}/1.vcfRegions/${scaffold}*.vcf.gz | \
    sed 's,.vcf.gz,,g' | sed "s,${sgroup}-${slocus}/1.vcfRegions/,,g" | \
    xargs -n 1 -P 32 sh -c '
    ~/software/plink_1.9/plink \
        --vcf ${sgroup}-${slocus}/1.vcfRegions/$0.vcf.gz \
        --allow-extra-chr \
        --recode vcf-iid \
        --out ${sgroup}-${slocus}/1.vcfRegions/$0.simple
    ';
    rm ${sgroup}-${slocus}/1.vcfRegions/${scaffold}*.nosex
    rm ${sgroup}-${slocus}/1.vcfRegions/${scaffold}*.log
done

## Convert vcf to fasta 
rm ${sgroup}-${slocus}/2.vcf2fas/*.fasta
for scaffold in `cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt`; do
    echo $scaffold;
    ls ${sgroup}-${slocus}/1.vcfRegions/${scaffold}*.simple.vcf | \
    sed 's,.simple.vcf,,g' | sed "s,${sgroup}-${slocus}/1.vcfRegions/,,g" | \
    xargs -n 1 -P 32 sh -c '
        perl \
            ~/code/heliconius_seixas/2.elevatus_pardalinus/5.GlobalStats/gphocs/vcf2fasta.pl \
            ${sgroup}-${slocus}/1.vcfRegions/$0.simple.vcf \
            ${sgroup}-${slocus}/2.vcf2fas/$0.fasta
    '
done

## Filter alignments
rm ${sgroup}-${slocus}/3.fltFasta/*.filter.fasta
for scaffold in `cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt  `; do
    echo $scaffold;
    ls ${sgroup}-${slocus}/2.vcf2fas/${scaffold}*.fasta | \
        sed "s,${sgroup}-${slocus}/2.vcf2fas/,,g" | \
        sed "s,.fasta,,g" | xargs -n 1 -P 1 sh -c '
        perl ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/filterFastaAlignments.pl \
            ${sgroup}-${slocus}/2.vcf2fas/$0.fasta \
            ${sgroup}-${slocus}/3.fltFasta/$0.filter.fasta \
            /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/msci/${sgroup}.imap.txt \
            /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/msci/${sgroup}.pmin.txt \
            0.20 0.00 800
    '
done

# Convert to BPP format
rm ${sgroup}-${slocus}/4.bppFormat/*.fasta
for scaffold in `cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt `; do
    echo $scaffold;
    ls ${sgroup}-${slocus}/3.fltFasta/${scaffold}* | \
    sed 's,.filter.fasta,,g' | sed "s,${sgroup}-${slocus}/3.fltFasta/,,g" | \
    xargs -n 1 -P 32 sh -c '
        perl /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/BPP/fasta2bpp.pl \
            ${sgroup}-${slocus}/3.fltFasta/$0.filter.fasta \
            ${sgroup}-${slocus}/4.bppFormat/$0.bpp.fasta \
            $0 \
            300 
    '
done

#/ Concatenate alignments 
rm ${sgroup}-${slocus}/${sgroup}.seqs.txt
touch ${sgroup}-${slocus}/${sgroup}.seqs.txt
ls ${sgroup}-${slocus}/4.bppFormat/* | xargs -n 1 sh -c '
    cat $0 >> ${sgroup}-${slocus}/${sgroup}.seqs.txt
'

# ## Determine missing data
# cd ${sgroup}-${slocus}
# # concatenate whole genome loci 
# lfiles=$(ls 2.vcf2fas/*)
# ~/software/seqkit concat -w 0 --seq-type dna -j 1 -o concatAlignment.fasta $lfiles
# # missing data
# perl ~/code/heliconius_seixas/2.elevatus_pardalinus/5.GlobalStats/dils/fastaMissing.pl concatAlignment.fasta > missingData.txt
# cd ..
