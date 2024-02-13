## load modules
require(reshape2)
require(stringr)
require(ggplot2)
require(cowplot)
options(scipen = 999)
rm(list = ls())

## variables
burnin = 25000
maxite = 125000
isteps = maxite/1000
burn=floor(burnin/isteps)


## directories and files
dir = "/n/mallet_lab/Lab/fseixas/1.projects/2.elevatus_pardalinus/1.analyses/4.GlobalStats/gphocs.v2/Simulations/"
pat = "Assym"
fil = "mcmc.log"
dirs = list.files(path=dir, pattern=pat)

## read trace files for each Population pair and Replicate run
AllTraces = data.frame()
for (d in dirs) {
  print(d)
  for (r in 1:3) {
    # read trace and add details
    trace = read.table(paste0(dir,d,"/rep",r,"/",fil), header=T)
    trace$point = seq(1, nrow(trace),1)
    trace = trace[1:(nrow(trace)-1),]
    trace$sim = d 
    trace$rep = paste0("rep",r)
    # add trace
    AllTraces = rbind(AllTraces, trace)
    print(paste0(d,"-",r,":",nrow(trace)))
  }
}
AllTraces$set = paste0(AllTraces$sim,"_",AllTraces$rep)




#####
## re-scale parameters
mutRate = 2.9*(10^-9) # subs/site/gen (Keightley et al. 2014)
# mutRate = 1.9*(10^-9) # subs/site/gen (Kozak et al. 2015)
genTime = 0.25        # 4 gen = 1 year 
traceReScale = AllTraces
# traceReScale$theta_A = AllTraces$theta_A/(4*mutRate)/1000000
# traceReScale$theta_B = AllTraces$theta_B/(4*mutRate)/1000000
# traceReScale$theta_C = AllTraces$theta_C/(4*mutRate)/1000000
# traceReScale$theta_AB = AllTraces$theta_AB/(4*mutRate)/1000000
# traceReScale$theta_ABC = AllTraces$theta_ABC/(4*mutRate)/1000000
# traceReScale$tau_AB = AllTraces$tau_AB/mutRate*genTime/1000000
# traceReScale$tau_ABC = AllTraces$tau_ABC/mutRate*genTime/1000000
# traceReScale$Nm_AB = AllTraces$m_A..B * 1000 * AllTraces$theta_B
# traceReScale$Nm_BA = AllTraces$m_B..A * 1000 * AllTraces$theta_A

################################### Burn-in ####################################
# burn-in
l1=(burn+1)
l2=nrow(AllTraces)
traceReScaleBurn = traceReScale[l1:l2,]
# organize data
traceBurnLong = melt(traceReScaleBurn, id.vars = c("sim","rep","set"))
# remove unnecessary columns
traceBurnLong = subset(traceBurnLong, !(variable=="tau_A"))
traceBurnLong = subset(traceBurnLong, !(variable=="Data.ld.ln"))
traceBurnLong = subset(traceBurnLong, !(variable=="Full.ld.ln"))
traceBurnLong = subset(traceBurnLong, !(variable=="Sample"))
traceBurnLong = subset(traceBurnLong, !(variable=="point"))



### summary of data
require(tidyr)
a = aggregate(value~sim+rep+variable, traceBurnLong, mean)
aReshape = dcast(a, sim + rep ~ variable)
aReshape = separate(data = aReshape, col=sim, into = c("Direction","Td1","Td2","NeI","Nma","Nmb"), sep = "[.]")
aReshape = unite(data = aReshape, "Nm", Nma:Nmb, sep = ".")
# refine how the simulated parameters are presented  
aReshape$Td1 = str_remove(aReshape$Td1, "Td1_")
aReshape$Td2 = str_remove(aReshape$Td2, "Td2_")
aReshape$NeI = str_remove(aReshape$Ne, "Ne_")
aReshape$Nm = str_remove(aReshape$Nm, "Nm_")
head(aReshape)

#
aReshape = aReshape[with(aReshape, order(NeI, as.numeric(Nm))),]
View(aReshape)

