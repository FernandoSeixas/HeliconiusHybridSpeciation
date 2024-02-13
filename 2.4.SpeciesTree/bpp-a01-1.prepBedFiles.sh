## BPP 
#/ Load modules
module load bedtools2/2.26.0-fasrc01



mkdir bedFiles/

## Genomic coordinates *************************************************************************************************

#/ Rerence genome coordinates
genome="support/hmelv25.genome.bed"
genes="support/hmelv25.genes.bed"
exons="support/hmelv25.exons.bed"
scafflen="support/hmelv25.scaffoldsLength.noheader.txt"

#/ Create buffer around genes
# bedtools slop -b 2000 -i ${genes} -g ${scafflen} > bedFiles/hmelv25.genes.buffer_2kb.bed 
bedtools slop -b 2000 -i ${exons} -g ${scafflen} > bedFiles/hmelv25.exons.buffer_2kb.bed 
sort -k1,1 -k2,2n bedFiles/hmelv25.exons.buffer_2kb.bed > bedFiles/hmelv25.exons.buffer_2kb.sorted.bed
bedtools merge -i bedFiles/hmelv25.exons.buffer_2kb.sorted.bed > bedFiles/hmelv25.exons.buffer_2kb.merge.bed


## Define regions to analyze *******************************************************************************************

## Exonic regions 
#/ make windows - 250-1000 bp, 2000 bp apart
bedtools makewindows -b $exons -w 250 -s 2000 | \
    egrep -v "Hmel200" | \
    awk '{if ($3-$2+1 > 99) print}' \
    > bedFiles/hmelv25.exonic.minL100.maxL250.minG2000.bed


## Non Genic regions
#/ make windows - 250-1000 bp, 2000 bp apart
bedtools makewindows -b bedFiles/hmelv25.exons.buffer_2kb.merge.bed -w 250 -s 2000 | \
    egrep -v "Hmel200" | \
    awk '{if ($3-$2+1 > 99) print}' \
    > bedFiles/hmelv25.noncod.minL100.maxL250.minG2000.bed

