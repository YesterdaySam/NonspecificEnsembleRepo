function [fHandle,pstruc,tblstruc,statstruc] = plot_cohort_grossStimAcc(mouseTables,saveName,pstruc,statstruc)
% 5/22/2021 LKW
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

nMice = size(mouseTables,2);

totAccs = [];
baseAccs = [];
totOffAccs = [];
onAccs = [];
mouseLabs = {};

for i = 1:nMice
    optoOnlyS(i).animalBhvrT = rmmissing(mouseTables(i).animalBhvrT);   %Add mouse table to opto Only Struct
    cleanInds = optoOnlyS(i).animalBhvrT.stimType == "pre_training";
    cleanInds = logical(cleanInds + (optoOnlyS(i).animalBhvrT.stimType == "Tagging"));
    optoOnlyS(i).animalBhvrT(cleanInds,:) = [];

    totAccs = [totAccs; optoOnlyS(i).animalBhvrT.totAcc];
    baseAccs = [baseAccs; optoOnlyS(i).animalBhvrT.baseAcc];
    totOffAccs = [totOffAccs; optoOnlyS(i).animalBhvrT.totOffAcc];
    onAccs = [onAccs; optoOnlyS(i).animalBhvrT.onAcc];
    strTmp = optoOnlyS(i).animalBhvrT.sessionID(1);
    spaceInds = strfind(strTmp,' ');
    mouseLabs{i} = optoOnlyS(i).animalBhvrT.sessionID{1}(1:spaceInds(1)-1);
end

nSess = numel(totAccs);

muTot = mean(totAccs); semTot = std(totAccs)./sqrt(nSess);
muBase = mean(baseAccs); semBase = std(baseAccs)./sqrt(nSess);
muTotOff = mean(totOffAccs); semTotOff = std(totOffAccs)./sqrt(nSess);
muOn = mean(onAccs); semOn = std(onAccs)./sqrt(nSess);

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
% b.CData(3,:) = 
b.CData(4,:) = [0.5 0.5 1];
b.EdgeColor = [0 0 0.8];
b.LineWidth = 1.5;
errorbar(meansV,semsV,'k.','LineWidth',1.5);    % SEM for raw acc

% For plotting individual mice
% % mouseColors = {'b','g','r','m','c',[0 0 0.5],[0 0.75 0],[1 0.5 0],[1 0.75 0]};
% mouseColors = hot(nMice+2);
% for i = 1:nMice
%     nMouseSess = size(optoOnlyS(i).animalBhvrT,1);
%     scatter(ones(nMouseSess,1)*1+randn(nMouseSess,1)./18,optoOnlyS(i).animalBhvrT.totAcc,[],mouseColors(i,:),'filled');
%     scatter(ones(nMouseSess,1)*2+randn(nMouseSess,1)./18,optoOnlyS(i).animalBhvrT.baseAcc,[],mouseColors(i,:),'filled','HandleVisibility','off');
%     scatter(ones(nMouseSess,1)*3+randn(nMouseSess,1)./18,optoOnlyS(i).animalBhvrT.totOffAcc,[],mouseColors(i,:),'filled','HandleVisibility','off');
%     scatter(ones(nMouseSess,1)*4+randn(nMouseSess,1)./18,optoOnlyS(i).animalBhvrT.onAcc,[],mouseColors(i,:),'filled','HandleVisibility','off');
% end
%  xlim([0.5 6]);

% errorbar([0.86 1.14 1.86 2.14],reshape(meansV',[1,4]),semsV,'k.','LineWidth',1)    % SEM for mean deltas
% for i = 1:nSess
%     plot(ones(1,nSess).*,sessionAccs(i,:),'-o','LineWidth',2);
% end 

plot([0 5],[0.5 0.5],'k--','HandleVisibility','off')                 % 50/50 line

xticks(1:4); xtickangle(45);
xticklabels({'All Trials','Baseline','Off Stim','On Stim'});
ylim([0 1.1]);
xlim([0.5 4.5]);
legCell = ['Means','SEM',mouseLabs];
ylabel('Mean DNMP Accuracy')
legend(legCell,'FontSize',16);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end