function [fHandle,ranksumPs,ranksumStats] = plot_cohort_rawLRAcc(mouseTables,saveName,tagSide)
%%% 2/25/2022 LKW
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

nMice = size(mouseTables,2);

leftOffAccs = [];
rightOffAccs = [];
mouseLabs = {};

if ischar(tagSide)
    leftOnAccs = [];
    rightOnAccs = [];
else
    matchAccs = [];
    misMatchAccs = [];
end

for i = 1:nMice
    optoOnlyS(i).animalBhvrT = rmmissing(mouseTables(i).animalBhvrT);   %Add mouse table to opto Only Struct
    cleanInds = optoOnlyS(i).animalBhvrT.stimType == "pre_training";
    cleanInds = logical(cleanInds + (optoOnlyS(i).animalBhvrT.stimType == "Tagging"));
    optoOnlyS(i).animalBhvrT(cleanInds,:) = [];

    leftOffAccs = [leftOffAccs; optoOnlyS(i).animalBhvrT.leftOffAcc];
    rightOffAccs = [rightOffAccs; optoOnlyS(i).animalBhvrT.rightOffAcc];
    if ischar(tagSide)
        leftOnAccs = [leftOnAccs; optoOnlyS(i).animalBhvrT.leftOnAcc];
        rightOnAccs = [rightOnAccs; optoOnlyS(i).animalBhvrT.rightOnAcc];
    else
        matchAccs = [matchAccs; optoOnlyS(i).animalBhvrT.matchAcc];
        misMatchAccs = [misMatchAccs; optoOnlyS(i).animalBhvrT.misMatchAcc];
    end
    strTmp = optoOnlyS(i).animalBhvrT.sessionID(1);
    spaceInds = strfind(strTmp,' ');
    mouseLabs{i} = optoOnlyS(i).animalBhvrT.sessionID{1}(1:spaceInds(1)-1);
end

nSess = numel(leftOffAccs);

%Wilcoxon RM mean difference test
[pLeftOffVRightOff,~,pLeftOffVRightOff_stats] = ranksum(leftOffAccs,rightOffAccs);%commpare left off vs right off
if tagSide == 1
    pLeftOnVOff = ranksum(leftOffAccs,matchAccs);     %compare left off vs left engram stim
    pRightOnVOff = ranksum(rightOffAccs,misMatchAccs);%compare right off vs left engram stim
elseif tagSide == 0
    pLeftOnVOff = ranksum(leftOffAccs,misMatchAccs);  %compare left off vs right engram stim
    pRightOnVOff = ranksum(rightOffAccs,matchAccs);   %Compare right off vs right engram stim
elseif ischar(tagSide)
    [pLeftOnVOff,~,pLeftOnVOff_stats] = ranksum(leftOffAccs,leftOnAccs);
    [pRightOnVOff,~,pRightOnVOff_stats] = ranksum(rightOffAccs,rightOnAccs);
end

muLeftOff = mean(leftOffAccs); semLeftOff = std(leftOffAccs)./sqrt(nSess);
muRightOff = mean(rightOffAccs); semRightOff = std(rightOffAccs)./sqrt(nSess);
if ischar(tagSide)
    muLeftOn = mean(leftOnAccs); semLeftOn = std(leftOnAccs)./sqrt(nSess);
    muRightOn = mean(rightOnAccs); semRightOn = std(rightOnAccs)./sqrt(nSess);
    [pLeftOnVRightOn,~,pLeftOnVRightOn_stats] = ranksum(leftOnAccs,rightOnAccs);
    meansV = [muLeftOff, muLeftOn; muRightOff, muRightOn];
    semsV = [semLeftOff, semLeftOn, semRightOff, semRightOn];
    ranksumPs = [pLeftOnVOff pRightOnVOff pLeftOffVRightOff pLeftOnVRightOn];
    ranksumStats = {pLeftOnVOff_stats,pRightOnVOff_stats,pLeftOffVRightOff_stats,pLeftOnVRightOn_stats};
else
    muMatch = mean(matchAccs); semMatch = std(matchAccs)./sqrt(nSess);
    muMisMatch = mean(misMatchAccs); semMisMatch = std(misMatchAccs)./sqrt(nSess);
    [pMatchVMisMatch,~,pMatchVMisMatch_stats] = ranksum(matchAccs,misMatchAccs);    %compare match vs mismatch engram stim
    meansV = [muLeftOff muRightOff muMatch muMisMatch];
    semsV = [semLeftOff semRightOff semMatch semMisMatch];
    ranksumPs = [pLeftOnVOff pRightOnVOff pLeftOffVRightOff pMatchVMisMatch];
    disp('Warning: graph xlabels  may not match this for OB L/R tag side cohorts!')
end


%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.33,0.525]);
b = bar(meansV,0.8);
b(1).FaceColor = [1 1 1];
b(1).EdgeColor = [0 0 0.8];
b(1).LineWidth = 1.5;
b(2).FaceColor = [0.5 0.5 1];
b(2).LineWidth = 1.5;

errorbar([0.85 1.15 1.85 2.15],reshape(meansV',[1,4]),semsV,'k.','LineWidth',1.5);    % SEM for raw acc

% For adding individual animals
% mouseColors = {'b','g','r','m','c',[0 0 0.5],[0 0.75 0],[1 0.5 0],[1 0.75 0]};
% mouseColors = hot(nMice+2);
% for i = 1:nMice
%     nMouseSess = size(optoOnlyS(i).animalBhvrT,1);
%     scatter(ones(nMouseSess,1)*0.85+randn(nMouseSess,1)./30,optoOnlyS(i).animalBhvrT.leftOffAcc,[],mouseColors(i,:),'filled');
%     scatter(ones(nMouseSess,1)*1.85+randn(nMouseSess,1)./30,optoOnlyS(i).animalBhvrT.rightOffAcc,[],mouseColors(i,:),'filled','HandleVisibility','off');
%     if tagSide == 'OBC'
%         scatter(ones(nMouseSess,1)*1.15+randn(nMouseSess,1)./30,optoOnlyS(i).animalBhvrT.leftOnAcc,[],mouseColors(i,:),'filled','HandleVisibility','off');
%         scatter(ones(nMouseSess,1)*2.15+randn(nMouseSess,1)./30,optoOnlyS(i).animalBhvrT.rightOnAcc,[],mouseColors(i,:),'filled','HandleVisibility','off');        
%     else
%         scatter(ones(nMouseSess,1)*3+randn(nMouseSess,1)./20,optoOnlyS(i).animalBhvrT.matchAcc,[],mouseColors(i,:),'filled','HandleVisibility','off');
%         scatter(ones(nMouseSess,1)*4+randn(nMouseSess,1)./20,optoOnlyS(i).animalBhvrT.misMatchAcc,[],mouseColors(i,:),'filled','HandleVisibility','off');
%     end
% end
%  xlim([0.5 3]);

plot([0 5],[0.5 0.5],'k--','HandleVisibility','off')                 % 50/50 line

xticks(1:2); % xtickangle(45);
% xticklabels({'Left Off','Right Off','Match Right On','Mis-Match Left On'});     %Relative to sample phase i.e. accuracy during test after left samples no stim
xticklabels({'Left','Right'});
ylim([0 1.1]);
xlim([0.5 2.5]);
% mouseLabs = {'OB09','OB10','OB11','OB12'};
legCell = ['Off','On','SEM',mouseLabs];
ylabel('Mean DNMP Accuracy')
legend(legCell,'FontSize',16);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end
end