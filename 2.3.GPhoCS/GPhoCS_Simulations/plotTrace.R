## load modules
require(ggplot2)
require(reshape2)
require(cowplot)
options(scipen = 999)
rm(list = ls())

## variables
burnin = 25000
maxite = 125000
isteps = maxite/1000
burn=floor(burnin/isteps)

TauSim = c(1,2)
NesSim = c(0.4,1,5)
MigSim = c(0.00,0.01,0.10,1.00,2.00,10.0)

## directories and files
dir = "/n/holyscratch01/mallet_lab/fseixas/gphocs.v2/Simulations/"
set = "Assym.Td1_4.Td2_8.Ne_1.Nm_0.01"
fil = "mcmc.log"


################################## read trace ##################################
traceReps = data.frame()
for (r in 1:3) {
  trace = read.table(paste0(dir,set,"/rep",r,"/",fil), header=T)
  trace$point = seq(1, nrow(trace),1)
  trace = trace[1:(nrow(trace)-1),]
  trace$rep = paste0("rep",r)
  trace = trace[,names(trace)[!grepl("tau_B", names(trace))]]
  traceReps = rbind(traceReps, trace)
  print(nrow(trace))
}



## re-scale parameters
mutRate = 2.9*(10^-9) # subs/site/gen (Keightley et al. 2014)
# mutRate = 1.9*(10^-9) # subs/site/gen (Kozak et al. 2015)
genTime = 0.25        # 4 gen = 1 year 
traceReScale = traceReps
traceReScale$theta_A = traceReps$theta_A/(4*mutRate)/1000000
traceReScale$theta_B = traceReps$theta_B/(4*mutRate)/1000000
traceReScale$theta_C = traceReps$theta_C/(4*mutRate)/1000000
traceReScale$theta_AB = traceReps$theta_AB/(4*mutRate)/1000000
traceReScale$theta_ABC = traceReps$theta_ABC/(4*mutRate)/1000000
traceReScale$tau_AB = traceReps$tau_AB/mutRate*genTime/1000000
traceReScale$tau_ABC = traceReps$tau_ABC/mutRate*genTime/1000000
traceReScale$Nm_AB = traceReps$m_A..B * 1000 * traceReps$theta_B
traceReScale$Nm_BA = traceReps$m_B..A * 1000 * traceReps$theta_A

# get median value
aggregate(traceReps$tau_AB, list(traceReps$rep), median)[,2]/mutRate*genTime/1000000
aggregate(traceReps$tau_ABC, list(traceReps$rep), median)[,2]/mutRate*genTime/1000000

# organize data
traceLong = melt(traceReScale, id.vars = c("point","rep"))
traceLong = subset(traceLong, !(variable %in% c("Sample","tau_A")))

# plot Trace
ggplot(traceLong) +
  geom_line(aes(x=point, y=value, col=rep), alpha=0.6) +
  # geom_vline(xintercept = seq(0,1000,100), col="red", alpha=0.2) +
  geom_vline(xintercept = burn, col="blue", alpha=0.5, lty=2)  +
  facet_wrap(~variable, scales = "free_y", ncol=2)


################################### Burn-in ####################################
# burn-in
l1=(burn+1)
l2=nrow(traceReScale)
traceReScaleBurn = traceReScale[l1:l2,]
head(traceReScaleBurn)
# organize data
traceBurnLong = melt(traceReScaleBurn, id.vars = c("Sample","point","rep"))
traceBurnLong = subset(traceBurnLong, !(variable=="tau_A"))



############################## Plot Densities ##################################
# names
thetas = unique(traceBurnLong$variable)[grep("theta", unique(traceBurnLong$variable))]
taus = unique(traceBurnLong$variable)[grep("tau", unique(traceBurnLong$variable))]
Nms = unique(traceBurnLong$variable)[grep("Nm", unique(traceBurnLong$variable))]
# subset
Ne = subset(traceBurnLong, traceBurnLong$variable %in% thetas)
Td = subset(traceBurnLong, traceBurnLong$variable %in% taus)
Nm = subset(traceBurnLong, traceBurnLong$variable %in% Nms)
# define limits
migmax = ceiling(max(Nm$value))
breaks = ceiling(signif(migmax, digits=1))/10
# plot
a=ggplot(Ne) +
  geom_density(aes(value,col=rep)) +
  geom_vline(xintercept = NesSim, col="red", alpha=0.2, lty=2) +
  scale_x_continuous(limits=c(0,10), breaks=seq(0,10,1.0)) +
  facet_wrap(~variable, scales = "free", nrow=5) + theme_classic()
b=ggplot(Td) +
  geom_density(aes(value,col=rep)) +
  geom_vline(xintercept = TauSim, col="red", alpha=0.2, lty=2) +
  scale_x_continuous(limits=c(0,10), breaks=seq(0,20,1)) +
  facet_wrap(~variable, scales = "free", nrow=4) + theme_classic()
c=ggplot(Nm) +
  geom_density(aes(value,col=rep)) +
  geom_vline(xintercept = MigSim, col="red", alpha=0.2, lty=2) +
  scale_x_continuous(limits = c(0,migmax), breaks=seq(0,60,breaks)) +
  facet_wrap(~variable, scales = "free", nrow=2) + theme_classic()
# combine plots
left_panel = plot_grid(a, labels = "Ne", label_size = 12)
rigt_panel = plot_grid(b,c, labels = c("Td","Nm"), label_size = 12, nrow=2, rel_heights = c(2/3,1/3))
plot_grid(left_panel, rigt_panel, ncol = 2)

## summary of data
aggregate(value~rep+variable, Td, mean)
aggregate(value~rep+variable, Ne, mean)
aggregate(value~rep+variable, Nm, mean)




## median and 95% HPD intervals ==================================================
library(HDInterval)

finalTrace = traceReScale[,c(2:(ncol(traceReScale)-6),((ncol(traceReScale)-1):ncol(traceReScale)))]
finalTrace = finalTrace[l1:l2,]

df = as.data.frame(hdi(finalTrace, credMass = 0.95))

TraceSummary = data.frame()
for (cl in 1:ncol(finalTrace)) {
  stat = names(df)[cl]
  hpd0025 = df[1,cl]
  hpd0975 = df[2,cl]
  meanVal = mean(finalTrace[,cl])
  medianVal = median(finalTrace[,cl])
  tmp = data.frame(Stat = stat, Mean = meanVal, Median = medianVal, HPDlow = hpd0025, HPDhig = hpd0975)
  TraceSummary = rbind(TraceSummary, tmp)
}
TraceSummary


MigrationSummary = data.frame(
  m_AB = mean(finalTrace$m_A..B),
  m_BA = mean(finalTrace$m_B..A)
)

TraceSummary = data.frame()
for (cl in 1:ncol(finalTrace)) {
  stat = names(df)[cl]
  meanVal = mean(finalTrace[,cl])
  tmp = data.frame(Stat = stat, Mean = meanVal)
  TraceSummary = rbind(TraceSummary, tmp)
}

n <- TraceSummary$Stat
TraceSummary_transpose <- as.data.frame(t(TraceSummary[,-1]))
colnames(TraceSummary_transpose) <- n


# m
mlik = max(traceReScale$Full.ld.ln)
t(subset(traceReScale, Full.ld.ln == mlik))
