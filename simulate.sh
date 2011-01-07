#!/bin/bash
# ./simulate.sh memberId

if [ x$1 = x ]; then 
	echo "Usage: ./node.sh memberId";
	exit 1;
fi;

columnId=$1;

fName="simulate_${columnId}";
sed -r "s/^columnId = [0-9]+/columnId = $columnId/" simulate.m > $fName.m;
sed -ri "s/trained_net/trained_net_${columnId}/" $fName.m;

echo "quit; " | nice -n 19 /afs/ms/@sys/bin/matlab -nodesktop -nosplash -r $fName > sim.$columnId.complete;

lines=`cat input.txt | wc -l`;
linesT=`echo $(($lines + 1))`;
tail -n${linesT} sim.$columnId.complete | head -n${lines} > sim.$columnId;

cat sim.$columnId;




