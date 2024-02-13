GENERAL-INFO-START

	seq-file            msms.Assymetric.vControl.seqs.txt
	trace-file          mcmc.log				
	locus-mut-rate      CONST

    burn-in		        100000
	mcmc-iterations	    200000
	iterations-per-log  2000
	logs-per-line       400


	find-finetunes		FALSE
	finetune-coal-time	0.01		
	finetune-mig-time	0.3		
	finetune-theta		0.04
	finetune-mig-rate	0.02
	finetune-tau		0.0000008
	finetune-mixing		0.003
#   finetune-locus-rate 0.3
	
	tau-theta-print		10000.0
	tau-theta-alpha		1.0			# for STD/mean ratio of 100%
	tau-theta-beta		10000.0		# for mean of 1e-4

	mig-rate-print		0.001
	mig-rate-alpha		0.002
	mig-rate-beta		0.00001

GENERAL-INFO-END

CURRENT-POPS-START	

	POP-START
		name		A
		samples		one dseq_1 d seq_2 d seq_3 d seq_4 d
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
		children		A		B
		tau-initial	0.000005
		tau-beta		20000.0	
		finetune-tau			0.0000008
	POP-END

	POP-START
		name			ABC
		children		AB		C
		tau-initial	0.00001
		tau-beta		20000.0	
		finetune-tau			0.0000008
	POP-END

ANCESTRAL-POPS-END

MIG-BANDS-START	

	BAND-START		
       source  A
       target  B
       mig-rate-print 0.1
	BAND-END

	BAND-START		
       source  B
       target  A
       mig-rate-print 0.1
	BAND-END

MIG-BANDS-END