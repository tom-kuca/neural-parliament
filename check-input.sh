#!/bin/bash
STRICT=0;

error='';
memberCount=`head -n1 input.txt | sed 's/\t/\n/g' | wc -l`;
votingCount=`cat input.txt | wc -l`;

inputLenColumns=`cat input.txt | perl -ne '@p=split; print ($#p+1)."\n";' | sort | uniq -c | wc -l`;
if [ $inputLenColumns != 1 ]; then 
	echo "Sloupce input.txt jsou ruzne dlouhe." >&2;
	cat input.txt | perl -ne '@p=split; print ($#p+1)."\n";' | sort | uniq -c >&2;
	error='x';
fi;

vCount=`cat votings.txt | wc -l`;
if [ $vCount != $votingCount ]; then 
	echo "Lisi se pocet hlasovani" >&2;
	echo "input.txt: $memberCount" >&2;
	echo "votings.txt: $vCount" >&2;
	error='x';
fi;

mCount=`cat members.txt | wc -l`;
if [ $mCount != $memberCount ]; then 
	echo "Lisi se pocet clenu" >&2;
	echo "input.txt: $memberCount" >&2;
	echo "members.txt: $mCount" >&2;
	error='x';
fi;

if [ $STRICT == 1 ]; then
	for i in `seq 1 ${memberCount}`; do 
		l=`cat input.txt | cut -f$i | sort | uniq -c | wc -l`; 
		if [ $l == 1 ]; then
			echo "input.txt - $i - jen jedna hodnota" >&2;
			cat input.txt | cut -f$i | sort | uniq -c >&2; 
			error='x';
		fi;
	done
fi;

if [ x${error} == xx ]; then
	exit 2;
fi;

