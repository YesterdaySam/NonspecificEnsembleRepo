function [fHandle,pstruc,statstruc] = plot_cohort_pulse_comp(ctlPulses,expPulses,saveName,pstruc,statstruc)
%%% 3/2/2023 LKW
%Inputs: 
%ctlTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

nMiceCtl = length(ctlPulses); 
nMiceExp = length(expPulses);

mu_pulse_ctl = mean(ctlPulses); sem_pulse_ctl = std(ctlPulses)./sqrt(nMiceCtl);
mu_pulse_exp = mean(expPulses); sem_pulse_exp = std(expPulses)./sqrt(nMiceExp);
[~,pstruc.pulse_ave_ctlVexp,~,statstruc.pulse_ave_ctlVexp] = ttest2(ctlPulses,expPulses);

fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.15,0.525]);
errorbar([1,2],[mu_pulse_ctl,mu_pulse_exp],[sem_pulse_ctl,sem_pulse_exp],'k.')
scatter(1.15*ones(1,nMiceCtl),ctlPulses,[],'o','filled','MarkerFaceColor',[0.7 0.7 0.7])
scatter(2.15*ones(1,nMiceExp),expPulses,[],'d','filled','MarkerFaceColor',[0.5 0.5 1])
xlim([0.5 2.5]); ylim([400 1200])
xticks(1:2); xticklabels({'eYFP','ChR2'})
ylabel('Mean Pulses')
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end