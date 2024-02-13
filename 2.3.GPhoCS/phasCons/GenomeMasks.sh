######################### Conserved Elements - PhastCons #######################

sbatch /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/phastConsPt1.slurm
sbatch /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/phastConsPt2.slurm



######################### CpG islands - gCluster ##############################

##### gCluster =====================================================
# https://bioinfo2.ugr.es/gCluster/manual-2/#UsinggClusterVM
# https://www.biorxiv.org/content/10.1101/015800v2.full

# load modules
module load python/3.8.5-fasrc01
module load Java/1.8

## Prepare assembly - split into canonical [chromosomes] and non-canonical [non-anchored scaffols]
python /n/home12/fseixas/software/gCluster_standalones/prepareAssembly.py \
    -i /n/mallet_lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/Heliconius_melpomene_melpomene_Hmel2.5.scaffolds.fa \
    -l hmelv25 \
    -r Hmel200

## Index the fasta
java -jar /n/home12/fseixas/software/gCluster_standalones/makeSeqObj.jar hmelv25_canonical.fa

## Randomizes DNA sequences
java -jar /n/home12/fseixas/software/gCluster_standalones/randomizer.jar hmelv25_canonical.zip

## Determine local clusters of DNA
mkdir results
java -jar /n/home12/fseixas/software/gCluster_standalones/gCluster.jar \
    genome=hmelv25_canonical.zip \
    pattern=CG \
    output=results/hmelv25_CpGislands \
    writedistribution=true \
    chromStat=true

## cluster cpg islands
perl /n/home12/fseixas/software/gCluster_standalones/GenomeCluster.pl \
    start results/hmelv25_CpGislands/cluster.txt \
    gi 1E-5 \
    hmelv25_canonical.N \
    0

## sort by coordinates
sort -k1,1 -k2,2n results/hmelv25_CpGislands/cluster.txt_GCresult/all_genomeIntersec_start_GenomeCluster.txt | cut -f1,2,3 > tmp; mv tmp results/hmelv25_CpGislands/hmelv25_CpGislands.bed
