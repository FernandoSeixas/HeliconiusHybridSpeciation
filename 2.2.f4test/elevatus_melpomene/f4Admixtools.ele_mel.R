# load modules
require(admixtools)
require(ggplot2)


#/ arguments
pgroup="ele_mel"
pexten="simple"
minmaf=0.02
maxmis=0.2

#/ calculate f2 
prefix = paste0("/n/holyscratch01/mallet_lab/fseixas/2.elepar/manuscript/f4test/",pgroup,"/",pexten,"/autosomes.hmelv25.geno",maxmis,".maf",minmaf,".prune01kb")
my_f2_dir = paste0("/n/holyscratch01/mallet_lab/fseixas/2.elepar/manuscript/f4test/",pgroup,"/",pexten,"/byPop/")
extract_f2(prefix, my_f2_dir, overwrite = T, auto_only = FALSE, maxmiss = 0.0)

#/ read pre-calculated f2 stats
f2_blocks = f2_from_precomp(my_f2_dir, afprod = TRUE)

#/ define f4 quartets
dir = "/n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/5.GlobalStats/f4-test/"
poplist = read.csv(paste0(dir,pgroup,".",pexten,".popsList.csv"), header=T)
pexten = "simple"

#/ calculate f4
f4Table = data.frame()
for (rw in 1:nrow(poplist)) {
  p1nm = poplist$P1[rw]
  p2nm = poplist$P2[rw]
  p3nm = poplist$P3[rw]
  p4nm = poplist$P4[rw]
  f4 = f4(data = f2_blocks, pop1 = p1nm, pop2 = p2nm, pop3 = p3nm, pop4 = p4nm)
  f4Table = rbind(f4Table, f4)
}
View(f4Table)


## Generate all possible f4 quartets
locPairs = read.csv("/n/home12/fseixas/code/heliconius_seixas/2.elevatus_pardalinus/5.GlobalStats/f4-test/ele_mel.complete.locPairs.csv", header=T)
elePops = subset(locPairs, spp == "Hele")
melPops = subset(locPairs, spp == "Hmel")
#/ all possible quartets
f4Quartets = data.frame()
for (li in 1:(length(unique(locPairs$loc))-1)) {
  for (lj in (li+1):length(unique(locPairs$loc))) {
    print( paste(locPairs$loc[li], locPairs$loc[lj]) )
    l1 = locPairs$loc[li]
    l2 = locPairs$loc[lj]
    ee1 = subset(elePops, loc == l1) 
    ee2 = subset(elePops, loc == l2) 
    mm1 = subset(melPops, loc == l1) 
    mm2 = subset(melPops, loc == l2)
    for (e1 in unique(ee1$pop)) {
      for (e2 in unique(ee2$pop)) {
        for (m1 in unique(mm1$pop)) {
          for (m2 in unique(mm2$pop)) {
            print(paste(e1,e2,m1,m2))
            quartet = data.frame(P1=e1, P2=e2, P3=m1, P4=m2)
            f4Quartets = rbind(f4Quartets, quartet)
          }
        }
      }
    }
  }
}
#/ calculate f4
f4Table = data.frame()
for (rw in 1:nrow(f4Quartets)) {
  p1nm = f4Quartets$P1[rw]
  p2nm = f4Quartets$P2[rw]
  p3nm = f4Quartets$P3[rw]
  p4nm = f4Quartets$P4[rw]
  f4 = f4(data = f2_blocks, pop1 = p1nm, pop2 = p2nm, pop3 = p3nm, pop4 = p4nm)
  f4Table = rbind(f4Table, f4)
}
View(f4Table)

ggplot(f4Table) + geom_point(aes(x=est, y=p, col=ifelse(p < 0.01, "red", "black")))
