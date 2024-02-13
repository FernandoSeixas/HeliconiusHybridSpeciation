#load libraries ----
use strict; # help you to keep track of variable names and scope


##### arguments //////////////////////////////////////////////////
my $phy = $ARGV[0]; # phylyp file to read
my $nse = $ARGV[1]; # number of sequences in alignment
my $nlc = $ARGV[2]; # number of loci




##### define IUPAC codes /////////////////////////////////////////
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



##### convert phy (concatenated) to G-phoCS format /////////////////

## print GphoCS file header
print "$nlc\n";

## read phy file and transform to gphocs
if ($phy =~ /.gz$/) { open(file, "gunzip -c $phy |") || die "can't open pipe to $phy"; }
else { open(file, $phy) or die "can't open $phy $!\n"; }

my $lineCount = 0;
my $locusCount = 1;
my $seqNumber = 1;
my %diploidize;
my $hapCount = 1;


while (my $line = <file>) {
    chomp($line);
    # header line 
    if ($lineCount == 0) {
        my @hea = split('\s+', $line);
        print "locus$locusCount\t";
        print $nse/2,"\t";
        print $hea[2],"\n";
        $lineCount++;
        $locusCount++;
    }
    else {
        my @els = split('\s+', $line);
        my $nam = $els[0];
        my $seq = $els[1];
        my %dip;
        # while not all seqs have been read
        if ($hapCount != $nse) {
            $diploidize{$nam} = $seq;
            $hapCount++;
        }
        # last seq in locus
        else {
            # add last sequence
            $diploidize{$nam} = $seq;
            # create diploid sequences
            foreach my $k ( sort { $a <=> $b } keys %diploidize) {
                # first in diploid sequence
                if ($k % 2 != 0) {
                    $dip{"a"} = $diploidize{$k};
                }
                # second of diploid sequence
                else {
                    $dip{"b"} = $diploidize{$k};
                    # create diploid sequence
                    my @dipseq;
                    my $seqlen = length($seq);
                    foreach(my $i=0; $i < $seqlen; $i++) {
                        my @hap_a = split("", $dip{"a"}) ;
                        my @hap_b = split("", $dip{"b"}) ;
                        my $GT = $hap_a[$i] . $hap_b[$i];
                        push (@dipseq, $iupac{$GT});
                    }
                    print "seq_$seqNumber\t";
                    print join("", @dipseq),"\n";
                    $seqNumber++;
                }
            }
            $hapCount = 1;
        }
        my $diploidize;
        $lineCount++;
    }
    # restart locus
    if ($lineCount == ($nse + 1)) { 
        $lineCount = 0;
        $seqNumber = 1;
    }
}