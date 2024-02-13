#load libraries ----
use strict; # help you to keep track of variable names and scope
use Data::Dumper;

##### arguments //////////////////////////////////////////////////
my $phy = $ARGV[0]; # phylyp file to read
my $nse = $ARGV[1]; # number of sequences in alignment



##### convert phy (concatenated) to G-phoCS format /////////////////

## read phy file and transform to gphocs
if ($phy =~ /.gz$/) { open(file, "gunzip -c $phy |") || die "can't open pipe to $phy"; }
else { open(file, $phy) or die "can't open $phy $!\n"; }


my %genoHash;
my $lineCount = 0;


my @rows = ();
my @transposed = ();

while (my $line = <file>) {
    chomp($line);
    # header line 
    if ($lineCount == 0) {}
    # seq line
    else {
        my @els = split('\s+', $line);
        my $nam = $els[0];
        my @seq = split("", $els[1]);
        $genoHash{$nam} .= $seq;
    }
    $lineCount++;
    # restart locus
    if ($lineCount == ($nse + 1)) { 
        $lineCount = 0;
    }
}




# This is each row in your table
push(@rows, [qw(0 1 2 3 4 5 6 7 8 9 10)]);
push(@rows, [qw(6 7 3 6 9 3 1 5 2 4 6)]);

for my $row (@rows) {
  for my $column (0 .. $#{$row}) {
    push(@{$transposed[$column]}, $row->[$column]);
  }
}

for my $new_row (@transposed) {
  for my $new_col (@{$new_row}) {
      print $new_col, " ";
  }
  print "\n";
}


## print geno file
# header line
print "#CHROM\tPOS\t";
my @indnames;
foreach my $k ( sort { $a <=> $b } keys %genoHash) { push(@indnames,"seq$k"); }
print join("\t",@indnames),"\n";



# print genos
my $rndkey = (keys %genoHash)[0];
my $seqlen = length($genoHash{$rndkey});

foreach(my $i=0; $i < $seqlen; $i++) {
    my $pos = $i + 1;
    print "chr_1\t$pos\t";
    foreach my $k ( sort { $a <=> $b } keys %genoHash) {
        my @nuc = split("", $genoHash{$k}) ;
        print "$nuc[$i]\t";
    }
    print "\n";
}