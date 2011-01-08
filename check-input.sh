#!/bin/bash
error='';
memberCount=`head -n1 input.txt | sed 's/\t/\n/g' | wc -l`;
votingCount=`cat input.txt | wc -l`;

vCount=`cat votings.txt | wc -l`;
if [ $vCount != $votingCount ]; then 
	echo "Lisi se pocet hlasovani" >&2;
	echo "input.txt: $memberCount" >&2;
	echo "votings.txt: $mCount" >&2;
	error='x';
fi;

mCount=`cat members.txt | wc -l`;
if [ $mCount != $memberCount ]; then 
	echo "Lisi se pocet clenu" >&2;
	echo "input.txt: $memberCount" >&2;
	echo "members.txt: $mCount" >&2;
	error='x';
fi;

for i in `seq 1 ${memberCount}`; do 
	l=`cat input.txt | cut -f$i | sort | uniq -c | wc -l`; 
	if [ $l == 1 ]; then
		echo "input.txt - $i - jen jedna hodnota" >&2;
		error='x';
	fi;
done

if [ x${error} == xx ]; then
	exit 2;
fi;

