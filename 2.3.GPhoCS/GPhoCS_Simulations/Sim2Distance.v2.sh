## load modules
module load python/2.7.14-fasrc01


## input variables
prefix=$1
pop1=$2
pop2=$3

## get individuals list
pop1ls=`grep $pop1 ../snpset1.samples.list | head -n 4 | xargs -n 1 sh -c ' printf "%s," $0 ' | sed 's/\(.*\),/\1/' `
pop2ls=`grep $pop2 ../snpset1.samples.list | head -n 4 | xargs -n 1 sh -c ' printf "%s," $0 ' | sed 's/\(.*\),/\1/' `
export pop1ls=$pop1ls
export pop2ls=$pop2ls


grep $pop1 ../snpset1.samples.list | head -n 4 | xargs -n 1 sh -c ' printf "%s," $0 ' | sed 's/\(.*\),/\1 /'

## convert to geno format
python genomics_general/seqToGeno.py \
    --seqFile $prefix.phy.gz \
    --format fasta \
    --genoFile $prefix.geno.gz

## run popgenWindows
python ~/software/popgen/genomics_general/popgenWindows.py \
    -T 1 -f diplo \
    --analysis popDist popPairDist \
    --windType coordinate -w 1000 -s 1000 -m 1 --writeFailedWindows \
    --genoFile $prefix.geno.gz \
    -o $prefix.popdist.csv \
    -p P1 $pop1ls \
    -p P2 $pop2ls





tail -n+2 autosomes.noColor.seqs.txt > test.seqs.txt



prefix="test"
pop1="Hparyurper"
pop2="Hbessppbra"

## get individuals list
pop1ls=`grep $pop1 ../snpset1.samples.list | head -n 4 | xargs -n 1 sh -c ' printf "%s," $0 ' | sed 's/\(.*\),/\1/' `
pop2ls=`grep $pop2 ../snpset1.samples.list | head -n 4 | xargs -n 1 sh -c ' printf "%s," $0 ' | sed 's/\(.*\),/\1/' `
export pop1ls=$pop1ls
export pop2ls=$pop2ls

python ~/software/popgen/genomics_general/seqToGeno.py \
    --seqFile 2.fastaFilter/Hmel201001o.11052151.11053150.filter.fasta \
    --format fasta \
    --genoFile $prefix.geno.gz

echo python ~/software/popgen/genomics_general/popgenWindows.py \
    -T 1 -f diplo \
    --analysis popDist popPairDist \
    --windType coordinate -w 1000 -s 1000 -m 1 --writeFailedWindows \
    --genoFile $prefix.geno.gz \
    -o $prefix.popdist.csv \
    -p P1 $pop1ls \
    -p P2 $pop2ls

