## Create directories
mkdir 1.varSites
mkdir 2.genofrtm
mkdir 3.afd_nfix


## Define parameters to run
pair="melspp-elesym"                ; export pair=$pair
bspace=1000                         ; export bspace=$bspace
afd="0.80"                          ; export afd=$afd
afdcode=`echo $afd | sed 's,\.,,g' `; export afdcode=$afdcode


## Get allelic differences
cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt | \
    xargs -n 1 sh -c '
    sbatch nearfix.v2.2-afd.slurm \
    $0 \
    $pair \
    $bspace \
    $afd
'

## Concatenate all chromosomes
head -n 1 3.afd_nfix/Hmel201001o.afd_${afdcode}_bp${bspace}.nomiss.gt.txt > wgenome.afd_${afdcode}_bp${bspace}.nomiss.gt.txt
cat 3.afd_nfix/Hmel2??00?o.afd_${afdcode}_bp${bspace}.nomiss.gt.txt | egrep -v "CHROM" >> wgenome.afd_${afdcode}_bp${bspace}.nomiss.gt.txt
wc -l wgenome.afd_${afdcode}_bp${bspace}.nomiss.gt.txt

