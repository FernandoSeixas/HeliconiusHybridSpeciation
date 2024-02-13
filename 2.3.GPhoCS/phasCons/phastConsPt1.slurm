#!/bin/bash
#SBATCH -n 8   # Number of cores requested
#SBATCH -N 1    # Ensure that all cores are on one machine
#SBATCH -t 180   # Runtime in minutes
#SBATCH -p shared # Partition to submit to
#SBATCH --mem-per-cpu=6000 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o phastCons_%j.out # Standard out goes to this file
#SBATCH -e phastCons_%j.err # Standard err goes to this filehostname


## load modules
module load hal/20160415-fasrc01
module load phast/1.4-fasrc01
module load ucsc/20150820-fasrc01
module load bedtools2/2.26.0-fasrc01

# create dirs
mkdir 0.Hmel2Annotations
mkdir 1.mafByScaffold
mkdir 2.4dSites

## define some files to use
genesAnnotation="/n/mallet_lab/edelman/18Genomes/results/DiscovarCompGenomics/data/heliconius_melpomene_melpomene_hmel2_core_32_85_1.gff"
tree="((((((((((((((Hpar,Hnum),Hbes),((Htim,Hcyd),(HmelRef,HmelDisco))),Ldor),(((((HeraRef,HeraDisco),(Hhim,HeraHhimHyb)),Hhsa),Htel),(Hsar,Hdem))),Etal),Avan),Mcin),Bany),Dple),Ppol),Lacc),Bmor),Pxyl)"
spplist="HmelRef,HmelDisco,Ldor,Hbes,Htim,Hcyd,Etal,Avan,Htel,Hhsa,HeraRef,HeraDisco,Hhim,HeraHhimHyb,Hsar,Hdem,Mcin,Bany,Dple,Ppol,Lacc,Bmor,Pxyl,Hpar,Hnum"

## get Nate's Heliconius alignment file in .hal format
#cp /n/mallet_lab/edelman/18Genomes/results/DiscovarCompGenomics/data/finalAssemblies_highQual_1kbFilter_161101.hal .
## get Hmel2 scaffolds infos
#cp /n/mallet_lab/edelman/18Genomes/results/DiscovarCompGenomics/sequenceEvolution/phast/data/Hmel2.sizes .
#awk '{print $1,1,$2}' Hmel2.sizes > Hmel2.scaffolds.bed
#awk '{if ($2 > 1000000) print }' Hmel2.sizes > Hmel2.larger1Mb.sizes
## extract annotation features by scaffold and adjust scaffold names
#cat Hmel2.larger1Mb.sizes | cut -f1 | xargs -n 1 -P 4 sh -c 'grep $0 $genesAnnotation > 0.Hmel2Annotations/$scaffold.genes.gff'
#for scaffold in `cat Hmel2.larger1Mb.sizes | cut -f1`; do sed -i "s,$scaffold,HmelRef.$scaffold,g" 0.Hmel2Annotations/$scaffold.genes.gff; done

## convert hal-to-maf (by scaffold)
cat Hmel2.larger1Mb.sizes | cut -f1 | xargs -n 1 -P 8 sh -c 'hal2maf --noAncestors --noDupes --refGenome HmelRef --refSequence $0 finalAssemblies_highQual_1kbFilter_161101.hal 1.mafByScaffold/$0.maf' 

## sort (https://github.com/UCSantaCruzComputationalGenomicsLab/last/blob/master/scripts/maf-sort.sh)
cat Hmel2.larger1Mb.sizes | cut -f1 | xargs -n 1 -P 8 sh -c 'bash maf-sort.sh 1.mafByScaffold/$0.maf > 1.mafByScaffold/$0.sort.maf'

## remove headers
for scaffold in `cat Hmel2.larger1Mb.sizes | cut -f1`; do sed '1d' 1.mafByScaffold/$scaffold.sort.maf > 1.mafByScaffold/$scaffold.noHeader.maf; done

## Generate neutral model file (phyloFit) -  null model of evolutionary rate with 4-fold degenerate sites for each scaffold separately with PhyloFit, and then averaged them together according to the PhastCons best practices
## extract 4 degenerate sites for each chromosome/scaffold
cat Hmel2.larger1Mb.sizes | cut -f1 | xargs -n 1 -P 8 sh -c '
    msa_view 1.mafByScaffold/$0.sort.maf --in-format MAF --4d --features 0.Hmel2Annotations/$0.genes.gff > 2.4dSites/$0.codons.ss 
    msa_view 2.4dSites/$0.codons.ss --in-format SS --out-format SS --tuple-size 1 > 2.4dSites/$0.sites.ss
'
# aggregate results of all scaffolds
rm 2.4dSites/all-4d.sites.ss
msa_view --aggregate $spplist 2.4dSites/*.sites.ss --unordered-ss --out-format SS > 2.4dSites/all-4d.sites.ss

# Generate neutral model file
phyloFit --tree $tree --msa-format SS --out-root nonconserved-all-4d 2.4dSites/all-4d.sites.ss








### Generate neutral model file (phyloFit) -  null model of evolutionary rate with 4-fold degenerate sites for each scaffold separately with PhyloFit, and then averaged them together according to the PhastCons best practices
## extract 4 degenerate sites for each chromosome/scaffold
#ls CHUNKS/*.sort.1-1000000* | sed 's,.sort.1-1000000.ss,,g' | sed 's,CHUNKS/,,g' | cut -f1 | xargs -n 1 -P 1 sh -c '
#    msa_view CHUNKS/$0.sort.1-1000000.ss --in-format SS --4d --features 0.Hmel2Annotations/$0.genes.gff > 2.4dSites/$0.1-1000000.codons.ss 
#    msa_view 2.4dSites/$0.1-1000000.codons.ss --in-format SS --out-format SS --tuple-size 1 > 2.4dSites/$0.1-1000000.sites.ss
#'
## aggregate results of all scaffolds
#rm 2.4dSites/all-4d.1-1000000.sites.ss
#msa_view --aggregate $spplist 2.4dSites/*.1-1000000.sites.ss --unordered-ss --out-format SS > 2.4dSites/all-4d.1-1000000.sites.ss
#
## Generate neutral model file
#phyloFit --tree $tree --msa-format SS --out-root nonconserved-all-4d.1-1000000 2.4dSites/all-4d.1-1000000.sites.ss



## convert Hmel2 to Hmel25 coordinates 
#module load R/3.5.1-fasrc01
#export R_LIBS_USER=$HOME/apps/R_3.5.1:$R_LIBS_USER
#Rscript ~/code/heliconius_seixas/0.general/hmel2-to-hmel25.Coordinates.R \
#    -t /n/mallet_lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/Hmel2.transitions.tsv \
#    -b dummy.bed \
#    -o phastCons.regions.bed