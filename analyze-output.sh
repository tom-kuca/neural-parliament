#!/bin/bash

# Usage: ./analyze-output.sh from to
# Example: 
# ./analyze-output.sh 10 11
# prints just results from 10th turn.

from=1;
to=250;
if [ x$1 != x ]; then
	from=$1;
fi;

if [ x$2 != x ]; then
	to=$2;
fi;

function compute
{
	cat /tmp/out.$$ |  perl -ne " print if ( /^${from}\s/ .. /^${to}\s/ ) ; " | grep '\sP\s' | cut -f$1 | perl -e '@a=(); while (<STDIN> ) { chomp; push(@a, $_) ; } print "summary(c(", join(",", @a), "))";' | R --no-save | tail -n3 | head -n2

}

cat > /tmp/out.$$;

echo "Pred";
compute 5;

echo "Time";
compute 7;

