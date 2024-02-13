require(ggplot2)

## read file
dir = "/n/holyscratch01/mallet_lab/fseixas/gphocs/Simulations/Complex.m0.001/"
fil = "msms.Complex.m0.001.geno.gz.popdist.csv"
inp = read.csv(paste0(dir,fil))

## correct Fst
for (cl in grep(pattern = "Fst", x = names(inp)) ) {
  inp[,cl] = ifelse(inp[,cl] < 0, 0, inp[,cl])
}

## plots
ggplot(inp) + 
  geom_boxplot(aes(x="dxy_P1_P2", y=dxy_P1_P2)) +
  geom_boxplot(aes(x="dxy_P1_P3", y=dxy_P1_P3)) +
  geom_boxplot(aes(x="dxy_P3_P3", y=dxy_P2_P3))

ggplot(inp) + 
  geom_boxplot(aes(x="Fst_P1_P2", y=Fst_P1_P2)) +
  geom_boxplot(aes(x="Fst_P1_P3", y=Fst_P1_P3)) +
  geom_boxplot(aes(x="Fst_P2_P3", y=Fst_P2_P3))

summary(inp$dxy_P1_P2)*100
summary(inp$Fst_P1_P2)
