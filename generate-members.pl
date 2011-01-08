#!/usr/bin/perl
use strict;
use warnings;
use utf8;

=head1 INFO
generuje jmena.

=cut

if ( $#ARGV != 0 ) { 
	print STDERR "Usage: $0 members\n";
	print STDERR "$0 20\n";
	print STDERR "generates 20 people\n";
	exit(1);
}

my $members = $ARGV[0];


my $part = int($members / 3);

for my $m (0 .. ($members - 1)) {
	print sprintf("P%03d ", $m + 1);
	if ( $m > $part ) {
		if ( $m % 4 == 0 ) { 
			print "(inv $m)";
		} elsif ( $m % 5 == 0 ) { 
			print "(same " . ($m + 1 - $part) .")";
		} elsif ( $m % 6 == 0 ) { 
			print "(sum)";
		} elsif ( $m % 7 == 0 ) {  
			print "(most)";
		} else { 
			print "(R)";
		}
	} else { 		
		print "(R)";
	}	
	print "\t" . substr(crypt(rand(),$m), -5);
	print "\n";
}

