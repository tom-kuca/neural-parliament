#!/bin/bash
init: machines.txt

machines.txt: lab-hosts.sh lab-execute.sh hostInfo.sh
	./lab-execute.sh "`pwd`/./hostInfo.sh" > machines.txt;

# Pocet spustenych node.sh na jednotlivych serverech
status: machines.txt
	rm /tmp/status.${USER}; \
	for i in `cat machines.txt | cut -f1`; do echo -n "$$i: "; ssh $$i " ps -U ${USER} | grep node.sh | wc -l | tee -a /tmp/status.${USER}"; done; \
	cat /tmp/status.${USER} | cut -f2 -d: | perl -e 'while (<STDIN>) { $$sum+=$$_;}; print "Sum: $$sum\n";';

# Vytizeni labu
load: machines.txt
	for i in `cat machines.txt | cut -f1`; do echo -n "$$i: "; ssh $$i ' w | head -n1 | cut -f2- -d,'; done

clean:
	rm -rf lab-hosts.sh lab-execute.sh hostInfo.sh machines.txt trained_net* res.* sim.* ga_* simulate_* input.txt* members.txt votings.txt

lab-hosts.sh:
	wget 'http://w2c.martin.majlis.cz/w2c/data/lab-hosts.sh';
	chmod a+x lab-hosts.sh;

lab-execute.sh:
	wget 'http://w2c.martin.majlis.cz/w2c/data/lab-execute.sh';
	chmod a+x lab-execute.sh;

hostInfo.sh:
	wget 'http://w2c.martin.majlis.cz/w2c/data/hostInfo.sh'
	chmod a+x hostInfo.sh;

visualize: visualize-10 visualize-11 visualize-12

visualize-clean:
	rm -rf out.*.avi out.period.*;

visualize-10: out.10.avi

visualize-11: out.11.avi

visualize-12: out.12.avi

out.10.avi: out.period.10 voting_10.tar.gz
	tar -xzf voting_10.tar.gz; \
	cat out.period.10 | ./visualize.sh  'Mirek Topolánek|2007 - 2009'; \
	cp out.avi out.10.avi;
	
out.11.avi: out.period.11 voting_11.tar.gz
	tar -xzf voting_11.tar.gz; \
	cat out.period.11 | ./visualize.sh  'Jan Fišer|2009-2010'; \
	cp out.avi out.11.avi;

out.12.avi: out.period.12 voting_12.tar.gz
	tar -xzf voting_12.tar.gz; \
	cat out.period.12 | ./visualize.sh  'Petr Nečas|2010-2011'; \
	cp out.avi out.12.avi;

voting_10.tar.gz:
	wget 'http://www.ms.mff.cuni.cz/~kucat5am/votings/voting_10.tar.gz';

out.period.10:
	wget 'http://www.ms.mff.cuni.cz/~kucat5am/votings/out.period.10';

out.period.11:
	wget 'http://www.ms.mff.cuni.cz/~majlm5am/out.period.11';

voting_11.tar.gz:
	wget 'http://www.ms.mff.cuni.cz/~kucat5am/votings/voting_11.tar.gz';

out.period.12:
	wget 'http://www.ms.mff.cuni.cz/~majlm5am/out.period.12';

voting_12.tar.gz:
	wget 'http://www.ms.mff.cuni.cz/~kucat5am/votings/voting_12.tar.gz';
