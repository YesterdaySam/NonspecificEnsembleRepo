function [fHandle] = plot_OE_Expmt_Bhvr(cohortStruc)
% 3/2/2021 LKW
%Inputs: 
%cohortStruc = struct of one field (table) for each mouse in cohort from
%getExpmtBhvr.m

nMice = length(cohortStruc);

%Find mouse with most sessions
for i = 1:nMice
    nSessions(i) = height(cohortStruc(i).table);
end
longestTrain = max(nSessions);

%Initiatlize accuracy and nTrials mats
accMat = zeros(nMice,longestTrain);
trialsMat = zeros(nMice,longestTrain);

for i = 1:nMice
    tTmp = cohortStruc(i).table;
    %Pad mats with nans for mice with fewer sessions
    if height(tTmp) < longestTrain
        sessDiff = longestTrain - height(tTmp);
        accMat(i,:) = [tTmp.totAcc' nan(1,sessDiff)];
        trialsMat(i,:) = [tTmp.nTrials' nan(1,sessDiff)];
    else
        accMat(i,:) = tTmp.totAcc;
        trialsMat(i,:) = tTmp.nTrials;
    end
end

accMean = nanmean(accMat);
accSEM = std(accMat,'omitnan')./sqrt(nMice);
trialMean = nanmean(trialsMat);
trialSEM = std(trialsMat,'omitnan')./sqrt(nMice);

fHandle = figure; hold on;
% yyaxis left
% plot(accMean,'k','LineWidth',2);
% errorbar(accMean,accSEM,'k','LineWidth',2);
ylabel('Total % Accuracy')
% yyaxis right
% plot(trialMean,'LineWidth',2);
% ylabel('N Trials')
xlabel('Session')
for i = 1:nMice
    tTmp = cohortStruc(i).table;
    nSess = height(tTmp);
%     yyaxis left
%     scatter(1:longestTrain,accMat(i,:));
    plot(accMat(i,1:nSess-1),'-o','LineWidth',2)
%     yyaxis right
%     scatter(1:longestTrain,trialsMat(i,:));
end
ylim([0 1])
set(gca,'fontname','times','FontSize',24)
legend('OE2','OEC1','OEC2','location','southwest');
end

