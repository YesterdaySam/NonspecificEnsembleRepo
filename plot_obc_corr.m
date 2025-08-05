function [fHandle] = plot_obc_corr(day,off_dat,on_dat,saveName)
%%% 8/15/2022 LKW
%Inputs: 
% day = vector of days from exptT
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

nMice = length(day)/5;
xs = reshape(day,5,nMice);
off_dat_ys = reshape(off_dat,5,nMice);
on_dat_ys = reshape(on_dat,5,nMice);

%Get means for each day
mu_off = mean(off_dat_ys,2); sem_off = std(off_dat_ys')./sqrt(nMice);
mu_on = mean(on_dat_ys,2); sem_on = std(on_dat_ys')./sqrt(nMice);

z = 1.96;   % 95% confidence = 1.96
upCIOff = mu_off' + z*sem_off; dnCIOff = mu_off' - z*sem_off;
upCIOn = mu_on' + z*sem_on; dnCIOn = mu_on' - z*sem_on;

%%
fHandle = figure; hold on; axis square
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.25,0.45]);
f1 = plot(xs(:,1),mu_off,'Color',[0.5 0.5 0.5],'LineWidth',3);
f3 = plot(xs(:,1),mu_on,'Color',[0.5 0.5 1],'LineWidth',3);
patchXs = [1:5,fliplr(1:5)]; %Vector of x coords;
patch(patchXs,[dnCIOff,fliplr(upCIOff)],'k','EdgeColor','none','FaceAlpha',0.2);
patch(patchXs,[dnCIOn,fliplr(upCIOn)],'b','EdgeColor','none','FaceAlpha',0.2);

% f2 = plot(xs,off_dat_ys,'Color',[0.5 0.5 0.5]);
% f4 = plot(xs,on_dat_ys,'Color',[0.5 0.5 1]);

xticks(1:5)
xlabel('Day');     %Relative to sample phase i.e. accuracy during test after left samples no stim
xlim([0.5 5.5]);
% legCell = {'Mean Off','Mean On'};
% legend(legCell,'FontSize',16,'Location','best');
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end
end