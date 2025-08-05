function [fHandle,wilcoxonPs] = plot_mouse_rawLRAcc(mouseTable,saveName,tagSide)
% 2/25/2022 LKW
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'
%tagSie = 0 or 1 for R vs L maze tag

optoOnlyT = rmmissing(mouseTable);
cleanInds = optoOnlyT.stimType == "pre_training";
cleanInds = logical(cleanInds + (optoOnlyT.stimType == "Tagging"));
optoOnlyT(cleanInds,:) = [];
nSess = height(optoOnlyT);

%Wilcoxon RM mean difference test
if tagSide == 1
    pLeftOnVOff = ranksum(optoOnlyT.leftOffAcc,optoOnlyT.matchAcc);     %compare left off vs left engram stim
    pRightOnVOff = ranksum(optoOnlyT.rightOffAcc,optoOnlyT.misMatchAcc);%compare right off vs left engram stim
elseif tagSide == 0
    pLeftOnVOff = ranksum(optoOnlyT.leftOffAcc,optoOnlyT.misMatchAcc);  %compare left off vs right engram stim
    pRightOnVOff = ranksum(optoOnlyT.rightOffAcc,optoOnlyT.matchAcc);   %Compare right off vs right engram stim
elseif tagSide == 'OBC'
    pLeftOnVOff = ranksum(optoOnlyT.leftOffAcc,optoOnlyT.leftOnAcc);
    pRightOnVOff = ranksum(optoOnlyT.rightOffAcc,optoOnlyT.rightOnAcc);
end

muLeftOff = mean(optoOnlyT.leftOffAcc); semLeftOff = std(optoOnlyT.leftOffAcc)./sqrt(nSess);
muRightOff = mean(optoOnlyT.rightOffAcc); semRightOff = std(optoOnlyT.rightOffAcc)./sqrt(nSess);
pLeftOffVRightOff = ranksum(optoOnlyT.leftOffAcc,optoOnlyT.rightOffAcc);%commpare left off vs right off
if tagSide == 'OBC'
    muLeftOn = mean(optoOnlyT.leftOnAcc); semLeftOn = std(optoOnlyT.leftOnAcc)./sqrt(nSess);
    muRightOn = mean(optoOnlyT.rightOnAcc); semRightOn = std(optoOnlyT.rightOnAcc)./sqrt(nSess);
    meansV = [muLeftOff muLeftOn muRightOff muRightOn];
    semsV = [semLeftOff semLeftOn semRightOff semRightOn];
    pLeftVRightOn = ranksum(optoOnlyT.leftOnAcc,optoOnlyT.rightOnAcc);    %compare match vs mismatch engram stim
    sessionAccs = [optoOnlyT.leftOffAcc optoOnlyT.leftOnAcc optoOnlyT.rightOffAcc optoOnlyT.rightOnAcc];
    wilcoxonPs = [pLeftOnVOff pRightOnVOff pLeftOffVRightOff pLeftVRightOn];
    xtickLabs = {'Left Off','Left On','Right Off','Right On'};
else
    muMatch = mean(optoOnlyT.matchAcc); semMatch = std(optoOnlyT.matchAcc)./sqrt(nSess);
    muMisMatch = mean(optoOnlyT.misMatchAcc); semMisMatch = std(optoOnlyT.misMatchAcc)./sqrt(nSess);
    meansV = [muLeftOff muRightOff muMatch muMisMatch];
    semsV = [semLeftOff semRightOff semMatch semMisMatch];
    pMatchVMisMatch = ranksum(optoOnlyT.matchAcc,optoOnlyT.misMatchAcc);    %compare match vs mismatch engram stim
    sessionAccs = [optoOnlyT.leftOffAcc optoOnlyT.rightOffAcc optoOnlyT.matchAcc optoOnlyT.misMatchAcc];
    wilcoxonPs = [pLeftOnVOff pRightOnVOff pLeftOffVRightOff pMatchVMisMatch];
    xtickLabs = {'Left Off','Left On','Right Off','Right On'};
    
    disp('warning: check xlabels of graph for accuracy')
end


%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.33,0.525]);
bar(meansV,0.4)
errorbar(meansV,semsV,'k.','LineWidth',1);    % SEM for raw acc
plot(sessionAccs','-o','LineWidth',2);
% errorbar([0.86 1.14 1.86 2.14],reshape(meansV',[1,4]),semsV,'k.','LineWidth',1)    % SEM for mean deltas
% for i = 1:nSess
%     plot(ones(1,nSess).*,sessionAccs(i,:),'-o','LineWidth',2);
% end 
plot([0 5],[0.5 0.5],'k--')                 % 50/50 line

xticks(1:4); xtickangle(45);
xticklabels(xtickLabs);
ylim([0 1.1]); xlim([0.5 6]);
ylabel('Mean DNMP Accuracy')
legend({'Means','SEM','Day 1','2','3','4','5'},'FontSize',16);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end
end