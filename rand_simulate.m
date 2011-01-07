columnId = 3;

% Nahodna neuronova sit
%
% nacte hlasovani input.txt, tvari se jako neuronova sit, 
% ktera simuluje hlasovani na zaklade dat, ale vystupem jsou nahodna cisla
%
load input.txt
num_votings = length(input);
out = (round(rand(num_votings)) * 2 - 1);

fprintf(1,'%d\n', out);

