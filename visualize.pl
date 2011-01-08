#!/usr/bin/perl

use strict;
use warnings;

use GD;

my $turn = 0;
my @result = ();
my %members = ();
my %histograms = ();
my $pRow = 0;
while ( <STDIN> ) { 
	chomp;
	my @p = split(/\t/);
	if ( $p[0] ) { 
		$turn = $p[0];
		push(@result, { 
			't' => $p[0],
			'id' => $p[1], 
			'name' => $p[2], 
			'pred' => $p[3], 
			'diffV' => $p[4], 
			'diffD' => $p[5]
		});
		$pRow = 0;
	} else { 
		if ( $p[1] eq 'P' ) { 
			$members{$turn}[$pRow] = { 'name' => $p[3], 'pred' => $p[4], 'pos' => $pRow };
			$histograms{$turn}{int(($p[4]-0.001)*10)}++;
			$pRow++;
		}
	}
}

my $frameId = 0;
my $y = 0;
my $val = 0;
my $id = 0;
my $col = 0;
my $colWidth = 320;
my $membersTop = 40;
my $histLeft = $colWidth + 40;

drawInitFrame();
for my $r (@result) { 
	drawFrame($r);
}

sub drawFrame
{
	my $r = shift;

	my $im = new GD::Image(640,480,1);
	
    my $white = $im->colorAllocate(255,255,255);
    my $black = $im->colorAllocate(0,0,0);       
    my $red = $im->colorAllocate(255,0,0);      

	# generate header

	$im->string(gdGiantFont,10,10,sprintf("%3d", $r->{t}), $red);
	$im->string(gdGiantFont,50,10,sprintf("%-20s", $r->{name}), $red);
	$im->string(gdGiantFont,250,10,sprintf("%-7s", "Strana"), $red);
	$im->string(gdGiantFont,340,10,sprintf("%2.2f%%", 100*$r->{pred}), $red);
	$im->string(gdGiantFont,420,10,sprintf("%3d", $r->{diffV}), $red);	
	$im->string(gdGiantFont,470,10,sprintf("%3d", $r->{diffD}), $red);

	# generate members list
	$y = $membersTop;
	$col = 0;
	for my $m (@{$members{$r->{t}}}) {
		$im->string(gdLargeFont,5 + $col*$colWidth,$y,sprintf("%3d", $m->{pos}+$r->{t}), $red);
		$im->string(gdLargeFont,35 + $col*$colWidth,$y,sprintf("%-20s", $m->{name}), $red);
		$im->string(gdLargeFont,210 + $col*$colWidth,$y,sprintf("%-7s", "Strana"), $red);
		$im->string(gdLargeFont,270 + $col*$colWidth,$y,sprintf("%2.1f%%", 100*$m->{pred}), $red);
		$y += 14;
		if ($col == 0 && $y > 450 ) { 
			$col++;
			$y = $membersTop;
		} elsif ( $col == 1 && $y > 330 ) { 
			last;
		}
	}

	$y = $membersTop + 330;
	
	for my $h (reverse 1 .. 5) {
		$val = 0;
		$id = 4 + $h;
		if ( exists($histograms{$r->{t}}{$id}) ) {
			$val = $histograms{$r->{t}}{$id};
		}
		$im->string(gdLargeFont,$histLeft,$y,sprintf("%3d -%3d%%: %2d", ($id+1)* 10, ($id)* 10, $val), $red);

		$val = 0;
		$id = $h - 1;
		if ( exists($histograms{$r->{t}}{$id}) ) {
			$val = $histograms{$r->{t}}{$id};
		}
		$im->string(gdLargeFont,$histLeft+125,$y,sprintf("%3d -%3d%%: %2d", ($id+1)* 10, ($id) * 10, $val), $red);

		$y += 14;
	}
	


	my $pngData = $im->png();
	saveFrame(\$pngData);

}

sub drawInitFrame
{
	my $im = new GD::Image(640,480,1);
	
    my $white = $im->colorAllocate(255,255,255);
    my $black = $im->colorAllocate(0,0,0);       
    my $red = $im->colorAllocate(255,0,0);      

	# generate header

	$im->string(gdGiantFont,10,10,sprintf("%3s", '#'), $red);
	$im->string(gdGiantFont,50,10,sprintf("%-20s", 'Jmeno poslance'), $red);
	$im->string(gdGiantFont,250,10,sprintf("%-7s", "Strana"), $red);
	$im->string(gdGiantFont,340,10,sprintf("%6s", "#Pred"), $red);
	$im->string(gdGiantFont,420,10,sprintf("%3s", "#H"), $red);	
	$im->string(gdGiantFont,470,10,sprintf("%3s", "#V"), $red);



	# generate members list
	$y = $membersTop;
	$im->string(gdLargeFont,10 ,$y, '# - aktualni kolo', $red);
	$y += 14;
	$im->string(gdLargeFont,10 ,$y, '#Pred - shoda mezi poslancem a neuronovou siti (NS)', $red);
	$y += 14;
	$im->string(gdLargeFont,30 ,$y, '95% - v 95% pripadu hlasuje NS stejne jako poslanec', $red);
	$y += 14;

	$im->string(gdLargeFont,10 ,$y, '#H - kolikrat hlasoval jinak', $red);
	$y += 14;
	$im->string(gdLargeFont,10 ,$y, '#V - kolik hlasovani melo jiny vysledek', $red);

	$y += 4 * 14;
	$im->string(gdLargeFont,5,$y,sprintf("%3s", '#'), $red);
	$im->string(gdLargeFont,35,$y,sprintf("%-20s", 'Jmeno poslance A'), $red);
	$im->string(gdLargeFont,210,$y,sprintf("%-7s", "Str A"), $red);
	$im->string(gdLargeFont,270,$y,sprintf("%4s", '#Pred'), $red);
	$y += 14;
	$im->string(gdLargeFont,5,$y,sprintf("%3s", '#'), $red);
	$im->string(gdLargeFont,35,$y,sprintf("%-20s", 'Jmeno poslance B'), $red);
	$im->string(gdLargeFont,210,$y,sprintf("%-7s", "Str B"), $red);
	$im->string(gdLargeFont,270,$y,sprintf("%4s", '#Pred'), $red);
	$y += 14;
	$im->string(gdLargeFont,5,$y,sprintf("%3s", '#'), $red);
	$im->string(gdLargeFont,35,$y,sprintf("%-20s", 'Jmeno poslance C'), $red);
	$im->string(gdLargeFont,210,$y,sprintf("%-7s", "Str B"), $red);
	$im->string(gdLargeFont,270,$y,sprintf("%4s", '#Pred'), $red);
	$y += 14;
	$im->string(gdLargeFont,5,$y,sprintf("%3s", '#'), $red);
	$im->string(gdLargeFont,35,$y,sprintf("%-20s", 'Jmeno poslance D'), $red);
	$im->string(gdLargeFont,210,$y,sprintf("%-7s", "Str A"), $red);
	$im->string(gdLargeFont,270,$y,sprintf("%4s", '#Pred'), $red);

	my $pngData = $im->png();
	for my $j (0 .. 3 ) { 
		saveFrame(\$pngData);
	}

}

sub saveFrame
{
	my $pngDataRef = shift;
	for my $j (0 .. 5 ) { 
		open(my $fh, '>', 'frame_'.sprintf("%06d", $frameId).'.png');
		binmode $fh;
		print $fh $$pngDataRef;
		close($fh);
		$frameId++;
	}

}


