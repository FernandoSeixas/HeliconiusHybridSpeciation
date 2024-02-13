## load modules
module load Java/1.8

cd LargePops

## generate trees [msms]
java -Xmx1500M -jar /n/home12/fseixas/software/simulations/msms/lib/msms.jar \
    18 100 \
    -T \
    -I 3 8 8 2 \
    -ej 0.25 2 1 \
    -ej 1.0 3 1 \
    -n 1 3.0 \
    -n 2 3.0 \
    -m 1 2 0.1 \
    -m 2 1 0.1 \
    -r 0.0 1000 \
    -N 1000000 | grep ";" > msms_441_l1k_noRec_m0.100.LargePops.txt

## generate sequences [Seq-gen]
# scaling rate is ginen by 4Neu (N is the N used in ms, and u is the mutation rate 2.9*10E-9)
partitions=$(wc -l msms_441_l1k_noRec_m0.100.LargePops.txt)

/n/home12/fseixas/software/simulations/Seq-Gen/source/seq-gen \
    -mHKY \
    -l 1000 \
    -s 0.0116 \
    -p $partitions < msms_441_l1k_noRec_m0.100.LargePops.txt | gzip > msms_441_l1k_noRec_m0.100.LargePops.phy.gz

## convert to gphocs format
perl /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/seqgen2gphocs.v2.pl msms_441_l1k_noRec_m0.100.LargePops.phy.gz 18 100 > msms_441_l1k_noRec_m0.100.LargePops.seqs.txt

## run G-PhoCS
cp /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/gphocs.Simulations.3pops.ctl .
sed -i 's,alignment,msms_441_l1k_noRec_m0.100.LargePops,g' gphocs.Simulations.3pops.ctl
sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/runGphocs.slurm gphocs.Simulations.3pops.ctl


tail -n 1 LargePops/mcmc.log | sed 's,\t\t,\t,g'