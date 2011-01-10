#!/bin/bash
for i in 11 10; do 
    file="voting_$i.tar.gz";
    rm $file;
    wget "http://www.ms.mff.cuni.cz/~kucat5am/votings/$file";
    tar xf $file;
    time ./master.sh throw > out.period.$i;
done
