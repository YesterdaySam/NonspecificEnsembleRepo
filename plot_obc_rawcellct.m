function [fHandle] = plot_obc_rawcellct(ctl_ct,exp_ct,grpCols,saveName)
%%% 8/15/2022 LKW
%Inputs: 
%grpCols = Nx3 matrix of N groups and RGB triplets
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

nMiceCtl = length(ctl_ct);
nMiceExp = length(exp_ct);
mu_ctl = mean(ctl_ct); sem_ctl = std(ctl_ct)./sqrt(nMiceCtl);
mu_exp = mean(exp_ct); sem_exp = std(exp_ct)./sqrt(nMiceExp);

%%
fHandle = figure; hold on
b1 = errorbar(1,mu_ctl,sem_ctl,'o','Color',grpCols(1,:),'MarkerEdgeColor',grpCols(1,:),'MarkerFaceColor',grpCols(1,:));
s1 = scatter(0.25+ones(nMiceCtl,1),ctl_ct,'o','MarkerEdgeColor',grpCols(1,:));
b2 = errorbar(2,mu_exp,sem_exp,'d','Color',grpCols(2,:),'MarkerEdgeColor',grpCols(2,:),'MarkerFaceColor',grpCols(2,:));
s2 = scatter(0.25+2*ones(nMiceExp,1),exp_ct,'d','MarkerEdgeColor',grpCols(2,:));
xticks(1:2)
xticklabels({'eYFP','ChR2'});
xlim([0.5 2.75])
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.15,0.45]);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end