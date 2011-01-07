#!/usr/bin/perl
use strict;
use warnings;
use utf8;

=head1 INFO
* prvni tretina je nahodne
* ve zbytku:
  * kdyz je delitelny 4, tak hlasuje jako poslanec pred nim
  * kdyz je delitelny 5, tak hlasuje jako poslanec o 1/3 pred nim
  * kdyz je delitelny 6, tak hlasuje podle "souctu" 3 poslancu pred nim
  * kdyz je delitelny 7, tak hlasuje jak hlasovala vetsina ze 6 poslancu pred nim
  * jinak hlasuje nahodne
  
  
./generate-data.pl 25 20
8, 12, 16, 20, 24	hlasuji podle poslance pred nim
10, 15				hlasuji podle poslance o 1/3 pred nim (4, 9)
18					hlasuje podle "souctu"
14, 21				hlasuje podle vetsiny ze 6 poslancu pred nim
ostatni			nahodne		

=cut

if ( $#ARGV != 1 ) { 
	print STDERR "Usage: $0 members votings\n";
	print STDERR "$0 20 120\n";
	print STDERR "20 people are voting 120 times.\n";
	exit(1);
}

my $members = $ARGV[0];
my $turns = $ARGV[1];
my @data;
my $part = int($members / 3);

for my $t (0 .. ($turns-1)) { 
	for my $m (0 .. ($members - 1)) {
		if ( $m > $part ) {
			if ( $m % 4 == 0 ) { 
				$data[$m] = -1 * $data[$m - 1];
			} elsif ( $m % 5 == 0 ) { 
				$data[$m] = $data[$m - ($part) ];				
			} elsif ( $m % 6 == 0 ) { 
				my $s = $data[$m - 3] + $data[$m - 2] + $data[$m - 1];
				if ( $s != 0 ) {
					$data[$m] = $s / abs($s);
				} else { 
					$data[$m] = 0;				
				}
			} elsif ( $m % 7 == 0 ) { 
				my %h = ();				 
				for my $j ( ($m-6) .. ($m - 1) ) { 
					$h{$data[$j]} ++;
				} 
				my $r = (sort { $h{$b} <=> $h{$a} } keys %h)[0];
				$data[$m] = $r;
			} else { 
				$data[$m] = randVote();
			}
		} else { 		
			$data[$m] = randVote();
		}	
	}
	print join("\t", @data), "\n";

}


sub randVote
{
	return int(rand(3)) - 1;
}
	

