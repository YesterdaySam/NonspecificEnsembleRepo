function [fHandle,statstruc,pstruc] = plot_cohort_onoffDays(mouseTables,saveName,tagSide,pstruc,statstruc)
%%% 11/5/2021 LKW
%Inputs: 
%mouseTables = table of trial IDs, accuracies and trial numbers from
%getExpmtBhvr.m
%saveName = fullpath string i.e. 'F:\Research\Code\OB_project\OB5\OB5_deltaLR_Acc'

nMice = size(mouseTables,2);

onAccsByDay = []; offAccsByDay = [];
matchAccsByDay = []; misMatchAccsByDay = [];
mouseLabs = {};

for i = 1:nMice
%     optoOnlyS(i).animalBhvrT = rmmissing(mouseTables(i).animalBhvrT);   %Add mouse table to opto Only Struct
    optoOnlyS(i).animalBhvrT = mouseTables(i).animalBhvrT;   %Add mouse table to opto Only Struct
    cleanInds = optoOnlyS(i).animalBhvrT.stimType == "pre_training";
    cleanInds = logical(cleanInds + ...
        (optoOnlyS(i).animalBhvrT.stimType == "Tagging") + (optoOnlyS(i).animalBhvrT.stimType == "tagging"));
    optoOnlyS(i).animalBhvrT(cleanInds,:) = [];

    offAccsByDay = [offAccsByDay; optoOnlyS(i).animalBhvrT.totOffAcc'];
    onAccsByDay = [onAccsByDay; optoOnlyS(i).animalBhvrT.onAcc'];
    
%     if ~ischar(tagSide)
%         matchAccsByDay = [matchAccsByDay; optoOnlyS(i).animalBhvrT.matchAcc'];
%         misMatchAccsByDay = [misMatchAccsByDay; optoOnlyS(i).animalBhvrT.misMatchAcc'];
%     end
    
    strTmp = optoOnlyS(i).animalBhvrT.sessionID(1);
    spaceInds = strfind(strTmp,' ');
    mouseLabs{i} = optoOnlyS(i).animalBhvrT.sessionID{1}(1:spaceInds(1)-1);
end

[nSess,nDays] = size(offAccsByDay);
offSessNoNaN = nSess - sum(isnan(sum(offAccsByDay)));
onSessNoNaN = nSess - sum(isnan(sum(onAccsByDay)));

muOffDays = mean(offAccsByDay,"omitnan"); semOff = std(offAccsByDay,"omitnan")./sqrt(offSessNoNaN);
muOnDays = mean(onAccsByDay,"omitnan"); semOn = std(onAccsByDay,"omitnan")./sqrt(onSessNoNaN);
z = 1.96;   % 95% confidence = 1.96
upCIOff = muOffDays + 1.96*semOff; dnCIOff = muOffDays - 1.96*semOff;
upCIOn = muOnDays + 1.96*semOn; dnCIOn = muOnDays - 1.96*semOn;

%Wilcoxon RM mean difference test
vDay = 1:nDays;
[statstruc.acc_corr_offXDays_rho,pstruc.acc_corr_offXdays] = corr(vDay',muOffDays');
[statstruc.acc_corr_onXDays_rho,pstruc.acc_corr_onXdays] = corr(vDay',muOnDays');

meansV = [muOffDays; muOnDays];
semsV = [semOff semOn];

%% Plot as bar graph
% fHandle = figure; hold on;
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.6,0.525]);
% b = bar(meansV',0.8);
% b(1).FaceColor = [1 1 1];
% b(1).EdgeColor = [0 0 0.8];
% b(1).LineWidth = 1.5;
% b(2).FaceColor = [0.5 0.5 1];
% b(2).LineWidth = 1.5;
% errorbar(vDay-0.15,muOffDays,semOff,'k.','LineWidth',1.5);    % SEM for off acc
% errorbar(vDay+0.15,muOnDays,semOn,'k.','LineWidth',1.5,'HandleVisibility','off');
% 
% % For plotting individual mice
% % % mouseColors = {'b','g','r','m','c',[0 0 0.5],[0 0.75 0],[1 0.5 0],[1 0.75 0]};
% % mouseColors = hot(nMice+2);
% % for i = 1:nMice
% %     scatter(vDay-0.15+randn(1,nDays)./40,offAccsByDay(i,:),[],mouseColors(i,:),'filled');
% %     scatter(vDay+0.15+randn(1,nDays)./40,onAccsByDay(i,:),[],mouseColors(i,:),'filled','HandleVisibility','off');
% % end
% % xlim([0.5 nDays+1.5]);
% 
% plot([0 8],[0.5 0.5],'k--','HandleVisibility','off')                 % 50/50 line
% 
% xticks(1:5)
% xlabel('Day');
% ylim([0 1.1]); 
% xlim([0.5 nDays+0.5]);
% legCell = ['Mean Off','Mean On','SEM',mouseLabs];
% ylabel('Raw DNMP Accuracy')
% legend(legCell,'FontSize',16);
% set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Plot as line graph instead
fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.4,0.525]);
xticks(1:5)
xlabel('Day');
ylim([0 1.1]); 
xlim([0.5 nDays+0.5]);
ylabel('Raw DNMP Accuracy')

mouseColors = [0.5 0.5 0.5; 0.5 0.5 1];

plot(meansV(1,:),'LineWidth',2,'Color',mouseColors(1,:));
plot(meansV(2,:),'LineWidth',2,'Color',mouseColors(2,:));
patchXs = [1:nDays,fliplr(1:nDays)]; %Vector of x coords;
patch(patchXs,[dnCIOff,fliplr(upCIOff)],'k','EdgeColor','none','FaceAlpha',0.2);
patch(patchXs,[dnCIOn,fliplr(upCIOn)],'b','EdgeColor','none','FaceAlpha',0.2);

randxs = repmat(vDay,[nMice,1]) + randn(nMice,nDays)./40;
% For plotting individual day on vs off by mouse
% for i = 1:nDays
%     plot([randxs(:,i)-0.15, randxs(:,i)+0.15]',[offAccsByDay(:,i), onAccsByDay(:,i)]','k')
% end

for i = 1:nMice
    scatter(randxs(i,:)-0.15,offAccsByDay(i,:),[],mouseColors(1,:),'filled');
    scatter(randxs(i,:)+0.15,onAccsByDay(i,:),[],mouseColors(2,:),'filled');
end
xlim([0.5 nDays+0.5]);
plot([0 5],[0.5 0.5],'k--','HandleVisibility','off')                 % 0 line

legCell = {'Mean Off','Mean On'};
legend(legCell,'location','se','FontSize',16);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

%% Save
if ischar(saveName)
    saveFigTypes(fHandle,saveName)
end
end