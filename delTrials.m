function [trialBlocks] = delTrials(trialBlocks,trInds,sname)
% Deletes user-defined trials from the trialBlocks structure made by
% getTrialBlocks.m
%Inputs:
% trialBlocks = trialBlocks variable from getTrialBlocks, [start,end]
% trialInds = Mx1 matrix of indices of trials to be deleted
% sname = string of 'rec_file_trialBlocks' identical to an existing var in
% the parent folder
%Outputs:
% trialBlocks = Updated, sorted, saved

trialBlocks(trInds,:) = [];

trialBlocks = sort(trialBlocks);

save(sname,'trialBlocks')
end