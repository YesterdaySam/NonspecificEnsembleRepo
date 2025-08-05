function [fHandle] = plot_obc_cellcorr(ctl_ct,exp_ct,ctl_bhvr,exp_bhvr,grpCols,saveName)
%%% 8/15/2022 LKW
%Inputs: 
% day = vector of days from exptT
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

% nMiceCtl = length(ctl_ct);
% nMiceExp = length(exp_ct);

mdl_ctl = fitlm(ctl_ct,ctl_bhvr);
xs_ctl = [min(ctl_ct); max(ctl_ct)];
ys_ctl = predict(mdl_ctl,xs_ctl);

mdl_exp = fitlm(exp_ct,exp_bhvr);
xs_exp = [min(exp_ct); max(exp_ct)];
ys_exp = predict(mdl_exp,xs_exp);

%%
fHandle = figure; hold on; axis square
% plot(ctl_ct,ctl_bhvr,'o','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor',[0.7 0.7 0.7])
% plot(exp_ct,exp_bhvr,'d','MarkerFaceColor',[0.5 0.5 1],'MarkerEdgeColor',[0.5 0.5 1]);
% plot(xs_ctl,ys_ctl,'--','Color',[0.7 0.7 0.7],'LineWidth',2)
% plot(xs_exp,ys_exp,'--','Color',[0.5 0.5 1],'LineWidth',2)
plot(ctl_ct,ctl_bhvr,'o','MarkerEdgeColor',grpCols(1,:));
plot(exp_ct,exp_bhvr,'d','MarkerEdgeColor',grpCols(2,:));
plot(xs_ctl,ys_ctl,'--','Color',grpCols(1,:),'LineWidth',2)
plot(xs_exp,ys_exp,'--','Color',grpCols(2,:),'LineWidth',2)
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.25,0.45]);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end
end