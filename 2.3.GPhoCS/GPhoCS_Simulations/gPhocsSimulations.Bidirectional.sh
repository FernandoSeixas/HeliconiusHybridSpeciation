## load modules
module load Java/1.8


## set parameters to simulate
TD1=$1
NEa=$2
NMg=$3

TD2=$(( $TD1 * 2 ))
newNMg=$(echo "4 * $NMg" | bc | awk '{printf "%.3f", $0}')
SET="Bidir.Td1_$TD1.Td2_$TD2.Ne_$NEa.Nm_$NMg"

export TD1=$TD1
export TD2=$TD2
export NEa=$NEa
export NMg=$NMg
export SET=$SET

echo $SET


## create dir
mkdir $SET
cd $SET

### generate trees [msms]
## -m is 4Nm: where N is defined by -N
#java -Xmx1500M -jar /n/home12/fseixas/software/simulations/msms/lib/msms.jar 18 100 \
#    -T \
#    -I 3 8 8 2 \
#    -ej $TD1 2 1 \
#    -ej $TD2 1 3 \
#    -n 1 $NEa \
#    -n 2 $NEa \
#    -n 3 0.4 \
#    -m 1 2 $NMg \
#    -m 2 1 $NMg \
#    -r 0 1000 \
#    -N 1000000 | grep ";" > msms.$SET.txt
#
### generate sequences [Seq-gen]
## scaling rate is ginen by 4Neu (N is the N used in ms, and u is the mutation rate 2.9*10E-9)
#partitions=$(wc -l msms.$SET.txt)
#
#/n/home12/fseixas/software/simulations/Seq-Gen/source/seq-gen \
#    -mHKY \
#    -l 1000 \
#    -s 0.0116 \
#    -p $partitions < msms.$SET.txt | gzip > msms.$SET.phy.gz
#
### convert to gphocs format
## this script converts the .phy file to g-phocs format, joining two haploid sequences into a diploid sequence (with IUPAC codes) - to perfectly mimic my dataset
## run as follows seqgen2gphocs.v2.pl [.phy] [number of haploid sequences] [number of loci]
#perl /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/seqgen2gphocs.v2.pl msms.$SET.phy.gz 18 100 > msms.$SET.seqs.txt


## run G-PhoCS - 3 replicate runs
for i in `seq 1 3`; do
    mkdir rep$i; 
    cd rep$i;
    # 
    cp ../msms.*.seqs.txt .
    # ctrl file 
    cp /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/gphocs.Simulations.3pops.ctl .
    sed -i "s,alignment,msms.$SET,g" gphocs.Simulations.3pops.ctl
    # launch run
    sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/gphocs/Simulations/runGphocs.Sims.slurm gphocs.Simulations.3pops.ctl
    cd ..
done
