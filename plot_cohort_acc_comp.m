function [fHandle,pstruc,statstruc] = plot_cohort_acc_comp(ctlTable,expTable,saveName,pstruc,statstruc)
%%% 3/2/2023 LKW
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

ctlOn = []; expOn = [];
ctlOff = []; expOff = [];
ctlMNames = {}; expMNames = {};

for i = 1:nMiceCtl
    mouseInds = strtok(ctlTable.sessionID) == ctlNames(i);
    %By trial
%     ctlOff = ;
%     ctlOn = ;
    %Mouse averaged
    ctlOff = [ctlOff; mean(ctlTable.totOffAcc(mouseInds))];
    ctlOn = [ctlOn; mean(ctlTable.onAcc(mouseInds))];
end

for i = 1:nMiceExp
    mouseInds = strtok(expTable.sessionID) == expNames(i);
    expOff = [expOff; mean(expTable.totOffAcc(mouseInds))];
    expOn = [expOn; mean(expTable.onAcc(mouseInds))];
end

nSessCtl = numel(ctlOff);
nSessExp = numel(expOff);

muCtlOff = mean(ctlOff); seCtlOff = std(ctlOff)./sqrt(nSessCtl);
muCtlOn = mean(ctlOn); seCtlOn = std(ctlOn)./sqrt(nSessCtl);
muExpOff = mean(expOff); seExpOff = std(expOff)./sqrt(nSessExp);
muExpOn = mean(expOn); seExpOn = std(expOn)./sqrt(nSessExp);

%Wilcoxon RM mean difference test
[~,pstruc.acc_tt_ctlVexp_off,~,statstruc.acc_tt_ctlVexp_off] = ttest2(ctlOff,expOff);  %Independent samples
[~,pstruc.acc_tt_ctlVexp_on,~,statstruc.acc_tt_ctlVexp_on] = ttest2(ctlOn,expOn);

meansV = [muCtlOff muExpOff; muCtlOn muExpOn];
semsV = [seCtlOff seExpOff; seCtlOn seExpOn];

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.15,0.525]);
patch([1.5 2.5 2.5 1.5],[0 0 1.1 1.1],[0.8 0.8 1],'EdgeColor','none','FaceAlpha',0.5,'HandleVisibility','off')
b = bar(meansV,0.8,'LineWidth',1.5,'EdgeColor',[0 0 0.8]);
b(1).FaceColor = [0.7 0.7 0.7];
b(2).FaceColor = [0.5 0.5 1];
errorbar([0.85 1.15; 1.85 2.15],meansV,semsV,'k.','LineWidth',1);    % SEM for raw acc
%For mouse-averaged individual plotting
plot(repmat([0.8; 1.8],[1 nSessCtl])+0.1,[ctlOff,ctlOn]','o','MarkerEdgeColor',[0.5 0.5 0.5]);
plot(repmat([1.1; 2.1],[1 nSessExp])+0.1,[expOff,expOn]','d','MarkerEdgeColor',[0.3 0.3 0.7]);

plot([0 5],[0.5 0.5],'k--','HandleVisibility','off')                 % 50/50 line

xticks(1:2);
xticklabels({'Off','On'});     %Relative to sample phase i.e. accuracy during test after left samples no stim
ylim([0 1.1]); 
xlim([0.5 2.5]);
legCell = {'eYFP','ChR2'};
ylabel('Mean DNMP Accuracy')
legend(legCell,'FontSize',16,'location','se');
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end