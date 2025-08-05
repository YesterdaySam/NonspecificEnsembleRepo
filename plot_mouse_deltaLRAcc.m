function [fHandle,wilcoxonPs] = plot_mouse_deltaLRAcc(mouseTable,saveName,tagSide)
% 3/13/2021 LKW
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

optoOnlyT = rmmissing(mouseTable);
cleanInds = optoOnlyT.stimType == "pre_training";
cleanInds = logical(cleanInds + (optoOnlyT.stimType == "Tagging"));
optoOnlyT(cleanInds,:) = [];
nSess = height(optoOnlyT);

if tagSide == 1
    leftOnOffAcc =  optoOnlyT.matchAcc - optoOnlyT.leftOffAcc;              %Delta Left Off vs Left On
    rightOnOffAcc = optoOnlyT.misMatchAcc - optoOnlyT.rightOffAcc;          %Delta Right Off vs Right On
elseif tagSide == 0
    leftOnOffAcc = optoOnlyT.misMatchAcc - optoOnlyT.leftOffAcc;
    rightOnOffAcc = optoOnlyT.matchAcc - optoOnlyT.rightOffAcc;
elseif tagSide == 'OBC'
    leftOnOffAcc = optoOnlyT.leftOnAcc - optoOnlyT.leftOffAcc;
    rightOnOffAcc = optoOnlyT.rightOnAcc - optoOnlyT.rightOffAcc;
end

muLeftOnOff = mean(leftOnOffAcc); semLeftOnOff = std(leftOnOffAcc)./sqrt(nSess);
muRightOnoff = mean(rightOnOffAcc); semRightOnOff = std(rightOnOffAcc)./sqrt(nSess);

%Signed Rank tests against 0
pLeftOnOff = signrank(leftOnOffAcc);
pRightOnOff = signrank(rightOnOffAcc);

%Wilcoxon RM mean difference test
pLeftVRight = ranksum(leftOnOffAcc,rightOnOffAcc);
% %Across groups Kruskal Wallis (independent) and Friedman (repeated measures)
% anovaVect = [leftOnOffAcc, rightOnOffAcc, leftPostOffAcc, rightPostOffAcc];
% [kw_p,kw_tbl,kw_stats] = kruskalwallis(anovaVect,[],'off');
% [fried_p,fried_tbl,fried_stats] = friedman(anovaVect,1,'off');

meansV = [muLeftOnOff muRightOnoff];
semsV = [semLeftOnOff semRightOnOff];
wilcoxonPs = [pLeftOnOff pRightOnOff pLeftVRight];

%%
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.5,0.33,0.5]);
scatter(1:2,meansV,'filled','kd')       % Mean Deltas
errorbar(meansV,semsV,'k.')    % SEM for mean deltas
% scatter(ones(nSess,1)*1+randn(nSess,1)./20,leftOnOffAcc,'k') %Individual deltas Left On vs Off
% scatter(ones(nSess,1)*2+randn(nSess,1)./20,rightOnOffAcc,'k') %Individual deltas Right On vs Off
% sessMarks = {'o','+','*','x','s','d','p','h'};
sessMarks = {'o','o','o','o','o','o','o'};
for i = 1:nSess
    scatter(1+randn./20,leftOnOffAcc(i),'k',sessMarks{i}) %Individual deltas Left On vs Off
    scatter(2+randn./20,rightOnOffAcc(i),'k',sessMarks{i},'HandleVisibility','off') %Individual deltas Right On vs Off
end
plot([0 5],[0 0],'k--')                 % 0 line

xticks(1:2); %xtickangle(45);
row1 = {'Left','Right'};
if tagSide == 1
    row2 = {'Match','Mis-Match'}; 
elseif tagSide == 0
    row2 = {'Mis-Match','Match'}; 
elseif tagSide == 'OBC' 
    row2 = {'Sample','Sample'};
end
labelArray = [row1; row2];
tickLabels = strtrim(sprintf('%s\\newline%s\n', labelArray{:}));
xticklabels(tickLabels);
%     xticklabels({'Left (Match)','Right (Mis-Match)'});
ylim([-0.75 0.75]); xlim([0 3.5]);
ylabel({'\Delta % Accuracy', 'On - Off Stim'})
legend({'Means','SEM','Sessions'},'FontSize',16);
set(gca,'FontSize',20,'FontName','Times');

%% Save
if ischar(saveName)
    saveas(fHandle,saveName,'png')
    saveas(fHandle,saveName,'fig')
end
end