## load modules
module load python/2.7.14-fasrc01


## input variables
prefix=$1
pop1=$2
pop2=$3

## get individuals list
pop1ls=`grep $pop1 ../snpset1.samples.list | head -n 4 | xargs -n 1 sh -c ' printf "%s," $0' `
pop1ls=`grep $pop2 ../snpset1.samples.list | head -n 4 | xargs -n 1 sh -c ' printf "%s," $0' `
export pop1list=$pop1list
export pop2list=$pop2list


## convert to geno format
python ~/software/popgen/genomics_general/seqToGeno.py \
    --seqFile $prefix.phy.gz \
    --format phylip \
    --genoFile $prefix.geno.gz

## run popgenWindows
python ~/software/popgen/genomics_general/popgenWindows.py \
    -T 1 -f haplo \
    --analysis popDist popPairDist \
    --windType coordinate -w 1000 -s 1000 -m 1 --writeFailedWindows \
    --genoFile $prefix.geno.gz \
    -o $prefix.popdist.csv \
    -p P1 seq_1,seq_2,seq_3,seq_4,seq_5,seq_6,seq_7,seq_8 \
    -p P2 seq_9,seq_10,seq_11,seq_12,seq_13,seq_14,seq_15,seq_16 \
    -p P3 seq_17,seq_18
