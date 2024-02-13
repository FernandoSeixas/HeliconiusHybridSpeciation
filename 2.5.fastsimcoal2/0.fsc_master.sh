## Prepare dataset *****************************************************************************************************
bash 1.prepareSFS_monoSites.sh


## Launch analyses *****************************************************************************************************
#/ Tree1
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_SI_simple
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_AM_simple
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_AM_complex
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_SC_simple
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_SC_complex1
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_SC_complex2
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_AMpSC_simple
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_AMpSC_complex1
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_AMpSC_complex2
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_IM_simple
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_IM_complex1
bash 2.launch.fastsimcoal.sh tree1 4pops_tree1_IM_complex2
#/ Tree2
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_SI_simple
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_AM_simple
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_AM_complex
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_SC_simple
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_SC_complex1
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_SC_complex2
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_AMpSC_simple
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_AMpSC_complex1
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_AMpSC_complex2
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_IM_simple
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_IM_complex1
bash 2.launch.fastsimcoal.sh tree2 4pops_tree2_IM_complex2


##### Progress & Collect Data ******************************************************************************************
tre="tree1"
#/ check progress (specific model)
cat ${tre}.models.txt | xargs -n 1 sh -c '
    printf "%s\t" $0;
    ls -d $0/run* | wc -l 
' 
cat ${tre}.models.txt | xargs -n 1 sh -c '
    printf "%s\t" $0;
    bash checkProgress.sh $0 100 | sort -n | uniq -c | egrep 40 
'
cat ${tre}.models.txt | xargs -n 1 sh -c '
    echo $0
    prefix=$0
    bash checkProgress.sh $prefix 100 > $prefix.progress
'



## Best Runs, AIC and likelihood distribution **************************************************************************

## Determine the 'Best Run' & get AIC for that run
cat all.models.txt | xargs -n 1 -P 1 sh -c '
    bash fsc_bestRun.sh $0
'

## Model Likelihood distributions 
#/ to account for the stochasticity in the likelihood approximation run each model 100 times with the best parameter 
#/ values - get likelihood distribution then check if there is an overlap of llhood distributions between different
#/ models
cat all.models.txt | xargs -n 1 sh -c '
    sbatch llhood-distribution.slurm $0
'



## Compare different models ********************************************************************************************
mkdir modelComparisons
cd modelComparisons
## AIC comparisons
printf '%s\t%s\t%s\n' "Model" "deltaL" "AIC" > allmodels.AIC
for i in ../4pops*/bestrun/*AIC; do
    echo -e `basename $i`"\t"`tail -n 1 $i` >> allmodels.AIC;
done
cat allmodels.AIC | sort -k3,3n > tmp; mv tmp allmodels.AIC
## Likelihood distribution comparisons
mkdir llhoods
for file in `ls ../4pops*/bestrun/*.lhoods`; do 
    cp $file llhoods/ ;
done



## Parameter estimates uncertainty:: block-bootstrapping ***************************************************************

## Run the following script
# prefix: dataset prefix (e.g. wgenome.dsites.pruned_1kb)
# bmodel: best model (e.g. 4pops_tree1_AMpSC_complex1)
prefix="wgenome.dsites.pruned_1kb"
bmodel="4pops_tree1_AMpSC_complex1"
bash 4.bootsrap_CI.sh \
    $prefix \
    $bmodel



##### Determine the 'Best Run' & get AIC for that run ******************************************************************
tre="tree1"
cat ${tre}.models.txt | xargs -n 1 sh -c ' bash fsc_bestRun.sh $0 '
#/ load modules
module load R/4.0.2-fasrc01
export R_LIBS_USER=$HOME/apps/R_4.0.2:$R_LIBS_USER
#/ determine best run and AIC
ls -d 4pops_* | egrep "4pops_tree1_AMpSC_complex1" | head -n 1  | xargs -n 1 sh -c '
    echo $0
    prefix=$0; export prefix=$prefix
    cd $prefix
    # determine best run
    bash fsc-selectbestrun.sh
    cat bestrun/*.bestlhoods
    # calculate AIC
    cd bestrun
    printf "\n" >> $prefix.est
    Rscript calculateAIC.R ${prefix}
    cd /n/holyscratch01/mallet_lab/fseixas/2.elepar/analyses/demographicModelling
'



#### Model Likelihood distributions **************************************************************************************
#/ to account for the stochasticity in the likelihood approximation
#/ run each model 100 times with the best parameter values - get likelihood distribution
#/ then check if there is an overlap of llhood distributions between different models
# chose model
tre="tree1"
cat ${tre}.models.txt | xargs -n 1 sh -c ' sbatch llhood-distribution.slurm $0 '
# tree 1
sbatch llhood-distribution.slurm 4pops_tree1_SI_simple
sbatch llhood-distribution.slurm 4pops_tree1_AM_simple
sbatch llhood-distribution.slurm 4pops_tree1_AM_complex
sbatch llhood-distribution.slurm 4pops_tree1_SC_simple
sbatch llhood-distribution.slurm 4pops_tree1_SC_complex1
sbatch llhood-distribution.slurm 4pops_tree1_SC_complex2
sbatch llhood-distribution.slurm 4pops_tree1_AMpSC_simple
sbatch llhood-distribution.slurm 4pops_tree1_AMpSC_complex1
sbatch llhood-distribution.slurm 4pops_tree1_AMpSC_complex2
sbatch llhood-distribution.slurm 4pops_tree1_IM_simple
sbatch llhood-distribution.slurm 4pops_tree1_IM_complex1
sbatch llhood-distribution.slurm 4pops_tree1_IM_complex2
# tree 2
sbatch llhood-distribution.slurm 4pops_tree2_SI_simple
sbatch llhood-distribution.slurm 4pops_tree2_AM_simple
sbatch llhood-distribution.slurm 4pops_tree2_AM_complex
sbatch llhood-distribution.slurm 4pops_tree2_SC_simple
sbatch llhood-distribution.slurm 4pops_tree2_SC_complex1
sbatch llhood-distribution.slurm 4pops_tree2_SC_complex2
sbatch llhood-distribution.slurm 4pops_tree2_AMpSC_simple
sbatch llhood-distribution.slurm 4pops_tree2_AMpSC_complex1
sbatch llhood-distribution.slurm 4pops_tree2_AMpSC_complex2
sbatch llhood-distribution.slurm 4pops_tree2_IM_simple
sbatch llhood-distribution.slurm 4pops_tree2_IM_complex1
sbatch llhood-distribution.slurm 4pops_tree2_IM_complex2



## Compare different models ********************************************************************************************
mkdir 2.fastsimcoal/modelComparisons
cd 2.fastsimcoal
cd modelComparisons
## AIC comparisons
printf '%s\t%s\t%s\n' "Model" "deltaL" "AIC" > allmodels.AIC
for i in ../*/bestrun/*AIC; do    
    echo -e `basename $i`"\t"`tail -n 1 $i` >> allmodels.AIC;
done
cat allmodels.AIC | sort -k3,3n > tmp; mv tmp allmodels.AIC
## Likelihood distribution comparisons
for file in `ls ../*/bestrun/*.lhoods`; do    
    cp $file .;
done



## Parameter estimates uncertainty // block-bootstrapping **************************************************************
bash bootsrap_CI.sh



## Plot best demographic model (with parameter estimates) **************************************************************
prefix="4pops_tree1_AMpSC_complex1"
export prefix=$prefix
#
# Rscript plotModel.r -d ${prefix}/bestrun/ -p ${prefix} -l parser,parama,eleama,elegui
# plot demographic model
module load R/4.0.2-fasrc01
export R_LIBS_USER=$HOME/apps/R_4.0.2:$R_LIBS_USER
Rscript ~/software/simulations/fsc26_linux64/ParFileInterpreter-v6.3.r ${prefix}/bestrun/${prefix}.par




