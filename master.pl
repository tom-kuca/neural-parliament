#!/usr/bin/perl
use warnings;
use strict;

use GRID::Cluster;
use Data::Dumper;
use File::Basename;
use File::Copy;
use Cwd;

BEGIN { $| = 1 }

my $MACHINES_FILE = 'machines.txt';
my $MEMORY_REQUIREMENT = 1000000;
my $WORKING_DIRECTORY = dirname(Cwd::abs_path($0)) . '/';
my $DEBUG = 0;


my %machines = ();
if ( -f $MACHINES_FILE ) { 

	open (my $fh, '<', $MACHINES_FILE);
	while ( <$fh> ) {
		my @p = split;
		$machines{$p[0]} = min($p[1], int($p[2] / $MEMORY_REQUIREMENT)); 
	}
	close($fh);
} else { 
	%machines = ("localhost" => 2);
}

# !! debugging - comment out 
#%machines = ("u-pl28" => 3, "u-pl29" => 3, 'u-pl1' => 7, 'u-pl2'=> 7, 'u-pl3' => 7);
# !! debugging - comment out 


# read input data files

# process members
open(my $fh, '<', 'members.txt') or die ('Missing input file members.txt');
my $memberCount = 0;
my %members = ();
my %membersWinning = ();
my %membersMapping = ();
my %mappingR2A = ();
while ( <$fh> ) {
	$memberCount++;
	chomp;
	my @p = split (/\t/);
	$members{$memberCount} = {'name' => $p[0], 'party' => $p[1], 'type' => 0};
	$membersMapping{0}{$memberCount} = $memberCount;
	$mappingR2A{$memberCount} = $memberCount;
}
close($fh);

# process input file with votes
copy("input.txt", "input.txt.begin");
my @voting;
my @votingO;
my $votingId = 0;
open($fh, '<', 'input.txt') or die ('Missing input file input.txt');
while ( <$fh> ) {
	chomp;	
	my @p = map(int, split);
	$voting[$votingId] = \@p;
	$votingO[$votingId] = \@p;
	$votingId++;
}
close($fh);

# process input files with voting information
my @votingInfo;
my @votingInfoO;
$votingId = 0;
open($fh, '<', 'votings.txt') or die ('Missing input file votings.txt');
while ( <$fh> ) {
	chomp;	
	my @p = split (/\t/);
	my $h = { 
		'id' => $p[0], 
		'name' => $p[1], 
		'req' => int($p[2]), 
		'1' => int($p[3]), 
		'-1' => int($p[4]), 
		'0' => int($p[5]),
		'res' => ($p[3] >= $p[2] ? 1 : -1)
	};
	$votingInfo[$votingId] = $h;
	$votingInfoO[$votingId] = $h;

	$votingId++;

}
close($fh);

# specify number of iterations
my $limit = $memberCount;
if ( exists($ARGV[0]) ) {
	if ( $ARGV[0] eq 'keep' || $ARGV[0] eq 'throw' ) { 
		$ARGV[1] = $ARGV[0];
	} else { 
		$limit = int($ARGV[0]);
	}
}
if ( $limit > $memberCount ) { 
	$limit = $memberCount;
}

# specify strategy
my $strategy = 'keep';
if ( exists($ARGV[1]) ) { 
	$strategy = $ARGV[1];
}
if ( $strategy ne 'keep' && $strategy ne 'throw' ) { 
	print STDERR "Unknown strategy\n";
	exit(2);
}

my $diffV = 0;
my $diffD = 0;
my @wrongVoting = ();

print STDERR "Machines: \n";
for my $m (sort keys %machines) { 
	print STDERR "\t$m\t$machines{$m}\n";
}

print STDERR "\n";
print STDERR "Limit: $limit\n";
print STDERR "Strategy: $strategy\n";
print STDERR "\n";

print STDERR time() . "\tCluster INIT - BEGIN\n";
# init cluster
my $cluster = GRID::Cluster->new(max_num_np => \%machines,);
$cluster->chdir($WORKING_DIRECTORY);
print STDERR time() . "\tCluster INIT - END\n";

for my $round ( 1 .. ($limit) ) { 
	print STDERR "\nRound: $round\n";
	print STDERR time() . "\tRound: $round\n";
	# store input file for each iteration	
	createInputFile("input.txt.".$round);
	copy("input.txt.".$round, "input.txt") or die "Copy failed: $!";

	# prepare commands for execution
	my @commands = ();
	for my $k (sort grep { $members{$_}{type} == 0 } keys %members) {
		my $command = "./node.sh $mappingR2A{$k}";
		if ( $DEBUG ) {
			print STDERR "\tCommand: $command\n";
		}
		push(@commands, $command);
	}

	# execute commands
	print STDERR time() . "\tEXECUTE - BEGIN\n";
	my $result = $cluster->qx(@commands);
	print STDERR time() . "\tEXECUTE - END\n";

	# store results
	my %results = ();
	for my $res (@{$result}) {
		my @p = split(/\n/, $res);
		$results{$p[1]} = { 'score' => $p[4],
							'host' => $p[0],
							'time' => $p[3] - $p[2],
	 };
	}

	# find the most predictable member
	my @sorted = sort { $results{$b}{score} <=> $results{$a}{score} } keys %results;
	my $bestAct  = $sorted[0];
	my $bestReal = $membersMapping{$round-1}{$bestAct};

	if ( $DEBUG ) {
		print STDERR "Best: $bestAct\n";
	}

	$membersWinning{$round} = $bestAct;
	if ( $strategy eq 'keep' ) { 
		$membersMapping{$round} = $membersMapping{$round-1};
	} elsif ( $strategy eq 'throw' ) { 
		my $delta = 0;
		if ( $DEBUG ) { 
			print STDERR "Mapping BEF: ";
			for my $k (sort keys %{$membersMapping{$round-1}}) { 
				print STDERR "$k => " . $membersMapping{$round-1}{$k} . ", ";
			}
			print STDERR "\n";
		}

		for my $k (sort keys %{$membersMapping{$round-1}}) { 
			$membersMapping{$round}{$k-$delta} = $membersMapping{$round-1}{$k};
			$mappingR2A{$membersMapping{$round}{$k-$delta}} = $k - $delta;

			if ( $bestAct == $k ) { 
				$delta = 1;
			}
		}
		if ( $DEBUG ) { 
			print STDERR "Mapping AFT: ";
			for my $k (sort keys %{$membersMapping{$round}}) { 
				print STDERR "$k => " . $membersMapping{$round}{$k} . ", ";
			}
			print STDERR "\n";
		}
	}	




	$members{$bestReal}{type} = $round;

	$diffV = 0;
	$diffD = 0;
	@wrongVoting = ();

	print STDERR time() . "\tPROCESS RESULTS - BEGIN\n";
	if ( $strategy eq 'keep' ) { 
		processResultKeep($bestReal);
	} elsif ( $strategy eq 'throw' ) { 
		processResultThrow($round, $bestAct);
	}
	print STDERR time() . "\tPROCESS RESULTS - END\n";
	
	# print out information about iteration
	print "$round\t$bestReal\t$members{$bestReal}{name}\t$results{$bestAct}{score}\t$diffD\t$diffV\n";
	for my $k (@sorted) { 
		my $actK = $membersMapping{$round - 1}{$k};
		print "\tP\t$actK\t$members{$actK}{name}\t$results{$k}{score}\t$results{$k}{host}\t$results{$k}{time}\n";
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


sub processResultKeep
{
	# simulate his voting
	my $r = shift;
	open(my $fhSim, '-|', "./simulate.sh $r");
	my @mVoting = ();
	my $mVotingId = 0;

	
	while ( <$fhSim> ) { 
		chomp;
		my $v = int($_);
		
		# if member doesn't vote in real, he will skip voting in simulation
		if ( $voting[$mVotingId][$r - 1] == 0 ) { 
			$v = 0;
		}

		$mVoting[$mVotingId] = $v;

		# if decision differs, count it
		if ( $v != $voting[$mVotingId][$r - 1] ) { 
			# different vote
			$diffV++;

			# change voting counts
			$votingInfo[$mVotingId]{$voting[$mVotingId][$r - 1]}--;
			$votingInfo[$mVotingId]{$v}++;
			
			# check, whether result is different
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

		# store voting
		$voting[$mVotingId][$r - 1] = $v;
		$mVotingId++;
	}	
	close($fhSim);
}


sub processResultThrow
{
	my ($round, $r) = @_;

	# simulate his voting
	copy('trained_net_' . $r . '.mat', 'trained_net_turn_' . $round . '.mat');	

	my @keys = sort keys %membersWinning;
	@voting = map { [@$_] } @votingO;

	# vyhozeni nepotrenobnych sloupcu ze souboru
	# aktualni kolo se nevyhazuje
	for my $k (@keys) { 
		if ( $k != $round ) { 
			removeInputColumn($membersWinning{$k});	
		}
	}

	# postupne odsimuluj vysledky
	for my $k (reverse @keys) { 
		simulateThrow($round, $k);	
	}

	# prepocitej vysledky
	for my $v (0 .. (@voting - 1)) { 
		my %map = (-1 => 0, 0 => 0, 1 => 0 );
		for my $m (@{$voting[$v]}) {
			$map{$m}++;
		}
		my $diff = 0;
		$diff += abs($votingInfo[$v]{-1} - $map{-1});
		$diff += abs($votingInfo[$v]{1} - $map{1});
		$diffV += $diff;

		my $actRes = ($map{1} >= $votingInfo[$v]{req} ? 1 : -1);
		if ( $votingInfo[$v]{res} != $actRes ) { 
			$diffD++;
			push(@wrongVoting, { 'id' => $votingInfo[$v]{id}, 
								 'name' => $votingInfo[$v]{name},
								 'from' => $votingInfo[$v]{res},
								 'to' => $actRes }
			);
		}
		#print "$v\t$diff\t$diffV\t$diffD\n";
	}
	
	for my $k (@keys) { 
		removeInputColumn($membersWinning{$k});	
	}
}

sub removeInputColumn
{
	my $colId = shift;
	$colId--;

	if ( $DEBUG ) { 
		print STDERR "Del: $colId\n";
		print STDERR "Bef:\t" . join("\t", @{$voting[0]}) . "\n";
	}

	my @votingB = map { [@$_] } @voting;
	@voting = ();
	for my $v (0 .. (@votingB - 1)) { 
		my $i = 0;
		for my $m (0 .. (@{$votingB[$v]} - 1)) { 
			if ( $m != $colId ) { 
				$voting[$v][$i++] = $votingB[$v][$m];
			}
		}
	}

	if ( $DEBUG ) { 
		print STDERR "After:\t" . join("\t", @{$voting[0]}) . "\n";
	}
}


sub simulateThrow
{
	my ($round, $turn) = @_;
	my $mId = $membersWinning{$turn} - 1;

	if ( $DEBUG ) { 
		print STDERR "Simulate Turn: $turn, Member: $mId\n";
		print STDERR "Bef:\t" . join("\t", @{$voting[0]}) . "\n";
	}

	copy('trained_net_turn_' . $turn . '.mat', 'trained_net_' . ($mId+1) . '.mat');
	
	open(my $fhSim, '-|', "./simulate.sh " . ( $mId + 1));
	my @mVoting = ();
	my $mVotingId = 0;

	while ( <$fhSim> ) { 
		chomp;
		my $v = int($_);
		
		# if member doesn't vote in real, he will skip voting in simulation
		if ( $votingO[$mVotingId][$membersMapping{$turn-1}{$mId+1}-1] == 0 ) { 
			$v = 0;
		}
#		$mVoting[$mVotingId] = 'S['.$turn.']'.$v;
		$mVoting[$mVotingId] = $v;

		$mVotingId++;
	}	
	close($fhSim);

	# zadny sloupec se nepridava, jen se prepisi hodnoty
	if ( $turn == $round ) { 
		for my $v (0 .. (@voting - 1)) { 
			for my $m (0 .. (@{$voting[$v]} - 1)) { 
				if ( $m == $mId ) { 
					$voting[$v][$m] = $mVoting[$v];
				}
			}
		}		
	} else { 

		for my $v (0 .. (@voting - 1)) { 
			my $old = undef;
			for my $m (0 .. (@{$voting[$v]} - 1)) { 
				if ( $m == $mId ) { 
					$old = $voting[$v][$m];
					$voting[$v][$m] = $mVoting[$v];
				} else { 
					my $new = $voting[$v][$m];
					if ( ! defined($old) ) { 
						$voting[$v][$m] = $new;				
					} else { 
						$voting[$v][$m] = $old;
					}
					$old = $new;
				}
			}
			if ( ! defined($old) ) { 
				$old = $mVoting[$v];
			}
			$voting[$v][@{$voting[$v]}] = $old;
		}		
	}

	if ( $DEBUG ) {
		print STDERR "After:\t" . join("\t", @{$voting[0]}) . "\n";	
	}
}

