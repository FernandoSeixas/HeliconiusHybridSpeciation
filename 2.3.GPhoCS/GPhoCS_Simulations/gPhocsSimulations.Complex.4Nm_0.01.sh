## load modules
module load Java/1.8

mkdir Complex.m0.000001
cd Complex.m0.000001

## generate trees [msms]
#    -en 0.26 1 1.0 \
# -m is 4Nm: where N is defined by -N
java -Xmx1500M -jar /n/home12/fseixas/software/simulations/msms/lib/msms.jar 18 100 \
    -T \
    -I 3 8 8 2 \
    -ej 0.25 2 1 \
    -ej 1.0 1 3 \
    -n 1 2.0 \
    -n 2 2.0 \
    -n 3 2.0 \
    -m 1 2 0.01 \
    -m 2 1 0.01 \
    -r 0 1000 \
    -N 1000000 | grep ";" > msms.Complex.m0.000001.txt

## generate sequences [Seq-gen]
# scaling rate is ginen by 4Neu (N is the N used in ms, and u is the mutation rate 2.9*10E-9)
partitions=$(wc -l msms.Complex.m0.000001.txt)

/n/home12/fseixas/software/simulations/Seq-Gen/source/seq-gen \
    -mHKY \
    -l 1000 \
    -s 0.0116 \
    -p $partitions < msms.Complex.m0.000001.txt | gzip > msms.Complex.m0.000001.phy.gz

## convert to gphocs format
perl /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/seqgen2gphocs.v2.pl msms.Complex.m0.000001.phy.gz 18 100 > msms.Complex.m0.000001.seqs.txt

## run G-PhoCS
cp /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gphocs.Simulations.3pops.ctl .
sed -i 's,alignment,msms.Complex.m0.000001,g' gphocs.Simulations.3pops.ctl
sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/runGphocs.slurm gphocs.Simulations.3pops.ctl


#tail -n 1 Complex.m0.000001/mcmc.log | sed 's,\t\t,\t,g'
