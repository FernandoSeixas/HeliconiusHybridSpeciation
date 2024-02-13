#!/bin/bash
#SBATCH -n 16                              # Number of cores requested
#SBATCH -N 1                               # Ensure that all cores are on one machine
#SBATCH -t 600                             # Runtime in minutes
#SBATCH -p serial_requeue,shared           # Partition to submit to
#SBATCH --mem-per-cpu=1000                 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append                 #
#SBATCH -o prepGPhocs_%j.out               # Standard out goes to this file
#SBATCH -e prepGPhocs_%j.err               # Standard err goes to this filehostname


## Define variables & export
slocus=$1; export slocus=$slocus
sgroup=$2; export sgroup=$sgroup
refnam="hmelv25"; export refnam=$refnam
tomask="/n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/1.analyses/4.GlobalStats/gphocs.v2/repeatANDgcrich.merge.bed"; export tomask=$tomask

## create directories
mkdir bpp-a01-${sgroup}-${slocus}
mkdir bpp-a01-${sgroup}-${slocus}/1.vcfRegions
mkdir bpp-a01-${sgroup}-${slocus}/2.vcf2fas
mkdir bpp-a01-${sgroup}-${slocus}/3.fltFasta
mkdir bpp-a01-${sgroup}-${slocus}/4.bppFormat



## 1.1 extract vcfs ****************************************************************************************************
# extract regions from vcf [and mask repeat regions]
rm bpp-a01-${sgroup}-${slocus}/1.vcfRegions/*.vcf.gz
cat bedFiles/${refnam}.${slocus}.bed | xargs -n 3 -P 16 sh -c '
    bcftools view \
    -r $0:$1-$2 \
    --samples-file ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/bpp-a01-${sgroup}.inds.list \
    --targets-file ^$tomask \
    /n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/0.data/2.3.merge/$0.${refnam}.merge.vcf.gz \
    --output-type z \
    --output-file bpp-a01-${sgroup}-${slocus}/1.vcfRegions/$0.$1.$2.vcf.gz
    # check if file as enough lines
    nsnps=`bcftools view -H bpp-a01-${sgroup}-${slocus}/1.vcfRegions/$0.$1.$2.vcf.gz | wc -l`
    if [ $nsnps -lt 10 ] 
    then 
        rm bpp-a01-${sgroup}-${slocus}/1.vcfRegions/$0.$1.$2.vcf.gz
    fi
'


## 1.2 simplify vcf ****************************************************************************************************
module load plink/1.90-fasrc01
rm bpp-a01-${sgroup}-${slocus}/1.vcfRegions/*.simple.vcf
for scaffold in `cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt`; do
    echo $scaffold;
    ls bpp-a01-${sgroup}-${slocus}/1.vcfRegions/${scaffold}*.vcf.gz | sed 's,.vcf.gz,,g' | sed "s,bpp-a01-${sgroup}-${slocus}/1.vcfRegions/,,g" | xargs -n 1 -P 16 sh -c '
    plink \
        --vcf bpp-a01-${sgroup}-${slocus}/1.vcfRegions/$0.vcf.gz \
        --allow-extra-chr \
        --recode vcf-iid \
        --out bpp-a01-${sgroup}-${slocus}/1.vcfRegions/$0.simple
    ';
    rm bpp-a01-${sgroup}-${slocus}/1.vcfRegions/${scaffold}*.nosex
    rm bpp-a01-${sgroup}-${slocus}/1.vcfRegions/${scaffold}*.log
done



## 1.3 convert vcf to fasta ********************************************************************************************
rm bpp-a01-${sgroup}-${slocus}/2.vcf2fas/*.fasta
for scaffold in `cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt`; do
    echo $scaffold;
    ls bpp-a01-${sgroup}-${slocus}/1.vcfRegions/${scaffold}*.simple.vcf | sed 's,.simple.vcf,,g' | sed "s,bpp-a01-${sgroup}-${slocus}/1.vcfRegions/,,g" | xargs -n 1 -P 16 sh -c '
        perl \
            /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/5.GlobalStats/gphocs/vcf2fasta.pl \
            bpp-a01-${sgroup}-${slocus}/1.vcfRegions/$0.simple.vcf \
            bpp-a01-${sgroup}-${slocus}/2.vcf2fas/$0.fasta
    '
done



############################## Filter alignments and convert to BPP ###################################

## 2.1 filter alignments
rm bpp-a01-${sgroup}-${slocus}/3.fltFasta/*.filter.fasta
for scaffold in `cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt `; do
    echo $scaffold;
    ls bpp-a01-${sgroup}-${slocus}/2.vcf2fas/${scaffold}*.fasta | \
        sed "s,bpp-a01-${sgroup}-${slocus}/2.vcf2fas/,,g" | \
        sed "s,.fasta,,g" | xargs -n 1 -P 16 sh -c '
        perl ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/filterFastaAlignments.pl \
            bpp-a01-${sgroup}-${slocus}/2.vcf2fas/$0.fasta \
            bpp-a01-${sgroup}-${slocus}/3.fltFasta/$0.filter.fasta \
            ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/bpp-a01-${sgroup}.popmap.txt \
            ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/bpp-a01-${sgroup}.popmin.txt \
            0.50 0.20 50
    '
done

# 2.2. convert to BPP format
rm bpp-a01-${sgroup}-${slocus}/4.bppFormat/*.fasta
for scaffold in `cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt `; do
    echo $scaffold;
    ls bpp-a01-${sgroup}-${slocus}/3.fltFasta/${scaffold}* | sed 's,.filter.fasta,,g' | sed "s,bpp-a01-${sgroup}-${slocus}/3.fltFasta/,,g" | xargs -n 1 -P 16 sh -c '
        perl /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/BPP/fasta2bpp.pl \
            bpp-a01-${sgroup}-${slocus}/3.fltFasta/$0.filter.fasta \
            bpp-a01-${sgroup}-${slocus}/4.bppFormat/$0.bpp.fasta \
            $0 \
            50
    '
done
