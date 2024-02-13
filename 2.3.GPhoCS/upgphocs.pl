#load libraries ----
use strict; # help you to keep track of variable names and scope


##### arguments /////////////////////////
my $pho = $ARGV[0]; # fasta file to read


## get filters for min individuals per pop
my $ln=1; 
my $header;
my %seqs;


open(gphocs, '<', $pho) or die $!;
while(my $line = <gphocs>){
    chomp $line;
    # if header line of G-Phocs file
    if ($ln == 1) {
	print $line,"\n"; 
	$ln++;
	next;
    } 
    # if alignment part
    else {
	#print $line,"\n";
        # header line
        if ($line =~ /^Hmel/) {
            if ($ln == 2) {
                $header = $line;
		$ln++;
            }
            else {
                # count seqs to update header and print header
                my $seqNumber = scalar keys %seqs;
                my @hea = split(" ", $header);
                print "$hea[0] $seqNumber $hea[2]\n";
                # print seqs
                foreach (keys %seqs) { print "$_\t$seqs{$_}\n";  }
		print "\n";
                # update header and restart seq hash
                $header = $line;
                my %seqs;
		$ln++;
            }
        }
        # seqs lines
        else {
            my @eles = split("\t", $line);
            $seqs{ $eles[0] } = $eles[1];
        }
    }
}

## write last locus
# count seqs to update header and print header
my $seqNumber = scalar keys %seqs;
my @hea = split(" ", $header);
print "$hea[0] $seqNumber $hea[2]\n";
# print seqs
foreach (keys %seqs) { print "$_\t$seqs{$_}\n";  }
print "\n";

close(gphocs);

