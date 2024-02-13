## load modules
module load bedtools2/2.26.0-fasrc01

## UCSC phastCons elements (multiple alignments of 124 insects genome sequences, coordinates using the reference D. melanogaster/dm6/Aug. 2014 assembly)
# convert bw to bedgraph format
bigWigToBedGraph  dm6.phastCons124way.bw dm6.phastCons124way.bedGraph
# retain only regions with phastcons score >0.8 
awk '{if ($4 >= 0.8) print}' dm6.phastCons124way.bedGraph | cut -f1,2,3 > dm6.phastCons124way.score0.8.bed
# merge contiguous segments (1-bp apart)
bedtools merge -d 1 -i dm6.phastCons124way.score0.8.bed > dm6.phastCons124way.score0.8.merged.d01.bed
# merge contiguous segments (10-bp apart)
bedtools merge -d 10 -i dm6.phastCons124way.score0.8.merged.d01.bed > dm6.phastCons124way.score0.8.merged.d10.bed
# merge contiguous segments (20-bp apart)
bedtools merge -d 20 -i dm6.phastCons124way.score0.8.merged.d10.bed > dm6.phastCons124way.score0.8.merged.d20.bed
# get conserved regions > 50 bp
awk '{if ($3-$2+1 > 50) print }' dm6.phastCons124way.score0.8.merged.d01.bed > dm6.phastCons124way.score0.8.merged.len50bp.bed
## get sequences of the conserved elements
bedtools getfasta -fi dm6.fa -bed dm6.phastCons124way.score0.8.merged.len50bp.bed -fo dm6.phastCons124way.score0.8.merged.len50bp.fasta





/n/home12/fseixas/software/MashMap/mashmap \
    --ref /n/mallet_lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/Heliconius_melpomene_melpomene_Hmel2.5.scaffolds.fa \
    --query dm6.phastCons124way.score0.8.merged.len50bp.fasta \
    --segLength 1000 \
    --perc_identity 85 \
    -f one-to-one \
    --output dm6-to-hmelv25.phastCons124way.mashmap





## align hmel25 to dm6 assemblies
module load minimap2/2.9-fasrc01


minimap2 -x asm10 -c /n/mallet_lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/Heliconius_melpomene_melpomene_Hmel2.5.scaffolds.fa dm6.fa > dm6-2-hmel25.paf

paftools.js stat dm6-2-hmel25.paf

paftools.js liftover -l50 dm6-2-hmel25.paf dm6.phastCons124way.score0.8_len50bp.bed

minimap2 -c /n/mallet_lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/Heliconius_melpomene_melpomene_Hmel2.5.scaffolds.fa dm6.fa | \
    paftools.js liftover -l50 - <(echo -e "MT_orang\t2000\t5000")     # liftOver


/n/home12/fseixas/software/MashMap/mashmap \
    --ref /n/mallet_lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/Heliconius_melpomene_melpomene_Hmel2.5.scaffolds.fa \
    --query dm6.fa \
    --perc_identity 70 \
    -f one-to-one \
    --output dm6-to-hmelv25.mashmap