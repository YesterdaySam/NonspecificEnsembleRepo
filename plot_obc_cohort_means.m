function [fHandle] = plot_obc_cohort_means(ctl_trn,exp_trn,ctl_tst,exp_tst,saveName)
%%% 8/16/2022 LKW
%Inputs: 
%
%saveName = only save if string. fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

nMiceCtl = length(ctl_trn)/5;
nMiceExp = length(exp_trn)/5;

xs_ctl = rand(nMiceCtl,1)*0.05;
xs_exp = rand(nMiceExp,1)*0.05;

ctl_trn_ys = mean(reshape(ctl_trn,5,nMiceCtl));
exp_trn_ys = mean(reshape(exp_trn,5,nMiceExp));
ctl_tst_ys = mean(reshape(ctl_tst,5,nMiceCtl));
exp_tst_ys = mean(reshape(exp_tst,5,nMiceExp));

%Get means of data
mu_dat = [mean(ctl_trn), mean(exp_trn); mean(ctl_tst), mean(exp_tst)];
sem_dat = [std(ctl_trn_ys)./sqrt(nMiceCtl),std(exp_trn_ys)./sqrt(nMiceExp);std(ctl_tst_ys)./sqrt(nMiceCtl),std(exp_tst_ys)./sqrt(nMiceExp)];

%%
fHandle = figure; hold on; axis square
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.25,0.45]);
b = bar(mu_dat);
b(1).FaceColor = [0.7 0.7 0.7];
b(1).EdgeColor = [0 0 0.8];
b(1).LineWidth = 1.5;
b(2).FaceColor = [0.5 0.5 1];
b(2).EdgeColor = [0 0 0.5];
b(2).LineWidth = 1.5;

errorbar([0.85,1.15;1.85,2.15],mu_dat,sem_dat,'k.','LineWidth',1)

plot([0 3],[1 1],'k--') %base line

s1 = scatter(xs_ctl+0.75,ctl_trn_ys,'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0.5 0.5 0.5]);
s2 = scatter(xs_exp+1.05,exp_trn_ys,'d','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0.3 0.3 0.7]);
s1 = scatter(xs_ctl+1.75,ctl_tst_ys,'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0.5 0.5 0.5]);
s2 = scatter(xs_exp+2.05,exp_tst_ys,'d','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0.3 0.3 0.7]);

xticks(1:2)
xticklabels({'Train','Test'})
xlim([0.5 2.5]);
curY = max(ylim);
ylim([0, curY+curY/3]);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end
end