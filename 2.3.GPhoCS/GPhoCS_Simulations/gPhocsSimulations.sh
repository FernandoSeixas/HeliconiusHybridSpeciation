## load modules
module load Java/1.8

## generate trees [msms]
java -Xmx1500M -jar /n/home12/fseixas/software/simulations/msms/lib/msms.jar \
    18 100 \
    -T \
    -I 3 8 8 2 \
    -ej 0.25 2 1 \
    -ej 1.0 3 1 \
    -m 1 2 0.1 \
    -m 2 1 0.1 \
    -r 0.0 1000 \
    -N 1000000 | grep ";" > msms_441_l1k_noRec_m0.100.txt

## generate sequences [Seq-gen]
# scaling rate is ginen by 4Neu (N is the N used in ms, and u is the mutation rate 2.9*10E-9)
partitions=$(wc -l msms_441_l1k_noRec_m0.100.txt)

/n/home12/fseixas/software/simulations/Seq-Gen/source/seq-gen \
    -mHKY \
    -l 1000 \
    -s 0.0116 \
    -p $partitions < msms_441_l1k_noRec_m0.100.txt | gzip > msms_441_l1k_noRec_m0.100.phy.gz

## convert to gphocs format
perl /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/seqgen2gphocs.v2.pl msms_441_l1k_noRec_m0.100.phy.gz 18 100 > msms_441_l1k_noRec_m0.100.seqs.txt

## run G-PhoCS
cp /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/gphocs.Simulations.3pops.ctl .
sed -i 's,alignment,msms_441_l1k_noRec_m0.100,g' gphocs.Simulations.3pops.ctl
sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/runGphocs.slurm gphocs.Simulations.3pops.ctl


## calculate Dxy and Fst
module load python/2.7.14-fasrc01
python ~/software/popgen/genomics_general/popgenWindows.py \
    -T 1 -f haplo \
    --analysis popDist popPairDist \
    --windType coordinate -w 1000 -s 1000 -m 1 --writeFailedWindows \
    --genoFile msms.Complex.m0.001.geno.gz \
    -o msms.Complex.m0.001.geno.gz.popdist.csv \
    -p P1 seq_1,seq_2,seq_3,seq_4,seq_5,seq_6,seq_7,seq_8 \
    -p P2 seq_9,seq_10,seq_11,seq_12,seq_13,seq_14,seq_15,seq_16 \
    -p P3 seq_17,seq_18