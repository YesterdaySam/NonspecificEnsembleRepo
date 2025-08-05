function [fHandle,pstruc,statstruc] = plot_cohort_onoffAcc2(bhvrTable,saveName,pstruc,statstruc)
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

onAccs = [];
offAccs = [];

for i = 1:nMice
    mouseInds = strtok(bhvrTable.sessionID) == mNames(i);
    offAccs = [offAccs; nanmean(bhvrTable.totOffAcc(mouseInds))];
    onAccs = [onAccs; nanmean(bhvrTable.onAcc(mouseInds))];
end

muOff = nanmean(offAccs); semOff = nanstd(offAccs)./sqrt(nMice);
muOn = nanmean(onAccs); semOn = nanstd(onAccs)./sqrt(nMice);

%Wilcoxon RM mean difference test
% pstruc.acc_onVoff = ranksum(offAccs,onAccs);
[~,pstruc.acc_tt_onVoff,~,statstruc.acc_tt_onVoff] = ttest(offAccs,onAccs);  %Paired-sample x-y vs 0
[~,pstruc.acc_tt_offV0,~,statstruc.acc_tt_offV0] = ttest(offAccs-0.5);  %Vs 0
[~,pstruc.acc_tt_onV0,~,statstruc.acc_tt_onV0] = ttest(onAccs-0.5);  %Vs 0

meansV = [muOff muOn];
semsV = [semOff semOn];

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.15,0.525]);
b = bar(meansV,0.4);
b.FaceColor = 'flat';
b.CData(1,:) = [1 1 1];
b.CData(2,:) = [0.5 0.5 1];
b.EdgeColor = [0 0 0.8];
b.LineWidth = 1.5;
errorbar(meansV,semsV,'k.','LineWidth',1);    % SEM for raw acc

%For mouse-averaged individual plotting
plot(repmat([1; 1.8],[1 nMice])+0.1,[offAccs,onAccs]','k-d','MarkerFaceColor','k');

plot([0 5],[0.5 0.5],'k--','HandleVisibility','off')                 % 50/50 line

xticks(1:2);
xticklabels({'Off Stim','On Stim'});     %Relative to sample phase i.e. accuracy during test after left samples no stim
ylim([0 1.1]); 
xlim([0.5 2.5]);
legCell = {'Means','SEM'};
ylabel('Mean DNMP Accuracy')
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end