function [fHandle] = plot_obc_corr_accVbhvr(bhvr_ctl,bhvr_exp,acc_ctl,acc_exp,saveName)
%%% 8/15/2022 LKW
%Inputs: 
% day = vector of days from exptT
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

nMiceCtl = length(bhvr_ctl)/5;
nMiceExp = length(bhvr_exp)/5;

bhvr_trn_ctl = mean(reshape(bhvr_ctl(:,1),5,nMiceCtl));
bhvr_tst_ctl = mean(reshape(bhvr_ctl(:,2),5,nMiceCtl));
bhvr_trn_exp = mean(reshape(bhvr_exp(:,1),5,nMiceExp));
bhvr_tst_exp = mean(reshape(bhvr_exp(:,2),5,nMiceExp));
xmin = min([bhvr_trn_ctl,bhvr_tst_ctl,bhvr_trn_exp,bhvr_tst_exp]);
xmax = max([bhvr_trn_ctl,bhvr_tst_ctl,bhvr_trn_exp,bhvr_tst_exp]);

acc_ctl = mean(reshape(acc_ctl,5,nMiceCtl));
acc_exp = mean(reshape(acc_exp,5,nMiceExp));

mdl_ctl_trn = fitlm(bhvr_trn_ctl,acc_ctl);
xs_ctl_trn = [min(bhvr_trn_ctl); max(bhvr_trn_ctl)];
ys_ctl_trn = predict(mdl_ctl_trn,xs_ctl_trn);

mdl_exp_trn = fitlm(bhvr_trn_exp,acc_exp);
xs_exp_trn = [min(bhvr_trn_exp); max(bhvr_trn_exp)];
ys_exp_trn = predict(mdl_exp_trn,xs_exp_trn);

mdl_ctl_tst = fitlm(bhvr_tst_ctl,acc_ctl);
xs_ctl_tst = [min(bhvr_tst_ctl); max(bhvr_tst_ctl)];
ys_ctl_tst = predict(mdl_ctl_tst,xs_ctl_tst);

mdl_exp_tst = fitlm(bhvr_tst_exp,acc_exp);
xs_exp_tst = [min(bhvr_tst_exp); max(bhvr_tst_exp)];
ys_exp_tst = predict(mdl_exp_tst,xs_exp_tst);

%%
fHandle = figure; hold on; axis square
plot(bhvr_trn_ctl,acc_ctl,'o','MarkerEdgeColor',[0.4 0.4 0.4]);
plot(bhvr_tst_ctl,acc_ctl,'o','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor',[0.7 0.7 0.7]);
plot(bhvr_trn_exp,acc_exp,'d','MarkerEdgeColor',[0.3 0.3 1]);
plot(bhvr_tst_exp,acc_exp,'d','MarkerFaceColor',[0.5 0.5 1],'MarkerEdgeColor',[0.5 0.5 1]);
plot(xs_ctl_trn,ys_ctl_trn,'--','Color',[0.4 0.4 0.4],'LineWidth',1)
plot(xs_exp_trn,ys_exp_trn,'--','Color',[0.3 0.3 1],'LineWidth',1)
plot(xs_ctl_tst,ys_ctl_tst,'--','Color',[0.7 0.7 0.7],'LineWidth',1)
plot(xs_exp_tst,ys_exp_tst,'--','Color',[0.5 0.5 1],'LineWidth',1)
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.25,0.45]);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

ylabel('DNMP Accuracy');     %Relative to sample phase i.e. accuracy during test after left samples no stim
ylim([0 1.1])
xlim([xmin-0.1, xmax+0.1]);
legCell = {'eYFP Train','eYFP Test','ChR2 Train','ChR2 Test'};
legend(legCell,'FontSize',16,'Location','best');
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end
end