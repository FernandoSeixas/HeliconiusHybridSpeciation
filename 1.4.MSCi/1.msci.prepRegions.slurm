#!/bin/bash

## *********************************************************************************************************************
## BPP_prepRegions.sh
# this script defines from which regions sequence data should be extracted from

#/ Load libraries
module load python/3.10.9-fasrc01


#/ Arguments
refnam="hmelv25"; export refnam=$refnam
exonbuffer=5000 

#/ Rerence genome coordinates
genome="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/${refnam}/${refnam}.genome.bed"
exons="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/${refnam}/${refnam}.exons.bed"
scalen="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/${refnam}/${refnam}.scaffold.sizes"

#/ Create directories
mkdir bedFiles
mkdir bedFiles/infoDensity/


#/ Create buffer around exons // for non coding regions
~/software/bedtools2/bin/bedtools slop -b ${exonbuffer} -i ${exons} -g ${scalen} > bedFiles/${refnam}.noncod.5kb_exonbuff.bed 
sort -k1,1 -k2,2n bedFiles/${refnam}.noncod.5kb_exonbuff.bed > bedFiles/${refnam}.noncod.5kb_exonbuff.sorted.bed
~/software/bedtools2/bin/bedtools merge -i bedFiles/${refnam}.noncod.5kb_exonbuff.sorted.bed > bedFiles/${refnam}.noncod.5kb_exonbuff.merge.bed
rm bedFiles/${refnam}.noncod.5kb_exonbuff.bed 
rm bedFiles/${refnam}.noncod.5kb_exonbuff.sorted.bed
mv bedFiles/${refnam}.noncod.5kb_exonbuff.merge.bed bedFiles/${refnam}.noncod.bed

#/ make windows
edist=5000                       # minimum distance to exons
lsize=2000                       # locus size
lstep=20000                      # minimum distance between adjacent loci
slocus="noncod.l${lsize}_g${lstep}_e${edist}"
python makewindows.py \
    bedFiles/${refnam}.noncod.bed \
    bedFiles/wgenome.noncod.${slocus}.bed \
    --window_size ${lsize} \
    --window_step ${lstep}

