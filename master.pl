#!/usr/bin/perl
use warnings;
use strict;

use GRID::Cluster;
use Data::Dumper;

my $INFO_FILE = 'lab-info.txt';
my $MEMORY_REQUIREMENT = 200;
my $memberCount = 20;

# nacti informace o labu
if ( ! -f 'lab-info.txt' ) { 
	exec("wget", 'http://w2c.martin.majlis.cz/w2c/data/lab-info.txt');
}
if ( ! -f $INFO_FILE ) { 
	print STDERR "Neexistuje soubor s informacemi o labu.\n";
	exit 1;
}

# ostry provoz
my %machines = ();
open (my $fh, '<', $INFO_FILE);
while ( <$fh> ) {
	my @p = split;
	$machines{$p[0]} = min($p[1], int($p[2] / $MEMORY_REQUIREMENT)); 
}

# debugovani
%machines = ("u-pl28" => 3, "u-pl29" => 3);


# inicializuj poslance
my %members = ();
for my $i ( 0 .. ($memberCount - 1) ) { 
	$members{$i} = 0;
}
  
my $cluster = GRID::Cluster->new(max_num_np => \%machines,);


for my $round ( 1 .. ($memberCount) ) { 
	# vytvor prikazy pro jednotlive poslance

	my @commands = ();
	for my $k (grep { $members{$_} == 0 } keys %members) {
		push(@commands, "./node.sh $k");
	}

	$cluster->chdir("/afs/ms/u/m/majlm5am/BIG/nail002-neuronove-site/neural-parlament/");

	my $result = $cluster->qx(@commands);

	my %results = ();
	for my $res (@{$result}) {
		my @p = split(/\n/, $res);
		$results{$p[0]} = $p[1];
	}

	my @sorted = sort { $results{$b} <=> $results{$a} } keys %results;
	my $r = $sorted[0];

	print "$round\t$r\t$results{$r}\n";
	for my $k (@sorted) { 
		print STDERR "\t$k\t$results{$k}\n";
	}
	$members{$r} = $round;
}

sub min
{
	my ($v1, $v2) = @_;
	if ( $v1 < $v2 ) { 
		return $v1;
	} else { 
		return $v2;
	}
}
