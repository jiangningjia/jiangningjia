use strict;

open(IN,"<$ARGV[0]") || die $!;
open(OUT,">$ARGV[0]\_single.txt") || die $!;

chomp(my $head = <IN>);

print OUT "$head\n";

while(my $line = <IN>){
    chomp($line);
    
    my @split = split(/\s+/,$line);

    for my $i(11 .. $#split){
        if($split[$i] eq "AA"){
            $split[$i] = "A";
        }elsif($split[$i] eq "TT"){
            $split[$i] = "T";
        }elsif($split[$i] eq "CC"){
            $split[$i] = "C";
        }elsif($split[$i] eq "GG"){
            $split[$i] = "G";
        }elsif($split[$i] eq "AC" or $split[$i] eq "CA"){
            $split[$i] = "M";
        }elsif($split[$i] eq "AG" or $split[$i] eq "GA"){
            $split[$i] = "R";
        }elsif($split[$i] eq "AT" or $split[$i] eq "TA"){
            $split[$i] = "W";
        }elsif($split[$i] eq "CG" or $split[$i] eq "GC"){
            $split[$i] = "S";
        }elsif($split[$i] eq "CT" or $split[$i] eq "TC"){
            $split[$i] = "Y";
        }elsif($split[$i] eq "GT" or $split[$i] eq "TG"){
            $split[$i] = "K";
        }elsif($split[$i] eq "NN" or $split[$i] eq "--"){
            $split[$i] = "N";
        }
    }
    print OUT "@split\n";
}

close(IN);
close(OUT);
exit;