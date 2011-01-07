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
sed -ri "s/^function ga/function $fName/" $fName.m;
sed -ri "s/trained_net/trained_net_${columnId}/" $fName.m;


disp=`echo $((${columnId} + 20))`;
export DISPLAY=:${disp}
Xvfb :${disp} -screen 0 1024x768x16 &
xb=`echo $!`;
echo "quit; " | nice -n 19 /afs/ms/@sys/bin/matlab -nodesktop -nosplash -r $fName > res.$columnId.complete;
#perl -e 'print (("\n", rand()) x 3);' > res.$columnId.complete;
kill $xb &> /dev/null;
tail -n2 res.$columnId.complete | head -n1 > res.$columnId;
hostname;
echo $columnId;
cat res.$columnId;

rm -rf res.${columnId} res.${columnId}.complete $fName.m;




