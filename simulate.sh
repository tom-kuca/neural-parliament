#!/bin/bash
# ./simulate.sh memberId
self=`readlink -f $0`;
actDir=`dirname $self`;
config=${actDir}/config.sh;
source ${config};


if [ x$1 = x ]; then 
	echo "Usage: ./simulate.sh memberId";
	exit 1;
fi;

columnId=$1;
fName="simulate_${columnId}";
lines=`cat input.txt | wc -l`;
linesT=`echo $(($lines + 1))`;

if [ $DEVEL == 0 ]; then
	sed -r "s/^columnId = [0-9]+/columnId = $columnId/" simulate.m | \
	sed -r "s/trained_net/trained_net_${columnId}/" > $fName.m;

	echo "quit; " | nice -n 19 /afs/ms/@sys/bin/matlab -nodesktop -nosplash -r $fName > sim.$columnId.complete;
	tail -n${linesT} sim.$columnId.complete | head -n${lines} > sim.$columnId;
else
	d=`date +'%N' | cut -c3`;
	if [ $d -gt 2 ]; then
		perl -e "for $i (1 .. ${lines}) { print ((int(rand(2))*2-1), \"\\n\"); }" > sim.$columnId;
	fi;
fi;
cat sim.$columnId;

rm -rf sim.${columnId} sim.${columnId}.complete $fName.m;
