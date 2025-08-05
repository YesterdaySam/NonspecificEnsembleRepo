function [fHandle,pstruc,statstruc] = plot_cohort_deltaLR2(bhvrTable,saveName,tagSide,pstruc,statstruc)
%%% 10/17/23 LKW Rewrite of old code to use cleaner table system
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'
%tagSide = vector of 1 or 0 for left or right tag side respectively

ctlCleanInds = bhvrTable.stimType ~= "opto_20Hz";
bhvrTable(ctlCleanInds,:) = [];
bhvrTable = rmmissing(bhvrTable);   %Provisional
mNames = unique(strtok(bhvrTable.sessionID)); 
nMice = numel(mNames);

matchAccs = [];
misMatchAccs = [];
leftAccs = [];
rightAccs = [];

for i = 1:nMice
    mouseInds = strtok(bhvrTable.sessionID) == mNames(i);
    if ischar(tagSide)
        leftAccs = [leftAccs; nanmean(bhvrTable.leftOnAcc(mouseInds) - bhvrTable.leftOffAcc(mouseInds))];
        rightAccs = [rightAccs; nanmean(bhvrTable.rightOnAcc(mouseInds) - bhvrTable.rightOffAcc(mouseInds))];
%     elseif tagSide(i) == 1
%         matchAccs = [matchAccs; mean(optoOnlyS(i).animalBhvrT.matchAcc - optoOnlyS(i).animalBhvrT.leftOffAcc)];
%         misMatchAccs = [misMatchAccs; mean(optoOnlyS(i).animalBhvrT.misMatchAcc - optoOnlyS(i).animalBhvrT.rightOffAcc)];
%         nSess = numel(matchAccs);
%     elseif tagSide(i) == 0
%         matchAccs = [matchAccs; mean(optoOnlyS(i).animalBhvrT.matchAcc - optoOnlyS(i).animalBhvrT.rightOffAcc)];
%         misMatchAccs = [misMatchAccs; mean(optoOnlyS(i).animalBhvrT.misMatchAcc - optoOnlyS(i).animalBhvrT.leftOffAcc)];
%         nSess = numel(matchAccs);
    end
end

if ischar(tagSide)
    muLeftOnOff = nanmean(leftAccs); semLeftOnOff = nanstd(leftAccs)./sqrt(nMice);
    muRightOnOff = nanmean(rightAccs); semRightOnOff = nanstd(rightAccs)./sqrt(nMice);
    
%     [pstruc.acc_deltaLV0,~,statstruc.acc_deltaLV0] = signrank(leftAccs);
%     [pstruc.acc_deltaRV0,~,statstruc.acc_deltaRV0] = signrank(rightAccs);
%     [pstruc.acc_deltaLVR,~,statstruc.acc_deltaLVR] = ranksum(leftAccs,rightAccs);
    [~,pstruc.acc_tt_deltaLV0,~,statstruc.acc_tt_deltaLV0] = ttest(leftAccs);
    [~,pstruc.acc_tt_deltaRV0,~,statstruc.acc_tt_deltaRV0] = ttest(rightAccs);
    [~,pstruc.acc_tt_deltaLVR,~,statstruc.acc_tt_deltaLVR] = ttest(leftAccs,rightAccs);
    
    meansV = [muLeftOnOff muRightOnOff];
    semsV = [semLeftOnOff semRightOnOff];
    tickLabels = {'Left','Right'};
% else
%     muMatchOnOff = mean(matchAccs); semLeftOnOff = std(matchAccs)./sqrt(nSess);
%     muMisMatchOnOff = mean(misMatchAccs); semRightOnOff = std(misMatchAccs)./sqrt(nSess);
%     
% %     [pstruc.deltaMatchV0,~,stats.deltaMatchV0] = signrank(matchAccs);
% %     [pstruc.deltaMisMatchV0,~,stats.deltaMisMatchV0] = signrank(misMatchAccs);
% %     [pstruc.deltaMatchVMisMatch,~,stats.deltaMatchVMisMatch] = ranksum(matchAccs,misMatchAccs);
%     [~,pstruc.acc_tt_deltaMV0, ~,statstruc.acc_tt_deltaMV0]  = ttest(matchAccs);
%     [~,pstruc.acc_tt_deltaMMV0,~,statstruc.acc_tt_deltaMMV0] = ttest(misMatchAccs);
%     [~,pstruc.acc_tt_deltaMVMM,~,statstruc.acc_tt_deltaMVMM] = ttest(matchAccs,misMatchAccs);
% 
%     meansV = [muMatchOnOff muMisMatchOnOff];
%     semsV = [semLeftOnOff semRightOnOff];
%     tickLabels = {'Match', 'Mis-Match'};
end

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.18,0.525]);
scatter(1:2,meansV,'filled','kd')       % Mean Deltas
errorbar(meansV,semsV,'k.','LineWidth',1.5);    % SEM for deltas

if ischar(tagSide)
    plot(repmat([1; 1.8],[1 nMice])+0.1,[leftAccs,rightAccs]','k-d','MarkerFaceColor','k');
else
    plot(repmat([1; 1.8],[1 nMice])+0.1,[matchAccs,misMatchAccs]','k-d','MarkerFaceColor','k');
end

plot([0 5],[0 0],'k--','HandleVisibility','off')                 % 0 line

xticks(1:2); % xtickangle(45);
xticklabels(tickLabels);
ylim([-0.50 0.50]);
xlim([0.5 2.5]);
legCell = {'Means','SEM'};
ylabel({'\Delta % Accuracy', 'On - Off Stim'})
legend(legCell,'FontSize',16);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end