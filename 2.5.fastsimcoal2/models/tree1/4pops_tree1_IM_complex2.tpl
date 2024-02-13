//Parameters for the coalescence simulation program : fastsimcoal.exe
4 samples to simulate :
//Population effective sizes (number of genes)
NPOP_0
NPOP_1
NPOP_2
NPOP_3
//Haploid samples sizes 
pop1inds
pop2inds
pop3inds
pop4inds
//Growth rates: negative growth implies population expansion
0
0
0
0
//Number of migration matrices : 0 implies no migration between demes
4
//Migration matrix 0
0 MIG_10 0 0
MIG_01 0 MIG_21 0
0 MIG_12 0 MIG_32
0 0 MIG_23 0
//Migration matrix 1
0 MIG_10 0 0
MIG_01 0 0 MIG_31
0 0 0 0
0 MIG_13 0 0
//Migration matrix 2
0 0 MIG_20 0
0 0 0 0
MIG_02 0 0 MIG_32
0 0 MIG_23 0
//Migration matrix 3
0 0 0 MIG_30
0 0 0 0
0 0 0 0
MIG_03 0 0 0
//historical event: time, source, sink, migrants, new deme size, new growth rate, migration matrix index
3 historical event
TDIV_10 1 0 1 NANC_CHG_10 0 MigrMat1a
TDIV_23 2 3 1 NANC_CHG_23 0 MigrMat1b
TDIV_30 3 0 1 NANC_CHG_30 0 3
//Number of independent loci [chromosome] 
1 0
//Per chromosome: Number of contiguous linkage Block: a block is a set of contiguous loci
1
//per Block:data type, number of loci, per generation recombination and mutation rates and optional parameters
FREQ  1   0   2.9e-9 OUTEXP
