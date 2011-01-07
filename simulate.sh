#!/bin/bash
# ./simulate.sh memberId

if [ x$1 = x ]; then 
	echo "Usage: ./node.sh memberId";
	exit 1;
fi;

columnId=$1;

fName='simulate';

sed -ri "s/^columnId = [0-9]+/columnId = $columnId/" $fName.m;
echo "quit; " | nice -n 19 /afs/ms/@sys/bin/matlab -nodesktop -nosplash -r $fName > sim.$columnId.complete;

lines=`cat input.txt | wc -l`;
lines=`echo $(($lines + 1))`;
tail -n${lines} sim.$columnId.complete | tail -n +1 > sim.$columnId;

cat sim.$columnId;




