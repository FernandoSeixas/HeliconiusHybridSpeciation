## load modules
require(stringr)
require(ggplot2)
require(ggsignif)
require(tidyr)
require(tidyverse)
options(scipen = 999)



## Compare AIC *****************************************************************
dir = "/n/holyscratch01/mallet_lab/fseixas/2.elepar/manuscript/fastsimcoal/modelComparisons/"
aic = read.table(paste0(dir, list.files(dir, pattern = ".AIC")), header=T)
aic$Model = str_replace(aic$Model, ".AIC", "")
minAIC = min(aic$AIC)
aic$deltaAIC = 0
for (rw in 1.:nrow(aic)) { aic$deltaAIC[rw] = aic$AIC[rw] - minAIC }
#/ refine table
require(tidyr)
aic = separate(aic, col = Model, into = c("pops","tree","dModel","complexity"), sep="_")
aic$dModel= factor(aic$dModel, levels = c("SI","AM","SC","AMpSC","IM"))
aic$tree= factor(aic$tree, levels = c("tree1","tree2"))
aic$complexity= factor(aic$complexity, levels = c("simple","complex","complex1","complex2"))
aic$model = paste0(aic$tree,".",aic$dModel,".",aic$complexity)
aic[order(aic$deltaAIC),]


## Plot AIC of different models
ggplot(aic) + 
  geom_point(aes(x=model, y=deltaAIC)) + 
  coord_flip()



## compare lhood distributions *************************************************

#/ dirs and files
dir = "/n/holyscratch01/mallet_lab/fseixas/2.elepar/manuscript/fastsimcoal/modelComparisons/llhoods/"
lfiles = list.files(dir, pattern = ".lhoods")
# lfiles = lfiles[!grepl("tree2_AM_simple", lfiles)]

#/ get models lhood distributions 
lldComparison = data.frame()
for (file in lfiles) {
  lld = read.table(paste0(dir,file))
  model = str_replace(file, ".lhoods", "")
  df = data.frame(model = rep(model, nrow(lld)), lhood = lld[,1])
  lldComparison = rbind(lldComparison, df)
}

#/ refine table
unique(lldComparison$model)
lldComparison = separate(lldComparison, col = model, into = c("pops","tree","dModel","complexity"), sep="_")
lldComparison$dModel= factor(lldComparison$dModel, levels = c("SI","AM","SC","AMpSC","IM"))
lldComparison$tree= factor(lldComparison$tree, levels = c("tree1","tree2"))
lldComparison$complexity= factor(lldComparison$complexity, levels = c("simple","complex","complex1","complex2"))
lldComparison$model = paste0(lldComparison$tree,".",lldComparison$dModel,".",lldComparison$complexity)

#/ plot llhood distributions
lldComparison %>%
  # filter(!(tree == "tree2" & dModel == "AM" & complexity == "simple")) %>%
  ggplot(aes(x=model, y=lhood)) +
  geom_boxplot(aes(color=tree, fill=tree), alpha=0.1) +
  facet_wrap(~tree+dModel+complexity, nrow=1) +
  # beautify
  scale_fill_manual(values = c("#cd3a43","#e1af00")) +
  scale_color_manual(values = c("#cd3a43","#e1af00")) +
  xlab("Model") + ylab("Likelihood") +
  theme_classic() +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) 

#/ Plot top 10 models 
topModels = head(aic[order(aic$deltaAIC),]$model, n = 10)

log10(-lldComparison$lhood)
lldComparison %>%
  filter(model %in% topModels) %>%
  # ggplot(aes(x=model, y=log10(-lhood)) ) +
  ggplot(aes(x=model, y=lhood) ) +
  geom_boxplot(aes(color=tree, fill=tree), alpha=0.1) +
  # facet_wrap(~tree+dModel+complexity, nrow=1) +
  # beautify
  scale_fill_manual(values = c("#cd3a43","#e1af00")) +
  scale_color_manual(values = c("#cd3a43","#e1af00")) +
  xlab("Model") + ylab("Likelihood") +
  theme_classic() +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) 





