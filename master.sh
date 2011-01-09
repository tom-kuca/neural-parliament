#!/bin/bash

date=`date '+%s'`;
./master.pl $* 2> out.${date}.err | tee out.${date}.std;
