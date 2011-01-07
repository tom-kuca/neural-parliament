columnId = 3;

% nejaky vypocet
%
load input.txt
num_votings = length(input);
out = (round(rand(num_votings)) * 2 - 1);

fprintf(1,'%f\n', out);

