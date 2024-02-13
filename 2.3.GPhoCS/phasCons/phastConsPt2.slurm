#!/bin/bash
#SBATCH -n 24   # Number of cores requested
#SBATCH -N 1    # Ensure that all cores are on one machine
#SBATCH -t 240   # Runtime in minutes
#SBATCH -p shared # Partition to submit to
#SBATCH --mem-per-cpu=4000 # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append
#SBATCH -o phastConsPt2_%j.out # Standard out goes to this file
#SBATCH -e phastConsPt2_%j.err # Standard err goes to this filehostname


## load modules
module load hal/20160415-fasrc01
module load phast/1.4-fasrc01
module load ucsc/20150820-fasrc01
module load bedtools2/2.26.0-fasrc01


## 1. Split the alignments into small fragments (each spanning about 1Mb of the human genome) ==============================
#mkdir -p 1.CHUNKS            # put fragments here
#for file in 1.mafByScaffold/*.sort.maf ; do
#    root=`basename $file .maf`
#    msa_split \
#        --in-format MAF $file  \
#        --windows 100000,0 --out-root 1.CHUNKS/$root --out-format SS \
#        --min-informative 100 --between-blocks 5000 
#done


## 2. Estimate parameters for each fragment, separately and in parallel. ===================================================
#mkdir -p 2.TREES     # put estimated tree models here
#rm -f 2.TREES/*      # in case old versions left over
#ls 1.CHUNKS/*.sort.1-100000.ss | sed 's,.sort.1-100000.ss,,g' | sed 's,1.CHUNKS/,,g' | xargs -n 1 -P 24 sh -c '
#    phastCons \
#        --target-coverage 0.125 --expected-length 20 \
#        --gc 0.4 --estimate-trees 2.TREES/$0 \
#        1.CHUNKS/$0.sort.1-100000.ss nonconserved-all-4d.mod --no-post-probs
#'

### 3. Combine the separately estimated parameters by averaging. ============================================================
#ls 2.TREES/*.cons.mod > cons.txt
#phyloBoot --read-mods '*cons.txt' --output-average ave.cons.mod 
#ls 2.TREES/*.noncons.mod > noncons.txt
#phyloBoot --read-mods '*noncons.txt' --output-average ave.noncons.mod 


## 4. Predict conserved elements and conservation scores globally using the combined estimates =============================
mkdir -p 3.ELEMENTS 4.SCORES
rm -f 3.ELEMENTS/* 4.SCORES/*
ls 1.CHUNKS/*.sort.1-1000000.ss | sed 's,.sort.1-1000000.ss,,g' | sed 's,1.CHUNKS/,,g' | xargs -n 1 -P 24 sh -c ''
    phastCons \
        --target-coverage 0.125 --expected-length 20 \
        --most-conserved 3.ELEMENTS/$0.bed --score \
        1.CHUNKS/$0.sort.1-1000000.ss ave.cons.mod,ave.noncons.mod > 4.SCORES/$0.wig
cat 3.ELEMENTS/*.bed | sort -k1,1 -k2,2n > most-conserved.bed
#
#
### 5. Adjust tuning parameters and return to step 2, if necessary. Repeat until coverage and smoothing targets are met. =====
## concatenate CDS
#cat 0.Hmel2Annotations/*.genes.gff | grep "CDS" | awk '{print $1,$4,$5}' | sed 's,HmelRef.,,g' | sed 's, ,\t,g' > 0.Hmel2Annotations/all_1Mb_scaff.CDS.bed
## Targets are:
## a. 65% coverage of coding exons (based on previous studies on insects)
#bedtools intersect -a 0.Hmel2Annotations/all_1Mb_scaff.CDS.bed most-conserved.bed
## b. PIT of 10 bits
#consEntropy .125 20 ave.cons.mod ave.noncons.mod



