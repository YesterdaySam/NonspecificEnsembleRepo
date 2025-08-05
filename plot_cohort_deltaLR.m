function [fHandle,pstruc,statstruc] = plot_cohort_deltaLR(mouseTables,saveName,tagSide,pstruc,statstruc)
% 5/22/2021 LKW
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'
%tagSide = vector of 1 or 0 for left or right tag side respectively

nMice = size(mouseTables,2);

matchAccs = [];
misMatchAccs = [];
leftAccs = [];
rightAccs = [];
mouseLabs = {};

for i = 1:nMice
    optoOnlyS(i).animalBhvrT = rmmissing(mouseTables(i).animalBhvrT);   %Add mouse table to opto Only Struct
    cleanInds = optoOnlyS(i).animalBhvrT.stimType == "pre_training";
    cleanInds = logical(cleanInds + (optoOnlyS(i).animalBhvrT.stimType == "Tagging"));
    optoOnlyS(i).animalBhvrT(cleanInds,:) = [];
    strTmp = optoOnlyS(i).animalBhvrT.sessionID(1);
    spaceInds = strfind(strTmp,' ');
    mouseLabs{i} = optoOnlyS(i).animalBhvrT.sessionID{1}(1:spaceInds(1)-1);

    if ischar(tagSide)
        %By session
%         leftAccs = [leftAccs; optoOnlyS(i).animalBhvrT.leftOnAcc - optoOnlyS(i).animalBhvrT.leftOffAcc];
%         rightAccs = [rightAccs; optoOnlyS(i).animalBhvrT.rightOnAcc - optoOnlyS(i).animalBhvrT.rightOffAcc];
        %By Mouse
        leftAccs = [leftAccs; mean(optoOnlyS(i).animalBhvrT.leftOnAcc - optoOnlyS(i).animalBhvrT.leftOffAcc)];
        rightAccs = [rightAccs; mean(optoOnlyS(i).animalBhvrT.rightOnAcc - optoOnlyS(i).animalBhvrT.rightOffAcc)];
        nSess = numel(leftAccs);
    elseif tagSide(i) == 1
        %By session
%         matchAccs = [matchAccs; optoOnlyS(i).animalBhvrT.matchAcc - optoOnlyS(i).animalBhvrT.leftOffAcc];
%         misMatchAccs = [misMatchAccs; optoOnlyS(i).animalBhvrT.misMatchAcc - optoOnlyS(i).animalBhvrT.rightOffAcc];
        %By Mouse
        matchAccs = [matchAccs; mean(optoOnlyS(i).animalBhvrT.matchAcc - optoOnlyS(i).animalBhvrT.leftOffAcc)];
        misMatchAccs = [misMatchAccs; mean(optoOnlyS(i).animalBhvrT.misMatchAcc - optoOnlyS(i).animalBhvrT.rightOffAcc)];
        nSess = numel(matchAccs);
    elseif tagSide(i) == 0
        %By session
%         matchAccs = [matchAccs; optoOnlyS(i).animalBhvrT.matchAcc - optoOnlyS(i).animalBhvrT.rightOffAcc];
%         misMatchAccs = [misMatchAccs; optoOnlyS(i).animalBhvrT.misMatchAcc - optoOnlyS(i).animalBhvrT.leftOffAcc];
        %By Mouse
        matchAccs = [matchAccs; mean(optoOnlyS(i).animalBhvrT.matchAcc - optoOnlyS(i).animalBhvrT.rightOffAcc)];
        misMatchAccs = [misMatchAccs; mean(optoOnlyS(i).animalBhvrT.misMatchAcc - optoOnlyS(i).animalBhvrT.leftOffAcc)];
        nSess = numel(matchAccs);
    end
end

if ischar(tagSide)
    muLeftOnOff = mean(leftAccs); semLeftOnOff = std(leftAccs)./sqrt(nSess);
    muRightOnOff = mean(rightAccs); semRightOnOff = std(rightAccs)./sqrt(nSess);
    
%     [pstruc.acc_deltaLV0,~,statstruc.acc_deltaLV0] = signrank(leftAccs);
%     [pstruc.acc_deltaRV0,~,statstruc.acc_deltaRV0] = signrank(rightAccs);
%     [pstruc.acc_deltaLVR,~,statstruc.acc_deltaLVR] = ranksum(leftAccs,rightAccs);
    [~,pstruc.acc_tt_deltaLV0,~,statstruc.acc_tt_deltaLV0] = ttest(leftAccs);
    [~,pstruc.acc_tt_deltaRV0,~,statstruc.acc_tt_deltaRV0] = ttest(rightAccs);
    [~,pstruc.acc_tt_deltaLVR,~,statstruc.acc_tt_deltaLVR] = ttest(leftAccs,rightAccs);
    
    meansV = [muLeftOnOff muRightOnOff];
    semsV = [semLeftOnOff semRightOnOff];
    tickLabels = {'Left','Right'};
else
    muMatchOnOff = mean(matchAccs); semLeftOnOff = std(matchAccs)./sqrt(nSess);
    muMisMatchOnOff = mean(misMatchAccs); semRightOnOff = std(misMatchAccs)./sqrt(nSess);
    
%     [pstruc.deltaMatchV0,~,stats.deltaMatchV0] = signrank(matchAccs);
%     [pstruc.deltaMisMatchV0,~,stats.deltaMisMatchV0] = signrank(misMatchAccs);
%     [pstruc.deltaMatchVMisMatch,~,stats.deltaMatchVMisMatch] = ranksum(matchAccs,misMatchAccs);
    [~,pstruc.acc_tt_deltaMV0, ~,statstruc.acc_tt_deltaMV0]  = ttest(matchAccs);
    [~,pstruc.acc_tt_deltaMMV0,~,statstruc.acc_tt_deltaMMV0] = ttest(misMatchAccs);
    [~,pstruc.acc_tt_deltaMVMM,~,statstruc.acc_tt_deltaMVMM] = ttest(matchAccs,misMatchAccs);

    meansV = [muMatchOnOff muMisMatchOnOff];
    semsV = [semLeftOnOff semRightOnOff];
    tickLabels = {'Match', 'Mis-Match'};
end

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.18,0.525]);
scatter(1:2,meansV,'filled','kd')       % Mean Deltas
errorbar(meansV,semsV,'k.','LineWidth',1.5);    % SEM for deltas

% For plotting individual mice
% mouseColors = {'b','g','r','m','c',[0 0 0.5],[0 0.75 0],[1 0.5 0],[1 0.75 0]};
% mouseColors = hot(nMice+2);
% ct = 0;
% for i = 1:nMice
%     nMouseSess = size(optoOnlyS(i).animalBhvrT,1);
%     if ischar(tagSide)
%         scatter(ones(nMouseSess,1)*0.8+randn(nMouseSess,1)./15,leftAccs(1+ct:nMouseSess+ct),[],mouseColors(i,:),'filled');
%         scatter(ones(nMouseSess,1)*1.8+randn(nMouseSess,1)./15,rightAccs(1+ct:nMouseSess+ct),[],mouseColors(i,:),'filled','HandleVisibility','off');
%         ct = ct + nMouseSess;
%     else
%         scatter(ones(nMouseSess,1)*0.8+randn(nMouseSess,1)./15,matchAccs(1+ct:nMouseSess+ct),[],mouseColors(i,:),'filled');
%         scatter(ones(nMouseSess,1)*1.8+randn(nMouseSess,1)./15,misMatchAccs(1+ct:nMouseSess+ct),[],mouseColors(i,:),'filled','HandleVisibility','off');
%         ct = ct + nMouseSess;
%     end
% end
if ischar(tagSide)
    plot(repmat([1; 1.8],[1 nSess])+0.1,[leftAccs,rightAccs]','k-d','MarkerFaceColor','k');
else
    plot(repmat([1; 1.8],[1 nSess])+0.1,[matchAccs,misMatchAccs]','k-d','MarkerFaceColor','k');
end

plot([0 5],[0 0],'k--','HandleVisibility','off')                 % 0 line

xticks(1:2); % xtickangle(45);
xticklabels(tickLabels);
ylim([-0.50 0.50]);
xlim([0.5 2.5]);
legCell = ['Means','SEM',mouseLabs];
ylabel({'\Delta % Accuracy', 'On - Off Stim'})
% legend(legCell,'FontSize',16);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end