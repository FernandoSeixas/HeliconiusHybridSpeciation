          seed = -1

       seqfile = seqs.txt
      Imapfile = imap.txt
       outfile = outp.txt
      mcmcfile = mcmc.txt
    checkpoint = 10000 20000


  speciesdelimitation = 0               * fixed species tree
* speciesdelimitation = 1 0 2           * species delimitation rjMCMC algorithm0 and finetune(e)
* speciesdelimitation = 1 1 2 1         * species delimitation rjMCMC algorithm1 finetune (a m)
          speciestree = 0               * species tree fixed

*   speciesmodelprior = 1  * 0: uniform LH; 1:uniform rooted trees; 2: uniformSLH; 3: uniformSRooted

  species&tree = 3  A       B       C
                    ipopA   ipopB   ipopC
                    ((H[&phi=0.100000,tau-parent=no],A)S, (B,(C)H[&phi=0.900000,tau-parent=yes])T)R;
  phase =           1       1       1         * 0: do not phase, 1: phase diploid unphased sequences

       usedata = 1           * 0: no data (prior); 1:seq like
         nloci = numberLoci  * number of data sets in seqfile
*        model = jc * default
*        model = gtr * default
*        alphaprior = 1 1 4 

     cleandata = 0  * remove sites with ambiguity data (1:yes, 0:no)?

    thetaprior = 3 0.04 e  # inverse gamma(a, b) for theta 
      tauprior = 3 0.06    # inverse gamma(a, b) for root tau & Dirichlet(a) for other tau's
      phiprior = 1 1       # beta(a, b) for phi in the MSci model

      finetune = 1: .01 .02 .03 .04 .05 .01 .01  # auto (0 or 1): MCMC step lengths

         print = 1 0 0 0   * MCMC samples, locusrate, heredityscalars, Genetrees
        burnin = 50000
      sampfreq = 10
       nsample = 100000
