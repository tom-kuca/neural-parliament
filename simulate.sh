#!/bin/bash
# ./simulate.sh memberId

DEVEL=0;

if [ x$1 = x ]; then 
	echo "Usage: ./simulate.sh memberId";
	exit 1;
fi;

columnId=$1;

fName="simulate_${columnId}";
sed -r "s/^columnId = [0-9]+/columnId = $columnId/" simulate.m > $fName.m.1;
sed -ri "s/trained_net/trained_net_${columnId}/" $fName.m.1 > $fName.m;
rm -rf $fName.m.*;
lines=`cat input.txt | wc -l`;
linesT=`echo $(($lines + 1))`;

if [ $DEVEL == 0 ]; then
	echo "quit; " | nice -n 19 /afs/ms/@sys/bin/matlab -nodesktop -nosplash -r $fName > sim.$columnId.complete;
	tail -n${linesT} sim.$columnId.complete | head -n${lines} > sim.$columnId;
else
	perl -e "for $i (1 .. ${lines}) { print ((int(rand(3))-1), \"\\n\"); }" > sim.$columnId;
fi;
cat sim.$columnId;

rm -rf sim.${columnId} sim.${columnId}.complete $fName.m;



