function [fHandle,pstruc,statstruc] = plot_cohort_accXdays_comp(ctlTable,expTable,saveName,pstruc,statstruc)
%%% 3/2/2023 LKW
%Inputs: 
%ctlTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

ctlCleanInds = ctlTable.stimType ~= "opto_20Hz";
expCleanInds = expTable.stimType ~= "opto_20Hz";
ctlTable(ctlCleanInds,:) = [];
expTable(expCleanInds,:) = [];
ctlNames = unique(strtok(ctlTable.sessionID)); nMiceCtl = numel(ctlNames);
expNames = unique(strtok(expTable.sessionID)); nMiceExp = numel(expNames);

ctlOn = []; expOn = [];
ctlOff = []; expOff = [];

for i = 1:nMiceCtl
    mouseInds = strtok(ctlTable.sessionID) == ctlNames(i);
    ctlOff = [ctlOff; ctlTable.totOffAcc(mouseInds)'];
    ctlOn = [ctlOn; ctlTable.onAcc(mouseInds)'];
end

for i = 1:nMiceExp
    mouseInds = strtok(expTable.sessionID) == expNames(i);
    expOff = [expOff; expTable.totOffAcc(mouseInds)'];
    expOn = [expOn; expTable.onAcc(mouseInds)'];
end

muCtlDelta = mean(ctlOn) - mean(ctlOff); semCtlDelta = std(ctlOn - ctlOff)./sqrt(nMiceCtl);
muExpDelta = mean(expOn) - mean(expOff); semExpDelta = std(expOn - expOff)./sqrt(nMiceExp);

z = 1.96;   % 95% confidence = 1.96, 99% = 2.57
upCICtl = muCtlDelta + z*semCtlDelta; dnCICtl = muCtlDelta - z*semCtlDelta;
upCIExp = muExpDelta + z*semExpDelta; dnCIExp = muExpDelta - z*semExpDelta;

%Wilcoxon RM mean difference test
nDays = size(muExpDelta,2);
vDay = 1:nDays;
[statstruc.acc_corr_ctlDelta_rho,pstruc.acc_corr_ctlDelta] = corr(vDay',muCtlDelta');
[statstruc.acc_corr_expDelta_rho,pstruc.acc_corr_expDelta] = corr(vDay',muExpDelta');

meansV = [muCtlDelta; muExpDelta];
semsV = [semCtlDelta semExpDelta];

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.4,0.525]);
xticks(1:5)
xlabel('Day');
ylim([-0.5 0.5]); 
xlim([0.5 nDays+0.5]);
ylabel('\Delta DNMP Accuracy On - Off')

mouseColors = [0.5 0.5 0.5; 0.5 0.5 1];

plot(meansV(1,:),'LineWidth',2,'Color',mouseColors(1,:));
plot(meansV(2,:),'LineWidth',2,'Color',mouseColors(2,:));
patchXs = [1:nDays,fliplr(1:nDays)]; %Vector of x coords;
patch(patchXs,[dnCICtl,fliplr(upCICtl)],'k','EdgeColor','none','FaceAlpha',0.4);
patch(patchXs,[dnCIExp,fliplr(upCIExp)],'b','EdgeColor','none','FaceAlpha',0.4);

randCxs = repmat(vDay,[nMiceCtl,1]) + randn(nMiceCtl,nDays)./40;
randExs = repmat(vDay,[nMiceExp,1]) + randn(nMiceExp,nDays)./40;

for i = 1:nMiceCtl
    scatter(randCxs(i,:)-0.15,(ctlOn(i,:) - ctlOff(i,:)),[],mouseColors(1,:),'o');
end
for i = 1:nMiceExp
    scatter(randExs(i,:)+0.15,(expOn(i,:) - expOff(i,:)),[],mouseColors(2,:),'d');
end

xlim([0.5 nDays+0.5]);
plot([0 5],[0 0],'k--','HandleVisibility','off')                 % 0 line

legCell = {'eYFP','ChR2'};
legend(legCell,'location','se','FontSize',16);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end