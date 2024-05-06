use strict;
open(IN,"<$ARGV[0]") || die $!;
open(OUT,">$ARGV[0].fasta") || die $!;
chomp(my $head = <IN>);
my @split_head = split(/\s+/,$head);
my %hash = ();
while(my $line = <IN>){
  chomp($line);
  my @split_line = split(/\s+/,$line);
  for my $i(11 .. $#split_line){
    $hash{$split_head[$i]} .= $split_line[$i]."\t";
  }
}
my @keys = keys %hash;
for my $j(0 .. $#keys){
  my $value = $hash{$keys[$j]};
  my @split_hash = split(/\s+/,$value);
   print OUT ">".$keys[$j];
   print OUT "\n";
   my $size = 60;
  for(my $z = 0;$z < $#split_hash;$z += $size){
    my $interval = $z + $size - 1;
    my $window = join("",@split_hash[$z .. $interval]);
    print OUT "$window\n";
  }
}
close IN;
close OUT;
exit;

