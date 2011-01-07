#!/usr/bin/perl
use warnings;
use strict;

use GRID::Cluster;
use Data::Dumper;
use File::Basename;
use File::Copy;
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
%machines = ("u-pl28" => 3, "u-pl29" => 3, 'u-pl1' => 7, 'u-pl2'=> 7, 'u-pl3' => 7);
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
close($fh);


copy("input.txt", "input.txt.begin");
my @voting;
my $votingId = 0;
open($fh, '<', 'input.txt');
while ( <$fh> ) {
	chomp;	
	my @p = map(int, split);
	$voting[$votingId++] = \@p;
}
close($fh);

my @votingInfo;
$votingId = 0;
open($fh, '<', 'votings.txt');
while ( <$fh> ) {
	chomp;	
	my @p = split (/\t/);
	$votingInfo[$votingId++] = { 
		'id' => $p[0], 
		'name' => $p[1], 
		'req' => int($p[2]), 
		'1' => int($p[3]), 
		'-1' => int($p[4]), 
		'0' => int($p[5]),
		'res' => ($p[3] >= $p[2] ? 1 : -1)
	};
}
close($fh);


my $limit = $memberCount;
if ( exists($ARGV[0]) ) {
	$limit = int($ARGV[0]);
}

my $cluster = GRID::Cluster->new(max_num_np => \%machines,);

for my $round ( 1 .. ($limit) ) { 
	# vytvor prikazy pro jednotlive poslance
	
	createInputFile("input.txt.".$round);
	copy("input.txt", "input.txt.".$round);

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

	$members{$r}{type} = $round;
	
	open(my $fhSim, '-|', "./simulate.sh $r");
	my @mVoting = ();
	my $mVotingId = 0;
	my $diffV = 0;
	my $diffD = 0;
	my @wrongVoting = ();
	
	while ( <$fhSim> ) { 
		chomp;
		my $v = int($_);
		
		# pokud mel v puvodnim hlasovani 0, tak i v simulaci ma 0
		if ( $voting[$mVotingId][$r - 1] == 0 ) { 
			$v = 0;
		}
		$mVoting[$votingId] = $v;
#		print STDERR "$v vs ".$voting[$mVotingId][$r - 1]."\n";
		if ( $v != $voting[$mVotingId][$r - 1] ) { 
			$diffV++;
			$votingInfo[$votingId]{$voting[$mVotingId][$r - 1]}--;
			
			$votingInfo[$mVotingId]{$voting[$mVotingId][$r - 1]}--;
			$votingInfo[$mVotingId]{$v}++;
			my $actRes = ($votingInfo[$mVotingId]{1} >= $votingInfo[$mVotingId]{-1} ? 1 : -1);
			if ( $actRes != $votingInfo[$mVotingId]{res} ) { 
				$diffD++;
				push(@wrongVoting, { 'id' => $votingInfo[$mVotingId]{id}, 
									 'name' => $votingInfo[$mVotingId]{name},
									 'from' => $votingInfo[$mVotingId]{res},
									 'to' => $actRes }
				);
			}
		}

		$voting[$mVotingId][$r - 1] = $v;
		$mVotingId++;
	}	
	close($fhSim);
	
	print "$round\t$r\t$members{$r}{name}\t$results{$r}{score}\t$diffD\t$diffV\n";
	for my $k (@sorted) { 
		print "\tP\t$k\t$members{$k}{name}\t$results{$k}{score}\t$results{$k}{host}\n";
	}
	for my $v (@wrongVoting) { 
		print "\tV\t$v->{id}\t$v->{name}\t$v->{from}\t$v->{to}\n";	
	}
		
}
createInputFile("input.txt.end");
copy("input.txt.begin", "input.txt");



sub min
{
	my ($v1, $v2) = @_;
	if ( $v1 < $v2 ) { 
		return $v1;
	} else { 
		return $v2;
	}
}

sub createInputFile
{
	my $fName = shift;
	open(my $fh, '>', $fName);
	for my $v (@voting) { 
		print ${fh} join("\t", @{$v}), "\n";	
	}
	close($fh);

}
