#!/bin/bash
#SBATCH -n 8                      # Number of cores requested
#SBATCH -N 1                      # Ensure that all cores are on one machine
#SBATCH -t 180                    # Runtime in minutes
#SBATCH -p serial_requeue         # Partition to submit to
#SBATCH --mem-per-cpu=200         # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append        #
#SBATCH -o sfsdist_%j.out         # Standard out goes to this file
#SBATCH -e sfsdist_%j.err         # Standard err goes to this filehostname



#### Model Likelihood distributions **************************************************************************************
#/ to account for the stochasticity in the likelihood approximation
#/ run each model 100 times with the best parameter values - get likelihood distribution
#/ then check if there is an overlap of llhood distributions between different models
# chose model

prefix=$1; export prefix=$prefix
cd $prefix 
cd bestrun

# Run fastsimcoal 100 times to get the likelihood of the observed SFS under the best parameter values with 1 million simulated SFS.
rm ${prefix}.lhoods
seq 1 100 | xargs -n 1 -P 8 sh -c '
    # create dir & copy necessary files
    mkdir iter${0};
    cd iter${0};
    cp ../${prefix}_DSFS.obs ${prefix}.iter${0}_maxL_DSFS.obs
    cp ../${prefix}_maxL.par ${prefix}.iter${0}_maxL.par
    # fsc
    ~/software/demographicModelling/fsc27_linux64/fsc2702 \
    --cores 1 \
    -i ${prefix}.iter${0}_maxL.par \
    --multiSFS \
    --dsfs \
    -n 1000000 \
    --quiet \
    # Fastsimcoal will generate a new folder called ${model}_maxL and write files in there
    # collect the lhood values (Note that >> appends to the file, whereas > would overwrite it)
    sed -n '2,3p' ${prefix}.iter${0}_maxL/${prefix}.iter${0}_maxL.lhoods >> ../${prefix}.lhoods
    # delete the folder with results
    cd ..
    rm -r iter${0}
'
cd ../../