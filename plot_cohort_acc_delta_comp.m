function [fHandle,pstruc,statstruc] = plot_cohort_acc_delta_comp(ctlTable,expTable,saveName,pstruc,statstruc)
%%% 4/17/2023 LKW
%Inputs: 
%ctlTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

ctlCleanInds = ctlTable.stimType ~= "opto_20Hz";
expCleanInds = expTable.stimType ~= "opto_20Hz";
ctlTable(ctlCleanInds,:) = [];
expTable(expCleanInds,:) = [];
ctlNames = unique(strtok(ctlTable.sessionID)); nMiceCtl = numel(ctlNames);
expNames = unique(strtok(expTable.sessionID)); nMiceExp = numel(expNames);

ctlLD = []; expLD = [];
ctlRD = []; expRD = [];
ctlMNames = {}; expMNames = {};

for i = 1:nMiceCtl
    mouseInds = strtok(ctlTable.sessionID) == ctlNames(i);
    ctlRD = [ctlRD; mean(ctlTable.rightOnAcc(mouseInds) - ctlTable.rightOffAcc(mouseInds))];
    ctlLD = [ctlLD; mean(ctlTable.leftOnAcc(mouseInds) - ctlTable.leftOffAcc(mouseInds))];
end

for i = 1:nMiceExp
    mouseInds = strtok(expTable.sessionID) == expNames(i);
    expRD = [expRD; mean(expTable.rightOnAcc(mouseInds) - expTable.rightOffAcc(mouseInds))];
    expLD = [expLD; mean(expTable.leftOnAcc(mouseInds) - expTable.leftOffAcc(mouseInds))];
end

nSessCtl = numel(ctlRD);
nSessExp = numel(expRD);

muCtlR = mean(ctlRD); seCtlR = std(ctlRD)./sqrt(nSessCtl);
muCtlL = mean(ctlLD); seCtlL = std(ctlLD)./sqrt(nSessCtl);
muExpR = mean(expRD); seExpR = std(expRD)./sqrt(nSessExp);
muExpL = mean(expLD); seExpL = std(expLD)./sqrt(nSessExp);

%Comparison between groups and conditions
[~,pstruc.acc_tt_ctlVexp_deltaR,~,statstruc.acc_tt_ctlVexp_deltaR] = ttest2(ctlRD,expRD);  %Independent samples
[~,pstruc.acc_tt_ctlVexp_deltaL,~,statstruc.acc_tt_ctlVexp_deltaL] = ttest2(ctlLD,expLD);
[~,pstruc.acc_tt_exp_deltaLVR,~,statstruc.acc_tt_exp_deltaLVR] = ttest(expLD,expRD);  %Dependent samples
[~,pstruc.acc_tt_ctl_deltaLVR,~,statstruc.acc_tt_ctl_deltaLVR] = ttest(ctlLD,ctlRD);

meansV = [muCtlL muExpL; muCtlR muExpR];
semsV = [seCtlL seExpL; seCtlR seExpR];

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.15,0.40]);
scatter([0.9 1.9],meansV(:,1),'filled','markerfacecolor',[.7 .7 .7])
scatter([1.1 2.1],meansV(:,2),'d','filled','markerfacecolor',[0.5 0.5 1])
errorbar([0.9 1.9],meansV(:,1),semsV(:,1),'.','Color',[.7 .7 .7],'LineWidth',1);    % SEM for raw acc
errorbar([1.1 2.1],meansV(:,2),semsV(:,2),'.','Color',[0.5 0.5 1],'LineWidth',1);    % SEM for raw acc

%For mouse-averaged individual plotting
plot(repmat([0.8; 1.8],[1 nSessCtl])+0.05.*rand(1,nSessCtl),[ctlLD,ctlRD]','ko','MarkerEdgeColor',[0.7 0.7 0.7]);
plot(repmat([1.2; 2.2],[1 nSessExp])+0.05.*rand(1,nSessExp),[expLD,expRD]','kd','MarkerEdgeColor',[0.5 0.5 1]);

plot([0 3],[0 0],'k--','HandleVisibility','off')                 % 50/50 line

xticks(1:2);
xticklabels({'Left','Right'});     %Relative to sample phase i.e. accuracy during test after left samples no stim
xlabel('Train Phase')
ylim([-0.5 0.5]); 
xlim([0.5 2.5]);
legCell = {'eYFP','ChR2'};
ylabel('\Delta DNMP Accuracy On - Off')
legend(legCell,'FontSize',16,'location','ne');
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end