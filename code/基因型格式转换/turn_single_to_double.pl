use strict;
use warnings;
use Getopt::Std;

my $option_vars = "r:w:";
my %options;

getopts($option_vars, \%options);

open(IN, "<$options{r}") || die $!;
open(OUT, ">$options{w}") || die $!;

chomp(my $head = <IN>);
print OUT "$head\n";

while(my $line = <IN>){
  chomp($line);
  my @split = split(/\s+/, $line);
  for my $i(11 .. $#split){
    if($split[$i] eq "A"){
      $split[$i] = "AA";
    }elsif($split[$i] eq "T"){
      $split[$i] = "TT";
    }elsif($split[$i] eq "C"){
      $split[$i] = "CC";
    }elsif($split[$i] eq "G"){
      $split[$i] = "GG";
    }elsif($split[$i] eq "Y"){
      $split[$i] = "CT";
    }elsif($split[$i] eq "W"){
      $split[$i] = "AT";
    }elsif($split[$i] eq "R"){
      $split[$i] = "AG";
    }elsif($split[$i] eq "S"){
      $split[$i] = "CG";
    }elsif($split[$i] eq "M"){
      $split[$i] = "AC";
    }elsif($split[$i] eq "K"){
      $split[$i] = "GT";
    }else{
      $split[$i] = "NN"
    }
  }
  print OUT "@split\n";
}
close IN;
close OUT;
exit;
