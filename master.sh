#!/bin/bash
./check-input.sh;
res=$?;
if [ $res == 0 ]; then 
	date=`date '+%s'`;
	./master.pl $* 2> out.run.${date}.err | tee out.run.${date}.std;
fi;

exit $res;
