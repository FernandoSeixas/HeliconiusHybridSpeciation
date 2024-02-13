#!/bin/bash


## load modules **************************************
module load gcc/10.2.0-fasrc01 openmpi/4.1.0-fasrc01


## variables *****************************************
prefix=$1;                     export prefix=$prefix
bkb=$2;                        export bkb=$bkb
replic=${SLURM_ARRAY_TASK_ID}; export replic=$replic
echo $prefix
echo $replic
echo $bkb

## run fastsimcoal ***********************************

# copy fsc input files
rm -r run${replic}
mkdir run${replic}
cp ${prefix}.tpl run${replic}/
cp ${prefix}.est run${replic}/

# copy observed msfs
cp ../elepar.set01.dsites.pruned_${bkb}kb.multiSFS/fastsimcoal2/wgenome_MSFS.obs run${replic}/
mv run${replic}/wgenome_MSFS.obs run${replic}/${prefix}_DSFS.obs

# run fastsimcoal / unfolded sfs (dsfs)
cd run$replic
~/software/demographicModelling/fsc27_linux64/fsc2702 \
    --cores 8 \
    --numBatches 16 \
    -t ${prefix}.tpl \
    -e ${prefix}.est \
    --multiSFS \
    --dsfs \
    -n 100000 \
    --minSFSCount 1 \
    -L 40 -s 0 -M
cd ../

