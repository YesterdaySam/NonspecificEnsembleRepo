function [fHandle] = plot_obc_means(off_trn,on_trn,off_tst,on_tst,saveName)
%%% 8/16/2022 LKW
%Inputs: 
%
%saveName = only save if string. fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

nMice = length(off_trn)/5;
% xs = reshape(day,5,nMice);
xs = rand(nMice,1)*0.05;
off_trn_ys = mean(reshape(off_trn,5,nMice));
on_trn_ys = mean(reshape(on_trn,5,nMice));
off_tst_ys = mean(reshape(off_tst,5,nMice));
on_tst_ys = mean(reshape(on_tst,5,nMice));

%Get means of data
mu_dat = [mean(off_trn), mean(on_trn); mean(off_tst), mean(on_tst)];
sem_dat = [std(off_trn_ys)./sqrt(nMice),std(on_trn_ys)./sqrt(nMice);std(off_tst_ys)./sqrt(nMice),std(on_tst_ys)./sqrt(nMice)];
%%
fHandle = figure; hold on; axis square
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.25,0.45]);
b = bar(mu_dat);
b(1).FaceColor = [1 1 1];
b(1).EdgeColor = [0 0 0.8];
b(1).LineWidth = 1.5;
b(2).FaceColor = [0.5 0.5 1];
b(2).EdgeColor = [0 0 0.5];
b(2).LineWidth = 1.5;

errorbar([0.85,1.15;1.85,2.15],mu_dat,sem_dat,'k.','LineWidth',1)

plot([xs'+0.75;xs'+1.05],[off_trn_ys;on_trn_ys],'k')
plot([xs'+1.75;xs'+2.05],[off_tst_ys;on_tst_ys],'k')

s1 = scatter(xs+0.75,off_trn_ys,'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0 0 0.8]);
s2 = scatter(xs+1.05,on_trn_ys,'MarkerFaceColor',[0.5 0.5 1],'MarkerEdgeColor',[0 0 0.5]);
s1 = scatter(xs+1.75,off_tst_ys,'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0 0 0.8]);
s2 = scatter(xs+2.05,on_tst_ys,'MarkerFaceColor',[0.5 0.5 1],'MarkerEdgeColor',[0 0 0.5]);

xticks(1:2)
xticklabels({'Train','Test'})
xlim([0.5 2.5]);
curY = max(ylim);
ylim([0, curY+curY/3]);
legCell = {'Mean Off','Mean On'};
legend(legCell,'FontSize',16,'Location','best');
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end
end