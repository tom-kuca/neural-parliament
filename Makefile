#!/bin/bash
init: machines.txt

machines.txt:
	wget 'http://w2c.martin.majlis.cz/w2c/data/lab-info.txt' -O machines.txt;

# Pocet spustenych node.sh na jednotlivych serverech
status: machines.txt
	for i in `cat machines.txt | cut -f1`; do echo -n "$$i: "; ssh $$i ' ps -U `whoami` | grep node.sh | wc -l'; done


clean:
	rm -rf machines.txt trained_net* res.* sim.* ga_* simulate_* input.txt* members.txt votings.txt
