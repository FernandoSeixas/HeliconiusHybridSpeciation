prefix=$1
maxrep=$2
export prefix=$prefix
export maxrep=$maxrep

for repl in `seq 1 $maxrep`; do
    file="${prefix}/run${repl}/${prefix}/${prefix}.brent_lhoods"
    # printf "%s\t" $file;
    awk '{if ($1 == 0) print}' $file | wc -l
done