
prefix=$1

#/ resume failed runs (if necessary) 
lmcmc=$(wc -l 5.2.bpp/$prefix.mcmc.list | awk '{ print $1}');
echo $lmcmc

if [ $lmcmc -eq 100001 ]
then 
    echo $prefix; 
    # mkdir 5.2.bpp/$prefix
    mv 5.2.bpp/$prefix.*chk 5.2.bpp/$prefix/
    mv 5.2.bpp/$prefix.*  5.2.bpp/finished/
    # rm  5.2.bpp/finished/$prefix.*.chk
# else
#     printf "%s\t" $prefix;
#     chk=`ls 5.2.bpp/$prefix*.chk | sort -V | tail -n 1`;
#     echo $chk;
#     sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/BPP/bpp_Resume.slurm $chk;
#     cd ../../
fi

