function [fHandle,wilcoxonPs] = plot_mouse_prePostAcc(mouseTable,saveName)
% 5/24/2021 LKW
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

expmtT = rmmissing(mouseTable); %Clears tag day and missing values
cleanInds = expmtT.stimType == "pre_training";
expmtT(cleanInds,:) = [];
nExpmt = height(expmtT);

trainT = mouseTable;
trainInds = mouseTable.stimType ~= "pre_training";
trainT(trainInds,:) = [];
nTrain = height(trainT);

muPreAcc = mean(trainT.totAcc); semPreAcc = std(trainT.totAcc)./sqrt(nTrain);
muPostAcc = mean(expmtT.totAcc); semPostAcc = std(expmtT.totAcc)./sqrt(nExpmt);

%Wilcoxon RM mean difference test
pPrePost = ranksum(trainT.totAcc,expmtT.totAcc);

meansV = [muPreAcc muPostAcc];
semsV = [semPreAcc semPostAcc];
wilcoxonPs = [pPrePost];

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.5,0.33,0.5]);
bar(meansV,0.4)
errorbar(meansV,semsV,'k.')    % SEM for mean deltas
scatter(ones(nTrain,1)*1+randn(nTrain,1)./20,trainT.totAcc,'k') %Individual deltas Left On vs Off
scatter(ones(nExpmt,1)*2+randn(nExpmt,1)./20,expmtT.totAcc,'k') %Individual deltas Right On vs Off
plot([0 5],[0.5 0.5],'k--')                 % 0 line

xticks(1:2); xtickangle(45);
xticklabels({'Pre-Train','Experimental'});
ylim([0 1.1]); xlim([0 3.5]);
ylabel('Raw DNMP Accuracy')
legend({'Means','SEM','Sessions'},'FontSize',16);
set(gca,'FontSize',20,'FontName','Times');

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end
end