function [trialBlocks] = addTrials(root,trialBlocks,trialTimes,sname)
% Adds user specified timestamps from trialTimes to an existing trialBlocks
% variable, sorts everything by ts of start box exit, and saves to current
% directory
%Inputs:
% root = CMBHome object
% trialBlocks = trialBlocks variable from getTrialBlocks, [start,end]
% trialTimes = Mx2 matrix of trial times organized [start,end] each number
% is min.sec i.e. 10 min 22 sec as 10.22
% sname = string of 'rec_file_trialBlocks' identical to an existing var in
% the parent folder
%Outputs:
% trialBlocks = Updated, sorted

nAdds = size(trialTimes,1);

for i = 1:nAdds
    tStartMin = floor(trialTimes(i,1));
    tStart = tStartMin*60 + (trialTimes(i,1)-tStartMin)*100;
    tStopMin = floor(trialTimes(i,2));
    tStop = tStopMin*60 + (trialTimes(i,2)-tStopMin)*100;
    
    if tStart < root.ts(end)
        indStart = find(root.ts > tStart,1,'first');
    else
        warning('User-defined lap start outside recording range')
    end
    
    if tStop < root.ts(end)
        indStop = find(root.ts > tStop,1,'first');
    else
        warning('User-defined lap end outside recording range, defaulting to final root timestamp')
        indStop = root.ts(end);
    end

    trialBlocks = [trialBlocks; [indStart,indStop]];
end

trialBlocks = sort(trialBlocks);

save(sname,'trialBlocks')
end