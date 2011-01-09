#!/bin/bash
# ./node.sh memberId
DEVEL=0;
if [ x$1 = x ]; then 
	echo "Usage: ./node.sh memberId";
	exit 1;
fi;

dateBegin=`date '+%s.%N'`;
columnId=$1;
fName=ga_$columnId;

sed -r "s/^columnId = [0-9]+/columnId = $columnId/" ga.m > $fName.m.1;
sed -ri "s/^function ga/function $fName/" $fName.m.1 > $fName.m.2;
sed -ri "s/^function ga/function $fName/" $fName.m.2 > $fName.m.3;
sed -ri "s/trained_net/trained_net_${columnId}/" $fName.m.3 > $fName.m;
rm -rf $fName.m.*;

if [ $DEVEL == 0 ]; then
	disp=`echo $((${columnId} + 20))`;
	export DISPLAY=:${disp}
	Xvfb :${disp} -screen 0 1024x768x16 &> /dev/null &
	xb=`echo $!`;
	echo "quit; " | nice -n 19 /afs/ms/@sys/bin/matlab -nodesktop -nosplash -r $fName > res.$columnId.complete;
	kill $xb &> /dev/null;
else
	perl -e 'print (("\n", rand()) x 3);' > res.$columnId.complete;
fi;

tail -n2 res.$columnId.complete | head -n1 > res.$columnId;
dateEnd=`date '+%s.%N'`;
hostname;
echo $columnId;
echo $dateBegin;
echo $dateEnd;
cat res.$columnId;

rm -rf res.${columnId} res.${columnId}.complete $fName.m;




