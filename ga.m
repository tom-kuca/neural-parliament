% Cislo sloupce, pro ktery chceme natrenovat sit
columnId = 1;

% Nacist vstupni data
load input.txt

num_votings = length(input);
num_voters = length(input(1,:));

% Ze vstupnich dat se vytvori 
%       trenovaci data - odebere se sloupec columnId
%       spravne vysledky - sloupec ColumnId
voting = [input(:, 1:columnId-1) input(:, (columnId+1):num_voters)]';
result = input(:, columnId)'

% Vytvorit neuronovou sit
net=newff(voting,result,[20],{},'trainrp');

net.trainParam.epochs = 1000;
net.trainParam.goal = 0.001;
net.trainParam.max_fail = 20;

% natrenovat neuronovou sit
%
[trained_net,tr]=train(net,voting,result);
simulation = hardlims(sim(trained_net, voting));

% natrenovana sit se ulozi do soubor net.4.mat (4 je columnId)
save trained_net;

% spocitact shodu s realnym hlasovanim v procentech
%
% pokud poslanec nehlasoval, pak se vysledek nezapocita
miss = sum(simulation + result == 0);
total = sum(result ~= 0);
if total == 0
	hist_pct = 0;
else
	hits_pct = (total-miss) / total;
end;


% vypsat shodu s realnym hlasovanim v procentech
fprintf(1,'%d\n', miss);
fprintf(1,'%d\n', total);
fprintf(1,'%f\n', hits_pct);
