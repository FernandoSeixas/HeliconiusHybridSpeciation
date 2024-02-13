## Script to parse all runs and 
# 1. check if all finished, resume if not
# 2. move finsihed runs to a specific folder


sed -i 's,mcmcfile = ,mcmcfile = 5.2.bpp/,g' 5.2.bpp/$0/$0.ctl

for prefix in `ls -d 5.2.bpp/* | sed 's,5.2.bpp/,,g' `; do
    echo $prefix
    sed -i 's,outfile = ,outfile = 5.2.bpp/,g' 5.2.bpp/$prefix/$prefix.ctl
    sed -i 's,mcmcfile = ,mcmcfile = 5.2.bpp/,g' 5.2.bpp/$prefix/$prefix.ctl
done

for prefix in `ls -d 5.2.bpp/* | egrep Hmel201001o.block_01.rep1 | sed 's,5.2.bpp/,,g' `; do
    echo $prefix
    mv 5.2.bpp/$prefix/* 5.2.bpp/
done


#/ Move final files to finalized folder
mkdir 5.2.bpp/finished/
ls 5.2.bpp/*mcmc.list |  sed 's,5.2.bpp/,,g' | sed 's,.mcmc.list,,g' | xargs -n 1 -P 1 sh -c '
    bash ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/bpp01/checkpointBlock.sh $0
'
#/ Move all mcmc/out files to 5.2.bpp 
mv 5.2.bpp/finished/*out.txt 5.2.bpp/
mv 5.2.bpp/finished/*mcmc.list 5.2.bpp/
rmdir 5.2.bpp/finished/
ls 5.2.bpp/*.mcmc.list | xargs -n 1 -P 8 sh -c 'gzip $0'

#/ concatenate output files // tree Counts
rm bpp_block_treeCounts.txt
ls 5.2.bpp/*out* | xargs -n 1 -P 8 sh -c 'perl /n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/BPP/parseBPP_output.pl $0 >> bpp_block_treeCounts.txt'
sort -k1,1 -k3,3nr bpp_block_treeCounts.txt > tmp
mv tmp bpp_block_treeCounts.txt
less bpp_block_treeCounts.txt




#/ Check state of runs 
for pref in `ls 5.2.bpp/*mcmc.list | sed 's,.mcmc.list,,g' | sed 's,5.2.bpp/,,g' `; do
    lmcmc=$(wc -l 5.2.bpp/$pref.mcmc.list | awk '{ print $1}');
    printf "%s\t%s\n" $pref $lmcmc;
done 

rm countByScaffold.txt
ls 5.2.bpp/*rep1.mcmc* | sed 's,5.2.bpp/,,g' | sed 's,.rep1.mcmc.list.gz,,g' | cut -d'.' -f1 | uniq -c | awk '{print $2,$1}' >  countByScaffold.txt
ls 5.2.bpp/*rep2.mcmc* | sed 's,5.2.bpp/,,g' | sed 's,.rep2.mcmc.list.gz,,g' | cut -d'.' -f1 | uniq -c | awk '{print $2,$1}' >> countByScaffold.txt
ls 5.2.bpp/*rep3.mcmc* | sed 's,5.2.bpp/,,g' | sed 's,.rep3.mcmc.list.gz,,g' | cut -d'.' -f1 | uniq -c | awk '{print $2,$1}' >> countByScaffold.txt
cat countByScaffold.txt

