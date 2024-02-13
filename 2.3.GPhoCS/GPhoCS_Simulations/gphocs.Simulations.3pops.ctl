GENERAL-INFO-START

	seq-file            alignment.seqs.txt
	trace-file          mcmc.log				
	locus-mut-rate	    CONST

	mcmc-iterations	    	125000
	mcmc-sample-skip    	124	# writes to output (mcmc.log) every [mcmc-sample-skip] steps 
	iterations-per-log  	125	# for each line in scree, how many iterations are shown/updated
	logs-per-line       	10	# the product of logs-per-line * iterations-per-log determines when to start new line on screen

	# when using finetunes should always discard the first [find-finetunes-num-steps]*[find-finetunes-samples-per-step]/[mcmc-sample-skip+1] log lines
	find-finetunes					TRUE
	find-finetunes-num-steps		50		# 
	find-finetunes-samples-per-step	500		# 
	
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
		samples		seq_1 d seq_2 d seq_3 d seq_4 d
	POP-END

	POP-START
		name		B
		samples		seq_5 d seq_6 d seq_7 d seq_8 d
	POP-END
	
	POP-START
		name		C
		samples		seq_9 d
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
