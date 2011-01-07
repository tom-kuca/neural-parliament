#!/bin/bash
# ./node.sh memberId

if [ x$1 = x ]; then 
	echo "Usage: ./node.sh memberId";
	exit 1;
fi;

columnId=$1;
fName=ga_$columnId;

sed -r "s/^columnId = [0-9]+/columnId = $columnId/" ga.m > $fName.m;
sed -ri "s/^function ga/function $fName/" $fName.m;

echo "quit; " | /afs/ms/@sys/bin/matlab -nodesktop -nosplash -r $fName > res.$columnId.complete;
tail -n2 res.$columnId.complete | head -n1 > res.$columnId;
echo $columnId;
cat res.$columnId;




