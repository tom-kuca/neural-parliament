#!/usr/bin/perl
use strict;
use warnings;
use utf8;
=head1 INFO
Format: nazev	potreba	pro	proti	jedno
=cut

if ( $#ARGV != -1 ) { 
	print STDERR "Usage: $0\n";
	exit(1);
}

open(my $fh, '<', 'input.txt');
while ( <$fh> ) {
	chomp;	
	my @p = map(int, split);
	my %h = (-1 => 0, 0 => 0, 1 => 0);
	for my $v (@p) { 
		$h{$v} ++;
	} 
	my $r = (sort { $h{$b} <=> $h{$a} } keys %h)[0];	
	print sprintf("Hlasovani o %04d", $.), "\t", int(($h{1} + $h{-1})/2), "\t", $h{1}, "\t", $h{-1}, "\t", $h{0}, "\n";

}
close($fh);

=item
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
	
=cut
