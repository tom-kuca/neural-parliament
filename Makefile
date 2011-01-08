#!/bin/bash
init: machines.txt

machines.txt:
	wget 'http://w2c.martin.majlis.cz/w2c/data/lab-info.txt' -O machines.txt;

clean:
	rm -rf machines.txt trained_net* res.* sim.* ga_* simulate_* input.txt* members.txt votings.txt
