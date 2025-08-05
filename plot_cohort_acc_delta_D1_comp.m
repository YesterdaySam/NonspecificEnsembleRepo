function [fHandle,pstruc,statstruc] = plot_cohort_acc_delta_D1_comp(ctlTable,expTable,ctlTag,expTag,saveName,pstruc,statstruc)
%%% 4/17/2023 LKW
%Inputs: 
%ctlTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

ctlCleanInds = ctlTable.stimType ~= "opto_20Hz";
expCleanInds = expTable.stimType ~= "opto_20Hz";
ctlTable(ctlCleanInds,:) = [];
expTable(expCleanInds,:) = [];

%Hard coded Tag directions for each mouse
% ctl_TR = [3 4 6]; ctl_TL = [1 2 5];     %R: 03 04 06; L: 01 02 05
% exp_TR = [3 5 6]; exp_TL = [1 2 4];    %R: 20 4 7 8;  L: 17 19 3

ctlTable_TL = ctlTable(ctlTag,:); ctlTable_TR = ctlTable(~ctlTag,:);
expTable_TL = expTable(expTag,:); expTable_TR = expTable(~expTag,:);

nCtlTL = height(ctlTable_TL);
nCtlTR = height(ctlTable_TR);
nExpTL = height(expTable_TL);
nExpTR = height(expTable_TR);

%Calculate on - off accuracy deltas for each group/tag/turn direction subset
ctlRD_TL = ctlTable_TL.rightOnAcc - ctlTable_TL.rightOffAcc;
ctlRD_TR = ctlTable_TR.rightOnAcc - ctlTable_TR.rightOffAcc;
ctlLD_TL = ctlTable_TL.leftOnAcc - ctlTable_TL.leftOffAcc;
ctlLD_TR = ctlTable_TR.leftOnAcc - ctlTable_TR.leftOffAcc;
expRD_TL = expTable_TL.rightOnAcc - expTable_TL.rightOffAcc;
expRD_TR = expTable_TR.rightOnAcc - expTable_TR.rightOffAcc;
expLD_TL = expTable_TL.leftOnAcc - expTable_TL.leftOffAcc;
expLD_TR = expTable_TR.leftOnAcc - expTable_TR.leftOffAcc;

%Same as above but mean and standard deviation
muCtlR_TL = mean(ctlRD_TL); seCtlR_TL = std(ctlRD_TL)./sqrt(nCtlTL);
muCtlR_TR = mean(ctlRD_TR); seCtlR_TR = std(ctlRD_TR)./sqrt(nCtlTR);
muCtlL_TL = mean(ctlLD_TL); seCtlL_TL = std(ctlLD_TL)./sqrt(nCtlTL);
muCtlL_TR = mean(ctlLD_TR); seCtlL_TR = std(ctlLD_TR)./sqrt(nCtlTR);
muExpR_TL = mean(expRD_TL); seExpR_TL = std(expRD_TL)./sqrt(nExpTL);
muExpR_TR = mean(expRD_TR); seExpR_TR = std(expRD_TR)./sqrt(nExpTR);
muExpL_TL = mean(expLD_TL); seExpL_TL = std(expLD_TL)./sqrt(nExpTL);
muExpL_TR = mean(expLD_TR); seExpL_TR = std(expLD_TR)./sqrt(nExpTR);

%% Plot
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.2,0.525]);
scatter([0.75 1.75],[muCtlL_TL muCtlR_TL],'o','markerfacecolor',[0.4 0.4 0.4],'markeredgecolor',[0.4 0.4 0.4])
scatter([0.85 1.85],[muCtlL_TR muCtlR_TR],'o','markerfacecolor',[0.7 0.7 0.7],'markeredgecolor',[0.7 0.7 0.7])
scatter([1.15 2.15],[muExpL_TL muExpR_TL],'d','markerfacecolor',[0.2 0.2 1.0],'markeredgecolor',[0.2 0.2 1.0])
scatter([1.25 2.25],[muExpL_TR muExpR_TR],'d','markerfacecolor',[0.5 0.5 1.0],'markeredgecolor',[0.5 0.5 1.0])

errorbar([0.75 1.75],[muCtlL_TL muCtlR_TL],[seCtlL_TL seCtlR_TL],'o','Color',[0.4 0.4 0.4],'LineWidth',1);    % SEM for raw acc
errorbar([0.85 1.85],[muCtlL_TR muCtlR_TR],[seCtlL_TR seCtlR_TR],'o','Color',[0.7 0.7 0.7],'LineWidth',1);    % SEM for raw acc
errorbar([1.15 2.15],[muExpL_TL muExpR_TL],[seExpL_TL seExpR_TL],'d','Color',[0.2 0.2 1.0],'LineWidth',1);    % SEM for raw acc
errorbar([1.25 2.25],[muExpL_TR muExpR_TR],[seExpL_TR seExpR_TR],'d','Color',[0.5 0.5 1.0],'LineWidth',1);    % SEM for raw acc

plot(repmat([0.75; 1.75],[1 nCtlTL])+0.05.*rand(1,nCtlTL),[ctlLD_TL,ctlRD_TL]','ko','MarkerEdgeColor',[0.4 0.4 0.4]);
plot(repmat([0.85; 1.85],[1 nCtlTR])+0.05.*rand(1,nCtlTR),[ctlLD_TR,ctlRD_TR]','ko','MarkerEdgeColor',[0.7 0.7 0.7]);
plot(repmat([1.15; 2.15],[1 nExpTL])+0.05.*rand(1,nExpTL),[expLD_TL,expRD_TL]','kd','MarkerEdgeColor',[0.2 0.2 1]);
plot(repmat([1.25; 2.25],[1 nExpTR])+0.05.*rand(1,nExpTR),[expLD_TR,expRD_TR]','kd','MarkerEdgeColor',[0.5 0.5 1]);

plot([0 3],[0 0],'k--','HandleVisibility','off')                 % 50/50 line

xticks(1:2);
xticklabels({'Left','Right'});     %Relative to sample phase i.e. accuracy during test after left samples no stim
xlabel('Train Phase')
xlim([0.5 2.5]);
legCell = {'eYFP-L','eYFP-R','ChR2-L','ChR2-R'};
ylim([-0.7 1]); ylabel('\Delta DNMP Accuracy Day 1');
legend(legCell,'FontSize',16,'location','nw');
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end