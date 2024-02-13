#load libraries ----
use strict; # help you to keep track of variable names and scope


##### arguments //////////////////////////////////////////////////
my $phy = $ARGV[0]; # phylyp file to read
my $nse = $ARGV[1]; # number of sequences in alignment



##### convert phy (concatenated) to G-phoCS format /////////////////

## read phy file and transform to gphocs
if ($phy =~ /.gz$/) { open(file, "gunzip -c $phy |") || die "can't open pipe to $phy"; }
else { open(file, $phy) or die "can't open $phy $!\n"; }


my %genoHash;
my $lineCount = 0;
my $locusCount = 0;

#my $seqNumber = 1;
#my $hapCount = 1;


while (my $line = <file>) {
    chomp($line);
    # header line 
    if ($lineCount == 0) {
        my @hea = split('\s+', $line);
        $locusCount++;
    }
    else {
        my @els = split('\s+', $line);
        my $nam = $els[0];
        my $seq = $els[1];
        $genoHash{$nam} = $seq;
        my $seqlen = length($seq);
        # last seq in locus
        if ($lineCount == $nse) {
            # print header line (only first time)
            if ($locusCount == 1) {
                print "#CHROM\tPOS\t";
                my @indnames;
                foreach my $k ( sort { $a <=> $b } keys %genoHash) { push(@indnames,"seq_$k"); }
                print join("\t",@indnames),"\n";
            }
            # print genos
            foreach(my $i=0; $i < $seqlen; $i++) {
                my $pos = $i + 1;
                print "chr_$locusCount\t$pos\t";
                foreach my $k ( sort { $a <=> $b } keys %genoHash) {
                    my @nuc = split("", $genoHash{$k}) ;
                    print "$nuc[$i]\t";
                }
                print "\n";
            }
        }
    }
    $lineCount++;
    # restart locus
    if ($lineCount == ($nse + 1)) { 
        $lineCount = 0;
    }
}