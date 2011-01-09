#!/bin/bash
init: machines.txt

machines.txt:
	wget 'http://w2c.martin.majlis.cz/w2c/data/lab-info.txt' -O machines.txt;

# Pocet spustenych node.sh na jednotlivych serverech
status: machines.txt
	for i in `cat machines.txt | cut -f1`; do echo -n "$$i: "; ssh $$i " ps -U ${USER} | grep node.sh | wc -l"; done

# Vytizeni labu
load: machines.txt
	for i in `cat machines.txt | cut -f1`; do echo -n "$$i: "; ssh $$i ' w | head -n1 | cut -f2- -d,'; done

clean:
	rm -rf machines.txt trained_net* res.* sim.* ga_* simulate_* input.txt* members.txt votings.txt
