#!/bin/bash
# ./node.sh memberId

self=`readlink -f $0`;
actDir=`dirname $self`;
config=${actDir}/config.sh;
source ${config};

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

if [ $DEVEL == 0 ]; then
	sed -r "s/^columnId = [0-9]+/columnId = $columnId/" ga.m | \
	sed -r "s/^function ga/function $fName/" | \
	sed -r "s/^function ga/function $fName/" | \
	sed -r "s/trained_net/trained_net_${columnId}/" > $fName.m;
	err=0;
	counter=0;
	while [ ! -r input.txt ]; do 
		sleep 2; 
		counter=`$(($counter + 1))`;
		if [ $counter -gt 5 ]; then
			err=1;
			break;
		fi;
	done;
	if [ $err == 0 ]; then 
		disp=`echo $((${columnId} + 20))`;
		export DISPLAY=:${disp}
		Xvfb :${disp} -screen 0 1024x768x16 &> /dev/null &
		xb=`echo $!`;
		echo "quit; " | nice -n 19 /afs/ms/@sys/bin/matlab -nodesktop -nosplash -r $fName > res.$columnId.complete;
		kill $xb &> /dev/null;
		cp trained_net_${columnId}.mat $CURDIR;
	else
		echo 0 > res.$columnId.complete;
		echo 0 >> res.$columnId.complete;
		echo 0 >> res.$columnId.complete;
	fi;
else
	d=`date +'%N' | cut -c3`;
	if [ $d -gt 2 ]; then
		perl -e 'print (("\n", rand()) x 5);' > res.$columnId.complete;
	fi;
fi;

tail -n4 res.$columnId.complete | head -n3 > res.$columnId;
dateEnd=`date '+%s.%N'`;
hostname;
echo $columnId;
echo $dateBegin;
echo $dateEnd;
cat res.$columnId;

rm -rf $TMPDIR       
