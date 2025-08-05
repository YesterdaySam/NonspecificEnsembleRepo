function [fHandle,wilcoxonPs] = plot_mouse_preLRAcc(mouseTable,saveName)
% 5/29/2021 LKW
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

trainT = mouseTable;
trainInds = mouseTable.stimType ~= "pre_training";
trainT(trainInds,:) = [];
trainT = rmmissing(trainT);
nTrain = height(trainT);

muPreLAcc = mean(trainT.leftOffAcc); semPreLAcc = std(trainT.leftOffAcc)./sqrt(nTrain);
muPreRAcc = mean(trainT.rightOffAcc); semPreRAcc = std(trainT.rightOffAcc)./sqrt(nTrain);

%Wilcoxon RM mean difference test
pPreLR = ranksum(trainT.leftOffAcc,trainT.rightOffAcc);

meansV = [muPreLAcc muPreRAcc];
semsV = [semPreLAcc semPreRAcc];
wilcoxonPs = [pPreLR];

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.5,0.33,0.5]);
bar(meansV,0.4)
errorbar(meansV,semsV,'k.')    % SEM for mean deltas
scatter(ones(nTrain,1)*1+randn(nTrain,1)./20,trainT.leftOffAcc,'k') %Individual deltas Left On vs Off
scatter(ones(nTrain,1)*2+randn(nTrain,1)./20,trainT.rightOffAcc,'k') %Individual deltas Right On vs Off
plot([0 5],[0.5 0.5],'k--')                 % 0 line

xticks(1:2); xtickangle(45);
xticklabels({'Left','Right'});
ylim([0 1.1]); xlim([0 3.5]);
ylabel({'Pre-Training'; 'DNMP Accuracy'})
legend({'Means','SEM','Sessions'},'FontSize',16);
set(gca,'FontSize',20,'FontName','Times');

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end

end