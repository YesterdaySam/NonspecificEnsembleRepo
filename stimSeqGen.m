%% Generate DNMP sample phases

baseline = [0 0 1 1 round(rand)];
randBase = datasample(baseline,5,'Replace',false);

trials = [zeros(1,10) ones(1,10)];
[randTrials,idx] = datasample(trials,20,'Replace',false);

opto = [0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1];

free = round(rand(1,10));

sampSeq = [randBase randTrials free]
optoSeq = [zeros(1,5) opto(idx) round(rand(1,10))]