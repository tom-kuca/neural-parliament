#!/bin/bash

if [ $# != 2 ]; then 
	echo "Usage: $0 members votings" >&2;
	echo "$0 20 120" >&2;
	echo "20 people are voting 120 times." >&2;
	exit 2;
fi;

./generate-votes.pl $1 $2 > input.txt;
./generate-members.pl $1 > members.txt;
./generate-votings.pl > votings.txt;
