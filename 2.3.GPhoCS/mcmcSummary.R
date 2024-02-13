## load libraries
require(reshape2)
require(tidyr)
require(tidyverse)
require(stringr)
require(ggplot2)
require(ggbeeswarm)
require(ggrepel)
require(reshape2)
require(viridis)
require(viridis)
options(scipen = 999)

## variables
dir = "/n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/1.analyses/4.GlobalStats/gphocs.v2/"
run="autoNoColor"
fil = "mcmc.log"

burnin = 50000
maxite = 250000
isteps = 200
burn = floor(burnin/isteps)

pairs = list.files(dir, pattern = "H")
pairs = pairs[grepl(pattern = "Hbessppbra", x = pairs)]


## read trace files for each Population pair and Replicate run
AllTraces = data.frame()
for (pp in pairs) {
  print(pp)
  for (r in 1:3) {
    # read trace
    trace = read.table(paste0(dir,pp,"/",run,"/rep",r,"/",fil), header=T)
    # add info
    trace$point = seq(1, nrow(trace),1)
    trace = trace[1:(nrow(trace)-1),]
    trace$pair = pp 
    trace$rep = paste0("rep",r)
    AllTraces = rbind(AllTraces, trace)
    print(paste0(pp,"-",r,":",nrow(trace)))
  }
}
AllTraces$set = paste0(AllTraces$pair,"_",AllTraces$rep)
prog = aggregate(Sample ~ set + rep, AllTraces, max)
hist(prog$Sample/maxite*100, breaks = seq(0,100,5), xlab="Percent Complete")


# AllTracesSep = separate(AllTraces, col = "pair", into = c("pop1","pop2","pop3"), sep="_")
# AllTracesSep$Nm_AB = AllTracesSep$m_A..B * AllTracesSep$theta_B / 4
# AllTracesSep$Nm_BA = AllTracesSep$m_B..A * AllTracesSep$theta_A / 4



################################# Apply burn-in ################################
# burn-in
l1=(burn+1)
l2=maxite/isteps
AllTracesBurn = subset(AllTraces, point %in% seq(l1,l2,1) )



#################### Summary of all runs ####################
pop3List = read.table("~/code/heliconius_seixas/2.elevatus_pardalinus/5.GlobalStats/gphocs/3pops.list")[,1]

SummaryRuns = data.frame()
for (mcmc in unique(AllTracesBurn$set)) {
  # subset run
  subTrace = subset(AllTracesBurn, set == mcmc)
  par = unique(subTrace$pair)
  rep = unique(subTrace$rep)
  subTrace = subTrace[,1:(ncol(subTrace)-4)]
  # get mean values for each stat
  traceSummary = data.frame()
  for (cl in 1:ncol(subTrace)) {
    stat = names(subTrace)[cl]
    meanVal = mean(subTrace[,cl])
    tmp = data.frame(Stat = stat, Mean = meanVal)
    traceSummary = rbind(traceSummary, tmp)
  }
  # transpose
  n <- traceSummary$Stat
  traceSummary_transpose <- as.data.frame(t(traceSummary[,-1]))
  colnames(traceSummary_transpose) <- n
  # add run names
  traceSummary_transpose$Pair = par
  traceSummary_transpose$Rep = rep
  SummaryRuns = rbind(SummaryRuns, traceSummary_transpose)
}


############# Add information about species, population and locations ##########
# separate pops in pair
SummaryRuns = separate(SummaryRuns, Pair, c("Pop1","Pop2","Pop3"), "_")
# species
SummaryRuns$spp1 = substr(SummaryRuns$Pop1, 1, 4)
SummaryRuns$spp2 = substr(SummaryRuns$Pop2, 1, 4)
# location
SummaryRuns$loc1 = substr(SummaryRuns$Pop1, 5, 12)
SummaryRuns$loc2 = substr(SummaryRuns$Pop2, 5, 12)
# correct location names
SummaryRuns$loc1 = ifelse(SummaryRuns$loc1 == "napecu", "norecu", SummaryRuns$loc1)
SummaryRuns$loc2 = ifelse(SummaryRuns$loc2 == "napecu", "norecu", SummaryRuns$loc2)
SummaryRuns$loc1 = ifelse(SummaryRuns$loc1 == "oreecu", "norecu", SummaryRuns$loc1)
SummaryRuns$loc2 = ifelse(SummaryRuns$loc2 == "oreecu", "norecu", SummaryRuns$loc2)
SummaryRuns$loc1 = ifelse(SummaryRuns$loc1 == "pmdper", "mddper", SummaryRuns$loc1)
SummaryRuns$loc2 = ifelse(SummaryRuns$loc2 == "pmdper", "mddper", SummaryRuns$loc2)
SummaryRuns$loc1 = ifelse(SummaryRuns$loc1 == "lamper", "mddper", SummaryRuns$loc1)
SummaryRuns$loc2 = ifelse(SummaryRuns$loc2 == "lamper", "mddper", SummaryRuns$loc2)
# Pair type
SummaryRuns$PairType = NA
SummaryRuns$PairType = ifelse(SummaryRuns$spp1 != SummaryRuns$spp2 & SummaryRuns$loc1 == SummaryRuns$loc2, "10-par-ele", SummaryRuns$PairType) # 10
SummaryRuns$PairType = ifelse(SummaryRuns$spp1 != SummaryRuns$spp2 & SummaryRuns$loc1 != SummaryRuns$loc2, "11-par-ele", SummaryRuns$PairType) # 11
SummaryRuns$PairType = ifelse(SummaryRuns$spp1 == "Hele" & SummaryRuns$spp1 == SummaryRuns$spp2 & SummaryRuns$loc1 != SummaryRuns$loc2, "01-ele-ele", SummaryRuns$PairType) # 01 - ele
SummaryRuns$PairType = ifelse(SummaryRuns$spp1 == "Hpar" & SummaryRuns$spp1 == SummaryRuns$spp2 & SummaryRuns$loc1 != SummaryRuns$loc2, "01-par-par", SummaryRuns$PairType) # 01 - par
SummaryRuns$PairType = ifelse(SummaryRuns$spp1 == SummaryRuns$spp2 & SummaryRuns$loc1 != SummaryRuns$loc2 & SummaryRuns$loc1 == "bargui", "01-bar-ele", SummaryRuns$PairType) # 11
SummaryRuns$PairType = ifelse(SummaryRuns$spp1 == SummaryRuns$spp2 & SummaryRuns$loc1 != SummaryRuns$loc2 & SummaryRuns$loc1 == "serper", "01-ser-par", SummaryRuns$PairType) # 11
SummaryRuns$PairType = ifelse(SummaryRuns$spp1 != SummaryRuns$spp2 & SummaryRuns$loc1 != SummaryRuns$loc2 & SummaryRuns$loc1 == "bargui", "11-bar-par", SummaryRuns$PairType) # 11
SummaryRuns$PairType = ifelse(SummaryRuns$spp1 != SummaryRuns$spp2 & SummaryRuns$loc1 != SummaryRuns$loc2 & SummaryRuns$loc1 == "serper", "11-ser-ele", SummaryRuns$PairType) # 11
SummaryRuns$PairType = ifelse(SummaryRuns$Pop1 == "Hparserper" & SummaryRuns$Pop2 == "Helebargui", "11-ser-bar", SummaryRuns$PairType) # 
# order Pair Types
PTlevels = c(
  "11-ser-bar","01-ser-par","11-ser-ele","11-bar-par","01-bar-ele",
  "11-par-ele","10-par-ele",
  "01-par-par","01-ele-ele"
)
SummaryRuns$PairType = factor(SummaryRuns$PairType, levels = PTlevels) 
# define colors for pair types
PairTypeColors = viridis(length(unique(SummaryRuns$PairType)), direction = 1)
# re-order rows by trio 
SummaryRuns$set = paste0(SummaryRuns$Pop1,"_",SummaryRuns$Pop2,"_",SummaryRuns$Pop3)
SummaryRuns$set = factor(SummaryRuns$set, levels = pop3List)
SummaryRuns = with(SummaryRuns, SummaryRuns[order(set),])


SummaryRuns$ptype = NA
SummaryRuns$ptype = ifelse(SummaryRuns$PairType == "11-ser-bar", "ser-bar", SummaryRuns$ptype) # ser-bar
SummaryRuns$ptype = ifelse(SummaryRuns$PairType == "01-ser-par", "ser-par", SummaryRuns$ptype) # ser-bar
SummaryRuns$ptype = ifelse(SummaryRuns$PairType == "01-bar-ele", "eas-ele", SummaryRuns$ptype) # ser-bar
SummaryRuns$ptype = ifelse(SummaryRuns$PairType == "10-par-ele", "par-ele", SummaryRuns$ptype) # ser-bar
SummaryRuns$ptype = ifelse(SummaryRuns$PairType == "11-par-ele", "par-ele", SummaryRuns$ptype) # ser-bar
SummaryRuns$ptype = ifelse(SummaryRuns$PairType == "01-ele-ele", "ele-ele", SummaryRuns$ptype) # ser-bar
SummaryRuns$ptype = ifelse(SummaryRuns$PairType == "01-par-par", "par-par", SummaryRuns$ptype) # ser-bar

plevels = c("ser-bar","ser-par","eas-ele","par-ele","par-par","ele-ele")
SummaryRuns$ptype = factor(SummaryRuns$ptype, levels = plevels)


##### Plot statistics per population or pair

# same location or not
SummaryRuns$locPair = ifelse(SummaryRuns$loc1 == SummaryRuns$loc2, "sympatric", "allopatric")

unique(SummaryRuns$loc1)
unique(SummaryRuns$loc2)

locShape = c(
  "sympatric" = 19,
  "allopatric" = 1
)

## min and max Migration =======================================================
SummaryRuns$Nm_AB = SummaryRuns$m_A..B * 1000 * SummaryRuns$theta_B / 4
SummaryRuns$Nm_BA = SummaryRuns$m_B..A * 1000 * SummaryRuns$theta_A / 4
SummaryRuns$MinMig = apply(SummaryRuns[, grep("Nm_", names(SummaryRuns))], 1, min)
SummaryRuns$MaxMig = apply(SummaryRuns[, grep("Nm_", names(SummaryRuns))], 1, max)

## Maximum migration
head(SummaryRuns)
p = SummaryRuns %>%
  filter( !is.na(ptype) ) %>%
  # filter( Rep == "rep1" ) %>%
  ggplot(aes(x=ptype, y=MaxMig, fill=ptype, color=ptype)) + 
  geom_boxplot() + 
  geom_beeswarm(aes(shape=locPair), cex=1.5, size=2) +
  # baseline at Nm=1 (threshold of panmixia)
  geom_hline(yintercept = 1, lty=2) +
  # beautify
  scale_shape_manual(values = locShape) +
  scale_color_viridis_d() + scale_fill_viridis_d() +
  scale_x_discrete(name="") +
  scale_y_continuous(breaks=seq(0,20,1), name=expression(italic(N[m])) ) +
  # facet_wrap(~Rep, ncol=3) +
  theme_classic() +
  theme(
    legend.position = "none"
  )
p
ggsave(filename = "/n/holyscratch01/mallet_lab/fseixas/2.elepar/2023.grc/figure2_panel2.eps",
       plot = p, units = "in", height = 4, width = 3.0, bg = "transparent")

SummaryRuns %>%
  # mutate(PairType = ifelse(PairType == "10-par-ele","11-par-ele",PairType) ) %>%
  filter(PairType %in% c("11-ser-bar","01-ser-par","01-bar-ele","10-par-ele","11-par-ele","01-par-par","01-ele-ele")) %>%
  ggplot(aes(x=PairType, y=MaxMig, fill=PairType, color=PairType)) + 
  geom_boxplot(alpha=0.1) + 
  geom_beeswarm(priority="density", cex=1.0, alpha=0.5) +
  # geom_errorbar(aes(ymin=MaxMig, ymax=MaxMig+MaxMig_SE), width=.2, position=position_dodge(.9)) +
  # baseline at Nm=1 (threshold of panmixia)
  geom_hline(yintercept = 1, lty=2, alpha=.2) +
  # beautify
  scale_color_manual(values = PairTypeColors) + scale_fill_manual(values = PairTypeColors) +
  # scale_color_viridis_d() + scale_fill_viridis_d() +
  scale_y_continuous(breaks=seq(0,20,1)) +
  ylab("Nm (max)") +
  theme_classic()



##
se = function(x) sd(x)/sqrt(length(x))

maxNmAgg = aggregate(SummaryRuns$MaxMig, list(SummaryRuns$PairType), mean)
names(maxNmAgg) = c("PairType","MaxMig_mean")
maxNmAgg$MaxMig_se = aggregate(SummaryRuns$MaxMig, list(SummaryRuns$PairType), se)[,2]

ggplot(maxNmAgg, aes(x=PairType, y=MaxMig_mean, color=PairType)) + 
  geom_point(position=position_dodge()) +
  geom_errorbar(aes(ymin=MaxMig_mean-MaxMig_se, ymax=MaxMig_mean+MaxMig_se), width=.2, position=position_dodge(.9)) +
  scale_color_manual(values = PairTypeColors) +
  ylab("Max. Migration (Nm)") +
  theme_classic()


## Maximum-Minimum migration
ggplot(SummaryRuns, aes(fill=PairType, color=PairType)) + 
  geom_boxplot(aes(x=PairType, y=0+MaxMig), alpha=0.1) +
  geom_boxplot(aes(x=PairType, y=0-MinMig), alpha=0.1) + 
  geom_jitter(aes(x=PairType, y=0+MaxMig), priority="density", cex=1.0, alpha=0.5) +
  geom_jitter(aes(x=PairType, y=0-MinMig), priority="density", cex=1.0, alpha=0.5) +
  # baseline at Nm=1 (threshold of panmixia)
  geom_hline(yintercept = c(-1,0,1), lty=2, alpha=.2) +
  # beautify
  scale_color_manual(values = PairTypeColors) + scale_fill_manual(values = PairTypeColors) +
  scale_y_continuous(breaks=seq(0,20,1)) +
  ylab("Nm (max)") +
  theme_classic()




## Nm by geo-distance ==========================================================
# read geo distances 
dir = "/n/mallet_lab/fseixas/1.projects/2.elevatus_pardalinus/1.analyses/geoCoords/"
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
# update names
geoDistPair$pop1 = str_remove_all(geoDistPair$pop1, "[.]")
geoDistPair$pop2 = str_remove_all(geoDistPair$pop2, "[.]")
# add geo distance info 
SummaryRuns$geoDist = 0
for (rw in 1:nrow(SummaryRuns)) {
  # define pops
  p1 = SummaryRuns$Pop1[rw]
  p2 = SummaryRuns$Pop2[rw]
  # extract distances  
  dist1 = subset(geoDistPair, (pop1 == p1 & pop2 == p2) | (pop1 == p2 & pop2 == p1) )[1,3]
  # add geo distance
  SummaryRuns$geoDist[rw] = dist1
}


## Amazonian Populations (Nm > 1) ==============================================
Amazon = subset(SummaryRuns, !(PairType %in% c("11-ser-bar","01-ser-par","11-ser-ele","11-bar-par","01-bar-ele")))
Amazon = subset(SummaryRuns, !(PairType %in% c("11-ser-bar","01-ser-par","11-ser-ele","11-bar-par","01-bar-ele","10-par-ele")))
ggplot(Amazon, aes(x=geoDist, y=MaxMig, color=PairType, fill=PairType)) +
  geom_point(alpha=0.5) +
  geom_smooth(method = "lm", alpha=0.2) +
  #
  xlab("Geographic Distance (km)") + ylab("Maximum Nm") +
  # beautify
  scale_color_manual(values = PairTypeColors[7:9]) +
  scale_fill_manual(values = PairTypeColors[7:9]) +
  facet_wrap(~PairType, ncol=3) +
  theme_classic()


## Non-Panmitic populations (Nm < 1) ===========================================
nonpanm = subset(SummaryRuns, PairType %in% c("11-ser-bar","01-ser-par","11-ser-ele","11-bar-par","01-bar-ele"))
unique(nonpanm$PairType)

ggplot(nonpanm, aes(fill=PairType, color=PairType)) + 
  geom_boxplot(aes(x=PairType, y=0+Nm_AB), alpha=0.1) + 
  geom_boxplot(aes(x=PairType, y=0-Nm_BA), alpha=0.1) + 
  geom_beeswarm(aes(x=PairType, y=0+Nm_AB), priority="density", cex=1.0, alpha=0.5) +
  geom_beeswarm(aes(x=PairType, y=0-Nm_BA), priority="density", cex=1.0, alpha=0.5) +
  # baseline at Nm=1 (threshold of panmixia)
  geom_hline(yintercept = c(-1,1), lty=2, alpha=.2) +
  # beautify
  scale_color_viridis_d() + scale_fill_viridis_d() +
  scale_y_continuous(breaks=seq(-1,1,0.1)) +
  ylab("Nm (max)") +
  theme_classic()


head(nonpanm)
nonpanmLong = nonpanm[,grep("set|PairType|Rep|Nm_AB|Nm_BA", names(nonpanm))]
nonpanmLong$Set = paste0(nonpanmLong$set,"_",nonpanmLong$Rep)
nonpanmLong = subset(nonpanmLong, select = -set)
nonpanmLong = subset(nonpanmLong, select = -Rep)
nonpanmLong = melt(nonpanmLong, id.vars = c("Set","PairType"))
head(nonpanmLong)
#
nonpanmLong = separate(nonpanmLong, col="Set", into=c("Pop1","Pop2","Pop3","Rep"),sep="_")
nonpanmLong$Set = paste0(nonpanmLong$Pop1,"-",nonpanmLong$Pop2,"-",nonpanmLong$Rep)
nonpanmLong$Pair = paste0(nonpanmLong$Pop1,"-",nonpanmLong$Pop2)
# 
nonpanmLong$loc1 = substr(nonpanmLong$Pop1,5,10)
nonpanmLong$loc2 = substr(nonpanmLong$Pop2,5,10)
nonpanmLong$locPair = paste0(nonpanmLong$loc1,"-",nonpanmLong$loc2)

# plot
ggplot(nonpanmLong) +
  geom_point(aes(x=variable, y=value, group=Set, color=locPair), alpha=0.5) +
  geom_line(aes(x=variable, y=value, group=Set, color=locPair), alpha=0.5) +
  facet_wrap(~PairType, nrow=1) +
  theme_classic()



## median by rep
pops = c("Hparserper","Hparoreecu","Hparletcol","Hparyurper","Hparlamper","Hparbenbol","Hparcarbra","Helenapecu","Heleletcol","Heleyurper","Helepmdper","Helebenbol","Helecarbra","Helebargui")
pops = c(
  "Hparserper",
  "Hparoreecu","Helenapecu",
  "Hparletcol","Heleletcol",
  "Hparyurper","Heleyurper",
  "Hparlamper","Helepmdper",
  "Hparbenbol","Helebenbol",
  "Hparcarbra","Helecarbra",
  "Helebargui"
)
npops = length(pops)

df = as.data.frame(matrix(rep(0, npops*npops), nrow=npops, ncol=npops))
rownames(df) = pops
colnames(df) = pops
for (rw in 1:nrow(NmSummary)) {
  rpop = NmSummary$Pop1[rw]
  cpop = NmSummary$Pop2[rw]
  rpopNb = grep(rpop, rownames(df))
  cpopNb = grep(cpop, colnames(df))
  df[rpopNb,cpopNb] = NmSummary$Nm_AB[rw]
  df[cpopNb,rpopNb] = NmSummary$Nm_BA[rw]
}

heatmap.2(
  as.matrix(df), 
  Rowv = F, Colv = F, trace = "none", 
  sepcolor="black", colsep=1:ncol(mt), rowsep=1:nrow(mt),
  col = cols
)


require(gplots)
require(viridis)
library(RColorBrewer)
cols = brewer.pal(n = 11, name = "RdBu")

mt = log10(df)
is.na(mt) <- sapply(mt, is.infinite)
heatmap.2(
  as.matrix(mt), 
  Rowv = F, Colv = F, trace = "none", 
  sepcolor="black", colsep=1:ncol(mt), rowsep=1:nrow(mt),
  col = cols
)



NmSummary = SummaryRuns[,grep("set|PairType|Rep|Nm_AB|Nm_BA", names(SummaryRuns))]
NmSummary$NewSet = NmSummary$set
NmSummary = separate(NmSummary, "set", c("Pop1","Pop2","Pop3"))


NmSummaryAgg_AB = aggregate(Nm_AB~set, NmSummary, mean)
NmSummaryAgg_BA = aggregate(Nm_BA~set, NmSummary, mean)
NmSummaryAgg_AB = separate(NmSummaryAgg_AB, "set", c("Pop1","Pop2","Pop3"))
NmSummaryAgg_BA = separate(NmSummaryAgg_BA, "set", c("Pop1","Pop2","Pop3"))

NmSummaryAgg_AB = subset(NmSummaryAgg_AB, select = -Pop3)
NmSummaryAgg_BA = subset(NmSummaryAgg_BA, select = -Pop3)

NmSummaryAgg_AB$Pop1 = factor(NmSummaryAgg_AB$Pop1, levels = pops)
NmSummaryAgg_AB$Pop2 = factor(NmSummaryAgg_AB$Pop2, levels = pops)
NmSummaryAgg_BA$Pop1 = factor(NmSummaryAgg_BA$Pop1, levels = pops)
NmSummaryAgg_BA$Pop2 = factor(NmSummaryAgg_BA$Pop2, levels = pops)

ab = dcast(data = NmSummaryAgg_AB, Pop1~Pop2, value.var = "Nm_AB", fill=0)
ba = dcast(data = NmSummaryAgg_BA, Pop2~Pop1, value.var = "Nm_BA", fill=0)
rownames(ab) = ab[,1]; ab=ab[,2:ncol(ab)]
rownames(ba) = ba[,1]; ba=ba[,2:ncol(ba)]
cc = ab[,2:ncol(ab)]+ba[,2:ncol(ba)]
cc

ab[,1]


## Divergence Time ===========
mutRate = 2.9E-9 # Kightley et al 2014
# mutRate = 1.9E-9 # Kozak et al 2015
genTime = 0.25
SummaryRuns$Pair = paste0(SummaryRuns$Pop1,"-",SummaryRuns$Pop2)
Tagg = aggregate(tau_AB~Pair+PairType, SummaryRuns, mean)
ggplot(Tagg, aes(x=PairType, y=tau_AB/mutRate*genTime/1000000, label=Pair, color=PairType, fill=PairType)) + 
  geom_boxplot(alpha=0.2, width=0.50) +
  geom_beeswarm(alpha=0.50) +
  scale_color_manual(values = PairTypeColors) +
  scale_fill_manual(values = PairTypeColors) +
  # geom_text_repel() +
  ylab("Time of Divergence (My)") +
  ylim(0,2.5) +
  theme_classic(base_size = 16)

subset(Tagg, PairType == "01-ser-par" & tau_AB/mutRate*genTime/1000000 > 1)


# ggplot(Tagg, aes(tau_AB/mutRate*genTime/1000000, label=Pair, color=PairType, fill=PairType)) + 
#   geom_density(alpha=0.2) +
#   xlim(0,2.5) +
#   theme_classic(base_size = 16)



## Effective Population Size (Ne) ===========
mutRate = 2.9E-9
genTime = 0.25

popLevels = c("Hbessppbra",
              "Hparserper","Helebargui",
              "Hparoreecu","Helenapecu",
              "Hparletcol","Heleletcol",
              "Hparyurper","Heleyurper",
              "Hparlamper","Helepmdper",
              "Hparbenbol","Helebenbol",
              "Hparcarbra","Helecarbra"
)

df1 = data.frame(Pop = SummaryRuns$Pop1, theta = SummaryRuns$theta_A)
df2 = data.frame(Pop = SummaryRuns$Pop2, theta = SummaryRuns$theta_B)
df3 = data.frame(Pop = SummaryRuns$Pop3, theta = SummaryRuns$theta_C)
cmb = rbind(df1,df2,df3)
cmb$Ne = cmb$theta/(4*mutRate)
cmb$Pop = factor(cmb$Pop, levels = popLevels)

ggplot(cmb, aes(x=Pop, y=Ne/1000000)) +
  geom_boxplot() +
  coord_flip() +
  geom_hline(yintercept = c(0.4,0.5), lty=2) +
  xlab("Population") + ylab("Ne (x10E6)")




## min and max Migration =====

head(SummaryRuns)





##### GET HPD per pair #####
library(HDInterval)

hpd = data.frame()
for (pp in unique(AllTracesBurninReScale$pair)) {
  s1 = subset(AllTracesBurninReScale, pair == pp)
  ## hpd and maxHPD
  # thetaA
  theta_A_HPD025 = quantile(s1$theta_A, 0.025)
  theta_A_HPD975 = quantile(s1$theta_A, 0.975)
  theta_A_HPDmax = density(s1$theta_A)$x[ which.max(density(s1$theta_A)$y)]
  # thetaB
  theta_B_HPD025 = quantile(s1$theta_B, 0.025)
  theta_B_HPD975 = quantile(s1$theta_B, 0.975)
  theta_B_HPDmax = density(s1$theta_B)$x[ which.max(density(s1$theta_B)$y)]
  # thetaAB
  theta_AB_HPD025 = quantile(s1$theta_AB, 0.025)
  theta_AB_HPD975 = quantile(s1$theta_AB, 0.975)
  theta_AB_HPDmax = density(s1$theta_AB)$x[ which.max(density(s1$theta_AB)$y)]
  # tau_AB
  tau_AB_HPD025 = quantile(s1$tau_AB, 0.025)
  tau_AB_HPD975 = quantile(s1$tau_AB, 0.975)
  tau_AB_HPDmax = density(s1$tau_AB)$x[ which.max(density(s1$tau_AB)$y)]
  # mAB
  m_AB_HPD025 = quantile(s1$m_A..B, 0.025)
  m_AB_HPD975 = quantile(s1$m_A..B, 0.975)
  m_AB_HPDmax = density(s1$m_A..B)$x[ which.max(density(s1$m_A..B)$y)]
  # mBA
  m_BA_HPD025 = quantile(s1$m_B..A, 0.025)
  m_BA_HPD975 = quantile(s1$m_B..A, 0.975)
  m_BA_HPDmax = density(s1$m_B..A)$x[ which.max(density(s1$m_B..A)$y)]
  # data frame row
  pop1 = strsplit(pp, split = "_")[[1]][1]
  pop2 = strsplit(pp, split = "_")[[1]][2]
  df = data.frame(
    pair = pp, pop1 = pop1, pop2 = pop2,
    theta_A_HPD025=theta_A_HPD025,theta_A_HPD975=theta_A_HPD975,theta_A_HPDmax=theta_A_HPDmax,
    theta_B_HPD025=theta_B_HPD025,theta_B_HPD975=theta_B_HPD975,theta_B_HPDmax=theta_B_HPDmax,
    theta_AB_HPD025=theta_AB_HPD025,theta_AB_HPD975=theta_AB_HPD975,theta_AB_HPDmax=theta_AB_HPDmax,
    tau_AB_HPD025=tau_AB_HPD025,tau_AB_HPD975=tau_AB_HPD975,tau_AB_HPDmax=tau_AB_HPDmax,
    m_AB_HPD025=m_AB_HPD025,m_AB_HPD975=m_AB_HPD975,m_AB_HPDmax=m_AB_HPDmax,
    m_BA_HPD025=m_BA_HPD025,m_BA_HPD975=m_BA_HPD975,m_BA_HPDmax=m_BA_HPDmax
  )
  hpd = rbind(hpd, df)
}




hpdLong = melt(hpd, id.vars = c("pair","pop1","pop2"))
names(hpdLong) = c("pair","pop1","pop2","metric","number")
hpdLong2 = melt(hpdLong, id.vars = c("pair","metric","number"))
hpdLong2 = hpdLong2[,c(1,5,2,3)]
head(hpdLong2)
names(hpdLong2) = c("pair","pop","metric","value")

hpdLong3 = hpdLong2[grepl(hpdLong2$metric, pattern = "max"),]
ggplot(hpdLong3) + 
  geom_boxplot(aes(x=pop, y=value)) +
  geom_jitter(aes(x=pop, y=value)) +
  facet_wrap(~metric, scales = "free_y")



##### migration table
MigTable = hpd[,c(2,3,18,21)]
head(MigTable)

library(reshape2)
acast(MigTable, pop1~pop2, value.var="m_AB_HPDmax")
acast(MigTable, pop1~pop2, value.var="m_BA_HPDmax")

p1s = unique(hpd$pop1)
p2s = unique(hpd$pop2)

hpd


##### apply burnin to each pair #####

AllTracesReScaleBurnin = subset(AllTracesReScale, point %in% round(burnin*max(AllTracesReScale$point)):max(AllTracesReScale$point))

a = subset(AllTracesReScale, pair == "Heleletcol_Helebenbol")
ggplot(a) + geom_line(aes(x=point, y=Nm_AB, col=rep))
ggplot(a) + geom_line(aes(x=point, y=Nm_BA, col=rep))





head(s1)
ggplot(s1) + geom_density(aes(theta_A, col=rep))



###
summary(traceReScale)
mode(traceReScale$tau_AB)


density(traceReScale$theta_A)$x[maxpeak]
density(traceReScale$theta_B)$x[maxpeak]
density(traceReScale$theta_AB)$x[maxpeak]
density(traceReScale$tau_AB)$x[maxpeak]
density(traceReScale$m_A..B)$x[maxpeak]
density(traceReScale$m_B..A)$x[maxpeak]


density(traceReScale$theta_A)$x[ which.max(density(traceReScale$theta_A)$y)]
density(traceReScale$theta_B)$x[ which.max(density(traceReScale$theta_B)$y)]
density(traceReScale$tau_AB)$x[ which.max(density(traceReScale$tau_AB)$y)]


hpd005 = quantile(traceReScale$tau_AB, 0.05)
hpd095 = quantile(traceReScale$tau_AB, 0.95)

