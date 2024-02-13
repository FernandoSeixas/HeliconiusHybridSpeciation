#!/bin/bash
#SBATCH -n 32                               # Number of cores requested
#SBATCH -N 1                                # Ensure that all cores are on one machine
#SBATCH -t 180                              # Runtime in minutes
#SBATCH -p serial_requeue,shared            # Partition to submit to
#SBATCH --mem-per-cpu 1500                  # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append                  #
#SBATCH -o prepSFS_%j.out                   # Standard out goes to this file
#SBATCH -e prepSFS_%j.err                   # Standard err goes to this filehostname


# ## create directories
mkdir 1.vcf
mkdir 2.sfs
mkdir support

# fixed variables
datadir="/n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/0.data"
dataset="elepar.set01"
export datadir=$datadir
export dataset=$dataset

# select individuals
bcftools query -l ${datadir}/2.3.merge/Hmel201001o.hmelv25.merge.vcf.gz | egrep "par" | egrep "par.ser"                                                    >  support/parser.inds.txt    # 4 individuals
bcftools query -l ${datadir}/2.3.merge/Hmel201001o.hmelv25.merge.vcf.gz | egrep "par" | egrep "ecu|col|yur|lam|puc|bol|car|pmd.per.001"                    >  support/parama.inds.txt    # 27 individuals
bcftools query -l ${datadir}/2.3.merge/Hmel202001o.hmelv25.merge.vcf.gz | egrep "ele" | egrep "ecu|col|yur|pmd|pbe|bol|car|aut|lbm"                        >  support/eleama.inds.txt    # 26 individuals
bcftools query -l ${datadir}/2.3.merge/Hmel201001o.hmelv25.merge.vcf.gz | egrep "ele" | egrep "bar|tum|Hele.auy.ven.002|Hele.auy.ven.003|Hele.sfy.ven.005" >  support/eleeas.inds.txt    # 11 individuals
bcftools query -l ${datadir}/2.3.merge/Hmel201001o.hmelv25.merge.vcf.gz | egrep "Hbes.spp.bra.003|Hnum.bsl.bra.002|Hism.tel.pan.001"                       >  support/outgrp.inds.txt    # 3 individuals
cat support/parser.inds.txt support/parama.inds.txt support/eleama.inds.txt support/eleeas.inds.txt support/outgrp.inds.txt                                >  support/$dataset.txt       # 71 individuals (maf=0.0125)



## Mask regions of the genome: exons, repetitive regions, and introgression regions ************************************
module load bedtools2/2.26.0-fasrc01

#/ define distances
buffer=10000
export buffer=$buffer
bkb=`echo $(($buffer / 1000))`

#/ link mask files to variables
cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.exons.tab | 
    awk '{print $1, $2-$buffer, $3+$buffer }' | 
    awk '{if ($2 <0) print $1, 0, $3; else print $0}' \
    > support/exonsMask.${bkb}kb.txt
exonsMask="/n/holyscratch01/mallet_lab/fseixas/2.elepar/manuscript/fastsimcoal/support/exonsMask.${bkb}kb.txt"
repeatMask="/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25_repeats.txt"
ls -lgh $exonsMask 
ls -lgh $repeatMask

#/ merge Masks
cat $exonsMask $repeatMask | sed 's, ,\t,g' | sort -k1,1 -k2,2n > support/mergedMask.sorted.txt
bedtools merge -i support/mergedMask.sorted.txt > support/mergedMask.merged.txt 
mergedMask="/n/holyscratch01/mallet_lab/fseixas/2.elepar/analyses/demographicModelling/support/mergedMask.merged.txt"
export mergedMask=$mergedMask

#/ mask VCFs and select individuals
cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt | egrep -v "Hmel221" | xargs -n 1 -P 16 sh -c '
    echo $0
    bcftools view \
    --samples-file support/$dataset.txt \
    --targets-file ^$mergedMask \
    -O z -o 1.vcf/$0.masked.vcf.gz \
    $datadir/2.4.snpsets/$0.hmelv25.snpset1_outgrp.simplify.vcf.gz
'

#/ filter sites with too many missing data
module load plink/1.90-fasrc01
cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt | egrep -v "Hmel221" | xargs -n 1 -P 32 sh -c '
    plink \
    --vcf 1.vcf/$0.masked.vcf.gz \
    --allow-extra-chr \
    --geno 0.20 \
    --recode vcf-iid \
    --out 1.vcf/$0.filter
    bgzip -f 1.vcf/$0.filter.vcf
    tabix -f 1.vcf/$0.filter.vcf.gz
'


## Chose sites monomorphic in the outgroup species and variable in the ingroup *****************************************
#/ convert to geno
module load python/3.8.5-fasrc01
cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt | egrep -v "Hmel221" | xargs -n 1 -P 32 sh -c '
    python /n/home12/fseixas/software/popgen/genomics_general/VCF_processing/parseVCF.py \
        -i 1.vcf/$0.filter.vcf.gz \
        --skipIndels |
    bgzip > 1.vcf/$0.filter.geno.gz
'
#/ minimum individuals per pop
module load python/2.7.16-fasrc01
awk '{print $1, "parser"}' support/parser.inds.txt >  popmap1.txt
awk '{print $1, "parama"}' support/parama.inds.txt >> popmap1.txt
awk '{print $1, "eleama"}' support/eleama.inds.txt >> popmap1.txt
awk '{print $1, "eleeas"}' support/eleeas.inds.txt >> popmap1.txt
awk '{print $1, "outgrp"}' support/outgrp.inds.txt >> popmap1.txt
cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt | grep -v "Hmel221" | xargs -n 1 -P 8 sh -c '
    python \
    ~/software/popgen/genomics_general/filterGenotypes.py \
    --infile  1.vcf/$0.filter.geno.gz \
    --outfile 1.vcf/$0.indflt.geno.gz \
    --keepAllSamples \
    --threads 4 \
    -if phased \
    -of phased \
    --pop parser \
    --pop parama \
    --pop eleama \
    --pop eleeas \
    --pop outgrp \
    --popsFile popmap1.txt \
    --minPopCalls 4 20 20 10 3
'
#/ monomorphic sites in the outgroup
module load python/2.7.16-fasrc01
cat support/$dataset.txt | egrep "par|ele" | awk '{print $1, "ingroup"}' > ingroup.txt
cat support/$dataset.txt | egrep -v "par|ele" | awk '{print $1, "outgroup"}' > outgroup.txt
cat ingroup.txt outgroup.txt > popmap2.txt
cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt | \
    grep -v "Hmel221" | xargs -n 1 -P 8 sh -c '
    python \
    ~/software/popgen/genomics_general/filterGenotypes.py \
    --infile  1.vcf/$0.indflt.geno.gz \
    --outfile 1.vcf/$0.dsites.geno.gz \
    --keepAllSamples \
    --threads 4 \
    -if phased \
    -of phased \
    --pop ingroup \
    --pop outgroup \
    --minPopAlleles 1 1 \
    --maxPopAlleles 2 1 \
    --popsFile popmap2.txt
'
#/ reconvert to VCF
module load python/2.7.16-fasrc01
cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt | \
    egrep -v "Hmel221" | xargs -n 1 -P 32 sh -c '
    python ~/software/popgen/genomics_general/VCF_processing/genoToVCF.py \
    -f phased \
    --genoFile 1.vcf/$0.dsites.geno.gz \
    --outFile  1.vcf/$0.dsites.vcf \
'
#/ compress and index
ls 1.vcf/*.dsites.vcf | xargs -n 1 -P 32 sh -c ' 
    ~/software/samtools-1.17/htslib-1.17/bgzip -f $0; 
    ~/software/samtools-1.17/htslib-1.17/tabix $0.gz;
'
# concatenate SNPs passing above filters
ls 1.vcf/*.dsites.vcf.gz > concat_files.list
~/software/samtools-1.17/bcftools-1.17/bcftools concat \
    --threads 12 \
    --file-list concat_files.list \
    -O z \
    -o 1.vcf/wgenome.dsites.vcf.gz
rm concat_files.list



## Prune data *****************************************************************************
## remove sites with too much missing data (>20%)
## remove individuals with too much missing data (>75%)
## sample SNPs every 1-kb
#/ define distances
# dataset
buffer=1000
export buffer=$buffer
bkb=`echo $(($buffer / 1000))`
#/ filter SNPs
awk '{print $1,$1}' ./support/$dataset.txt | egrep "par|ele" > support/$dataset.samp_file.txt
~/software/plink_1.9/plink \
    --vcf 1.vcf/wgenome.dsites.vcf.gz \
    --allow-extra-chr \
    --keep support/$dataset.samp_file.txt \
    --mind 0.50 \
    --geno 0.20 \
    --bp-space $buffer \
    --make-bed \
    --recode vcf-iid \
    --out 1.vcf/wgenome.dsites.pruned_${bkb}kb
~/software/samtools-1.17/htslib-1.17/bgzip -f 1.vcf/wgenome.dsites.pruned_${bkb}kb.vcf
~/software/samtools-1.17/htslib-1.17/tabix -f 1.vcf/wgenome.dsites.pruned_${bkb}kb.vcf.gz
~/software/samtools-1.17/bcftools-1.17/bcftools view -H 1.vcf/wgenome.dsites.pruned_${bkb}kb.vcf.gz | wc -l 

# update valid individuals
~/software/samtools-1.17/bcftools-1.17/bcftools query -l 1.vcf/wgenome.dsites.pruned_${bkb}kb.vcf.gz | egrep "ele|par" | egrep "par" | egrep "par.ser"                             > support/parser.inds.txt         ## 4 individuals
~/software/samtools-1.17/bcftools-1.17/bcftools query -l 1.vcf/wgenome.dsites.pruned_${bkb}kb.vcf.gz | egrep "ele|par" | egrep "par" | egrep -v "par.ser"                          > support/parama.inds.txt         ## 27 individuals
~/software/samtools-1.17/bcftools-1.17/bcftools query -l 1.vcf/wgenome.dsites.pruned_${bkb}kb.vcf.gz | egrep "ele|par" | egrep "ele" | egrep -v "bar|tum|auy|sfy"                  > support/eleama.inds.txt         ## 26 individuals
~/software/samtools-1.17/bcftools-1.17/bcftools query -l 1.vcf/wgenome.dsites.pruned_${bkb}kb.vcf.gz | egrep "ele|par" | egrep "ele" | egrep "bar|tum|auy|sfy"                     > support/elegui.inds.txt         ## 11 individuals
cat support/parser.inds.txt support/parama.inds.txt support/eleama.inds.txt support/elegui.inds.txt > support/$dataset.inds.txt


#### multi-SFS - population pairs **************************************************************************************
# prepare pops file
cat \
    support/parser.inds.txt \
    support/parama.inds.txt \
    support/eleama.inds.txt \
    support/elegui.inds.txt | \
    sed 's,\.,\t,g' | awk '{print $1"."$2"."$3"."$4, $1 $2 $3}' > support/pruned.pops_file.txt
sed -i 's,Hparserper,parser,g' support/pruned.pops_file.txt
sed -i 's,Helebargui,elegui,g' support/pruned.pops_file.txt
sed -i 's,Heletumsur,elegui,g' support/pruned.pops_file.txt
sed -i 's,Heleauyven,elegui,g' support/pruned.pops_file.txt
sed -i 's,Helesfyven,elegui,g' support/pruned.pops_file.txt
sed -i 's,Hparbenbol,parama,g' support/pruned.pops_file.txt
sed -i 's,Hparcarbra,parama,g' support/pruned.pops_file.txt
sed -i 's,Hparlamper,parama,g' support/pruned.pops_file.txt
sed -i 's,Hparletcol,parama,g' support/pruned.pops_file.txt
sed -i 's,Hparoreecu,parama,g' support/pruned.pops_file.txt
sed -i 's,Hparpmdper,parama,g' support/pruned.pops_file.txt
sed -i 's,Hparpucper,parama,g' support/pruned.pops_file.txt
sed -i 's,Hparyurper,parama,g' support/pruned.pops_file.txt
sed -i 's,Heleautbra,eleama,g' support/pruned.pops_file.txt
sed -i 's,Helebenbol,eleama,g' support/pruned.pops_file.txt
sed -i 's,Helecarbra,eleama,g' support/pruned.pops_file.txt
sed -i 's,Helelbmbra,eleama,g' support/pruned.pops_file.txt
sed -i 's,Heleletcol,eleama,g' support/pruned.pops_file.txt
sed -i 's,Helenapecu,eleama,g' support/pruned.pops_file.txt
sed -i 's,Helepbeper,eleama,g' support/pruned.pops_file.txt
sed -i 's,Helepmdper,eleama,g' support/pruned.pops_file.txt
sed -i 's,Heleronbra,eleama,g' support/pruned.pops_file.txt
sed -i 's,Heleyurper,eleama,g' support/pruned.pops_file.txt



## easy SFS: convert to SFS  *******************************************************************************************
module load python/3.10.9-fasrc01
mamba activate easysfs
## convert to SFS
# determine best projection
~/software/demographicModelling/easySFS/easySFS.py \
    -a \
    -i 1.vcf/wgenome.dsites.pruned_${bkb}kb.vcf.gz \
    -p support/pruned.pops_file.txt \
    --preview 
# create SFS with down projection
~/software/demographicModelling/easySFS/easySFS.py \
    -f \
    -a \
    --unfolded \
    -i 1.vcf/wgenome.dsites.pruned_${bkb}kb.vcf.gz \
    -p support/pruned.pops_file.txt \
    --proj 8,40,40,20 \
    -o ${dataset}.dsites.pruned_${bkb}kb.multiSFS
mamba deactivate