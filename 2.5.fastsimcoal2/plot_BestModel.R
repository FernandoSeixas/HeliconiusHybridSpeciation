## Load libraries
require(ggplot2)
require(reshape2)
require(tidyverse)
options(scipen = 999)


## Arguments
gn = 0.25  


## Functions *******************************************************************

#/ Convert parameters
ParamConvert = function(x) {
  #/ Times -----
  for (cl in grep("T_|TDIV", colnames(x))) { x[,cl] = x[,cl]*gn }
  #/ Migration rates
  for (cl in grep("MIG", colnames(x)) ) {
    name = colnames(x)[cl]
    newname = str_replace(name, "MIG", "Nm")
    p2 = paste0("NPOP_",substr(name, 6, 6))
    x = x %>% mutate(!!newname := 2 * !!rlang::sym(p2) * !!rlang::sym(name) )
  }
  #/ Ne
  for (cl in grep("NP|NA", colnames(x))) { x[,cl] = x[,cl]/1000 }
  # output
  return(x)
}

#/ Add
AddParamType = function(x) {
  x$parameterType = NA
  x$parameterType = ifelse(grepl("NPOP|NANC", x$name), "Ne", x$parameterType)
  x$parameterType = ifelse(grepl("Nm", x$name), "Nm", x$parameterType)
  x$parameterType = ifelse(grepl("T", x$name), "Tdiv", x$parameterType)
  x = x %>% filter(parameterType != "NA")
  return(x)
}



## Best estimate full dataset **************************************************
# dir = "/n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/1.analyses/2.Demography/demographicModelling/2.fastsimcoal/4pops_tree1_AMpSC_complex1/bestrun/"

dir = "/n/holyscratch01/mallet_lab/fseixas/2.elepar/manuscript/fastsimcoal_v2/4pops_tree1_AMpSC_complex1/bestrun/"
fil = "4pops_tree1_AMpSC_complex1.bestlhoods"
bestEstimate = read.table(paste0(dir,fil), header=T) 
# convert parameters
bestEstimateConvert = ParamConvert(bestEstimate)
# long format
bestEstimateConvert = bestEstimateConvert %>% 
  pivot_longer(cols = everything()) %>% 
  group_by(name)
# add parameter types
bestEstimateConvert = AddParamType(bestEstimateConvert)
# Plot
bestEstimateConvert %>%
  ggplot() +
  geom_point(aes(x=name, y=value), col="blue") +
  # beautify
  facet_wrap(~parameterType, scales="free") +
  scale_y_continuous(limits=c(0,NA), expand=c(0.01,0.01)) +
  theme_classic()


## Bootstrap *******************************************************************
#/ Read data
dir = "/n/holyscratch01/mallet_lab/fseixas/2.elepar/manuscript/fastsimcoal_v2/3.bootstrap/"
fil = "bootstrap.bestEstimates.txt"
bootstrap = read.table(paste0(dir,fil), header=T) 
## Convert values *****
bootConvert = ParamConvert(bootstrap)
#/ 95% confidence interval 
options(scipen = 999)
ci = bootConvert %>% 
  pivot_longer(cols = everything()) %>% 
  group_by(name) %>%
  summarise(
    median=mean(value), qs025 = quantile(value, 0.025), qs975 = quantile(value, 0.975),
    minim = min(value), maxim = max(value)
  )
#/ add parameter type column
ci = AddParamType(ci)

#/ Plot
ci %>%
  filter(parameterType != "NA") %>%
  ggplot() +
  # geom_errorbar(aes(x=name, ymin = minim, ymax = maxim), width=0, col="red") +
  geom_errorbar(aes(x=name, ymin = qs025, ymax = qs975), width=0) +
  geom_point(aes(x=name, y=median)) +
  facet_wrap(~parameterType, scales="free") +
  theme_classic()

quantile(bootstrap$MaxEstLhood, 0.975)
quantile(bootstrap$MaxObsLhood, 0.975)



## Plot ******
bestEstimateConvert %>%
  ggplot() +
  # bootstrap
  # geom_errorbar(data=ci, aes(x=name, ymin = minim, ymax = maxim), width=0, col="red") +
  geom_errorbar(data=ci, aes(x=name, ymin = log10(qs025), ymax = log10(qs975) ), width=0) +
  geom_point(data=ci, aes(x=name, y=log10(median) )) +
  # full model
  geom_point(aes(x=name, y=log10(value) ), col="blue") +
  # beautify
  facet_wrap(~parameterType, scales="free") +
  theme_classic()





