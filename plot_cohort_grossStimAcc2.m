function [fHandle,pstruc,tblstruc,statstruc] = plot_cohort_grossStimAcc2(bhvrTable,saveName,pstruc,statstruc)
%%% 10/17/23 LKW Rewrite of old code to use cleaner table system
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

ctlCleanInds = bhvrTable.stimType ~= "opto_20Hz";
bhvrTable(ctlCleanInds,:) = [];
bhvrTable = rmmissing(bhvrTable);   %Provisional
mNames = unique(strtok(bhvrTable.sessionID)); 
nMice = numel(mNames);

totAccs     = [];
baseAccs    = [];
totOffAccs  = [];
onAccs      = [];

for i = 1:nMice
    mouseInds = strtok(bhvrTable.sessionID) == mNames(i);
    totAccs     = [totAccs; nanmean(bhvrTable.totAcc(mouseInds))];
    baseAccs    = [baseAccs; nanmean(bhvrTable.baseAcc(mouseInds))];
    totOffAccs  = [totOffAccs; nanmean(bhvrTable.totOffAcc(mouseInds))];
    onAccs      = [onAccs; nanmean(bhvrTable.onAcc(mouseInds))];
end

muTot       = nanmean(totAccs);     semTot      = nanstd(totAccs)./sqrt(nMice);
muBase      = nanmean(baseAccs);    semBase     = nanstd(baseAccs)./sqrt(nMice);
muTotOff    = nanmean(totOffAccs);  semTotOff   = nanstd(totOffAccs)./sqrt(nMice);
muOn        = nanmean(onAccs);      semOn       = nanstd(onAccs)./sqrt(nMice);

%Wilcoxon RM mean difference test
% pOnVOff = ranksum(totOffAccs,onAccs);
% pTotVBase = ranksum(totAccs,baseAccs);
[pstruc.acc_kw_baseVtotoffVon,tblstruc.acc_kw_baseVtotoffVon,statstruc.acc_kw_baseVtotoffVon] = kruskalwallis([baseAccs,totOffAccs,onAccs],[],'off');
% [mcomp_c,mcomp_m] = multcompare(kw_stats,[],'off');

meansV = [muTot muBase muTotOff muOn];
semsV = [semTot semBase semTotOff semOn];
% sessionAccs = [leftOffAccs rightOffAccs matchAccs misMatchAccs];
% wilcoxonPs = [pOnVOff, pTotVBase];

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.33,0.525]);
b = bar(meansV,0.4);
b.FaceColor = 'flat';
b.CData(1,:) = [0.75 0.75 1];
b.CData(2:3,:) = [1 1 1; 1 1 1];
b.CData(4,:) = [0.5 0.5 1];
b.EdgeColor = [0 0 0.8];
b.LineWidth = 1.5;
errorbar(meansV,semsV,'k.','LineWidth',1.5);    % SEM for raw acc

plot([0 5],[0.5 0.5],'k--','HandleVisibility','off')                 % 50/50 line

xticks(1:4); xtickangle(45);
xticklabels({'All Trials','Baseline','Off Stim','On Stim'});
ylim([0 1.1]);
xlim([0.5 4.5]);
legCell = {'Means','SEM'};
ylabel('Mean DNMP Accuracy')
legend(legCell,'FontSize',16);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end