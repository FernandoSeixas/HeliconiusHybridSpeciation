
## Load libraries
library(ggthemes)
library(ggrepel)

## Recode genotypes (par = 0, ele=1)
HILongGt = filter(newLongGt, variable != "dummy")
HILongGt$value = ifelse(HILongGt$value == "par", 0, HILongGt$value)
HILongGt$value = ifelse(HILongGt$value == "ele", 1, HILongGt$value)
HILongGt$value = ifelse(HILongGt$value == "het", 0.5, HILongGt$value)
HILongGt$value = as.numeric(HILongGt$value)
head(HILongGt)


## Hybrid index & Heterozigosity 
ancTable = HILongGt[,grep("variable|value", colnames(HILongGt))]
ancTable_wide = dcast(ancTable, variable ~ value)
#// Ancestry
ancTable_wide$hi = ((ancTable_wide[,3]*.5) + (ancTable_wide[,4]*1)) / rowSums(ancTable_wide[,2:4])
#// Heterozygozity
ancTable_wide$het = ((ancTable_wide[,3])/rowSums(ancTable_wide[,2:4]))
#/ assign to species
ancTable_wide$spp = substr(ancTable_wide$variable, 2,4)
ancTable_wide$pop = substr(ancTable_wide$variable, 2,10)

#
ancTable_wide$subspp = ancTable_wide$spp
ancTable_wide$subspp = ifelse(ancTable_wide$pop %in% c("parserper"), "ser", ancTable_wide$subspp)
ancTable_wide$subspp = ifelse(ancTable_wide$pop %in% c("elebargui","eletumsur","eleauyven","elesfyven"), "eas", ancTable_wide$subspp)
ancTable_wide$subspp = ifelse(ancTable_wide$pop %in% c("elerurbra","elebvcbra"), "sch", ancTable_wide$subspp)



#/ Plot
sppPal = c(
  "ser" = alpha("#f2c747", 1),
  "par" = alpha("#ce3a43", 1),
  "ele" = alpha("#516db4", 1),
  "eas" = alpha("#25534c", 1),
  "sch" = alpha("#a6bddb", 1),
  "luc" = alpha("#525352", 1)
)

hi_plot = ggplot(data=ancTable_wide, aes(x=hi, y=het)) +
  # Draw Area
  geom_segment(x=0.0, y=0.0, xend=1.0, yend=0.0, lwd=.1) +
  geom_segment(x=0.0, y=0.0, xend=0.5, yend=1.0, lwd=.1) +
  geom_segment(x=1.0, y=0.0, xend=0.5, yend=1.0, lwd=.1) +
  # Draw points
  geom_point(aes(fill=subspp), color="#525252", shape=21, size=3, alpha=0.8) +
  # geom_text_repel(aes(label=variable), size=3) +
  geom_rangeframe(data=data.frame(hi=c(0, 1), het=c(0, 1))) +
  # beautify
  # facet_wrap(~subspp) +
  scale_color_manual(values = sppPal, name="") +
  scale_fill_manual(values = sppPal, name="") +
  theme_tufte() +
  theme(legend.position = "none") +
  scale_x_continuous(breaks = seq(0, 1, .2), limits = c(0, 1), name="hybrid index") +
  scale_y_continuous(breaks = seq(0, 1, .2), limits = c(0, 1), name="heterozygosity") 
hi_plot

# for perfect triangle
wd=4
hg=sqrt(((wd^2)-(wd/2)^2))
ggsave(
  filename = "/n/holyscratch01/mallet_lab/fseixas/2.elepar/2023.grc/hybrid_index.svg",
  plot=hi_plot, dpi = 300, units = "in", width = wd, height = hg
)




# 582x428
plevels = ancTable_wide[order(ancTable_wide$hi, decreasing = "T"),]$variable
plevels = plevels[grep("par", plevels)]
elevels = ancTable_wide[order(ancTable_wide$hi, decreasing = "T"),]$variable
elevels = elevels[grep("ele|luc", elevels)]
ilevels = as.character(c(plevels, elevels))



