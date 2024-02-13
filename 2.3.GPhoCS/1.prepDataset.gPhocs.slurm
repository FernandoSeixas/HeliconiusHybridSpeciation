#!/bin/bash
#SBATCH -n 8    # Number of cores requested
#SBATCH -N 1    # Ensure that all cores are on one machine
#SBATCH -t 60 # Runtime in minutes
#SBATCH -p shared # Partition to submit to
#SBATCH --mem-per-cpu=4000 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o prepGPhocs_%j.out # Standard out goes to this file
#SBATCH -e prepGPhocs_%j.err # Standard err goes to this filehostname


## load modules
module load bedtools2/2.26.0-fasrc01
module load tabix/0.2.6-fasrc01
module load R/3.6.3-fasrc01
export R_LIBS_USER=$HOME/apps/R_v3.6.3:$R_LIBS_USER



### prepare global dataset =============================================================================
## 1.1. create bed file of NONCOD regions to sample from
## variables
genicRegions="/n/mallet_lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.genes_coord.tab"
hmelv25Genom="/n/mallet_lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.BigChrScaffoldsLength.txt"
## get non-genic regions coordinates [complement genic regions]
cut -f2,3,4 $genicRegions |
   grep -v "Hmel200" |
   egrep "Hmel201001o|Hmel202001o|Hmel203003o|Hmel204001o|Hmel205001o|Hmel206001o|Hmel207001o|Hmel208001o|Hmel209001o|Hmel210001o|Hmel211001o|Hmel212001o|Hmel213001o|Hmel214004o|Hmel215003o|Hmel216002o|Hmel217001o|Hmel218003o|Hmel219001o|Hmel220003o|Hmel221001o" \
   > hmelv25.GeneCoord-Chrom.bed
bedtools complement -i hmelv25.GeneCoord-Chrom.bed -g $hmelv25Genom > hmelv25.noncod.Step1.bed
# get conserverd regions [phastCons]
cat phastCons.regions.bed | 
   grep -v "Hmel200" |
   egrep "Hmel201001o|Hmel202001o|Hmel203003o|Hmel204001o|Hmel205001o|Hmel206001o|Hmel207001o|Hmel208001o|Hmel209001o|Hmel210001o|Hmel211001o|Hmel212001o|Hmel213001o|Hmel214004o|Hmel215003o|Hmel216002o|Hmel217001o|Hmel218003o|Hmel219001o|Hmel220003o|Hmel221001o" \
   > hmelv25.PhastCons-Chrom.bed
bedtools complement -i hmelv25.PhastCons-Chrom.bed -g hmelv25.noncod.Step2.bed > hmelv25.noncod.Step2.bed

## run Rscript to get coordinates of valid regions to sample from
Rscript ~/code/heliconius_seixas/2.elevatus_pardalinus/5.GlobalStats/dils/1.selectNoncodRegions.R -l 1000 -m 1000 -g 10000 -b 1000 -d /n/holyscratch01/mallet_lab/fseixas/gphocs/ -f hmelv25.noncod.Step1.bed


## variables 
refnam="hmelv25"
snpset="snpset1"
setloc="noncod.minL1000.maxL1000.minG10000"
repeat="/n/mallet_lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25_repeats.txt"
gcisle="/n/holyscratch01/mallet_lab/fseixas/gphocs.v2/gCluster/results/hmelv25_CpGislands/hmelv25_CpGislands.bed"

## concatenate repeat and gc-rich regions
cat $repeat $gcisle | sort -k1,1 -k2,2n > repeatANDgcrich.bed
bedtools merge -i repeatANDgcrich.bed > repeatANDgcrich.merge.bed
tomask="repeatANDgcrich.merge.bed"

## export variables
export refnam=$refnam
export snpset=$snpset
export setloc=$setloc
export tomask=$tomask

# create directories
mkdir $setloc.$snpset
mkdir $setloc.$snpset/1.vcfRegions
mkdir $setloc.$snpset/2.vcf2fas

## 1.2. extract vcfs
# extract regions from vcf [and mask repeat regions]
rm $setloc.$snpset/1.vcfRegions/*.vcf
cat $refnam.$setloc.bed | xargs -n 3 -P 8 sh -c '
    bcftools view \
    -r $0:$1-$2 \
    --targets-file ^$tomask \
    /n/holyscratch01/mallet_lab/fseixas/2.elepar/2.4.snpsets/$snpset/$0.hmelv25.$snpset.simplify.vcf.gz \
    > $setloc.$snpset/1.vcfRegions/$0.$1.$2.vcf
'

## 1.3 convert vcf to fasta
rm $setloc.$snpset/2.vcf2fas/*.fasta
ls $setloc.$snpset/1.vcfRegions/ | sed 's,.vcf,,g' | xargs -n 1 -P 8 sh -c '
    echo $0;
    perl /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/vcf2fasta.pl $setloc.$snpset/1.vcfRegions/$0.vcf $setloc.$snpset/2.vcf2fas/$0.fasta
'

## 1.4 replace names [simplify so that we can group individuals with different names in the same pop]
ls $setloc.$snpset/2.vcf2fas/*fasta | xargs -n 1 -P 8 sh -c '
    printf "%s\n" $0;
    /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/renamePops.sh $0
'

# ## determine missing data
# # concatenate all files
# cd $setloc.$snpset
# lfiles=$(ls 2.vcf2fas/*)
# ~/software/seqkit concat -w 0 --seq-type dna -j 1 -o concatAlignment.fasta $lfiles
# perl /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/dils/fastaMissing.pl concatAlignment.fasta > missingData.txt


grep ">" $setloc.$snpset/concatAlignment.fasta | sed 's,>,,g' > $setloc.$snpset/allinds.samples.list
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/dils/renamePops.sh $setloc.$snpset/allinds.samples.list
cat /n/holyscratch01/mallet_lab/fseixas/2.elepar/support/$snpset.samples.list | sed 's,\.,,g' > $setloc.$snpset/$snpset.samples.list
bash /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/dils/renamePops.sh $setloc.$snpset/$snpset.samples.list



############################## Filter alignments and convert to g-phocs ###################################

## 2.1 filter alignments
mkdir $setloc.$snpset/3.fltFasta
rm $setloc.$snpset/3.fltFasta/*.filter.fasta
ls $setloc.$snpset/2.vcf2fas/ | sed 's,.fasta,,g' | xargs -n 1 -P 8 sh -c '
    echo $setloc.$snpset/2.vcf2fas/$0.fasta; 
    perl /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/alignmentFilters.pl \
        $setloc.$snpset/2.vcf2fas/$0.fasta \
        $setloc.$snpset/3.fltFasta/$0.filter.fasta \
        0.60 0.25 100 \
        /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/MinIndFilters.txt
'

## 2.2. convert to gphocs format
mkdir $setloc.$snpset/4.gphocsFormat
rm $setloc.$snpset/4.gphocsFormat/*.fasta
ls $setloc.$snpset/3.fltFasta | sed 's,.filter.fasta,,g' | xargs -n 1 -P 8 sh -c '
   perl /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/fasta2gphocs.pl \
       $setloc.$snpset/3.fltFasta/$0.filter.fasta \
       $0 \
       $setloc.$snpset/4.gphocsFormat/$0.gphocs.fasta
'

## 2.3. concatenate files to final gPhocs format
cd $setloc
#/ autosomes
ls 4.gphocsFormat/ | grep -v Hmel221 | wc -l > autosomes.seqs.txt
for file in `ls 4.gphocsFormat | grep -v Hmel221`; do 
    cat 4.gphocsFormat/$file >> autosomes.seqs.txt
    printf "\n" >> autosomes.seqs.txt
done
#/ autosomes - no color
ls 4.gphocsFormat/ | egrep -v "Hmel210|Hmel215|Hmel218|Hmel221" | wc -l > autoNoColor.seqs.txt
for file in `ls 4.gphocsFormat | egrep -v "Hmel210|Hmel215|Hmel218|Hmel221"`; do 
    cat 4.gphocsFormat/$file >> autoNoColor.seqs.txt
    printf "\n" >> autoNoColor.seqs.txt
done
#/ Z-chromosome
# ls 4.gphocsFormat/ | grep Hmel221 | wc -l > zchromosome.seqs.txt
# for file in `ls 4.gphocsFormat | grep Hmel221`; do 
#     cat 4.gphocsFormat/$file >> zchromosome.seqs.txt
#     printf "\n" >> zchromosome.seqs.txt
# done
# cd ..


