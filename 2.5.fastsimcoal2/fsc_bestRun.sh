## Select best run and calculate AIC

#/ load modules
# module load R/4.0.2-fasrc01
module load R/4.3.1-fasrc01
export R_LIBS_USER=$HOME/apps/R_4.0.2:$R_LIBS_USER

#/ Arguments
echo $1
prefix=$1; export prefix=$prefix

#/ Determine best run
cd $prefix
bash ~/code/heliconius_seixas/2.elevatus_pardalinus/3.Demography/demographicModelling/fsc-selectbestrun.sh
cat bestrun/*.bestlhoods

#/ calculate AIC
cd bestrun
printf "\n" >> $prefix.est
Rscript ~/code/heliconius_seixas/2.elevatus_pardalinus/3.Demography/demographicModelling/calculateAIC.R ${prefix}
cd ../../