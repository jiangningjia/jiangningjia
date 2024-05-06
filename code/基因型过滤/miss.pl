use strict;
use warnings;
use Getopt::Std;

my %options = ();
getopts("r:w:m", \%options);

my $option_r = $options{r};
my $option_w = $options{w};
my $option_m = $options{m};

open(IN,"<$option_r") || die $!;
open(OUT,">$option_w") || die $!;

chomp(my $head = <IN>);

print OUT "$head\n";

while(my $line = <IN>){
	chomp($line);

	my %hash = ();

	my @split = split(/\s+/,$line);

	for my $i(11 .. $#split){
		if($split[$i] eq "N"){
			$hash{N} += 1;
		}
	}
	if($hash{N}/($#split  - 10) <= $option_m){
		print OUT "$line\n";
	}
}

close(IN);
close(OUT);
exit;
