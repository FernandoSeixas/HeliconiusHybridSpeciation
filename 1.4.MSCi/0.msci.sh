
## Generate newick tree for the msci model *****************************************************************************
~/software/bpp.v4.6.2/src/bpp \
        --msci-create models/msci.modelA.txt | tail -n 1 \
        > msci.modelA.nwk

~/software/bpp.v4.6.2/src/bpp \
        --msci-create models/msci.modelB1.txt | tail -n 1 \
        > models/msci.modelB1.nwk

~/software/bpp.v4.6.2/src/bpp \
        --msci-create models/msci.modelFc.txt | tail -n 1 \
        > models/msci.modelFc.nwk
cat models/msci.modelFc.nwk



#/ Define parameters
edist=5000                       # minimum distance to exons
lsize=2000                       # locus size
ldist=20000                      # minimum distance between loci
sgroup="Magl_Ebar_Pser_4ind"
slocus="noncod.l${lsize}_g${ldist}_e${edist}"
echo $slocus



## Dataset *************************************************************************************************************
#/ 1. Prepare regions
bash 1.msci.prepRegions.sh ${lsize} ${ldist} ${edist}

bash 1.bpp.prepbed.sh ${lsize} ${ldist} ${edist}
#/ 2. Prepare data files
mkdir ${sgroup}-${slocus}
sbatch 2.msci.prepBPP_general.slurm ${slocus} ${sgroup} 



## Run MSCI Models *****************************************************************************************************
sgroup="Magl_Ebar_Pser_4ind"
tmodel="modelB1"
echo ${sgroup}-${slocus}/${tmodel}
mkdir ${sgroup}-${slocus}/${tmodel}
#/ 3. Run BPP
sbatch 3.msci.RunBPP.slurm \
        noncod.l${lsize}_g${ldist}_e${edist} \
        ${sgroup} \
        ${tmodel} \
        3 3 3 \
        rep1



## Resume MSCi runs that halted ****************************************************************************************
sgroup="Magl_Ebar_Pser_4ind"
tmodel="modelA"
slocus="noncod.l2000_s20000_e5000"
replNb="rep1"
sbatch 4.msci.ResumeBpp.slurm.sh \
        ${sgroup} \
        ${slocus} \
        ${tmodel} \
        ${replNb}
