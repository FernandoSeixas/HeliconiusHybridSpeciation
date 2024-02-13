          seed = -1

       threads = 1
       
       seqfile = seqs.txt
      Imapfile = imap.txt
       outfile = outp.txt
      mcmcfile = mcmc.txt
    checkpoint = 10000 20000

  speciesdelimitation = 0               * fixed species tree
* speciesdelimitation = 1 0 2           * species delimitation rjMCMC algorithm0 and finetune(e)
* speciesdelimitation = 1 1 2 1         * species delimitation rjMCMC algorithm1 finetune (a m)
          speciestree = 1               * species tree SPR/SNL

*   speciesmodelprior = 1  * 0: uniform LH; 1:uniform rooted trees; 2: uniformSLH; 3: uniformSRooted

  species&tree = sppline
                 indline
                 treline

       usedata = 1  * 0: no data (prior); 1:seq like
         nloci = numberLoci  * number of data sets in seqfile

     cleandata = 0  * remove sites with ambiguity data (1:yes, 0:no)?

    thetaprior = 3 0.04 E  # Inv-gamma(a, b) for theta (integrated out by default; add E to also sample theta)
      tauprior = 3 0.06    # Inv-gamma(a, b) for root tau
*    phiprior = 1 1  # Beta(a, b) for root tau & Dirichlet(a) for other tau's

      finetune =  1: 3 0.003 0.002 0.00002 0.005 0.9 0.001 0.001 # finetune for GBtj, GBspr, theta, tau, mix

         print = 1 0 0 0   * MCMC samples, locusrate, heredityscalars, Genetrees
        burnin = 50000
      sampfreq = 10
       nsample = 100000
