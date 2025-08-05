function [fHandle,pstruc,statstruc] = plot_cohort_pulsexacc_comp(ctlTable,expTable,saveName,pstruc,statstruc)
%%% 4/17/2023 LKW
%Inputs: 
%ctlTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

corrType = "spearman";
ctlCleanInds = ctlTable.stimType ~= "opto_20Hz";
expCleanInds = expTable.stimType ~= "opto_20Hz";
ctlTable(ctlCleanInds,:) = [];
expTable(expCleanInds,:) = [];
ctlNames = unique(strtok(ctlTable.sessionID)); nMiceCtl = numel(ctlNames);
expNames = unique(strtok(expTable.sessionID)); nMiceExp = numel(expNames);
nDays = height(expTable)/nMiceExp;

[statstruc.accVpulse_exp,pstruc.accVpulse_exp] = corr(expTable.onAcc,expTable.muPulses,'Type',corrType);
[statstruc.accVpulse_ctl,pstruc.accVpulse_ctl] = corr(ctlTable.onAcc,ctlTable.muPulses,'Type',corrType);

mdl_pulseVAcc_ctl = fitlm(ctlTable.muPulses,ctlTable.onAcc);
plsAcc_xs_ctl = [min(ctlTable.muPulses); max(ctlTable.muPulses)];
plsAcc_ys_ctl = predict(mdl_pulseVAcc_ctl,plsAcc_xs_ctl);

mdl_pulseVAcc_exp = fitlm(expTable.muPulses,expTable.onAcc);
plsAcc_xs_exp = [min(expTable.muPulses); max(expTable.muPulses)];
plsAcc_ys_exp = predict(mdl_pulseVAcc_exp,plsAcc_xs_exp);

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.35,0.45]);
plot(plsAcc_xs_ctl,plsAcc_ys_ctl,'--','LineWidth',2,'Color',[.7 .7 .7]);
plot(plsAcc_xs_exp,plsAcc_ys_exp,'--','LineWidth',2,'Color',[.5 .5 1]);
plot(ctlTable.muPulses,ctlTable.onAcc,'o','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor',[0.7 0.7 0.7]);
plot(expTable.muPulses,expTable.onAcc,'d','MarkerFaceColor',[0.5 0.5 1],'MarkerEdgeColor',[0.5 0.5 1]);
xlabel('Mean Train Phase Pulses (n)')
ylabel('Mean On Accuracy (%)')
ylim([0 1])
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);
legCell = {'eYFP','ChR2'};
legend(legCell,'FontSize',16,'location','se');

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end