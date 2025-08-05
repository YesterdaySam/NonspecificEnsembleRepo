function [fHandle,pstruc,statstruc] = plot_cohort_accdeltaXdays(bhvrTable,saveName,pstruc,statstruc)
%%% 3/9/2023 LKW

ctlCleanInds = bhvrTable.stimType ~= "opto_20Hz";
bhvrTable(ctlCleanInds,:) = [];
bhvrTable = rmmissing(bhvrTable);   %Provisional
mNames = unique(strtok(bhvrTable.sessionID)); nMice = numel(mNames);

dayOn = [];
dayOff = [];

for i = 1:nMice
    mouseInds = strtok(bhvrTable.sessionID) == mNames(i);
    tmpOff = bhvrTable.totOffAcc(mouseInds)';
    tmpOn = bhvrTable.onAcc(mouseInds)';
    if length(tmpOff) < 5
        addlen = 5 - length(tmpOff);
        tmpOff = [tmpOff NaN(1,addlen)];
        tmpOn = [tmpOn NaN(1,addlen)];
    end
    dayOff = [dayOff; tmpOff];
    dayOn = [dayOn; tmpOn];
end

muDelta = nanmean(dayOn) - nanmean(dayOff); semDelta = nanstd(dayOn - dayOff)./sqrt(nMice);

z = 1.96;   % 95% confidence = 1.96
upCI = muDelta + z*semDelta; dnCI = muDelta - z*semDelta;

%Wilcoxon RM mean difference test
nDays = size(muDelta,2);
vDay = 1:nDays;
[statstruc.acc_corr_delta_rho,pstruc.acc_corr_delta] = corr(vDay',muDelta','Rows','complete');

meansV = [muDelta];
semsV = [semDelta];

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.4,0.525]);
xticks(1:5)
xlabel('Day');
ylim([-.75 0.75]); 
ylabel('\Delta DNMP Accuracy On - Off')

mouseColors = [0.5 0.5 0.5; 0.5 0.5 1];

plot(meansV(1,:),'LineWidth',2,'Color',mouseColors(1,:));
patchXs = [1:nDays,fliplr(1:nDays)]; %Vector of x coords;
patch(patchXs,[dnCI,fliplr(upCI)],'k','EdgeColor','none','FaceAlpha',0.2);

randCxs = repmat(vDay,[nMice,1]) + randn(nMice,nDays)./40;

for i = 1:nMice
    scatter(randCxs(i,:)-0,(dayOn(i,:) - dayOff(i,:)),[],mouseColors(1,:),'filled');
end

xlim([0.5 nDays+0.5]);
plot([0 5],[0 0],'k--','HandleVisibility','off')                 % 0 line

% legCell = {'eYFP','ChR2'};
% legend(legCell,'location','se','FontSize',16);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end