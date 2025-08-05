function [fHandle,wilcoxonPs] = plot_mouse_grossStimAcc(mouseTable,saveName)
% 5/16/2021 LKW
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

optoOnlyT = rmmissing(mouseTable);
cleanInds = optoOnlyT.stimType == "pre_training";
cleanInds = logical(cleanInds + (optoOnlyT.stimType == "Tagging"));
optoOnlyT(cleanInds,:) = [];
nSess = height(optoOnlyT);

muTotAcc = mean(optoOnlyT.totAcc); semTotAcc = std(optoOnlyT.totAcc)./sqrt(nSess);
muBaseAcc = mean(optoOnlyT.baseAcc); semBaseAcc = std(optoOnlyT.baseAcc)./sqrt(nSess);
muTotOffAcc = mean(optoOnlyT.totOffAcc); semTotOffAcc = std(optoOnlyT.totOffAcc)./sqrt(nSess);
muOnAcc = mean(optoOnlyT.onAcc); semOnAcc = std(optoOnlyT.onAcc)./sqrt(nSess);

%Wilcoxon RM mean difference test
pOnVOff = ranksum(optoOnlyT.totOffAcc,optoOnlyT.onAcc);
pTotVBase = ranksum(optoOnlyT.totAcc,optoOnlyT.baseAcc);

meansV = [muTotAcc muBaseAcc muTotOffAcc muOnAcc];
semsV = [semTotAcc semBaseAcc semTotOffAcc semOnAcc];
sessionAccs = [optoOnlyT.totAcc optoOnlyT.baseAcc optoOnlyT.totOffAcc optoOnlyT.onAcc];
wilcoxonPs = [pOnVOff, pTotVBase];

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.5,0.33,0.5]);
bar(meansV,0.4)
errorbar(meansV,semsV,'k.','LineWidth',1)    % SEM for mean deltas
plot(sessionAccs','-o','LineWidth',2);
plot([0 5],[0.5 0.5],'k--')                 % 0 line

xticks(1:4); xtickangle(45);
xticklabels({'Session','Baseline','Off Trials','Stim Trials'});
ylim([0 1.1]); xlim([0.5 6]);
ylabel('Raw DNMP Accuracy')
legend({'Means','SEM','Day 1','2','3','4','5'},'FontSize',16);
set(gca,'FontSize',20,'FontName','Times');

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end
end