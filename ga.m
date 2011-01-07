function out = name(args)
columnId = 3;

% nejaky vypocet
load input.txt

num_votings = length(input)
num_voters = length(input(1,:))

voting = [input(:, 1:columnId-1) input(:, (columnId+1):num_voters)]';
result = input(:, columnId)';

net=newff(voting,result,[100],{},'traingdm');
net.trainParam.lr = 0.01;
net.trainParam.epochs = 100;
net.trainParam.goal = 0.1;
net.trainParam.max_fail = 20;

[net1,tr]=train(net,voting,result);
simulation = hardlims(sim(net1, voting));

miss = sum(simulation + result == 0);
total = sum(result ~= 0);
hits_pct = (total-miss) / total;

% nekam se ulozi natrenovana neuronoa sit
save 

% shoda site s poslancem
fprintf(1,'%f\n', hits_pct);
