#load libraries ----
#use strict; # help you to keep track of variable names and scope


##### arguments /////////////////////////
my $fas = $ARGV[0]; # fasta file to read
my $flt = $ARGV[1]; # final file to write to
my $maxgaps = $ARGV[2];  # max proportion of Ns per sequence [horizontal]. FLOAT
my $maxmiss = $ARGV[3];  # max proportion of Ns per position [vertical]. FLOAT
my $minsize = $ARGV[4];  # min length of alignment. INTEGER
my $minlist = $ARGV[5];  # tab delimited file min number of individuals per population . FILE


## get filters for min individuals per pop
open(MI, '<', $minlist) or die $!;
my %mininds;
while(my $line = <MI>){
    chomp $line;
    my @els = split('\t', $line);
    $mininds{$els[0]} = $els[1];
}
close(MI);
# foreach my $k (sort {$a <=> $b} keys %mininds) { print "$k\t$mininds{$k}\n"; }
    

my %indCount;
my %posMissi;
foreach my $k (keys %mininds) { $indCount{$k} = 0; }


## read fas and filter individuals with too many missing sites
my $nlen = 0;
my %filter; 
my $name;
my $pop;
my $slen;


if ($fas =~ /.gz$/) { open(file, "gunzip -c $fas |") || die "can't open pipe to $fas"; }
else { open(file, $fas) or die "can't open $fas $!\n"; }
while (my $line = <file>) {
    chomp($line);
    ##  header lines 
    if ($line =~ /^\>/) {
        $line =~ s/\>//g;
        $name = $line;
        $pop = substr $name, 0, 10;
    }
    # sequence lines
    else {
        # get information about % missing nucleotides
        $slen = length($line);
        my $gaps = () = $line =~ /N/g;
        # if not more than the allowed missing sites then add to hash
        if ( $gaps/$slen <= $maxgaps & exists $mininds{$pop} ) {
            $filter{$name} = $line;
            $indCount{$pop}++;
        }
        # get missing data info per position (to use later in the position filter)
        if ($nlen == 0) {
            foreach(my $i=0; $i < $slen; $i++) { $posMissi{$i} = 0; }
            $nlen++;
        }
        my @nucs = split("", $line);
        foreach(my $i=0; $i < $slen; $i++) {
            my $nuc = $nucs[$i];
            if ($nuc eq "N") { $posMissi{$i}++; }
        }
    }
}


# foreach my $k (sort {$a <=> $b} keys %indCount) { print "$k\t$indCount{$k}\n"; }
# foreach my $k (sort {$a <=> $b} keys %posMissi) { print "$k\t$posMissi{$k}\n"; }


## filter alignemnts
my $alignStatus = "pass";

# 1. if minimum number of individuals per population is met
my $totalind=0;
foreach $pp (keys %indCount) {
    $totalind += $indCount{$pp};
    if ( $indCount{$pp} < $mininds{$pp} ) {
        $alignStatus = "fail";
        print "Exit: not enough individuals of pop $pp\n";
        exit;
    }
}
 
if ($totalind < 1) { print "Exit: not enough individuals\n"; exit;}
#print $totalind,"\n";


# 2. if minimum number of positions passing missing data filter and consequently min alignment is met  
my $passpos = 0;
foreach my $k (sort {$a <=> $b} keys %posMissi) {
    if ( $posMissi{$k}/$totalind <= $maxmiss ) { 
        $passpos++;
    }
}
if ($passpos < $minsize) { 
    $alignStatus = "fail";
    print "Exit: not enough sites\n";
    exit;
}

## if all filters met print
if ( $alignStatus eq "pass" ) {
    open (my $fh, '>', $flt) or die "can't open $flt $!\n"; 
    # print header info
    foreach my $k (sort keys %filter) {
        print $fh ">$k\n";
        print $fh "$filter{$k}\n";
    }
    close $fh;
}

