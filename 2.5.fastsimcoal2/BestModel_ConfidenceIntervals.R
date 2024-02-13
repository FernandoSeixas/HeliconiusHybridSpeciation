require(ggplot2)
require(reshape2)
require(tidyverse)


# Arguments ******************************************************************************
mu = 2.9E-9
gn = 0.25

# Read data
dir = "/n/holyscratch01/mallet_lab/fseixas/2.elepar/manuscript/moved/fastsimcoal_v3/3.bootstrap/"
fil = "bootstrap.bestEstimates.txt"
bootstrap = read.table(paste0(dir,fil), header=T) 

## Convert values **************************************************************
bootConvert = bootstrap
#/ times
for (cl in grep("T_|TDIV", colnames(bootConvert))) { bootConvert[,cl] = bootConvert[,cl]*gn }
#/ migration rates
for (cl in grep("MIG", colnames(bootConvert)) ) {
  name = colnames(bootConvert)[cl]
  newname = str_replace(name, "MIG", "Nm")
  p2 = paste0("NPOP_",substr(name, 6, 6))
  bootConvert = bootConvert %>% mutate(!!newname := 2 * !!rlang::sym(p2) * !!rlang::sym(name) )
}

## 95% confidence interval******************************************************
options(scipen = 999)
sm = bootConvert %>% 
  pivot_longer(cols = everything()) %>% 
  group_by(name) %>%
  summarise(
    median=mean(value), 
    qs025 = quantile(value, 0.025), 
    qs975 = quantile(value, 0.975),
    minimum = min(value),
    maximum = max(value)
  )
as.data.frame(summary(bootConvert))


## Plot ************************************************************************
#/ Time
bootConvert %>%
  select(starts_with("T")) %>%
  pivot_longer(cols = starts_with("T")) %>%
  ggplot() +
  geom_boxplot(aes(x=name, y=value/1000))
#/ Ne
bootConvert %>%
  select(starts_with(c("NPOP","NANC"))) %>%
  pivot_longer(cols = starts_with("N")) %>%
  ggplot() +
  geom_boxplot(aes(x=name, y=log10(value)))
#/ Nm
bootConvert %>%
  select(starts_with("Nm")) %>%
  pivot_longer(cols = starts_with("Nm")) %>%
  filter(!name %in% c("Nm_03","Nm_30") ) %>%
  ggplot() +
  geom_boxplot(aes(x=name, y=value))



##
bootstrapLong = melt(bootstrap)       # long format

bootstrapLong %>%
  mutate(Ne = case_when(str_detect(bootstrapLong$variable, "^NPOP") ~ value/1000))

head(bootstrapLong)

# plot data
bootstrapLong %>%
  filter(str_detect(variable, "^NPOP")) %>%
  ggplot() +
  geom_boxplot(aes(x=variable, y=value/1000))

bootstrapLong %>%
  filter(str_detect(variable, "^T")) %>%
  ggplot() +
  geom_boxplot(aes(x=variable, y=value*0.25/1000)) +
  scale_y_continuous(limits = c(0,NA))

bootstrapLong %>%
  filter(str_detect(variable, "^MIG")) %>%
  ggplot() +
  geom_boxplot(aes(x=variable, y=value))

median(bootstrap$TDIV_30)/1000*0.25
