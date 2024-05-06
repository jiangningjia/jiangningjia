# by JNJ on 2022/12/14
use strict;
use warnings;
use Getopt::Std;

my %options = ();
getopts("r:m:w:", \%options);
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
	for(11 .. $#split){
		if($split[$_] eq "A"){
			$hash{A} += 1;
			$hash{A} += 1;
		}elsif($split[$_] eq "T"){
			$hash{T} += 1;
			$hash{T} += 1;
		}elsif($split[$_] eq "C"){
			$hash{C} += 1;
			$hash{C} += 1;
		}elsif($split[$_] eq "G"){
			$hash{G} += 1;
			$hash{G} += 1;
		}elsif($split[$_] eq "M"){
			$hash{A} += 1;
			$hash{C} += 1;
		}elsif($split[$_] eq "R"){
			$hash{A} += 1;
			$hash{G} += 1;
		}elsif($split[$_] eq "W"){
			$hash{A} += 1;
			$hash{T} += 1;
		}elsif($split[$_] eq "S"){
			$hash{C} += 1;
			$hash{G} += 1;
		}elsif($split[$_] eq "Y"){
			$hash{C} += 1;
			$hash{T} += 1;
		}elsif($split[$_] eq "K"){
			$hash{G} += 1;
			$hash{T} += 1;
		}

	}
	my @key = keys %hash;
	if ($#key == 1){
		my $total = $hash{$key[0]} + $hash{$key[1]};
		my $max = $hash{$key[0]}/$total;
		if($option_m <= $max and $max <= 1 - $option_m){
			print OUT "$line\n";
		} 
	}
}
close(IN);
close(OUT);
exit;
