## load libraries  ==========================================================
library("admixtools")
require("reshape")
library("ggplot2")
require("ggrepel")
library("magrittr")
library("tidyverse")
library("ggthemes")
options(scipen = 999)



## read geo distances ==========================================================
dir = "/n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/1.analyses/geoCoords/"
fil = "popPairDistanceMatrix.txt"
geoDist = read.table(paste0(dir,fil), header=T)
geoDistPair = melt(geoDist)
names(geoDistPair) = c("pop1","pop2","geoDistance")
geoDistPair$pop2 = as.character(geoDistPair$pop2)
# update names
geoDistPair$pop1 = ifelse(geoDistPair$pop1 == "Hele.aut.bra", "Hele.car.bra", geoDistPair$pop1)
geoDistPair$pop1 = ifelse(geoDistPair$pop1 == "Hluc.ror.bra", "Hluc.tra.bra", geoDistPair$pop1)
geoDistPair$pop1 = ifelse(geoDistPair$pop1 == "Hluc.vnv.bra", "Hluc.tra.bra", geoDistPair$pop1)
geoDistPair$pop1 = ifelse(geoDistPair$pop1 == "Hele.bvc.bra", "Hele.rur.bra", geoDistPair$pop1)
geoDistPair$pop1 = ifelse(geoDistPair$pop1 == "Hele.sfy.ven", "Hele.auy.ven", geoDistPair$pop1)
geoDistPair$pop2 = ifelse(geoDistPair$pop2 == "Hele.aut.bra", "Hele.car.bra", geoDistPair$pop2)
geoDistPair$pop2 = ifelse(geoDistPair$pop2 == "Hluc.ror.bra", "Hluc.tra.bra", geoDistPair$pop2)
geoDistPair$pop2 = ifelse(geoDistPair$pop2 == "Hluc.vnv.bra", "Hluc.tra.bra", geoDistPair$pop2)
geoDistPair$pop2 = ifelse(geoDistPair$pop2 == "Hele.bvc.bra", "Hele.rur.bra", geoDistPair$pop2)
geoDistPair$pop2 = ifelse(geoDistPair$pop2 == "Hele.sfy.ven", "Hele.auy.ven", geoDistPair$pop2)




##### read EIGENSTRAT data =====================================================
## read data
dir="./"
pre="autosomes.hmelv25.snpset1.varsites"
genotype_data = paste0(dir,pre)

## calculate f2
f2_blocks = f2_from_geno(genotype_data, blgsize = 500000)

## define f4-popPairs to test
f4pairs = read.table("f4-pairs.txt")
names(f4pairs) = c("pop1","pop2","pop3","pop4")

## calculate f4-test
f4tests = data.frame()
for (rw in 1:nrow(f4pairs)) {
  p1 = f4pairs$pop1[rw]
  p2 = f4pairs$pop2[rw] 
  p3 = f4pairs$pop3[rw]
  p4 = f4pairs$pop4[rw] 
  df = as.data.frame(f4(pop1=p1, pop2=p2, pop3=p3, pop4=p4, f2_blocks))
  f4tests = rbind(f4tests, df)
}

## add pop information 
f4tests$loc1 = substr(f4tests$pop1, 6,12)
f4tests$loc2 = substr(f4tests$pop2, 6,12)
f4tests$set = paste0(f4tests$loc1,"-",f4tests$loc2)
f4tests$set = factor(f4tests$set, levels=f4tests$set)
f4tests$col = ifelse(abs(f4tests$z) >= 3, "outlier", "normal")

## add geographic distance
f4tests$meanDist = 0
for (rw in 1:nrow(f4tests)) {
  # define pops
  p1 = f4tests$pop1[rw]
  p2 = f4tests$pop2[rw]
  p3 = f4tests$pop3[rw]
  p4 = f4tests$pop4[rw]
  # extract distances  
  dist1 = subset(geoDistPair, (pop1 == p1 & pop2 == p2) | (pop1 == p2 & pop2 == p1) )[1,3]
  dist2 = subset(geoDistPair, (pop1 == p3 & pop2 == p4) | (pop1 == p4 & pop2 == p3) )[1,3]
  dist3 = mean(dist1, dist2)
  # add geo distance
  f4tests$meanDist[rw] = dist3
}



##### Amazon ===================================================================
f4_Amazon = f4tests



## Mantel test *********************************************************************************************************
require(ade4)
locs = c("ore.ecu","let.col","yur.per","lam.per","ben.bol","car.bra")

# f4
m1 = matrix(nrow=6, ncol=6)
m2 = matrix(nrow=6, ncol=6)
# rownames(m1) = locs; colnames(m1) = locs
# rownames(m2) = locs; colnames(m2) = locs

# diagonal
for (i in 1:6) { m1[i,i] = 0; m2[i,i] = 0}
# pairs
for (i in 1:nrow(f4_Amazon) ) {
  l1 = f4_Amazon$loc1[i]
  l2 = f4_Amazon$loc2[i]
  l1_index = grep(l1, locs)
  l2_index = grep(l2, locs)
  # 
  m1[l1_index,l2_index] = f4_Amazon$est[i]
  m1[l2_index,l1_index] = f4_Amazon$est[i]
  # 
  m2[l1_index,l2_index] = f4_Amazon$meanDist[i]
  m2[l2_index,l1_index] = f4_Amazon$meanDist[i]
}

mantel.rtest(as.dist(m1),as.dist(m2), nrepet = 9999)


## Correlation between f4 and geo. distance ****************************************************************************
spearman = cor.test(f4_Amazon$meanDist, f4_Amazon$est, method = "spearman")
corlabel = paste0("Spearman Rank Correlation\nRho=", round(spearman$estimate,2),"; P-value=", round(spearman$p.value, 4))

## plot f4-vs-geo.distance
p = ggplot(data=f4_Amazon, aes(x=meanDist, y=est)) + 
  # Guideline
  geom_hline(yintercept = 0, lty=3, col="lightgrey") +
  geom_rangeframe(data=data.frame(meanDist=c(200,2000), est=c(-0.0002,0.0008)) ) +
  # Stats
  geom_smooth(method = "lm", lwd=0.5, col="black", alpha=.1) +
  geom_errorbar(aes(ymin=est-(3*se), ymax=est+(3*se)) ) +
  geom_point(aes(fill=col), size=3, shape=21, alpha=.8) +
  # beautify
  scale_fill_manual(values=c("white","#7a0177"), name="") +
  theme_tufte() +
  theme(
    aspect.ratio = 1, 
    axis.text = element_text(size = 10),
    legend.position = "bottom"
  ) +
  scale_x_continuous(
    expand=expansion(mult = 0.02),
    breaks = seq(0,2000,200), 
    limits=c(NA,NA), 
    name="Geographic Distance (km)") +
  scale_y_continuous(expand=expansion(mult = 0.02), breaks=seq(-0.0002,0.0010,0.0002), name=expression(italic(f[4]~value)) )
p = p + annotate(geom="text", x=700, y=0.00075, label=corlabel, color="black")
p


# save to file
dir="/n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/1.analyses/4.GlobalStats/f4test/"
ggsave(filename = paste0(dir,"f4_vs_geo.svg"), p, dpi = 300, scale = .8)
require(scales)
require(viridis)


