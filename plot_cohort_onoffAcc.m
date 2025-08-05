function [fHandle,pstruc,statstruc] = plot_cohort_onoffAcc(mouseTables,saveName,pstruc,statstruc)
%%% 5/19/2021 LKW
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

nMice = size(mouseTables,2);

onAccs = [];
offAccs = [];
mouseLabs = {};

for i = 1:nMice
    optoOnlyS(i).animalBhvrT = rmmissing(mouseTables(i).animalBhvrT);   %Add mouse table to opto Only Struct
    cleanInds = optoOnlyS(i).animalBhvrT.stimType == "pre_training";
    cleanInds = logical(cleanInds + (optoOnlyS(i).animalBhvrT.stimType == "Tagging"));
    optoOnlyS(i).animalBhvrT(cleanInds,:) = [];

    %By trial
%     offAccs = [offAccs; optoOnlyS(i).animalBhvrT.totOffAcc];
%     onAccs = [onAccs; optoOnlyS(i).animalBhvrT.onAcc];
    %Mouse averaged
    offAccs = [offAccs; mean(optoOnlyS(i).animalBhvrT.totOffAcc)];
    onAccs = [onAccs; mean(optoOnlyS(i).animalBhvrT.onAcc)];
    
%     strTmp = optoOnlyS(i).animalBhvrT.sessionID(1);
%     spaceInds = strfind(strTmp,' ');
    mouseLabs{i} = strtok(optoOnlyS(i).animalBhvrT.sessionID(1));
end

nSess = numel(offAccs);

muOff = mean(offAccs); semOff = std(offAccs)./sqrt(nSess);
muOn = mean(onAccs); semOn = std(onAccs)./sqrt(nSess);

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

% For plotting individual mice
% mouseColors = [0.5 0.5 0.5; 0.5 0.5 1];
% for i = 1:nMice
%     %For individual sessions
% %     nMouseSess = size(optoOnlyS(i).animalBhvrT,1);
% %     scatter(ones(nMouseSess,1)*1+randn(nMouseSess,1)./15,optoOnlyS(i).animalBhvrT.totOffAcc,[],mouseColors(i,:),'filled');
% %     scatter(ones(nMouseSess,1)*2+randn(nMouseSess,1)./15,optoOnlyS(i).animalBhvrT.onAcc,[],mouseColors(i,:),'filled','HandleVisibility','off');
% end

%For mouse-averaged individual plotting
plot(repmat([1; 1.8],[1 nSess])+0.1,[offAccs,onAccs]','k-d','MarkerFaceColor','k');
xlim([0.5 3]);

plot([0 5],[0.5 0.5],'k--','HandleVisibility','off')                 % 50/50 line

xticks(1:2);
xticklabels({'Off Stim','On Stim'});     %Relative to sample phase i.e. accuracy during test after left samples no stim
ylim([0 1.1]); 
xlim([0.5 2.5]);
% mouseLabs = {'OB09','OB10','OB11','OB12'};
legCell = {'Means','SEM'};
ylabel('Mean DNMP Accuracy')
% legend(legCell,'FontSize',16);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end