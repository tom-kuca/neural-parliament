#!/bin/bash

date=`date '+%s'`;
./master.pl $* 2> out.run.${date}.err | tee out.run.${date}.std;
