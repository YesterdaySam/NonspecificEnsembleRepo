function [fHandle] = plot_OE_Expmt_Comp(mouseTable)
% 3/13/2021 LKW
%Inputs: 
%mouseTable = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m

optoOnlyT = rmmissing(mouseTable);
cleanInds = optoOnlyT.stimType == "Square0.2Hz";
cleanInds = logical(cleanInds + (optoOnlyT.stimType == "Square0.1Hz"));
optoOnlyT(cleanInds,:) = [];

%Initiatlize accuracy and nTrials mats
accMat = zeros(4,height(optoOnlyT));   %Setup matrix of accuracies total, on, post, and off

accMat(1,:) = optoOnlyT.totAcc;
accMat(2,:) = optoOnlyT.onAcc;
accMat(3,:) = optoOnlyT.postAcc;
accMat(4,:) = optoOnlyT.offAcc;

fHandle = figure; hold on;
ylabel('% Accuracy')
xlabel('Opto Session #')
for i = 1:4
    plot(accMat(i,:),'LineWidth',2)
end
ylim([0 1]); xlim([0 height(optoOnlyT)+1]);
set(gca,'fontname','times','FontSize',24)
legend('Total Acc','On Acc','Post Acc','Off Acc','location','southwest','FontSize',20);
end

