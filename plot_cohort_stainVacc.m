function [fHandle,offRho,offP,onRho,onP] = plot_cohort_stainVacc(meanBhvrT,saveName)
%%% 4/4/2022 LKW
%Inputs: 
%meanBhvrT = table of averaged values for each mouse OB_Analyze_Script.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

nMice = size(meanBhvrT,2);

onAccs = [];
offAccs = [];
mouseLabs = {};

[offRho.eyfp,offP.eyfp] = corr([meanBhvrT.eyfp_ct meanBhvrT.totOffAcc],'Type','Spearman');
[offRho.cfos,offP.cfos] = corr([meanBhvrT.cfos_ct meanBhvrT.totOffAcc],'Type','Spearman');
[offRho.OL,offP.OL] = corr([meanBhvrT.OL_ct meanBhvrT.totOffAcc],'Type','Spearman');
[onRho.eyfp,onP.eyfp] = corr([meanBhvrT.eyfp_ct meanBhvrT.onAcc],'Type','Spearman');
[onRho.cfos,onP.cfos] = corr([meanBhvrT.cfos_ct meanBhvrT.onAcc],'Type','Spearman');
[onRho.OL,onP.OL] = corr([meanBhvrT.OL_ct meanBhvrT.onAcc],'Type','Spearman');

for i = 1:nMice
    optoOnlyS(i).animalBhvrT = rmmissing(meanBhvrT(i).animalBhvrT);   %Add mouse table to opto Only Struct
    cleanInds = optoOnlyS(i).animalBhvrT.stimType == "pre_training";
    cleanInds = logical(cleanInds + (optoOnlyS(i).animalBhvrT.stimType == "Tagging"));
    optoOnlyS(i).animalBhvrT(cleanInds,:) = [];

    offAccs = [offAccs; optoOnlyS(i).animalBhvrT.totOffAcc];
    onAccs = [onAccs; optoOnlyS(i).animalBhvrT.onAcc];
    strTmp = optoOnlyS(i).animalBhvrT.sessionID(1);
    spaceInds = strfind(strTmp,' ');
    mouseLabs{i} = optoOnlyS(i).animalBhvrT.sessionID{1}(1:spaceInds(1)-1);
end

nSess = numel(offAccs);

muOff = mean(offAccs); semOff = std(offAccs)./sqrt(nSess);
muOn = mean(onAccs); semOn = std(onAccs)./sqrt(nSess);

%Wilcoxon RM mean difference test
pOnVOff = ranksum(offAccs,onAccs);

meansV = [muOff muOn];
semsV = [semOff semOn];
wilcoxonPs = pOnVOff;

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.33,0.525]);
plot(meanBhvrT.eyfp_ct,meanBhvrT.totOffAcc,'o','LineWidth',2,'MarkerSize',10,'MarkerEdgeColor',[0 0 0.8])
plot(meanBhvrT.eyfp_ct,meanBhvrT.onAcc,'o','LineWidth',2,'MarkerSize',10,'MarkerEdgeColor',[0 0 0.8],'MarkerFaceColor',[0.5,0.5,1])

% plot([0 5],[0.5 1],'k--','HandleVisibility','off')                 % 50/50 line

% xticks(1:2);
% xticklabels({'Off Stim','On Stim'});     %Relative to sample phase i.e. accuracy during test after left samples no stim
% ylim([0 1.1]); 
% xlim([0.5 2.5]);
% % mouseLabs = {'OB09','OB10','OB11','OB12'};
% legCell = ['Means','SEM',mouseLabs];
% ylabel('Mean DNMP Accuracy')
% legend(legCell,'FontSize',16);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end
end