function [fHandle,pstruc,statstruc] = plot_cohort_pulsexday_comp(ctlTable,expTable,saveName,pstruc,statstruc)
%%% 4/17/2023 LKW
%Inputs: 
%ctlTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

corrType = "pearson";
ctlCleanInds = ctlTable.stimType ~= "opto_20Hz";
expCleanInds = expTable.stimType ~= "opto_20Hz";
ctlTable(ctlCleanInds,:) = [];
expTable(expCleanInds,:) = [];
ctlNames = unique(strtok(ctlTable.sessionID)); nMiceCtl = numel(ctlNames);
expNames = unique(strtok(expTable.sessionID)); nMiceExp = numel(expNames);
nDays = height(expTable)/nMiceExp;

% Days Vs pulses
exp_xs = reshape(expTable.day,nDays,nMiceExp);
exp_pulses = reshape(expTable.muPulses,5,nMiceExp);
mu_exp = mean(exp_pulses,2); sem_exp = std(exp_pulses')./sqrt(nMiceExp);
ctl_xs = reshape(ctlTable.day,nDays,nMiceCtl); 
ctl_pulses = reshape(ctlTable.muPulses,5,nMiceCtl);
mu_ctl = mean(ctl_pulses,2); sem_ctl = std(ctl_pulses')./sqrt(nMiceCtl);

z = 1.96;   % 95% confidence = 1.96
upCICtl = mu_ctl' + z*sem_ctl; dnCICtl = mu_ctl' - z*sem_ctl;
upCIExp = mu_exp' + z*sem_exp; dnCIExp = mu_exp' - z*sem_exp;

[statstruc.dayVpulse_exp,pstruc.dayVpulse_exp] = corr(expTable.day,expTable.muPulses,'Type',corrType);
[statstruc.dayVpulse_ctl,pstruc.dayVpulse_ctl] = corr(ctlTable.day,ctlTable.muPulses,'Type',corrType);

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.35,0.45]);
plot(ctl_xs(:,1),mu_ctl,'Color',[0.7 0.7 0.7],'LineWidth',3);
plot(exp_xs(:,1),mu_exp,'Color',[0.5 0.5 1],'LineWidth',3);
patchXs = [1:nDays,fliplr(1:nDays)]; %Vector of x coords;
patch(patchXs,[dnCICtl,fliplr(upCICtl)],'k','EdgeColor','none','FaceAlpha',0.2);
patch(patchXs,[dnCIExp,fliplr(upCIExp)],'b','EdgeColor','none','FaceAlpha',0.2);
plot(ctl_xs-0.15,ctl_pulses,'o','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor',[0.5 0.5 0.5]);
plot(exp_xs+0.15,exp_pulses,'d','MarkerFaceColor',[0.3 0.3 0.7],'MarkerEdgeColor',[0.3 0.3 0.7]);
xticks(1:5)
xlabel('Day');     %Relative to sample phase i.e. accuracy during test after left samples no stim
xlim([0.5 5.5]);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);
legCell = {'eYFP','ChR2'};
legend(legCell,'FontSize',16,'location','ne');
ylabel('Train Phase Pulses (n)')

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end