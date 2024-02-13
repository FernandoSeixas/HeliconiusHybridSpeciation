GENERAL-INFO-START

	seq-file            alignment.seqs.txt
	trace-file          mcmc.log				
	locus-mut-rate	    CONST

#	burn-in		    		100000
	mcmc-iterations	    	250000
	mcmc-sample-skip    	249	# writes to output (mcmc.log) every [mcmc-sample-skip] steps 
	iterations-per-log  	250	# for each line in scree, how many iterations are shown/updated
	logs-per-line       	10	# the product of logs-per-line * iterations-per-log determines when to start new line on screen

#	start-mig		100000

	# when using finetunes should always discard the first [find-finetunes-num-steps]*[find-finetunes-samples-per-step]/[mcmc-sample-skip+1] log lines
	find-finetunes					TRUE
	find-finetunes-num-steps		100		# 
	find-finetunes-samples-per-step	500		# 
#	finetune-coal-time		5.0     
#	finetune-mig-time		5.0	
#	finetune-theta      	0.13
#	finetune-mig-rate		5.0
#	finetune-tau			0.0003
#	finetune-mixing			0.02
#   finetune-locus-rate 0.3
	
	tau-theta-print		1.0
	tau-theta-alpha		2		# for STD/mean ratio of 100%
	tau-theta-beta		100		# for mean of 1e-4

	mig-rate-print		0.001
	mig-rate-alpha		0.002
	mig-rate-beta		0.00001

GENERAL-INFO-END

CURRENT-POPS-START	

	POP-START
		name		A
		samples		pop1samples
	POP-END

	POP-START
		name		B
		samples		pop2samples
	POP-END
	
	POP-START
		name		C
		samples		pop3samples
	POP-END

CURRENT-POPS-END

ANCESTRAL-POPS-START

	POP-START
		name			AB
		children		A	B
		tau-initial		0.02
		tau-alpha		2
		tau-beta		100
	POP-END

	POP-START
		name			ABC
		children		AB  C
		tau-initial		0.04
		tau-alpha		2
		tau-beta		50
	POP-END

ANCESTRAL-POPS-END


MIG-BANDS-START

	BAND-START
        source	A
        target	B
	BAND-END

	BAND-START
        source	B
        target	A
	BAND-END

MIG-BANDS-END
