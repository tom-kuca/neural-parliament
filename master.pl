#!/usr/bin/perl
use warnings;
use strict;

use GRID::Cluster;
use Data::Dumper;
use File::Basename;
use Cwd;


my $INFO_FILE = 'lab-info.txt';
my $MEMORY_REQUIREMENT = 1000000;
my $WORKING_DIRECTORY = dirname(Cwd::abs_path($0)) . '/';


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
close($fh);

# debugovani
%machines = ("u-pl28" => 2, "u-pl29" => 2);
#machines = ("u-pl28" => 4);

# nacti datove soubory
open($fh, '<', 'members.txt');
my $memberCount = 0;
my %members = ();
while ( <$fh> ) {
	$memberCount++;
	chomp;
	$members{$memberCount} = {'name' => $_, 'type' => 0};
}



my $limit = $memberCount;
if ( exists($ARGV[0]) ) {
	$limit = int($ARGV[0]);
}

my $cluster = GRID::Cluster->new(max_num_np => \%machines,);

for my $round ( 1 .. ($memberCount) ) { 
	# vytvor prikazy pro jednotlive poslance

	my @commands = ();
	for my $k (grep { $members{$_}{type} == 0 } keys %members) {
		push(@commands, "./node.sh $k");
	}

	$cluster->chdir($WORKING_DIRECTORY);

	my $result = $cluster->qx(@commands);

	my %results = ();
	for my $res (@{$result}) {
		my @p = split(/\n/, $res);
		$results{$p[1]} = { 'score' => $p[2],
							'host' => $p[0] };
	}

	my @sorted = sort { $results{$b}{score} <=> $results{$a}{score} } keys %results;
	my $r = $sorted[0];

	print "$round\t$r\t$members{$r}{name}\t$results{$r}{score}\n";
	for my $k (@sorted) { 
		print STDOUT "\t$k\t$members{$k}{name}\t$results{$k}{score}\t$results{$k}{host}\n";
	}
	$members{$r}{type} = $round;
	
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
