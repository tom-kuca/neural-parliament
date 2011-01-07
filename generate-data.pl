#!/usr/bin/perl
use strict;
use warnings;
use utf8;

if ( $#ARGV != 1 ) { 
	print STDERR "Usage: $0 members votings\n";
	print STDERR "$0 20 120\n";
	print STDERR "20 people are voting 120 times.\n";
	exit(1);
}

my $members = $ARGV[0];
my $turns = $ARGV[1];
my @data;

for my $t (0 .. ($turns-1)) { 
	for my $m (0 .. ($members - 1)) {
		if ( $m > ($members / 2) ) {
			if ( $m % 5 == 0 ) { 
				$data[$m] = -1 * $data[$m - 1];
			} elsif ( $m % 6 == 0 ) { 
				my %h = ();				 
				for my $j ( ($m-5) .. ($m - 1) ) { 
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
	

