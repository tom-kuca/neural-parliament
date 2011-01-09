#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use GD;

# /usr/share/fonts/
my $font = '/usr/share/fonts/truetype/freefont/FreeSans.ttf';

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
my $membersTop = 60;
my $histTop = $membersTop + 330;
my $histLeft = $colWidth + 20;
my $lineHeight = 16;
my $titleFontSize = 20;
my $histFontSize = 14;
my $histLineHeight = 18;

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
    my $gray = $im->colorAllocate(40,40,40);      
    my $red = $im->colorAllocate(255,0,0);      
    my $blue = $im->colorAllocate(0,0,255); 
	my $headerColor = $red;
	my $memberColor = $white;

	# generate header
	$im->stringFT($headerColor,$font,$titleFontSize,0,10,30, sprintf("%3d", $r->{t}));
	$im->stringFT($headerColor,$font,$titleFontSize,0,60,30, sprintf("%-20s", $r->{name}));
	$im->stringFT($headerColor,$font,$titleFontSize,0,370,30, sprintf("%-7s", "Strana"));
	$im->stringFT($headerColor,$font,$titleFontSize,0,460,30, sprintf("%2.2f%%", 100*$r->{pred}));
	$im->stringFT($headerColor,$font,$titleFontSize,0,545,30, sprintf("%3d", $r->{diffV}));	
	$im->stringFT($headerColor,$font,$titleFontSize,0,590,30, sprintf("%3d", $r->{diffD}));

	# generate members list
	$y = $membersTop;
	$col = 0;
	for my $m (@{$members{$r->{t}}}) {
		if ( $m->{pos} % 2 == 1 ) { 
			$im->filledRectangle($col*$colWidth,$y - $lineHeight+2,(1+$col) * $colWidth,$y+2,$gray);
		}

		$im->stringFT($memberColor,$font,11,0, 5 + $col*$colWidth,$y,sprintf("%3d", $m->{pos}+$r->{t}));
		$im->stringFT($memberColor,$font,11,0, 35 + $col*$colWidth,$y,sprintf("%-20s", $m->{name}));
		$im->stringFT($memberColor,$font,11,0, 210 + $col*$colWidth,$y,sprintf("%-7s", "Strana"));
		$im->stringFT($memberColor,$font,11,0, 270 + $col*$colWidth,$y,sprintf("%2.1f%%", 100*$m->{pred}));
		$y += $lineHeight;
		if ($col == 0 && $y > 470 ) { 
			$col++;
			$y = $membersTop;
		} elsif ( $col == 1 && $y > 350 ) { 
			last;
		}
	}

	$y = $histTop;
	
	for my $h (reverse 1 .. 5) {
		$val = 0;
		$id = 4 + $h;
		if ( exists($histograms{$r->{t}}{$id}) ) {
			$val = $histograms{$r->{t}}{$id};
		}
		$im->stringFT($red,$font,$histFontSize,0, $histLeft,$y,sprintf("%- 3d", ($id+1)* 10));
		$im->stringFT($red,$font,$histFontSize,0, $histLeft+35,$y,sprintf(" - %- 3d%%:", ($id)* 10));
		$im->stringFT($red,$font,$histFontSize,0, $histLeft+105,$y,sprintf("%- 3d", $val));


		$val = 0;
		$id = $h - 1;
		if ( exists($histograms{$r->{t}}{$id}) ) {
			$val = $histograms{$r->{t}}{$id};
		}

		$im->stringFT($red,$font,$histFontSize,0, 145 + $histLeft,$y,sprintf("%- 3d", ($id+1)* 10));
		$im->stringFT($red,$font,$histFontSize,0, 145 + $histLeft+35,$y,sprintf(" - %- 3d%%:", ($id)* 10));
		$im->stringFT($red,$font,$histFontSize,0, 145 + $histLeft+105,$y,sprintf("%- 3d", $val));



		$y += $histLineHeight;
	}
	


	my $pngData = $im->png();
	saveFrame(\$pngData);

}

sub drawInitFrame
{
	my $r = shift;

	my $im = new GD::Image(640,480,1);
	
    my $white = $im->colorAllocate(255,255,255);
    my $black = $im->colorAllocate(0,0,0);       
    my $gray = $im->colorAllocate(40,40,40);      
    my $red = $im->colorAllocate(255,0,0);      
    my $blue = $im->colorAllocate(0,0,255); 
	my $headerColor = $red;
	my $memberColor = $white;

	# generate header
	$im->stringFT($headerColor,$font,$titleFontSize,0,10,30, sprintf("%3s", '#'));
	$im->stringFT($headerColor,$font,$titleFontSize,0,60,30, sprintf("%-20s", 'Jméno poslance'));
	$im->stringFT($headerColor,$font,$titleFontSize,0,370,30, sprintf("%-7s", "Strana"));
	$im->stringFT($headerColor,$font,$titleFontSize,0,460,30, sprintf("%6s", "#Pred"));
	$im->stringFT($headerColor,$font,$titleFontSize,0,545,30, sprintf("%3s", "#H"));	
	$im->stringFT($headerColor,$font,$titleFontSize,0,590,30, sprintf("%3s", "#V"));


	$y = $membersTop + 20;
	$im->stringFT($headerColor,$font,$titleFontSize,0,10 ,$y, '#');
	$im->stringFT($headerColor,$font,$titleFontSize,0,100 ,$y, 'aktuální kolo');
	$y += 26;

	$im->stringFT($headerColor,$font,$titleFontSize,0,10 ,$y, '#Pred');
	$im->stringFT($headerColor,$font,$titleFontSize,0,100 ,$y, 'shoda mezi poslancem a neuronovou');
	$y += 26;
	$im->stringFT($headerColor,$font,$titleFontSize,0,100 ,$y, 'sítí (NS)');
	$y += 26;


	$im->stringFT($headerColor,$font,$titleFontSize,0,100 ,$y, '95% - v 95% případů hlasuje NS stejně');
	$y += 26;
	$im->stringFT($headerColor,$font,$titleFontSize,0,120 ,$y, 'jako poslanec');
	$y += 26;

	$im->stringFT($headerColor,$font,$titleFontSize,0,10 ,$y, '#H');
	$im->stringFT($headerColor,$font,$titleFontSize,0,100 ,$y, 'kolikrát hlasoval jinak');
	$y += 26;

	$im->stringFT($headerColor,$font,$titleFontSize,0,10 ,$y, '#V');
	$im->stringFT($headerColor,$font,$titleFontSize,0,100 ,$y, 'kolik hlasování mělo jiný výsledek');
	$y += 26;

	# generate members list
	$y = $membersTop + 220;
	$col = 0;

	$im->stringFT($memberColor,$font,11,0, 5 + $col*$colWidth,$y,sprintf("%3s", '#'));
	$im->stringFT($memberColor,$font,11,0, 35 + $col*$colWidth,$y,sprintf("%-20s", 'Poslance A'));
	$im->stringFT($memberColor,$font,11,0, 210 + $col*$colWidth,$y,sprintf("%-7s", "Str A"));
	$im->stringFT($memberColor,$font,11,0, 270 + $col*$colWidth,$y,sprintf("%4s", '#Pred'));
	$y += 20;

	$im->stringFT($memberColor,$font,11,0, 5 + $col*$colWidth,$y,sprintf("%3s", '#'));
	$im->stringFT($memberColor,$font,11,0, 35 + $col*$colWidth,$y,sprintf("%-20s", 'Poslance B'));
	$im->stringFT($memberColor,$font,11,0, 210 + $col*$colWidth,$y,sprintf("%-7s", "Str A"));
	$im->stringFT($memberColor,$font,11,0, 270 + $col*$colWidth,$y,sprintf("%4s", '#Pred'));
	$y += 20;

	$im->stringFT($memberColor,$font,11,0, 5 + $col*$colWidth,$y,sprintf("%3s", '#'));
	$im->stringFT($memberColor,$font,11,0, 35 + $col*$colWidth,$y,sprintf("%-20s", 'Poslance C'));
	$im->stringFT($memberColor,$font,11,0, 210 + $col*$colWidth,$y,sprintf("%-7s", "Str B"));
	$im->stringFT($memberColor,$font,11,0, 270 + $col*$colWidth,$y,sprintf("%4s", '#Pred'));
	$y += 20;

	$im->stringFT($memberColor,$font,11,0, 5 + $col*$colWidth,$y,sprintf("%3s", '#'));
	$im->stringFT($memberColor,$font,11,0, 35 + $col*$colWidth,$y,sprintf("%-20s", 'Poslance D'));
	$im->stringFT($memberColor,$font,11,0, 210 + $col*$colWidth,$y,sprintf("%-7s", "Str A"));
	$im->stringFT($memberColor,$font,11,0, 270 + $col*$colWidth,$y,sprintf("%4s", '#Pred'));
	$y += 20;

	$im->stringFT($memberColor,$font,11,0, 5 + $col*$colWidth,$y,sprintf("%3s", '#'));
	$im->stringFT($memberColor,$font,11,0, 35 + $col*$colWidth,$y,sprintf("%-20s", 'Poslance E'));
	$im->stringFT($memberColor,$font,11,0, 210 + $col*$colWidth,$y,sprintf("%-7s", "Str B"));
	$im->stringFT($memberColor,$font,11,0, 270 + $col*$colWidth,$y,sprintf("%4s", '#Pred'));
	$y += 20;

	$im->stringFT($memberColor,$font,11,0, 5 + $col*$colWidth,$y,sprintf("%3s", '#'));
	$im->stringFT($memberColor,$font,11,0, 35 + $col*$colWidth,$y,sprintf("%-20s", 'Poslance F'));
	$im->stringFT($memberColor,$font,11,0, 210 + $col*$colWidth,$y,sprintf("%-7s", "Str C"));
	$im->stringFT($memberColor,$font,11,0, 270 + $col*$colWidth,$y,sprintf("%4s", '#Pred'));
	$y += 20;

	$im->stringFT($memberColor,$font,11,0, 5 + $col*$colWidth,$y,sprintf("%3s", '#'));
	$im->stringFT($memberColor,$font,11,0, 35 + $col*$colWidth,$y,sprintf("%-20s", 'Poslance G'));
	$im->stringFT($memberColor,$font,11,0, 210 + $col*$colWidth,$y,sprintf("%-7s", "Str B"));
	$im->stringFT($memberColor,$font,11,0, 270 + $col*$colWidth,$y,sprintf("%4s", '#Pred'));
	$y += 20;
	my $pngData = $im->png();
	for my $j (0 .. 5 ) { 
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


