columnId = 5;
file =  strcat('trained_net_', int2str(columnId),'.mat')
load(file)

% Nahodna neuronova sit
%
% nacte neuronovou sit v soubor 'trained_net.X.mat', kde X je cislo simulovaneho sloupce
% a simuluje pomoci ni hlasovani ktera simuluje hlasovani na zaklade dat z input.txt

load input.txt
num_votings = length(input);

num_votings = length(input);
num_voters = length(input(1,:));

% Ze vstupnich dat se vytvori 
%       trenovaci data - odebere se sloupec columnId
%       spravne vysledky - sloupec ColumnId
voting = [input(:, 1:columnId-1) input(:, (columnId+1):num_voters)]';
simulation = hardlims(sim(trained_net, voting));

fprintf(1,'%d\n', simulation);
