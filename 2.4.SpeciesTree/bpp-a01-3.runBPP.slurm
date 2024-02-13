#!/bin/bash
#SBATCH -n 8                              # Number of cores requested
#SBATCH -N 1                              # Ensure that all cores are on one machine
#SBATCH -t 300                            # Runtime in minutes
#SBATCH -p serial_requeue,shared          # Partition to submit to
#SBATCH --mem-per-cpu=1000                # Memory per cpu in MB (see also --mem-per-cpu)
#SBATCH --open-mode=append               
#SBATCH -o BPP_%j.out                     # Standard out goes to this file
#SBATCH -e BPP_%j.err                     # Standard err goes to this filehostname


## Run BPP analysis in blocks ******************************************************************************************

## set variables & export
#/ sgroup: string with codes of species to analyze separated by "_" (e.g. ser_par_ele_gui)
#/ nblock: number of loci per block (e.g. 50)
slocus=$1; export slocus=$slocus
sgroup=$2; export sgroup=$sgroup
refnam="hmelv25"; export refnam=$refnam
nlocus="100"; export nlocus=$nlocus
nblock="block${nlocus}"; export nblock=$nblock

#/ bpp details
#/ sline: species line (e.g. 6 ismout melgui pargp1 pargp3 elegp3 elegp1)
#/ iline: individuals/pop line (e.g. 1 3 3 3 3 3)
#/ tline1: initial tree rep1 - e.g  "(melgui,(ismout,((pargp1,pargp3),(elegp3,elegp1))));" 
#/ tline2: initial tree rep2 - e.g  "(melgui,(ismout,((pargp1,elegp3),(pargp3,elegp1))));" 
#/ tline3: initial tree rep3 - e.g  "(melgui,(ismout,((pargp1,elegp1),(pargp3,elegp3))));" 
sline=$3;  export sline=$sline 
iline=$4;  export iline=$iline 
tline1=$5; export tline1=$tline1 
tline2=$6; export tline2=$tline2 
tline3=$7; export tline3=$tline3 


# create directories
cd bpp-a01-${sgroup}-${slocus}
mkdir 5.0.blocks/
mkdir 5.1.blocksAlign/
mkdir 5.2.bpp
mkdir logs

## Prepare blocks of loci **********************************************************************************************

rm 5.0.blocks/*
rm 5.1.blocksAlign/*
rm 5.2.bpp/*

#/ list loci to concatenate
cd 4.bppFormat
ls *.bpp.fasta > ../finalLoci.list
cd ..
sed 's,\.,\t,g' finalLoci.list | sort -k1,1 -k2,2n | sed 's,\t,.,g' > tmp; mv tmp finalLoci.list

#/ determine blocks of loci
for scaff in `cat /n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaff_in_chrom.txt`; do
    grep $scaff finalLoci.list > $scaff.tmp
    split -l ${nlocus} --numeric-suffixes=1 $scaff.tmp 5.0.blocks/$scaff.block\_;
    rm $scaff.tmp
done

#/ separate loci within chr15 inversion
chr15_iSta=1356511;
chr15_iEnd=1757545;
ls 4.bppFormat/Hmel215*.bpp.fasta > chr15.loci
sed 's,4.bppFormat/,,g' chr15.loci | sed 's,\.,\t,g' | sort -k1,1 -k2,2n | \
    awk '{ 
        if ($3 < 1356511) print $0, "chr15a"
        else if ($2 <= 1757545 && $3 >= 1356511) print $0, "chr15b"
        if ($2 > 1757545) print $0, "chr15c"
        }
    ' |
    sed 's,\t,.,g' > tmp
grep chr15a tmp | sed 's, chr15a,,g' > chr15a.loci 
grep chr15b tmp | sed 's, chr15b,,g' > chr15b.loci 
grep chr15c tmp | sed 's, chr15c,,g' > chr15c.loci 
rm tmp
# split chr15 into blocks - non-inversion vs inversion (part a,b,c)
split -l $nlocus --numeric-suffixes=1 chr15a.loci 5.0.blocks/Hmel215003a.block\_;
blocka=`ls 5.0.blocks/Hmel215003a.block* | wc -l`
blocka=$((blocka + 1))
split -l $nlocus --numeric-suffixes=$blocka chr15b.loci 5.0.blocks/Hmel215003b.block\_;
blockb=`ls 5.0.blocks/Hmel215003b.block* | wc -l`
blockb=$((blocka + $blockb))
split -l $nlocus --numeric-suffixes=$blockb chr15c.loci 5.0.blocks/Hmel215003c.block\_;
# remove excessive files
rm 5.0.blocks/Hmel215003o.block*
rm chr15.loci 
rm chr15a.loci 
rm chr15b.loci 
rm chr15c.loci 
rm finalLoci.list

#/ Collapse blocks at the end of chromosomes when too few loci
rm locusList.txt
ls 5.0.blocks/* | xargs -n 1 -P 1 sh -c '
    nlocus=`grep Hmel $0 | wc -l`
    printf "%s\t%s\n" $0 $nlocus >> locusList.txt;
'

#// Note: this code only works when blocks with less than [min] alignments occur at the end of the chromosome (last block) 
for scaff in `ls 5.0.blocks/ | cut -d'.' -f1 | uniq `; do
    egrep ${scaff} locusList.txt | awk -v min=50 '$2 < min {printf "%s\n%s\n",f,$1} {f=$1}' > toMerge.txt
    # define new name of files to concatenate: 1st in list
    newnam=$(head -n 1 toMerge.txt)
    todrop=$(tail -n 1 toMerge.txt)
    echo $newnam
    echo $todrop
    # concatenate files and remove unnecessary ones (last)
    for file in `cat toMerge.txt`; do cat $file >> tmp; done
    mv tmp $newnam
    rm $todrop
done

#/ correct block numbers // applies to chromosome 15
cblock=1
for n in `ls 5.0.blocks/Hmel215*`; do
    # echo $n;
    bname=$(echo $n | cut -d'_' -f1)
    cb=$( printf "%02g" $cblock)
    nname=$( printf "%s_%s\n" $bname $cb )
    cblock=$( expr $cblock + 1 )
    mv $n $nname
done

#/ Concatenate alignments in the same block
rm 5.1.blocksAlign/*.seqs.txt;
for block in `ls 5.0.blocks/* | sed 's,5.0.blocks/,,g' `; do
    echo $block;
    cat 5.0.blocks/${block} | xargs -n 1 sh -c 'cat 4.bppFormat/$0' >> 5.1.blocksAlign/${block}.seqs.txt;
done


## Prepare imap file ***************************************************************************************************
cp ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/bpp-a01-${sgroup}.popmap.txt ${sgroup}.imap.list


## Prepare control files ***********************************************************************************************
rm BPP_A01.LociSummary.txt

ls 5.0.blocks/* | sed 's,5.0.blocks/,,g' | xargs -n 1 -P 1 sh -c '
    echo $0;
    mkdir 5.2.bpp/$0.rep1
    mkdir 5.2.bpp/$0.rep2
    mkdir 5.2.bpp/$0.rep3
    nlocus=`grep -v Hmel 5.1.blocksAlign/$0.seqs.txt | wc -l`
    # print number of loci
    printf "%s\t%s\n" $0 $nlocus >> BPP_A01.LociSummary.txt;
    # prepare control files 
    cp bpp-a01.ctl 5.2.bpp/$0.rep1/$0.rep1.ctl
    cp bpp-a01.ctl 5.2.bpp/$0.rep2/$0.rep2.ctl
    cp bpp-a01.ctl 5.2.bpp/$0.rep3/$0.rep3.ctl
    # specify number of loci
    sed -i "s,numberLoci,$nlocus,g" 5.2.bpp/$0.rep1/$0.rep1.ctl
    sed -i "s,numberLoci,$nlocus,g" 5.2.bpp/$0.rep2/$0.rep2.ctl
    sed -i "s,numberLoci,$nlocus,g" 5.2.bpp/$0.rep3/$0.rep3.ctl
    # specify alignments file
    sed -i "s,seqs.txt,5.1.blocksAlign/$0.seqs.txt,g" 5.2.bpp/$0.rep1/$0.rep1.ctl
    sed -i "s,seqs.txt,5.1.blocksAlign/$0.seqs.txt,g" 5.2.bpp/$0.rep2/$0.rep2.ctl
    sed -i "s,seqs.txt,5.1.blocksAlign/$0.seqs.txt,g" 5.2.bpp/$0.rep3/$0.rep3.ctl
    # specify output file
    sed -i "s,outp.txt,5.2.bpp/$0.rep1.out.txt,g" 5.2.bpp/$0.rep1/$0.rep1.ctl
    sed -i "s,outp.txt,5.2.bpp/$0.rep2.out.txt,g" 5.2.bpp/$0.rep2/$0.rep2.ctl
    sed -i "s,outp.txt,5.2.bpp/$0.rep3.out.txt,g" 5.2.bpp/$0.rep3/$0.rep3.ctl
    # specify imap file
    sed -i "s,imap.txt,${sgroup}.imap.list,g" 5.2.bpp/$0.rep1/$0.rep1.ctl
    sed -i "s,imap.txt,${sgroup}.imap.list,g" 5.2.bpp/$0.rep2/$0.rep2.ctl
    sed -i "s,imap.txt,${sgroup}.imap.list,g" 5.2.bpp/$0.rep3/$0.rep3.ctl
    # specify 
    sed -i "s,mcmc.txt,5.2.bpp/$0.rep1.mcmc.list,g" 5.2.bpp/$0.rep1/$0.rep1.ctl
    sed -i "s,mcmc.txt,5.2.bpp/$0.rep2.mcmc.list,g" 5.2.bpp/$0.rep2/$0.rep2.ctl
    sed -i "s,mcmc.txt,5.2.bpp/$0.rep3.mcmc.list,g" 5.2.bpp/$0.rep3/$0.rep3.ctl
    # replace species line
    sed -i "s/sppline/${sline}/g" 5.2.bpp/$0.rep1/$0.rep1.ctl
    sed -i "s/sppline/${sline}/g" 5.2.bpp/$0.rep2/$0.rep2.ctl
    sed -i "s/sppline/${sline}/g" 5.2.bpp/$0.rep3/$0.rep3.ctl
    # replace individual count line
    sed -i "s/indline/${iline}/g" 5.2.bpp/$0.rep1/$0.rep1.ctl
    sed -i "s/indline/${iline}/g" 5.2.bpp/$0.rep2/$0.rep2.ctl
    sed -i "s/indline/${iline}/g" 5.2.bpp/$0.rep3/$0.rep3.ctl
    # replace tree line
    sed -i "s/treline/${tline1}/g" 5.2.bpp/$0.rep1/$0.rep1.ctl
    sed -i "s/treline/${tline2}/g" 5.2.bpp/$0.rep2/$0.rep2.ctl
    sed -i "s/treline/${tline3}/g" 5.2.bpp/$0.rep3/$0.rep3.ctl
'


ls 5.0.blocks/* | sed 's,5.0.blocks/,,g' | xargs -n 1 -P 8 sh -c '
    echo $0;
    nlocus=`grep -v Hmel 5.1.blocksAlign/$0.seqs.txt | wc -l`
    # print number of loci
    printf "%s\t%s\n" $0 $nlocus >> BPP_A01.LociSummary.txt;
'



## BPP *****************************************************************************************************************

#/ launch BPP
ls 5.1.blocksAlign/* | sed 's,5.1.blocksAlign/,,g' | sed 's,.seqs.txt,,g' | xargs -n 1 -P 1 sh -c '
    echo $0;
    sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/BPP/bpp_Launch.slurm $0 rep1
    sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/BPP/bpp_Launch.slurm $0 rep2
    sbatch ~/code/heliconius_seixas/2.elevatus_pardalinus/2.SpeciesTree/BPP/bpp_Launch.slurm $0 rep3
'




