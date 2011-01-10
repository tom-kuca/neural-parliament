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

CURDIR=`pwd`
TMPDIR=`mktemp -d`
cp ga.m $TMPDIR/
cp input.txt $TMPDIR/
cd $TMPDIR

sed -r "s/^columnId = [0-9]+/columnId = $columnId/" ga.m | \
sed -r "s/^function ga/function $fName/" | \
sed -r "s/^function ga/function $fName/" | \
sed -r "s/trained_net/trained_net_${columnId}/" > $fName.m;

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


cp trained_net_${columnId}.mat $CURDIR

rm -rf $TMPDIR       


