#load libraries ----
#use strict; # help you to keep track of variable names and scope


##### arguments /////////////////////////
my $vcf = $ARGV[0]; # vcf file to read
my $out = $ARGV[1]; # output file

my @coords = split('\.', $vcf);
my $st = $coords[scalar(@coords)-3];
my $en = $coords[scalar(@coords)-2];
my $lc = $st;


## define iupac codes ///////////////////
my %iupac = (
    "AA" => "A",
    "CC" => "C",
    "GG" => "G",
    "TT" => "T",
    "AG" => "R", "GA" => "R",
    "CT" => "Y", "TC" => "Y",
    "GC" => "S", "CG" => "S",
    "AT" => "W", "TA" => "W",
    "GT" => "K", "TG" => "K",
    "AC" => "M", "CA" => "M",
    "NN" => "N"
);


##### read vcf file ////////////////////
my %fasta; # hash table to write fasta sequence
my %samples2numbers; # hash table making the connection between individual names and code in %fasta
my $lastcol;
my $allsites=0;
my $POS;


## read vcf and get info
if ($vcf =~ /.gz$/) { open(file, "gunzip -c $vcf |") || die "can't open pipe to $vcf"; }
else { open(file, $vcf) or die "can't open $vcf $!\n"; }
while (my $line = <file>) {
    chomp($line);

    ## ignore comment lines ////////////////////////////// section #1: ignore commen lines in vcf
    if ($line =~ /^\#\#/) { next; }

    ## get header line (with sample names) /////////////// section #2: get individual names
    elsif ($line =~ /^\#CHROM/) {
        my @cols = split("\t", $line);
        chomp @cols;
        # define last column in vcf [last individual]
        $lastcol = scalar @cols - 1;
        # create key for individual in hash;
        for my $x (9 .. $lastcol) {
            my $name = $cols[$x] ;
            $samples2numbers{$x} = $name; # correspondance between VCF column and individual name
        }
    }

    ## get individuals genotypes ////////////////////////// section #3: get haplotypes
    else {
        # get elements from line
        my @cols = split("\t", $line);
        chomp @cols;
        my $CHR = $cols[0];
        $POS = $cols[1];
        my $REF = $cols[3];
        my $ALT = $cols[4];
        my @ALTERN = split(",", $ALT);

        ## check if positions have been skip in vcf and if yes then write Ns
        # if not first position and  missing
        if ( $allsites > 0) {
            #print "midmiss\n";
            if ( ($POS - $lc) > 1) {
                #print "$POS\n";
                #print "missing sites\t$lc\t$POS\n";
                my $lcsta = $lc  + 1;
                my $lcend = $POS - 1;
                for my $iter ( $lcsta .. $lcend ) {
                    #print "$iter\n";
                    for (my $i = 9; $i <= $lastcol; $i++) {
                        # add iupac code to fasta hash
                        my $name = $samples2numbers{$i}; # name for individual
                        $fasta{$name} .= "N"; # add iupac to hash
                    }
                $allsites++;
                }
            }
        }
        # if the very first position missing
        if ( $allsites == 0) {
            if ($POS > $lc) {
                my $lcend = $POS - 1;
                for my $iter ($st .. $lcend) {
                    #print "$iter\n";
                    for (my $i = 9; $i <= $lastcol; $i++) {
                        # add iupac code to fasta hash
                        my $name = $samples2numbers{$i}; # name for individual
                        $fasta{$name} .= "N"; # add iupac to hash
                    }
                    $allsites++;
                }
            }
        }

        ## determine if site is bi-allelic or more and skip in vcf if more than two alleles
        my $scalt = scalar @ALTERN;
        # if more than two alleles then write Ns
        if ($scalt > 1) {
            for (my $i = 9; $i <= $lastcol; $i++) {
                    # add iupac code to fasta hash
                    my $name = $samples2numbers{$i}; # name for individual
                    $fasta{$name} .= "N"; # add iupac to hash
                }
            $lc = $POS; # update last position
            $allsites++;
            next;
        }
        # if only two alleles or less then continue
        if ($scalt == 1) {$ALT = $ALTERN[0];}
        ## each individual genotype and convert to IUPAC
        my @GTline;
        for my $x (9 .. $lastcol) {
            my @GENO = split('\:', $cols[$x]);
            my $GT = $GENO[0]; # get genotype
            my $newGT; ### !!! ###
            ## homozygous
            if    ($GT eq "0/0") {$newGT = $REF . $REF;}
            elsif ($GT eq "1/1") {$newGT = $ALT . $ALT;}
            elsif ($GT eq "0")   {$newGT = $REF . $REF;}
            elsif ($GT eq "1")   {$newGT = $ALT . $ALT;}
            # heterozygous
            elsif ($GT eq "0/1") {$newGT = $REF . $ALT;}
            elsif ($GT eq "1/0") {$newGT = $ALT . $REF;}
            # missing
            elsif ($GT eq "./.") {$newGT = "NN"}
            elsif ($GT eq ".")   {$newGT = "NN"}
            ## convert to IUPAC
            my $geno = $iupac{$newGT};
            # add geno to array
            push(@GTline, $geno);
        }
        ## add to fasta hash
        for (my $i = 9; $i <= $lastcol; $i++) {
            # get individual GT and haplotypes
            my $index = $i - 9;
            my $gt = $GTline[$index];
            # add iupac code to fasta hash
            my $name = $samples2numbers{$i}; # name for individual
            $fasta{$name} .= $gt; # add iupac to hash
        }
        $allsites++;
        $lc = $POS;
    }
}

## add ends if "tail" missing in the vcf
if ($POS < $en & $allsites > 0) {
    my $lcsta = $POS + 1;
    for ($lcsta .. $en) {
        for (my $i = 9; $i <= $lastcol; $i++) {
            # add iupac code to fasta hash
            my $name = $samples2numbers{$i}; # name for individual
            $fasta{$name} .= "N"; # add iupac to hash
        }
    $allsites++;
    }
}

## print in fasta format (conditional on having a mimimum ammount of data in the alignment)
if ($allsites >= 10) {
    open (my $fh, '>', $out) or die "can't open $out $!\n";
    foreach my $k (sort keys %fasta) {
        my $newnam = $k;
        # $newnam =~ s/\.//g; 
        print $fh ">$newnam\n";
        print $fh "$fasta{$k}\n";
    }
    close $fh;
}

