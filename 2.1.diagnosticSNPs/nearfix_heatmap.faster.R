# load libraries
require(reshape2)
require(stringr)
require(tidyverse)
require(ggplot2)
require(cowplot)

source("~/code/heliconius_seixas/0.general/updateHmelv25Coords.R")
source("~/code/heliconius_seixas/2.elevatus_pardalinus/5.GlobalStats/nearFixDifferences/nearFixGeomTile/nfixDiff_functions.R")


## Arguments *******************************************************************
p1Name = "mel"
p2Name = "ele"
pair = "melspp-elesym"
bspace = 1000
maf = 0.80
mafcode = str_replace(string = sprintf("%.2f",maf) , pattern = "[.]", "")

maxStep = 500000

## Define individuals and color codes ******************************************
indLevels = read.table(paste0("/n/holyscratch01/mallet_lab/fseixas/2.elepar/manuscript/nearlyFixDifferences/",pair,"/",pair,".list"))[,1]
indLevels = c(indLevels,"dummy")
indLevels = str_replace_all(indLevels, "[.]", "")

#/ Define color pallete
colPal = c(
  "mel" = "#bf812d",
  "ele" = "#8da0cb",
  "het" = "#f0f0f0",
  "odd" = "#bdbdbd",
  "even" = "#252525"
)
borderPal = c(
  "mel" = "white",
  "ele" = "white",
  "het" = "white",
  "odd" = "#bdbdbd",
  "even" = "#252525"
)


## Read SNP file ***************************************************************
#/ Read file with nearly fixed differences
dir = paste0("/n/holyscratch01/mallet_lab/fseixas/2.elepar/manuscript/nearlyFixDifferences/",pair,"/")
fil = paste0("wgenome.afd_",mafcode,"_bp",bspace,".nomiss.gt.txt")
gt = read.table(paste0(dir,fil), header=T)

#/ Correct column names
newColNames = str_split_fixed(colnames(gt), pattern = "_", 2)[,2]
colnames(gt) = newColNames
colnames(gt)[1] = "scaffold"

#/ add dummy sample which later will be used to color blocks of SNPs
gt$dummy = "00"

#/ Add chromosome nb and update coordinates
gt$start = gt$POS
gt$end = gt$POS
gt = updateHmel25Coords(gt)
gt$chromNb = substr(gt$scaffold, 6, 7)

#/ Add Relative Position
gt$relpos = seq(1,nrow(gt),1)

#/ Recode 0 homozygous and heterozygous
gt = gt %>% mutate(across(starts_with("H"), ~ if_else(.x == "0", "00", as.character(.x))))
gt = gt %>% mutate(across(starts_with("H"), ~ if_else(.x %in% c("1","10"), "01", as.character(.x))))



## Define blocks of SNPs *******************************************************

#/ Add distance to previous SNP
gt$SNPgap = NA
tmp = data.frame()
for (ch in unique(gt$chromNb)) {
  s1 = subset(gt, chromNb == ch)
  s1$SNPgap[1] = 0
  if (nrow(s1) > 1) {
    for ( rw in 2:nrow(s1) ) {
      s1$SNPgap[rw] = s1$genome_end[rw] - s1$genome_end[(rw-1)]
    }
  }
  tmp = rbind(tmp, s1)
}
gt = tmp 

#/ Determine SNP blocks
gt$block = 1
for (rw in 2:nrow(gt)) {
  # different chromosome
  if ( gt$chromNb[rw] != gt$chromNb[(rw-1)]) { gt$block[rw:nrow(gt)] = gt$block[rw:nrow(gt)] + 1 }
  # big gap
  if ( gt$SNPgap[rw] > maxStep) { gt$block[rw:nrow(gt)] = gt$block[rw:nrow(gt)] + 1 }
}


## Recode so that there is pop1 and pop2-like alleles ****************

#/ MFA in reference population
pop1Nbs = grep("mel",colnames(gt))
colnames(gt)[grep("mel",colnames(gt))]
pop1Alleles = data.frame(chrom = gt$scaffold, pos = gt$POS, pop1Allele = NA)
for (rw in 1:nrow(gt)) {
  mfa_par = names(which.max(table(as.character(gt[rw,pop1Nbs]))))
  pop1Alleles$pop1Allele[rw] = mfa_par
}
pop1Alleles$pop1Allele = ifelse(pop1Alleles$pop1Allele == "0", "00", pop1Alleles$pop1Allele)

#/ recode gts 
newgt = gt
newgt$p1Allele = pop1Alleles$pop1Allele
newgt$p2Allele = ifelse(newgt$p1Allele == "00", "11", "00")
newgt = newgt %>% 
  mutate(across(starts_with("H"), ~ if_else(.x == p1Allele, "mel", ifelse(.x == p2Allele, "ele", "het"))))

#/ Long format 
gt_long = melt(newgt, id.vars = c("scaffold","POS","relpos","chrom","chromNb","start","end","UPstart","UPend","genome_sta","genome_end","SNPgap","block","p1Allele","p2Allele"))
# order individuals
gt_long$variable = factor(gt_long$variable, levels=rev(indLevels) )
# define block colors
gt_long$value = ifelse(gt_long$variable == "dummy" & gt_long$block %in% seq(1,100,2), "odd", gt_long$value)
gt_long$value = ifelse(gt_long$variable == "dummy" & gt_long$block %in% seq(2,100,2), "even", gt_long$value)
# add chrom number
gt_long$chromNb = substr(gt_long$scaffold, 6,7)
gt_long$relpos = factor(gt_long$relpos)

# add subspecies
gt_long$subspp = substr(gt_long$variable, 2,7)
# add species
gt_long$spp = substr(gt_long$variable, 2,4)
# gt_long$spp = ifelse(gt_long$subspp == "parser", "ser", gt_long$spp)
# gt_long$spp = ifelse(gt_long$subspp %in% c("elebar","eletum","eleauy","elesfy","elerur","elebvc"), "eas", gt_long$spp)
# gt_long$spp = factor(gt_long$spp, levels=c("umm","ser","par","ele","eas","luc"))
# gt_long$spp = ifelse(gt_long$spp == "umm", "", as.character(gt_long$spp) )
# gt_long$spp = factor(gt_long$spp, levels=c("","ser","par","ele","eas","luc"))

## Plot chromosomes and SNP positions ******************************************

#/ Chromosome lengths
scacumlen = read.table("/n/mallet_lab/Lab/fseixas/1.projects/0.basic_data/reference_genomes/hmelv25/hmelv25.scaffold.addlen.txt", header=T)
chrLen = aggregate(scacumlen$cumLen, list(scacumlen$chrom), max)
colnames(chrLen) = c("chrom","len")
chrLen$chromNb = substr(chrLen$chrom, 6, 7)


# # plot multiple chromosomes
# chList = c("01","02","03","04","05")
# a = plot_genotype(gt_long, chList, 20)
# chList = c("06","07","08","09","10")
# b = plot_genotype(gt_long, chList, 20)
# chList = c("11","12","13","14","15")
# c = plot_genotype(gt_long, chList, 20)
# chList = c("16","17","18","19","20")
# d = plot_genotype(gt_long, chList, 20)
# top = plot_grid(a,b,ncol=1)
# bot = plot_grid(c,d,ncol=1)
# save_plot(
#   filename = paste0(dir,pair,".top.pdf"),
#   plot = top, 
#   base_height = 4.8, base_width = 16, 
#   )
# save_plot(
#   filename = paste0(dir,pair,".bot.pdf"),
#   plot = bot, 
#   base_height = 4.8, base_width = 16, 
# )


unique(gt_long_2$variable)

gt_long_2 = subset(gt_long, !variable %in% c("dummy","Hmelvulcol001","Hmelvulcol002","Hmelvulcol003","Hmelvulcol004","Hmelrospan001","Hmelrospan002","Hmelrospan003","Hmelrospan004"))

# chList = c("01","02","03","04","05","06","07"); p1 = plot_genotype(gt_long_2, chList, 20)
# chList = c("08","09","10","11","12","13","14"); p2 = plot_genotype(gt_long_2, chList, 20)
# chList = c("15","16","17","18","19","20","21"); p3 = plot_genotype(gt_long_2, chList, 20)
# cmb = plot_grid(p1,p2,p3, ncol=1)
# cmb
# save_plot(
#   filename = paste0(dir,pair,".comb.pdf"),
#   plot = cmb, 
#   base_height = 10.3, base_width = 20
# )



chList = c("01","02","03"); p1 = plot_genotype(gt_long_2, chList, 10)
chList = c("04","05","06"); p2 = plot_genotype(gt_long_2, chList, 10)
chList = c("07","08","09"); p3 = plot_genotype(gt_long_2, chList, 10)
chList = c("10","11","12"); p4 = plot_genotype(gt_long_2, chList, 10)
chList = c("13","14","15"); p5 = plot_genotype(gt_long_2, chList, 10)
chList = c("16","17","18"); p6 = plot_genotype(gt_long_2, chList, 10)
chList = c("19","20","21"); p7 = plot_genotype(gt_long_2, chList, 10)
cmb = plot_grid(p1,p2,p3,p4,p5,p6,p7, ncol=1)
cmb
save_plot(
  filename = paste0(dir,pair,".comb_long.pdf"),
  plot = cmb,
  base_height = 7.6, base_width = 8.5
)
