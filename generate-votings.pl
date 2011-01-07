#!/usr/bin/perl
use strict;
use warnings;
use utf8;
=head1 INFO
Format: id	nazev	potreba	pro	proti	jedno
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
	print $., "\t", sprintf("Hlasovani o %04d", $.), "\t", int(($h{1} + $h{-1})/2), "\t", $h{1}, "\t", $h{-1}, "\t", $h{0}, "\n";

}
close($fh);
