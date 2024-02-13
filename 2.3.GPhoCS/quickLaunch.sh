pop1=$1
pop2=$2
pop3=$3
setloc=$4
ctrfil=$5

trio=$pop1"_"$pop2"_"$pop3

export pop1=$pop1
export pop2=$pop2
export pop3=$pop3
export trio=$trio
export setloc=$setloc
export ctrlfl=$ctrlfl


mkdir $trio/
cp v0.failedRuns/$trio/autosomes.noColor.seqs.txt $trio/


## run Gphocs ===================================
cd $trio
pop1list=`grep $pop1 ../snpset1.samples.list | head -n 4 | xargs -n 1 sh -c ' printf "%s\t%s\t" $0 d' `
pop2list=`grep $pop2 ../snpset1.samples.list | head -n 4 | xargs -n 1 sh -c ' printf "%s\t%s\t" $0 d' `
pop3list=`grep $pop3 ../snpset1.samples.list | head -n 1 | xargs -n 1 sh -c ' printf "%s\t%s\t" $0 d' `
export pop1list=$pop1list
export pop2list=$pop2list
export pop3list=$pop3list

rm -r autoNoColor
mkdir autoNoColor
for i in `seq 1 3`; do
    mkdir autoNoColor/rep$i; 
    cd autoNoColor/rep$i;
    # seqs files
    cp ../../autosomes.noColor.seqs.txt .
    # ctl file
    cp ~/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/$ctrfil .
    sed -i "s,pop1samples,$pop1list,g" $ctrfil
    sed -i "s,pop2samples,$pop2list,g" $ctrfil
    sed -i "s,pop3samples,$pop3list,g" $ctrfil
    sed -i "s,alignment,autosomes.noColor,g" $ctrfil
    # run
    sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/runGphocs.slurm $ctrfil
    cd ../../
done 
