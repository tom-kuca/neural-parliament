#!/bin/bash
function compute
{
	cat /tmp/out.$$ | grep '\sP\s' | cut -f$1 | perl -e '@a=(); while (<STDIN> ) { chomp; push(@a, $_) ; } print "summary(c(", join(",", @a), "))";' | R --no-save | tail -n3 | head -n2

}

cat > /tmp/out.$$;

echo "Pred";
compute 5;

echo "Time";
compute 7;

