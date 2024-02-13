## Input arguments
tree=$1; export tree=$tree
pref=$2; export pref=$pref

## Arguments
nhap1="8" ; export nhap1=$nhap1
nhap2="40"; export nhap2=$nhap2
nhap3="40"; export nhap1=$nhap1
nhap4="20"; export nhap2=$nhap2
buff=1000; bkb=`echo $(($buff / 1000))`; export bkb=$bkb

## copy & change necessary files
# rm -r ${pref}
mkdir ${pref}
cd ${pref}
cp ~/code/heliconius_seixas/2.elevatus_pardalinus/3.Demography/demographicModelling/models/${tree}/${pref}.tpl .
cp ~/code/heliconius_seixas/2.elevatus_pardalinus/3.Demography/demographicModelling/models/${tree}/${pref}.est .
sed -i "s,pop1inds,$nhap1,g" ${pref}.tpl
sed -i "s,pop2inds,$nhap2,g" ${pref}.tpl
sed -i "s,pop3inds,$nhap3,g" ${pref}.tpl
sed -i "s,pop4inds,$nhap4,g" ${pref}.tpl
mkdir logs

## run different fsc replicates
sbatch --array=1-100%50 ~/code/heliconius_seixas/2.elevatus_pardalinus/3.Demography/demographicModelling/2.runfsc.slurm ${pref} ${bkb}
cd ..

