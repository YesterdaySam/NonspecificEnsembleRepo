%%% OBC Analyze Script
% Runs all functions to analyze single animals and cohorts for OB Project
% Place all .xlsx files in mainPath directory
% LKW 8/2/22

%Base Trodes data
% dataPath = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\OBC Group\';
%Analysis folder and Excel Behavior sheets
% mainPath = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBC_Final\';
% mainPath = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBCD_Analysis\';
% mainPath = 'E:\OptoBehaviorProject\Analysis\';

% addpath('G:\Shared drives\HasselmoUsers\lwilmerd\Code\OB_project_code')
% addpath('G:\Shared drives\HasselmoUsers\lwilmerd\Code\')

dataPath = 'F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_Final';
mainPath = 'F:\Research\Experimental\DG_nonsense_project\Analysis';

pathFlag = 1; % 1 = Laptop; 2 = Desktop
if pathFlag == 1
    addpath(genpath('F:\Research\Code\CMBHome'))
    addpath(genpath('F:\Research\Code\trodal_recall'))    %importTrode.m adds paths to trodes export fns
    addpath('F:\Research\Code\OB_project_code')
    addpath('F:\Research\Code')
elseif pathFlag == 2
    addpath(genpath('C:\Users\cornu\Documents\GitHub\CMBHOME'))
    addpath(genpath('C:\Users\cornu\Documents\GitHub\trodal_recall'))    %importTrode.m adds paths to trodes export fns
end

cd(mainPath)

saveFlag = 0;
% saveBase = 'OBC_cohort_n7_reanalysis';
% saveBase = 'OBCC_Cohort01-06';
saveBase = 'OBC_Compare';

%% DLC Preprocess

parentDir = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\OBCD Group\OBC26';
cd(parentDir);
recFolders = dir(parentDir); tmp = [recFolders.isdir]; recFolders = recFolders(tmp); clear tmp
for i = 3:numel(recFolders)
    subDirTmp = fullfile(parentDir, recFolders(i).name);
    cd(subDirTmp)
    if ~isempty(dir('*.h264')) && isempty(dir('*.mp4*'))
        disp(strcat('Beginning mp4 Preprocessing of_',recFolders(i).name));
        vidFiles = dir('*.h264');
        cd('C:\Users\cornu\Desktop\ffmpeg\bin');
        for j = 1:numel(vidFiles)
            vh264 = fullfile(vidFiles(j).folder,vidFiles(j).name);
            vmp4 = [vh264(1:end-4),'mp4'];
            command = ['ffmpeg -i "', vh264, '" "', vmp4,  '"']; %Need double quotes for paths with spaces
            system(command,'-echo');
        end
    else
        disp(['Already tried mp4 preprocessing of ',recFolders(i).name]);
    end
end

% Use Anaconda DLC1 via powershell
% $cd D:\DLC1 
% $conda activate dlc-windowsGPU 
% $python dlc_abbrv_script.py

%% CMBHome import
parentDir = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\OBCD Group';

cd(parentDir);
mouseFolders = dir(parentDir); tmp = [mouseFolders.isdir]; mouseFolders = mouseFolders(tmp); clear tmp

for j = 3:numel(mouseFolders)    %Cohort
    mouseDirTmp = fullfile(parentDir, mouseFolders(j).name);
    cd(mouseDirTmp)
    recFolders = dir(mouseDirTmp); tmp = [recFolders.isdir]; recFolders = recFolders(tmp); clear tmp
    for i = 3:numel(recFolders) %All recordings of one mouse
        clear root optoTS
        subDirTmp = fullfile(mouseDirTmp, recFolders(i).name);
        
        if subDirTmp(end-2:end) == 'rec'    %Correct for trodes 2.1 name scheme
            sname = recFolders(i).name(1:end-4);
        else
            sname = recFolders(i).name;
        end
        
        cd(subDirTmp)
        if ~isempty(dir('*.dlcout')) && isempty(dir('CMBH*'))
            disp('Beginning Trodes to Matlab/CMBHome Conversion')
            root = importTrode(subDirTmp);
            disp('Import Trodes Success!')
        elseif ~isempty(dir('CMBH*'))
            disp(['CMBHome Object already created for ',sname])
%             rootStruct = dir('CMBH*');
%             load(rootStruct.name); clear rootStruct
%             disp('root loaded')
        else
            disp('No Root Object found, folder missing DLC data, or other exception')
            disp('Continuing to next subfolder')
        end
        if isempty(dir('*optoTS*'))
%             optoTS = getOptoTS(subDirTmp);
            optoTS = getDIOTS(subDirTmp);
            save(['optoTS_',sname(1:end-7)],'optoTS');
        else
            disp('Found optoTS file already made')
        end
    end
end

%% Analyze DNMP Accuracy
% mainPath = 'E:\OptoBehaviorProject\Analysis\OBCD_Final';
mainPath = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBC_Final\'; 
cd(mainPath)

rerunSoloFlag = 0; 
rerunCohortFlag = 1;

datFiles = dir('*.xlsx');
nMice = size(datFiles,1);

%% Single Animals analyses
for i = 1:nMice
    %Setup directories
    xlFile = datFiles(i).name;
    mouse = xlFile(10:end-5);  %Assumes format: Data_Log_XX#.xlsx
    outputDir = fullfile(mainPath,mouse);
    if exist(outputDir)
        parentDir = pwd; 
        cd(outputDir)
        if ~isempty(dir('*.fig')) && rerunSoloFlag == 0
            cd(parentDir)
            continue
        end
        cd(parentDir)
    end
    
    if ~exist(outputDir); mkdir(mouse); end
    
    %Make session structs
    sessName = strcat(mouse,'_sessions');
    [mouseSessions,tagSide] = createBhvrSessions(xlFile,outputDir,sessName);
    
    %Make experiment accuracy table
    bhvrTName = strcat(mouse,'_bhvrT');
    mouseBhvrT = getExpmtBhvr(outputDir,mouseSessions,bhvrTName);

    %Make Comparison Plots and save
    deltaName = strcat(mouse,'_deltaLR_Acc'); deltaName = fullfile(outputDir,deltaName);
    [deltaLRFig,wilcPs] = plot_mouse_deltaLRAcc(mouseBhvrT,deltaName,tagSide);
    save(strcat(deltaName,'_wilcPs'),'wilcPs');
    
    grossAccName = strcat(mouse,'_gross_Acc'); grossAccName = fullfile(outputDir,grossAccName);
    [grossAccFig,wilcPs] = plot_mouse_grossStimAcc(mouseBhvrT,grossAccName);
    save(strcat(grossAccName,'_wilcPs'),'wilcPs');
    
    rawLRName = strcat(mouse,'_rawLR_Acc'); rawLRName = fullfile(outputDir,rawLRName);
    [rawLRFig,wilcPs] = plot_mouse_rawLRAcc(mouseBhvrT,rawLRName,tagSide);
    save(strcat(rawLRName,'_wilcPs'),'wilcPs');

    preLRName = strcat(mouse,'_preLR_Acc'); preLRName = fullfile(outputDir,preLRName);
    [preLRFig,wilcPs] = plot_mouse_preLRAcc(mouseBhvrT,preLRName);
    save(strcat(preLRName,'_wilcPs'),'wilcPs');
    
    prePostName = strcat(mouse,'_prePost_Acc'); prePostName = fullfile(outputDir,prePostName);
    [prePostFig,wilcPs] = plot_mouse_prePostAcc(mouseBhvrT,prePostName);
    save(strcat(prePostName,'_wilcPs'),'wilcPs');
    
    close all
end

%% Generate Cohort tables
% mouseInclude = [0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 1 1 0 1 1 0]; %OBC 3,7,8,23,25,26
% mouseInclude = [0 1 0 1 0 1]; %OBCC all; or subset OB Train (n 6)
% mouseInclude = [1 1 0 1 1 1]; 
mouseInclude = [1 1 1 1 1 1 1 1]; %OBC Final Cohort all

clear bhvrTabs

tagSide = 'OBC';    %Use string for OBC
% OBCSeizure = [1 0 0 1]
% mouseGrp = 'OBCC_Cohort01-06';
% mouseGrp = 'OBC_cohort_n7_reanalysis';
% mouseGrp = 'OBCD_FinalCohort';
% mouseGrp = 'OBC_FullCohort';
mouseGrp = 'OBC_XSubFinal';

combineT = table;

ct = 1;
for i = 1:nMice
    if mouseInclude(i) == 1
        xlFile = datFiles(i).name;
        mouseXL = readtable(xlFile);
        mouse = xlFile(10:end-5);  %Assumes format: Data_Log_XX#.xlsx
        subDir = fullfile(mainPath,mouse,[mouse,'_bhvrT.mat']);
        bhvrTabs(ct) = load(subDir); 
        combineT = [combineT; bhvrTabs(ct).animalBhvrT];
        ct = ct+1;
    end
end

cohortDir = fullfile(mainPath,mouseGrp);
save([cohortDir,'_bhvrTabs'],'bhvrTabs')
save([cohortDir,'_combineT'],'combineT')

%% Cohort-level accuracy analyses
% load('OBC_hilus_cohort_combineT.mat')

cohortDir = fullfile(dataPath,mouseGrp);
ps = struct;
stats = struct;
tbl = struct;

if exist(cohortDir) && rerunCohortFlag == 0
    disp('Cohort analyzed previously, rerun off')
    return
else
    mkdir(mouseGrp)
    cd(cohortDir)
    
    onoffCohort = strcat(mouseGrp,'_onoffCohort_Acc');
    [onoffCohortFig,ps,stats] = plot_cohort_onoffAcc2(combineT,onoffCohort,ps,stats);
    stats.acc_tt_onVoff_BH_corr = adjustP_BH(ps,{'acc_tt_onVoff','acc_tt_offV0','acc_tt_onV0'},0.05);

    rawAccCohort = strcat(mouseGrp,'_grossCohort_Acc');
    [rawGrossCohortFig,ps,tbl,stats] = plot_cohort_grossStimAcc2(combineT,rawAccCohort,ps,stats);
    
%     rawLRCohort = strcat(mouseGrp,'_rawLRCohort_Acc');
%     [rawLRCohortFig,ranksumPs,ranksumStats] = plot_cohort_rawLRAcc(bhvrTabs,rawLRCohort,tagSide);
% %     save(strcat(rawLRCohort,'_ranksumPs'),'ranksumPs','ranksumStats');
    
    deltaLRCohort = strcat(mouseGrp,'_deltaLRCohort_Acc');
    [deltaLRCohortFig,ps,stats] = plot_cohort_deltaLR2(combineT,deltaLRCohort,tagSide,ps,stats);
%     fieldCell = {'acc_tt_deltaLV0','acc_tt_deltaRV0','acc_tt_deltaLVR'};
%     tbl.deltaLR_BH_corr = adjustP_BH(ps,fieldCell,0.05);
    
    onoffDays = strcat(mouseGrp,'_onoffOverDays');
    [onoffDaysFig,stats,ps] = plot_cohort_onoffDays(bhvrTabs,onoffDays,tagSide,ps,stats);

    accDeltaDays = strcat(mouseGrp,'_deltaXdays');
    [accDeltaDaysFig,stats,ps] = plot_cohort_accdeltaXdays(combineT,accDeltaDays,ps,stats);
    
    save([mouseGrp,'_stats'],'ps','stats','tbl')    
    cd(mainPath)
    
    close all
end

%% Load bhvrTabs with relevant mice for lap-specific import
cd(mainPath)

% load('OBC_cohort_OBC3-4_7-8_17-20cohort_bhvrTabs.mat');
% load('OBCC_Cohort01-06_bhvrTabs.mat');
load('OBC_FullCohort_bhvrTabs.mat');
% load('OBCD_FinalCohort_bhvrTabs.mat');

mList = cell(1,size(bhvrTabs,2));   %Make Cell of mice to analyze
for i = 1:size(bhvrTabs,2)
    mTmp = strtok(bhvrTabs(i).animalBhvrT.sessionID{1});
    mList(i) = {mTmp};
end

%% Create opto TS and get lap-specific data for all bhvrTabs mice

cd(mainPath)

mouseFolders = dir(dataPath); tmp = [mouseFolders.isdir]; mouseFolders = mouseFolders(tmp); clear tmp
ctM = 0; 
ctR = 0;
varNames = {'day','muPulses','velOff_trn','velOn_trn','dstOff_trn','dstOn_trn','lapTOff_trn','lapTOn_trn','tm2boxOff_trn','tm2boxOn_trn','chcOccOff_trn','chcOccOn_trn', ...
    'velOff_tst','velOn_tst','dstOff_tst','dstOn_tst','lapTOff_tst','lapTOn_tst','tm2boxOff_tst','tm2boxOn_tst','chcOccOff_tst','chcOccOn_tst'};
varTypes = repmat({'double'},[1,numel(varNames)]);
bhvrT = table('Size',[0 length(varTypes)],'VariableTypes',varTypes,'VariableNames',varNames);

root_bhvr = table;

for j = 3:numel(mouseFolders)
    mouseDirTmp = fullfile(dataPath, mouseFolders(j).name);
    cd(mouseDirTmp)
    
    if ~strcmp(mouseFolders(j).name,mList)  %Check dat folder against mList to analyze
        continue    %If not in list, skip datFolder
    end
    
    disp(mouseFolders(j).name)
    ctM = ctM+1;
    
    %Use pre-made bhvrTabs to add tagging and experimental days to table
    tagInd = find(any(ismember(bhvrTabs(ctM).animalBhvrT.stimType,'tagging'),2)==1);
    root_bhvr = [root_bhvr; bhvrTabs(ctM).animalBhvrT(tagInd:end,:)];
    
    recFolders = dir(mouseDirTmp); tmp = [recFolders.isdir]; recFolders = recFolders(tmp); clear tmp
    for i = 3:numel(recFolders) %3 Skips first two '.' and '..' dirs
        disp(recFolders(i).name)
        clear root optoTS rawLapTmp sumLapTmp
        subDirTmp = fullfile(mouseDirTmp, recFolders(i).name);
        
        if subDirTmp(end-2:end) == 'rec'    %Correct for trodes 2.1 name scheme
            sname = recFolders(i).name(1:end-4);
        else
            sname = recFolders(i).name;
        end
        
        cd(subDirTmp)
        
        % Load Root and Opto TS
        disp(['Loading Root for ',sname])
        rootStruct = dir('CMBH*');
        load(rootStruct.name); clear rootStruct
        optoStruct = dir('*optoTS*');
        load(optoStruct.name); clear optoStruct
        if isstruct(optoTS)
            try
                optoTS = optoTS(2).ts;
            catch
                optoTS = [];
            end
        end
        
        % Get recording session lap specific data
        if ~isempty(dir('*_trials.xlsx'))
            xlStruct = dir('*_trials.xlsx');
            lapsTmp = readtable(xlStruct.name); clear xlStruct
            disp(['Loaded excel file for ',sname])
        end

        % Reload old extracted data if possible
        if ~isempty(dir('*_lapData.mat'))
            lapStruct = dir('*_lapData.mat');
            load(lapStruct.name); clear lapStruct
            disp(['Loaded laps files for ',sname])
        else
            [rawLapTmp,sumLapTmp] = getTrialData(root,lapsTmp,optoTS,5);   %Use 5 second buffer
            save([sname,'_lapData'],'rawLapTmp','sumLapTmp')
        end
        
        ctR = ctR+1;    %Update rec folder counter
        
        offLaps_trn = sumLapTmp.opto_type == 0 & sumLapTmp.lap_type == 0;
        onLaps_trn = sumLapTmp.opto_type == 1 & sumLapTmp.lap_type == 0;
        onLaps_tst = logical([0; onLaps_trn(1:end-1)]); %Defined as test laps following opto train laps
        offLaps_tst = logical((sumLapTmp.lap_type == 1) - onLaps_tst);  %Defined as test laps following no-opto train laps
        
        bhvrT.day(ctR) = i-3;
        bhvrT.muPulses(ctR) = nanmean(sumLapTmp.nPulses(sumLapTmp.opto_type == 1));
        
        bhvrT.velOff_trn(ctR) = nanmean(sumLapTmp.muVel(offLaps_trn));
        bhvrT.velOn_trn(ctR) = nanmean(sumLapTmp.muVel(onLaps_trn));
        bhvrT.dstOff_trn(ctR) = nanmean(sumLapTmp.dTrav(offLaps_trn));
        bhvrT.dstOn_trn(ctR) = nanmean(sumLapTmp.dTrav(onLaps_trn));
        bhvrT.lapTOff_trn(ctR) = nanmean(sumLapTmp.lap_len(offLaps_trn));
        bhvrT.lapTOn_trn(ctR) = nanmean(sumLapTmp.lap_len(onLaps_trn));
        bhvrT.tm2boxOff_trn(ctR) = nanmean(sumLapTmp.tm2box(offLaps_trn));
        bhvrT.tm2boxOn_trn(ctR) = nanmean(sumLapTmp.tm2box(onLaps_trn));
        bhvrT.chcOccOff_trn(ctR) = nanmean(sumLapTmp.probInBox(offLaps_trn));
        bhvrT.chcOccOn_trn(ctR) = nanmean(sumLapTmp.probInBox(onLaps_trn));

        bhvrT.velOff_tst(ctR) = nanmean(sumLapTmp.muVel(offLaps_tst));
        bhvrT.velOn_tst(ctR) = nanmean(sumLapTmp.muVel(onLaps_tst));
        bhvrT.dstOff_tst(ctR) = nanmean(sumLapTmp.dTrav(offLaps_tst));
        bhvrT.dstOn_tst(ctR) = nanmean(sumLapTmp.dTrav(onLaps_tst));
        bhvrT.lapTOff_tst(ctR) = nanmean(sumLapTmp.lap_len(offLaps_tst));
        bhvrT.lapTOn_tst(ctR) = nanmean(sumLapTmp.lap_len(onLaps_tst));
        bhvrT.tm2boxOff_tst(ctR) = nanmean(sumLapTmp.tm2box(offLaps_tst));
        bhvrT.tm2boxOn_tst(ctR) = nanmean(sumLapTmp.tm2box(onLaps_tst));
        bhvrT.chcOccOff_tst(ctR) = nanmean(sumLapTmp.probInBox(offLaps_tst));
        bhvrT.chcOccOn_tst(ctR) = nanmean(sumLapTmp.probInBox(onLaps_tst));
        
    end
end

cd(mainPath)
bhvrT = [root_bhvr, bhvrT]; %Merge accuracy and position tables
if saveFlag == 1
    save([saveBase,'_lapTable'],'bhvrT')
    disp('Saved and completed creation of lap files and bhvrT table')
end

%% Begin Exp Vs Ctl Analysis Code Blocks

% plotDir = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBC_Analysis\OBC_seizure_analysis\';
% plotDir = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBC_Final\OBC_expVsctl\';
% plotDir = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBCC_Analysis\OBCC_Cohort01-06\';
plotDir = 'F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_Final\OBC_6Cohort\';
% plotDir = 'F:\Research\Experimental\DG_nonsense_project\Analysis\OBCD_Final\OBCD_expVsctl\';

% Load in Exp and Ctl cohorts
% load('G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBC_Final\OBC_FullCohort_bhvrTabs.mat')
% expBhvrT = bhvrT; tagInds = expBhvrT.stimType == "tagging"; expBhvrT(tagInds,:) = [];
% load('G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBCC_Analysis\OBCC_Cohort01-06_lapTable.mat')
% ctlBhvrT = bhvrT; tagInds = ctlBhvrT.stimType == "tagging"; ctlBhvrT(tagInds,:) = [];
cd('F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_Final\OBC_6Cohort');
load('expBhvrT.mat'); load('ctlBhvrT.mat');
ps = struct; stats = struct;
% saveBase = 'expVsctl';
saveFlag = 0;

%% Exp vs Ctl -  Acc, Acc x days, acc delta
cd(plotDir)
if saveFlag; cohort_acc_name = 'OBC_compare_cohort_acc'; else; cohort_acc_name = 0; end
[acc_comp_fig,ps,stats] = plot_cohort_acc_comp(ctlBhvrT,expBhvrT,cohort_acc_name,ps,stats);
stats.acc_tt_ctlVexp_BH_corr = adjustP_BH(ps,{'acc_tt_ctlVexp_off','acc_tt_ctlVexp_on'},0.05);

if saveFlag; accXdays_name = 'OBC_compare_cohort_accXdays'; else; accXdays_name = 0; end
[accxdays_fig,ps,stats] = plot_cohort_accXdays_comp(ctlBhvrT,expBhvrT,accXdays_name,ps,stats);

if saveFlag; deltaDays_name = 'OBC_compare_cohort_accDelta'; else; deltaDays_name = 0; end
[accDelta_comp_fig,ps,stats] = plot_cohort_acc_delta_comp(ctlBhvrT,expBhvrT,deltaDays_name,ps,stats);
stats.acc_tt_deltaLVR_BH_corr = adjustP_BH(ps,{'acc_tt_exp_deltaLVR','acc_tt_ctl_deltaLVR'},0.05);

%% Compare Exp Delta to Seiz Delta

load('F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_Final\OBC_6Cohort\expBhvrT.mat');
expTable = expBhvrT;

expCleanInds = expTable.stimType ~= "opto_20Hz";
expTable(expCleanInds,:) = [];
expNames = unique(strtok(expTable.sessionID)); nMiceExp = numel(expNames);
expAccD_mean = []; expMNames = {};
for i = 1:nMiceExp
    mouseInds = strtok(expTable.sessionID) == expNames(i);
    expAccD_mean = [expAccD_mean; mean(expTable.onAcc(mouseInds)) - mean(expTable.totOffAcc(mouseInds))];
end
nSessExp = numel(expAccD_mean);
muExpD = mean(expAccD_mean); seExpD = std(expAccD_mean)./sqrt(nSessExp);

load('F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_seizure\OBC_SeizCohort\expBhvrT.mat')
expBhvrT([3,12,22],:) = []; % Eliminate seizure days for OBC9, 10, 
seizT = expBhvrT;
seizMs = [1 1 2 2 2 2 2 3 3 3 4 4 4 4 4 5 5 5 5];
seizAccD = seizT.onAcc - seizT.totOffAcc;
mNames = unique(seizMs);
for i = 1:numel(mNames)
    seizAccD_mean(i) = mean(seizAccD(seizMs == mNames(i)));
end
muSeizD = mean(seizAccD_mean); seSeizD = std(seizAccD_mean)./sqrt(length(mNames));
[~,ps.acc_tt_expVseiz_delta,~,stats.acc_tt_expVseiz_delta] = ttest2(expAccD_mean,seizAccD_mean');

%% Compare seiz cohort to Chr2 experimental cohort

fHandle = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.15,0.525]);
b = bar([muExpD; muSeizD],0.4,'LineWidth',1.5,'EdgeColor',[0 0 0.5]);
b(1).FaceColor = [0.5 0.5 1];
errorbar([1; 2],[muExpD; muSeizD],[seExpD; seSeizD],'k.','LineWidth',1);    % SEM for raw acc
%For mouse-averaged individual plotting
plot(ones(length(nSessExp),1)+0.1,expAccD_mean,'o','MarkerEdgeColor',[0.3 0.3 0.7]);
plot(ones(length(nSessExp),1)+1.1,seizAccD_mean,'d','MarkerEdgeColor',[0.3 0.3 0.7]);

plot([0 3],[0 0],'k--','HandleVisibility','off')                 % 50/50 line

xticks(1:2);
xticklabels({'ChR2','ChR2-Seizure'});     %Relative to sample phase i.e. accuracy during test after left samples no stim
ylim([-0.5 0.5]); 
xlim([0.5 2.5]);
ylabel('\Delta % DNMP Accuracy')
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

cd('F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_seizure\OBC_SeizCohort')
saveFigTypes(fHandle,'OBC_Seiz_vs_Exp_Delta')

%% Exp v Ctl Day 1 specific analyses
expBhvrT_D1 = expBhvrT(find(expBhvrT.day == 1),:);
ctlBhvrT_D1 = ctlBhvrT(find(ctlBhvrT.day == 1),:);
ctl_tag_dir = logical([1 1 0 0 1 0]);    %OBCC 01-06
% exp_tag_dir = logical([1 1 0 1 0 1 0 0]);   %OBC 17 19 23 25 26 3 7 8
exp_tag_dir = logical([0 1 0 1 0 0]);   %OBC 23 25 26 3 7 8

[~,ps.d1baseacc_expVctl,~,stats.d1baseacc_expVctl] = ttest2(expBhvrT_D1.baseAcc,ctlBhvrT_D1.baseAcc);
[~,ps.d1baseacc_expVH0,~,stats.d1baseacc_expVH0] = ttest(expBhvrT_D1.baseAcc-0.5);
[~,ps.d1baseacc_ctlVH0,~,stats.d1baseacc_ctlVH0] = ttest(ctlBhvrT_D1.baseAcc-0.5);
stats.d1_baseacc_BH = adjustP_BH(ps,{'d1baseacc_expVctl','d1baseacc_expVH0','d1baseacc_ctlVH0'},0.05);
d1_acc_mu = [mean(ctlBhvrT_D1.baseAcc),mean(expBhvrT_D1.baseAcc)];
d1_acc_sem = [std(ctlBhvrT_D1.baseAcc)/sqrt(height(ctlBhvrT_D1)),std(expBhvrT_D1.baseAcc)/sqrt(height(expBhvrT_D1))];

d1_acc_fig = figure; hold on;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.12,0.525]);
b = bar(d1_acc_mu,0.5,'LineWidth',1.5,'EdgeColor',[0 0 0.8],'FaceColor','flat');
b.CData(1,:) = [0.7 0.7 0.7];
b.CData(2,:) = [0.5 0.5 1];
errorbar([1 2],d1_acc_mu,d1_acc_sem,'k.')
plot([0 5],[0.5 0.5],'k--','HandleVisibility','off')                 % 0 line
randxs_exp = rand(height(expBhvrT_D1),1).*0.3;
randxs_ctl = rand(height(ctlBhvrT_D1),1).*0.3;
scatter(randxs_ctl+1,ctlBhvrT_D1.baseAcc,[],'o','MarkerEdgeColor',[0.5 0.5 0.5]);
scatter(randxs_exp+2,expBhvrT_D1.baseAcc,[],'d','MarkerEdgeColor',[0.3 0.3 0.7]);
xticks(1:2); xticklabels({'eYFP','ChR2'}); ylim([0 1.19]); xlim([0.5 2.5]);
ylabel('Day 1 Pre-Stim Accuracy')
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

if saveFlag == 1
    saveFigTypes(d1_acc_fig,['OBC_baseAcc_d1_comp']);
end

% Plot delta on d1 only
if saveFlag; deltaDay1_name = 'OBC_compare_cohort_accDelta_D1'; else; deltaDay1_name = 0; end
[accDeltaD1_comp_fig,ps,stats] = plot_cohort_acc_delta_D1_comp(ctlBhvrT_D1,expBhvrT_D1,ctl_tag_dir,exp_tag_dir,deltaDay1_name,ps,stats);

%% Mixed Linear Models 
nExp = height(expBhvrT)/5; nCtl = height(ctlBhvrT)/5;

% Using Average across days -- do not use, undercuts power of treating mice as random variables
% acc_off = [mean(reshape(ctlBhvrT.totOffAcc,[5,nCtl]))'; mean(reshape(expBhvrT.totOffAcc,[5,nExp]))'];
% acc_on = [mean(reshape(ctlBhvrT.onAcc,[5,nCtl]))'; mean(reshape(expBhvrT.onAcc,[5,nExp]))'];
% group = [repmat("ctl",[nCtl,1]);repmat("exp",[nExp,1]);repmat("ctl",[nCtl,1]);repmat("exp",[nExp,1])];
% opto =
% [repmat("off",[nCtl,1]);repmat("off",[nExp,1]);repmat("on",[nCtl,1]);repmat("on",[nExp,1])];
% mouse = repmat(["OBCC01";"OBCC02";"OBCC03";"OBCC04";"OBCC05";"OBCC06";"OBC17";"OBC19";"OBC23";"OBC25";"OBC26";"OBC3";"OBC7";"OBC8"],[2,1]);

% Linear Model for accuracy with all days included 
acc_off = [ctlBhvrT.totOffAcc; expBhvrT.totOffAcc];
acc_on = [ctlBhvrT.onAcc; expBhvrT.onAcc];
group = repmat([repmat("ctl",[nCtl*5,1]); repmat("exp",[nExp*5,1])],[2,1]);
opto = [repmat("off",[(nExp+nCtl)*5,1]); repmat("on",[(nExp+nCtl)*5,1])];
% mouse = repmat([reshape(repmat(["OBCC01";"OBCC02";"OBCC03";"OBCC04";"OBCC05";"OBCC06"],[1,5])',[nCtl*5,1]); ...
%     reshape(repmat(["OBC17";"OBC19";"OBC23";"OBC25";"OBC26";"OBC3";"OBC7";"OBC8"],[5,1])',[nExp*5,1])],[2,1]);
mouse = repmat([reshape(repmat(["OBCC01";"OBCC02";"OBCC03";"OBCC04";"OBCC05";"OBCC06"],[1,5])',[nCtl*5,1]); ...
    reshape(repmat(["OBC23";"OBC25";"OBC26";"OBC3";"OBC7";"OBC8"],[5,1])',[nExp*5,1])],[2,1]);
% mouse = repmat([reshape(repmat(["OBCC01";"OBCC02";"OBCC03";"OBCC04";"OBCC05";"OBCC06"],[1,5])',[nCtl*5,1]); ...
%     reshape(repmat(["OBCD02";"OBCD04";"OBCD06"],[5,1])',[nExp*5,1])],[2,1]);

t1 = table([acc_off;acc_on],group,opto,mouse,'VariableNames',{'acc','group','opto','mouse'});
t1_lme = fitlme(t1,'acc~group*opto + (1|mouse)');
t1_lme2 = fitlme(t1,'acc~group*opto + (1 + opto|mouse)');
[ps.acc_lme_int,stats.acc_lme_int_F,stats.acc_lme_int_df] = coefTest(t1_lme,[1 0 0 0]);
[ps.acc_lme_grp,stats.acc_lme_grp_F,stats.acc_lme_grp_df] = coefTest(t1_lme,[0 1 0 0]);
[ps.acc_lme_opt,stats.acc_lme_opt_F,stats.acc_lme_opt_df] = coefTest(t1_lme,[0 0 1 0]);
[ps.acc_lme_grpxopto,stats.acc_lme_grpxopto_F,stats.acc_lme_grpxopto_df] = coefTest(t1_lme,[0 0 0 1]);

% Direction bias linear model
acc_DL = [mean(reshape(ctlBhvrT.leftOnAcc,[5,6]))' - mean(reshape(ctlBhvrT.leftOffAcc,[5,6]))'; mean(reshape(expBhvrT.leftOnAcc,[5,6]))'-mean(reshape(expBhvrT.leftOffAcc,[5,6]))'];
acc_DR = [mean(reshape(ctlBhvrT.rightOnAcc,[5,6]))' - mean(reshape(ctlBhvrT.rightOffAcc,[5,6]))'; mean(reshape(expBhvrT.rightOnAcc,[5,6]))'-mean(reshape(expBhvrT.rightOffAcc,[5,6]))'];
direction = [repmat("left",[6,1]);repmat("left",[6,1]);repmat("right",[6,1]);repmat("right",[6,1])];
group = repmat([repmat("ctl",[nCtl,1]); repmat("exp",[nExp,1])],[2,1]);
mouse = repmat(["OBCC01";"OBCC02";"OBCC03";"OBCC04";"OBCC05";"OBCC06";"OBC23";"OBC25";"OBC26";"OBC3";"OBC7";"OBC8"],[2,1]);
t2 = table([acc_DL;acc_DR],group,direction,mouse,'VariableNames',{'acc_delta','group','direction','mouse'});
t2_lme = fitlme(t2,'acc_delta~group*direction + (1|mouse)');
[ps.accDelta_lme_int,stats.accDelta_lme_int_F,stats.accDelta_lme_int_df] = coefTest(t2_lme,[1 0 0 0]);
[ps.accDelta_lme_grp,stats.accDelta_lme_grp_F,stats.accDelta_lme_grp_df] = coefTest(t2_lme,[0 1 0 0]);
[ps.accDelta_lme_dir,stats.accDelta_lme_dir_F,stats.accDelta_lme_dir_df] = coefTest(t2_lme,[0 0 1 0]);
[ps.accDelta_lme_grpxdir,stats.accDelta_lme_grpxdir_F,stats.accDelta_lme_grpxdir_df] = coefTest(t2_lme,[0 0 0 1]);

%% Linear model for velocity on SWM accuracy
nExp = height(expBhvrT)/5; nCtl = height(ctlBhvrT)/5;

acc_all = [ctlBhvrT.totOffAcc; expBhvrT.totOffAcc; ctlBhvrT.onAcc; expBhvrT.onAcc];
group = repmat([repmat("ctl",[nCtl*5,1]); repmat("exp",[nExp*5,1])],[2,1]);
opto = [repmat("off",[(nExp+nCtl)*5,1]); repmat("on",[(nExp+nCtl)*5,1])];
vel_trn = [ctlBhvrT.velOff_trn;     expBhvrT.velOff_trn;    ctlBhvrT.velOn_trn;     expBhvrT.velOn_trn];
vel_tst = [ctlBhvrT.velOff_tst;     expBhvrT.velOff_tst;    ctlBhvrT.velOn_tst;     expBhvrT.velOn_tst];
t2b_trn = [ctlBhvrT.tm2boxOff_trn;  expBhvrT.tm2boxOff_trn; ctlBhvrT.tm2boxOn_trn;  expBhvrT.tm2boxOn_trn];
t2b_tst = [ctlBhvrT.tm2boxOff_tst;  expBhvrT.tm2boxOff_tst; ctlBhvrT.tm2boxOn_tst;  expBhvrT.tm2boxOn_tst];
lpt_trn = [ctlBhvrT.lapTOff_trn;    expBhvrT.lapTOff_trn;   ctlBhvrT.lapTOn_trn;    expBhvrT.lapTOn_trn];
lpt_tst = [ctlBhvrT.lapTOff_tst;    expBhvrT.lapTOff_tst;   ctlBhvrT.lapTOn_tst;    expBhvrT.lapTOn_tst];
boc_trn = [ctlBhvrT.chcOccOff_trn;  expBhvrT.chcOccOff_trn; ctlBhvrT.chcOccOn_trn;  expBhvrT.chcOccOn_trn];
boc_tst = [ctlBhvrT.chcOccOff_tst;  expBhvrT.chcOccOff_tst; ctlBhvrT.chcOccOn_tst;  expBhvrT.chcOccOn_tst];
dst_trn = [ctlBhvrT.dstOff_trn;     expBhvrT.dstOff_trn;    ctlBhvrT.dstOn_trn;     expBhvrT.dstOn_trn];
dst_tst = [ctlBhvrT.dstOff_tst;     expBhvrT.dstOff_tst;    ctlBhvrT.dstOn_tst;     expBhvrT.dstOn_tst];
mouse = repmat([reshape(repmat(["OBCC01";"OBCC02";"OBCC03";"OBCC04";"OBCC05";"OBCC06"],[1,5])',[nCtl*5,1]); ...
    reshape(repmat(["OBC23";"OBC25";"OBC26";"OBC3";"OBC7";"OBC8"],[5,1])',[nExp*5,1])],[2,1]);

t2 = table(acc_all,group,opto,mouse,vel_trn,vel_tst,t2b_trn, t2b_tst, ...
    lpt_trn, lpt_tst, boc_trn, boc_tst, dst_trn, dst_tst, ...
    'VariableNames',{'acc','group','opto','mouse','vel_trn','vel_tst','t2box_trn','t2box_tst',...
    'lapT_trn','lapT_tst','BoxOcc_trn','BoxOcc_tst','Dist_trn','Dist_tst'});

%%
% Full model
% t2_lme = fitlme(t2,'acc ~ group*opto + group*BoxOcc_trn + group*BoxOcc_tst+ group*Dist_trn + group*Dist_tst + group*lapT_trn + group*lapT_tst + group*vel_trn + group*vel_tst + group*t2box_trn + group*t2box_tst + (1|mouse)')
% Train phase model
% t2_lme = fitlme(t2,'acc ~ group*opto + group*BoxOcc_trn + group*Dist_trn + group*lapT_trn + group*vel_trn + group*t2box_trn + (1|mouse)')
% Test phase model
t2_lme = fitlme(t2,'acc ~ group*opto + group*BoxOcc_tst + group*Dist_tst + group*lapT_tst + group*vel_tst + group*t2box_tst + (1|mouse)')
% Behavior interaction model
% t2_lme = fitlme(t2,'acc ~ group*opto + group*vel_tst + (1|mouse)')
% Single behavior parameter at a time
t2_lme = fitlme(t2,'acc ~ group*opto + group*vel_trn    + opto*vel_trn    + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*lapT_trn   + opto*lapT_trn   + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*Dist_trn   + opto*Dist_trn   + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*BoxOcc_trn + opto*BoxOcc_trn + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*t2box_trn  + opto*t2box_trn  + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*vel_tst    + opto*vel_tst    + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*lapT_tst   + opto*lapT_tst   + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*Dist_tst   + opto*Dist_tst   + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*BoxOcc_tst + opto*BoxOcc_tst + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*t2box_tst  + opto*t2box_tst  + (1|mouse)')
% Single behavior parameter across train/test at a time
% t2_lme = fitlme(t2,'acc ~ group*opto + group*vel_trn    + opto*vel_trn    + group*vel_tst    + opto*vel_tst     + vel_trn*vel_tst       + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*t2box_trn  + opto*t2box_trn  + group*t2box_tst  + opto*t2box_tst   + t2box_trn*t2box_tst   + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*Dist_trn   + opto*Dist_trn   + group*Dist_tst   + opto*Dist_tst    + Dist_trn*Dist_tst     + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*lapT_trn   + opto*lapT_trn   + group*lapT_tst   + opto*lapT_tst    + lapT_trn*lapT_tst     + (1|mouse)')
% t2_lme = fitlme(t2,'acc ~ group*opto + group*BoxOcc_trn + opto*BoxOcc_trn + group*BoxOcc_tst + opto*BoxOcc_tst  + BoxOcc_trn*BoxOcc_tst + (1|mouse)')

% [ps.acc_lme2_int,stats.acc_lme2_int_F,stats.acc_lme2_int_df] = coefTest(t2_lme,[1 0 0 0 0 0]);
% [ps.acc_lme2_grp,stats.acc_lme2_grp_F,stats.acc_lme2_grp_df] = coefTest(t2_lme,[0 1 0 0 0 0]);
% [ps.acc_lme2_opt,stats.acc_lme2_opt_F,stats.acc_lme2_opt_df] = coefTest(t2_lme,[0 0 1 0 0 0]);
% [ps.acc_lme2_vel,stats.acc_lme2_vel_F,stats.acc_lme2_vel_df] = coefTest(t2_lme,[0 0 0 1 0 0]);
% [ps.acc_lme2_grpxopt,stats.acc_lme2_grpxopt_F,stats.acc_lme2_grpxopt_df] = coefTest(t2_lme,[0 0 0 0 1 0]);
% [ps.acc_lme2_grpxvel,stats.acc_lme2_grpxvel_F,stats.acc_lme2_grpxvel_df] = coefTest(t2_lme,[0 0 0 0 0 1]);


%% RM Anova and Mixed Effect Model for OBC Seizure cohort
load('F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_seizure\OBC_SeizCohort\expBhvrT.mat')
expBhvrT([3,12,22],:) = []; % Eliminate seizure days for OBC9, 10, 
obc10dacc = [expBhvrT.onAcc(1:2) - expBhvrT.totOffAcc(1:2); NaN; NaN; NaN];
obc12dacc = [expBhvrT.onAcc(3:7) - expBhvrT.totOffAcc(3:7)];
obc14dacc = [expBhvrT.onAcc(8:10) - expBhvrT.totOffAcc(8:10); NaN; NaN];
obc21dacc = [expBhvrT.onAcc(11:15) - expBhvrT.totOffAcc(11:15)];
obc09dacc = [expBhvrT.onAcc(16:19) - expBhvrT.totOffAcc(16:19); NaN];
tmpT = [obc10dacc, obc12dacc, obc14dacc, obc21dacc, obc09dacc]';
subj = {'OBC10','OBC12','OBC14','OBC21','OBC9'}';
nsubj = length(subj);
% Set up rm anova table
seizT = table(subj,tmpT(:,1),tmpT(:,2),tmpT(:,3),tmpT(:,4),tmpT(:,5),'VariableNames',{'subject','d1','d2','d3','d4','d5'});
expTime = (1:5)';
withindesign = table({'d1'; 'd2'; 'd3'; 'd4'; 'd5'}, 'VariableNames', {'day'});

rm = fitrm(seizT,'d1-d5 ~ 1','WithinDesign',withindesign);
ranovatbl = ranova(rm);
disp(ranovatbl)

seizT2  = table([[expBhvrT.totOffAcc(1:2); NaN; NaN; NaN]; expBhvrT.totOffAcc(3:7); [expBhvrT.totOffAcc(8:10); NaN; NaN]; expBhvrT.totOffAcc(11:15); [expBhvrT.totOffAcc(16:19); NaN];...
    [expBhvrT.onAcc(1:2); NaN; NaN; NaN]; expBhvrT.onAcc(3:7); [expBhvrT.onAcc(8:10); NaN; NaN]; expBhvrT.onAcc(11:15); [expBhvrT.onAcc(16:19); NaN]],...
    repmat(expTime,nsubj*2,1), [repmat("Off",nsubj*5,1); repmat("On",nsubj*5,1)],repmat(reshape(repmat(subj',5,1),25,1),2,1),...
    'VariableNames',{'Accuracy','Day','Light','Mouse'});
seizT3  = table([obc10dacc; obc12dacc; obc14dacc; obc21dacc; obc09dacc],...
    repmat(expTime,nsubj,1),reshape(repmat(subj',5,1),25,1),...
    'VariableNames',{'Accuracy','Day','Mouse'});

seiz_lme = fitlme(seizT3,'Accuracy ~ Day + (1|Mouse)')

%% Exp vs Ctl - Pulses and pulse v accuracy
if saveFlag; pulse_day_name = 'OBC_compare_cohort_pulsesXdays'; else; pulse_day_name = 0; end
[pulsexdays_fig,ps,stats] = plot_cohort_pulsexday_comp(ctlBhvrT,expBhvrT,pulse_day_name,ps,stats);
stats.pulse_corr_ctlVexp_BH_corr = adjustP_BH(ps,{'dayVpulse_exp','dayVpulse_ctl'},0.05);

if saveFlag; pulse_acc_name = 'OBC_compare_cohort_pulsesXacc'; else; pulse_acc_name = 0; end
[pulsexacc_fig,ps,stats] = plot_cohort_pulsexacc_comp(ctlBhvrT,expBhvrT,pulse_acc_name,ps,stats);
stats.pulseacc_corr_ctlVexp_BH_corr = adjustP_BH(ps,{'accVpulse_exp','accVpulse_ctl'},0.05);

% Mean Pulses
ctl_pulse_ave = mean(reshape(ctlBhvrT.muPulses,[5 height(ctlBhvrT)/5;]));
exp_pulse_ave = mean(reshape(expBhvrT.muPulses,[5 height(expBhvrT)/5;]));
if saveFlag; cohort_pulse_name = 'OBC_compare_cohort_pulse_ave'; else; cohort_pulse_name = 0; end
[pulseave_fig,ps,stats] = plot_cohort_pulse_comp(ctl_pulse_ave,exp_pulse_ave,cohort_pulse_name,ps,stats);

%% Exp vs Ctl - Normalized behavior metrics
normVel_trn_ctl = ctlBhvrT.velOn_trn./ctlBhvrT.velOff_trn; normVel_tst_ctl = ctlBhvrT.velOn_tst./ctlBhvrT.velOff_tst;
normVel_trn_exp = expBhvrT.velOn_trn./expBhvrT.velOff_trn; normVel_tst_exp = expBhvrT.velOn_tst./expBhvrT.velOff_tst;
[~,ps.normVel_ctlVexp_trn,~,stats.normVel_ctlVexp_trn] = ttest2(normVel_trn_ctl,normVel_trn_exp);
[~,ps.normVel_ctlVexp_tst,~,stats.normVel_ctlVexp_tst] = ttest2(normVel_tst_ctl,normVel_tst_exp);

normDst_trn_ctl = ctlBhvrT.dstOn_trn./ctlBhvrT.dstOff_trn; normDst_tst_ctl = ctlBhvrT.dstOn_tst./ctlBhvrT.dstOff_tst;
normDst_trn_exp = expBhvrT.dstOn_trn./expBhvrT.dstOff_trn; normDst_tst_exp = expBhvrT.dstOn_tst./expBhvrT.dstOff_tst;
[~,ps.normDst_ctlVexp_trn,~,stats.normDst_ctlVexp_trn] = ttest2(normDst_trn_ctl,normDst_trn_exp);
[~,ps.normDst_ctlVexp_tst,~,stats.normDst_ctlVexp_tst] = ttest2(normDst_tst_ctl,normDst_tst_exp);

normLpT_trn_ctl = ctlBhvrT.lapTOn_trn./ctlBhvrT.lapTOff_trn; normLpT_tst_ctl = ctlBhvrT.lapTOn_tst./ctlBhvrT.lapTOff_tst;
normLpT_trn_exp = expBhvrT.lapTOn_trn./expBhvrT.lapTOff_trn; normLpT_tst_exp = expBhvrT.lapTOn_tst./expBhvrT.lapTOff_tst;
[~,ps.normLpT_ctlVexp_trn,~,stats.normLpT_ctlVexp_trn] = ttest2(normLpT_trn_ctl,normLpT_trn_exp);
[~,ps.normLpT_ctlVexp_tst,~,stats.normLpT_ctlVexp_tst] = ttest2(normLpT_tst_ctl,normLpT_tst_exp);

normT2B_trn_ctl = ctlBhvrT.tm2boxOn_trn./ctlBhvrT.tm2boxOff_trn; normT2B_tst_ctl = ctlBhvrT.tm2boxOn_tst./ctlBhvrT.tm2boxOff_tst;
normT2B_trn_exp = expBhvrT.tm2boxOn_trn./expBhvrT.tm2boxOff_trn; normT2B_tst_exp = expBhvrT.tm2boxOn_tst./expBhvrT.tm2boxOff_tst;
[~,ps.normT2B_ctlVexp_trn,~,stats.normT2B_ctlVexp_trn] = ttest2(normT2B_trn_ctl,normT2B_trn_exp);
[~,ps.normT2B_ctlVexp_tst,~,stats.normT2B_ctlVexp_tst] = ttest2(normT2B_tst_ctl,normT2B_tst_exp);

normBOc_trn_ctl = ctlBhvrT.chcOccOn_trn./ctlBhvrT.chcOccOff_trn; normBOc_tst_ctl = ctlBhvrT.chcOccOn_tst./ctlBhvrT.chcOccOff_tst;
normBOc_trn_exp = expBhvrT.chcOccOn_trn./expBhvrT.chcOccOff_trn; normBOc_tst_exp = expBhvrT.chcOccOn_tst./expBhvrT.chcOccOff_tst;
[~,ps.normBOc_ctlVexp_trn,~,stats.normBOc_ctlVexp_trn] = ttest2(normBOc_trn_ctl,normBOc_trn_exp);
[~,ps.normBOc_ctlVexp_tst,~,stats.normBOc_ctlVexp_tst] = ttest2(normBOc_tst_ctl,normBOc_tst_exp);

fig_vel_grp = plot_obc_cohort_means(normVel_trn_ctl,normVel_trn_exp,normVel_tst_ctl,normVel_tst_exp,0);
ylabel('Velocity (Norm. to Off)')
fig_dst_grp = plot_obc_cohort_means(normDst_trn_ctl,normDst_trn_exp,normDst_tst_ctl,normDst_tst_exp,0);
ylabel('Distance (Norm. to Off)')
fig_lpt_grp = plot_obc_cohort_means(normLpT_trn_ctl,normLpT_trn_exp,normLpT_tst_ctl,normLpT_tst_exp,0);
ylabel('Lap Time (Norm to Off)')
legCell = {'eYFP','ChR2'};
legend(legCell,'FontSize',16,'Location','best');
fig_t2b_grp = plot_obc_cohort_means(normT2B_trn_ctl,normT2B_trn_exp,normT2B_tst_ctl,normT2B_tst_exp,0);
ylabel('Time to Choice (Norm. to Off)')
fig_boc_grp = plot_obc_cohort_means(normBOc_trn_ctl,normBOc_trn_exp,normBOc_tst_ctl,normBOc_tst_exp,0);
ylabel('Choice Pt. Occ. (Norm to Off)')

if saveFlag == 1
    saveFigTypes(fig_vel_grp,['Velocity_Norm_Comp']);
    saveFigTypes(fig_dst_grp,['VDistance_Norm_Comp']);
    saveFigTypes(fig_lpt_grp,['LapTime_Norm_Comp']);
    saveFigTypes(fig_t2b_grp,['Time2Choice_Norm_Comp']);
    saveFigTypes(fig_boc_grp,['ChoiceOcc_Norm_Comp']);
    save('OBC_compare_cohort_acc_stats','ps','stats');
end

%% Exp vs Ctl - Correlate raw behavior across days train and test phase
fig_velxday_grp_trn = plot_obc_corr_trntst(ctlBhvrT.velOff_trn,expBhvrT.velOff_trn,ctlBhvrT.velOn_trn,expBhvrT.velOn_trn,0);
ylabel('Train Velocity (cm/s)'); ylim([0 16])
legCell = {'eYFP Off','ChR2 Off','eYFP On','ChR2 On'};
legend(legCell,'FontSize',16,'Location','se');

fig_dstxday_grp_trn = plot_obc_corr_trntst(ctlBhvrT.dstOff_trn,expBhvrT.dstOff_trn,ctlBhvrT.dstOn_trn,expBhvrT.dstOn_trn,0);
ylabel('Train Distance (cm)'); ylim([250 650])

fig_lptxday_grp_trn = plot_obc_corr_trntst(ctlBhvrT.lapTOff_trn,expBhvrT.lapTOff_trn,ctlBhvrT.lapTOn_trn,expBhvrT.lapTOn_trn,0);
ylabel('Train Lap Time (s)'); ylim([20 70])

fig_t2bxday_grp_trn = plot_obc_corr_trntst(ctlBhvrT.tm2boxOff_trn,expBhvrT.tm2boxOff_trn,ctlBhvrT.tm2boxOn_trn,expBhvrT.tm2boxOn_trn,0);
ylabel('Train Time to Choice Pt. (s)'); ylim([0 25])

fig_bocxday_grp_trn = plot_obc_corr_trntst(ctlBhvrT.chcOccOff_trn,expBhvrT.chcOccOff_trn,ctlBhvrT.chcOccOn_trn,expBhvrT.chcOccOn_trn,0);
ylabel('Train Choice Pt. Occ. (%)'); ylim([0 15])

fig_velxday_grp_tst = plot_obc_corr_trntst(ctlBhvrT.velOff_tst,expBhvrT.velOff_tst,ctlBhvrT.velOn_tst,expBhvrT.velOn_tst,0);
ylabel('Test Velocity (cm/s)'); ylim([0 16])
legCell = {'eYFP Off','ChR2 Off','eYFP On','ChR2 On'};
legend(legCell,'FontSize',16,'Location','se');

fig_dstxday_grp_tst = plot_obc_corr_trntst(ctlBhvrT.dstOff_tst,expBhvrT.dstOff_tst,ctlBhvrT.dstOn_tst,expBhvrT.dstOn_tst,0);
ylabel('Test Distance (cm)'); ylim([250 650])

fig_lptxday_grp_tst = plot_obc_corr_trntst(ctlBhvrT.lapTOff_tst,expBhvrT.lapTOff_tst,ctlBhvrT.lapTOn_tst,expBhvrT.lapTOn_tst,0);
ylabel('Test Lap Time (s)'); ylim([20 70])

fig_t2bxday_grp_tst = plot_obc_corr_trntst(ctlBhvrT.tm2boxOff_tst,expBhvrT.tm2boxOff_tst,ctlBhvrT.tm2boxOn_tst,expBhvrT.tm2boxOn_tst,0);
ylabel('Test Time to Choice Pt. (s)'); ylim([0 25])

fig_bocxday_grp_tst = plot_obc_corr_trntst(ctlBhvrT.chcOccOff_tst,expBhvrT.chcOccOff_tst,ctlBhvrT.chcOccOn_tst,expBhvrT.chcOccOn_tst,0);
ylabel('Test Choice Pt. Occ. (%)'); ylim([0 15])

if saveFlag == 1
    saveFigTypes(fig_velxday_grp_trn,['VelocityXDays_trn_Comp']);
    saveFigTypes(fig_dstxday_grp_trn,['VDistanceXDays_trn_Comp']);
    saveFigTypes(fig_lptxday_grp_trn,['LapTimeXDays_trn_Comp']);
    saveFigTypes(fig_t2bxday_grp_trn,['Time2ChoiceXDays_trn_Comp']);
    saveFigTypes(fig_bocxday_grp_trn,['ChoiceOccXDays_trn_Comp']);
    saveFigTypes(fig_velxday_grp_tst,['VelocityXDays_tst_Comp']);
    saveFigTypes(fig_dstxday_grp_tst,['VDistanceXDays_tst_Comp']);
    saveFigTypes(fig_lptxday_grp_tst,['LapTimeXDays_tst_Comp']);
    saveFigTypes(fig_t2bxday_grp_tst,['Time2ChoiceXDays_tst_Comp']);
    saveFigTypes(fig_bocxday_grp_tst,['ChoiceOccXDays_tst_Comp']);
    close all
end

%% Exp error over session

cd('F:\Research\Experimental\DG_nonsense_project\Analysis\OBC_Final')
mFolds = ["OBC3" "OBC7" "OBC8" "OBC23" "OBC25" "OBC26"];

bhvrStruc = [];
nMice = length(mFolds);

for i = 1:nMice
    cd(mFolds(i))
    sessList = dir("*_sessions.mat");
    load(sessList.name)
    ct = 1;
    errMatSum = [];
    for j = 1:length(sessionList)
        load(sessionList{j})
        if session.sessionType(1:3) == 'opt'
            bhvrStruc(i).sess(ct).opto = session.optoSeq;
            bhvrStruc(i).sess(ct).bhvr = session.bhvrScore;
            
            nTrials = length(session.optoSeq) - 5;
            tmpHalf = 5 + round(nTrials/2);
            bhvrStruc(i).errFrst(ct) = mean(session.bhvrScore(6:tmpHalf));
            bhvrStruc(i).errLast(ct) = mean(session.bhvrScore(tmpHalf:end));
            if length(session.bhvrScore(6:end)) == 20
%                 bhvrStruc(i).errSum(ct).err = cumsum(not(session.bhvrScore(6:end)));
                errMatSum(ct,:) = cumsum(not(session.bhvrScore(6:end))) ./ max(cumsum(not(session.bhvrScore(6:end))));
            else
%                 bhvrStruc(i).errSum(ct).err = NaN(1,20);
                errMatSum(ct,:) = NaN(1,20);
            end
            ct = ct + 1;
        else
            continue
        end
    end
    
    errMatFrst(i) = mean(bhvrStruc(i).errFrst);
    errMatLast(i) = mean(bhvrStruc(i).errLast);
    errMatMean(i,:) = nanmean(errMatSum);
    cd('..')
end

[~,ps.FrstLast_tt,~,stats.FrstLast_tt] = ttest(errMatFrst,errMatLast);

% KS Test over trials
% kstest(mean(errMatMean),'CDF',[mean(errMatMean)', cdf('unif',mean(errMatMean),0,1)'])
[~,ps.UnifDistro_ks,stats.UnifDistro_ks] = kstest(mean(errMatMean),'CDF',makedist('uniform','lower',0,'upper',1));

cmapcool = cool(nMice);
ksFig = figure; hold on; axis square
for i = 1:nMice
    plot(errMatMean(i,:),'Color',cmapcool(i,:),'HandleVisibility','off')
%    for j = 1:length(bhvrStruc(i).errFrst)
% %        plot(bhvrStruc(i).errSum(j).err ./ max(bhvrStruc(i).errSum(j).err),'Color',cmapcool(i,:))
%    end
end
plot(mean(errMatMean),'Color',[0 0 0.8],'LineWidth',2)
plot([0],[0],'Color',cmapcool(1,:))
plot([0 20],[0 1],'k--')
ylabel('Cumulative Error Rate'); legend({'Mean','Mice','Uniform'})
xlabel('Trial #')
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

% Simple comparison first half vs last half
firstLastFig = figure; hold on
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.15,0.525]);
bar(mean([errMatFrst; errMatLast],2),'FaceColor',[0.5 0.5 1],'EdgeColor',[0 0 0.8])
plot([ones(1,nMice) 1+ones(1,nMice)],[errMatFrst, errMatLast],'d','MarkerEdgeColor',[0.3 0.3 0.7])
ylim([0 1]); ylabel('DNMP Accuracy')
xticks(1:2); xticklabels({'First half' 'Last half'}); xtickangle(45)
plot([0 3],[0.5 0.5],'k--','HandleVisibility','off')                 % 50/50 line
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);

if saveFlag == 1
    cd(plotDir)
    saveFigTypes(ksFig,['error_KStest']);
    saveFigTypes(firstLastFig,['error_FirstLast']);
end

%% Exp vs Ctl Correlations - Granular Behavior vs accuracy
ctl_mu_acc_on = mean(reshape(ctlBhvrT.onAcc,5,nCtl));
ctl_mu_acc_off = mean(reshape(ctlBhvrT.totOffAcc,5,nCtl));
exp_mu_acc_on = mean(reshape(expBhvrT.onAcc,5,nExp));
exp_mu_acc_off = mean(reshape(expBhvrT.totOffAcc,5,nExp));
% ps = struct; stats = struct; corrType = 'pearson';

fig_dstxacc_grp_trntst = plot_obc_corr_accVbhvr([normDst_trn_ctl,normDst_tst_ctl],[normDst_trn_exp,normDst_tst_exp],ctlBhvrT.onAcc,expBhvrT.onAcc,0);
xlabel('Distance (Norm. to Off)')
[stats.ctl_accVDst_trn,ps.ctl_accVDst_trn] = corr(qckrshp(normDst_trn_ctl)',ctl_mu_acc_on','Type',corrType);
[stats.exp_accVDst_trn,ps.exp_accVDst_trn] = corr(qckrshp(normDst_trn_exp)',exp_mu_acc_on','Type',corrType);
[stats.ctl_accVDst_tst,ps.ctl_accVDst_tst] = corr(qckrshp(normDst_tst_ctl)',ctl_mu_acc_on','Type',corrType);
[stats.exp_accVDst_tst,ps.exp_accVDst_tst] = corr(qckrshp(normDst_tst_exp)',exp_mu_acc_on','Type',corrType);

fig_velxacc_grp_trntst = plot_obc_corr_accVbhvr([normVel_trn_ctl,normVel_tst_ctl],[normVel_trn_exp,normVel_tst_exp],ctlBhvrT.onAcc,expBhvrT.onAcc,0);
xlabel('Velocity (Norm. to Off)')
[stats.ctl_accVVel_trn,ps.ctl_accVVel_trn] = corr(qckrshp(normVel_trn_ctl)',ctl_mu_acc_on','Type',corrType);
[stats.exp_accVVel_trn,ps.exp_accVVel_trn] = corr(qckrshp(normVel_trn_exp)',exp_mu_acc_on','Type',corrType);
[stats.ctl_accVVel_tst,ps.ctl_accVVel_tst] = corr(qckrshp(normVel_tst_ctl)',ctl_mu_acc_on','Type',corrType);
[stats.exp_accVVel_tst,ps.exp_accVVel_tst] = corr(qckrshp(normVel_tst_exp)',exp_mu_acc_on','Type',corrType);

fig_bocxacc_grp_trntst = plot_obc_corr_accVbhvr([normBOc_trn_ctl,normBOc_tst_ctl],[normBOc_trn_exp,normBOc_tst_exp],ctlBhvrT.onAcc,expBhvrT.onAcc,0);
xlabel('Choice Pt. Occ. (Norm. to Off)')
[stats.ctl_accVBOc_trn,ps.ctl_accVBOc_trn] = corr(qckrshp(normBOc_trn_ctl)',ctl_mu_acc_on','Type',corrType);
[stats.exp_accVBOc_trn,ps.exp_accVBOc_trn] = corr(qckrshp(normBOc_trn_exp)',exp_mu_acc_on','Type',corrType);
[stats.ctl_accVBOc_tst,ps.ctl_accVBOc_tst] = corr(qckrshp(normBOc_tst_ctl)',ctl_mu_acc_on','Type',corrType);
[stats.exp_accVBOc_tst,ps.exp_accVBOc_tst] = corr(qckrshp(normBOc_tst_exp)',exp_mu_acc_on','Type',corrType);

fig_lptxacc_grp_trntst = plot_obc_corr_accVbhvr([normLpT_trn_ctl,normLpT_tst_ctl],[normLpT_trn_exp,normLpT_tst_exp],ctlBhvrT.onAcc,expBhvrT.onAcc,0);
xlabel('Lap Time (Norm. to Off)')
[stats.ctl_accVlpt_trn,ps.ctl_accVlpt_trn] = corr(qckrshp(normLpT_trn_ctl)',ctl_mu_acc_on','Type',corrType);
[stats.exp_accVlpt_trn,ps.exp_accVlpt_trn] = corr(qckrshp(normLpT_trn_exp)',exp_mu_acc_on','Type',corrType);
[stats.ctl_accVlpt_tst,ps.ctl_accVlpt_tst] = corr(qckrshp(normLpT_tst_ctl)',ctl_mu_acc_on','Type',corrType);
[stats.exp_accVlpt_tst,ps.exp_accVlpt_tst] = corr(qckrshp(normLpT_tst_exp)',exp_mu_acc_on','Type',corrType);

fig_t2bxacc_grp_trntst = plot_obc_corr_accVbhvr([normT2B_trn_ctl,normT2B_tst_ctl],[normT2B_trn_exp,normT2B_tst_exp],ctlBhvrT.onAcc,expBhvrT.onAcc,0);
xlabel('Time to Choice (Norm. to Off)')
[stats.ctl_accVt2b_trn,ps.ctl_accVt2b_trn] = corr(qckrshp(normT2B_trn_ctl)',ctl_mu_acc_on','Type',corrType);
[stats.exp_accVt2b_trn,ps.exp_accVt2b_trn] = corr(qckrshp(normT2B_trn_exp)',exp_mu_acc_on','Type',corrType);
[stats.ctl_accVt2b_tst,ps.ctl_accVt2b_tst] = corr(qckrshp(normT2B_tst_ctl)',ctl_mu_acc_on','Type',corrType);
[stats.exp_accVt2b_tst,ps.exp_accVt2b_tst] = corr(qckrshp(normT2B_tst_exp)',exp_mu_acc_on','Type',corrType);

if saveFlag == 1
    saveFigTypes(fig_dstxacc_grp_trntst,['dstxacc_grp_trntst']);
    saveFigTypes(fig_velxacc_grp_trntst,['velxacc_grp_trntst']);
    saveFigTypes(fig_bocxacc_grp_trntst,['bocxacc_grp_trntst']);
    saveFigTypes(fig_lptxacc_grp_trntst,['lptxacc_grp_trntst']);
    saveFigTypes(fig_t2bxacc_grp_trntst,['t2bxacc_grp_trntst']);
    save('bhvrVacc_stats','ps','stats');
    close all
end

%% Exp vs Ctl eYFP v Acc comparison
load('G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBC_expVsctl\OBCC_Ave_CellT.mat');
CT_ctl = MM_T_avg;
load('G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBC_expVsctl\OBC_Ave_CellT.mat');
CT_exp = MM_T_avg;

nCtl = height(CT_ctl); nExp = height(CT_exp);
corrType = 'pearson'; 
ps = struct; stats = struct;

ctl_mu_acc_on = mean(reshape(ctlBhvrT.onAcc,5,nCtl));
ctl_mu_acc_off = mean(reshape(ctlBhvrT.totOffAcc,5,nCtl));
exp_mu_acc_on = mean(reshape(expBhvrT.onAcc,5,nExp));
exp_mu_acc_off = mean(reshape(expBhvrT.totOffAcc,5,nExp));

nrm_ovlpeyfp_ctl = CT_ctl.CfosXEYFPOverlapCounts ./ CT_ctl.eYFPCounts;
nrm_ovlpeyfp_exp = CT_exp.CfosXEYFPOverlapCounts ./ CT_exp.eYFPCounts;
nrm_ovlpcfos_ctl = CT_ctl.CfosXEYFPOverlapCounts ./ CT_ctl.CfosCounts;
nrm_ovlpcfos_exp = CT_exp.CfosXEYFPOverlapCounts ./ CT_exp.CfosCounts;

% Raw Cell Count Comparison - eYFP and cFos and Overlap
[~,ps.rawct_cfos_ctlVexp,~,stats.rawct_cfos_ctlVexp] = ttest2(CT_ctl.CfosCounts,CT_exp.CfosCounts);
[~,ps.rawct_eyfp_ctlVexp,~,stats.rawct_eyfp_ctlVexp] = ttest2(CT_ctl.eYFPCounts,CT_exp.eYFPCounts);
[~,ps.rawct_ovlp_ctlVexp,~,stats.rawct_ovlp_ctlVexp] = ttest2(CT_ctl.CfosXEYFPOverlapCounts,CT_exp.CfosXEYFPOverlapCounts);
[~,ps.nrmct_ovlpeyfp_ctlVexp,~,stats.nrmct_ovlpeyfp_ctlVexp] = ttest2(nrm_ovlpeyfp_ctl,nrm_ovlpeyfp_exp);
[~,ps.nrmct_ovlpcfos_ctlVexp,~,stats.nrmct_ovlpcfos_ctlVexp] = ttest2(nrm_ovlpcfos_ctl,nrm_ovlpcfos_exp);

cfosCols = [0.7 0.1 0.1; 1 0 0];
eyfpCols = [0.3 0.8 0.1; 0.6 1 0.1]; 
ovlpCols = [0.9 0.7 0.075; 0.9 0.9 0.2];
fig_raw_cfos = plot_obc_rawcellct(CT_ctl.CfosCounts,CT_exp.CfosCounts,cfosCols,0);
ylabel('cFos Count'); ylim([50 225]);
fig_raw_eyfp = plot_obc_rawcellct(CT_ctl.eYFPCounts,CT_exp.eYFPCounts,eyfpCols,0);
ylabel('eYFP Count'); ylim([0 700]);
fig_raw_ovlp = plot_obc_rawcellct(CT_ctl.CfosXEYFPOverlapCounts,CT_exp.CfosXEYFPOverlapCounts,ovlpCols,0);
ylabel('Overlap Count'); ylim([0 70]);
fig_nrm_ovlpeyfp = plot_obc_rawcellct(nrm_ovlpeyfp_ctl, nrm_ovlpeyfp_exp,ovlpCols,0);
ylabel('eYFP Normalized Overlap'); ylim([0 0.5]);

%eYFP ON accuracy
[stats.ctl_accVeyfp_on,ps.ctl_accVeyfp_on] = corr(CT_ctl.eYFPCounts,ctl_mu_acc_on','Type',corrType);
[stats.exp_accVeyfp_on,ps.exp_accVeyfp_on] = corr(CT_exp.eYFPCounts,exp_mu_acc_on','Type',corrType);
fig_cellcount_eyfpVacc_on = plot_obc_cellcorr(CT_ctl.eYFPCounts,CT_exp.eYFPCounts,ctl_mu_acc_on',exp_mu_acc_on',eyfpCols,0);
xlabel('Promiscuous tag (# cells)'); ylabel('On Accuracy (%)')
legend({'eYFP','ChR2'},'location','se'); ylim([0 1]);

%cFos ON accuracy
[stats.ctl_accVcfos_on,ps.ctl_accVcfos_on] = corr(CT_ctl.CfosCounts,ctl_mu_acc_on','Type',corrType);
[stats.exp_accVcfos_on,ps.exp_accVcfos_on] = corr(CT_exp.CfosCounts,exp_mu_acc_on','Type',corrType);
fig_cellcount_cfosVacc_on = plot_obc_cellcorr(CT_ctl.CfosCounts,CT_exp.CfosCounts,ctl_mu_acc_on',exp_mu_acc_on',cfosCols,0);
xlabel('cFos tag (# cells)'); ylabel('On Accuracy (%)')
legend({'eYFP','ChR2'},'location','se'); ylim([0 1]);

%OL ON accuracy
[stats.ctl_accVovlp_on,ps.ctl_accVovlp_on] = corr(CT_ctl.CfosXEYFPOverlapCounts,ctl_mu_acc_on','Type',corrType);
[stats.exp_accVovlp_on,ps.exp_accVovlp_on] = corr(CT_exp.CfosXEYFPOverlapCounts,exp_mu_acc_on','Type',corrType);
fig_cellcount_ovlpVacc_on = plot_obc_cellcorr(CT_ctl.CfosXEYFPOverlapCounts,CT_exp.CfosXEYFPOverlapCounts,ctl_mu_acc_on',exp_mu_acc_on',ovlpCols,0);
xlabel('Overlap (# cells)'); ylabel('On Accuracy (%)')
legend({'eYFP','ChR2'},'location','se'); ylim([0 1]);

%Norm OL ON accuracy
[stats.ctl_accVnrmovlp_on,ps.ctl_accVnrmovlp_on] = corr(nrm_ovlpeyfp_ctl,ctl_mu_acc_on','Type',corrType);
[stats.exp_accVnrmovlp_on,ps.exp_accVnrmovlp_on] = corr(nrm_ovlpeyfp_exp,exp_mu_acc_on','Type',corrType);
fig_cellcount_nrmovlpVacc_on = plot_obc_cellcorr(nrm_ovlpeyfp_ctl,nrm_ovlpeyfp_exp,ctl_mu_acc_on',exp_mu_acc_on',ovlpCols,0);
xlabel('eYFP Normalized Overlap'); ylabel('On Accuracy (%)')
legend({'eYFP','ChR2'},'location','se'); ylim([0 1]);

%eYFP OFF accuracy
[stats.ctl_accVeyfp_off,ps.ctl_accVeyfp_off] = corr(CT_ctl.eYFPCounts,ctl_mu_acc_off','Type',corrType);
[stats.exp_accVeyfp_off,ps.exp_accVeyfp_off] = corr(CT_exp.eYFPCounts,exp_mu_acc_off','Type',corrType);
fig_cellcount_eyfpVacc_off = plot_obc_cellcorr(CT_ctl.eYFPCounts,CT_exp.eYFPCounts,ctl_mu_acc_off',exp_mu_acc_off',eyfpCols,0);
xlabel('Promiscuous tag (# cells)'); ylabel('Off Accuracy (%)')
legend({'eYFP','ChR2'},'location','se'); ylim([0 1]);

%cFos OFF accuracy
[stats.ctl_accVcfos_off,ps.ctl_accVcfos_off] = corr(CT_ctl.CfosCounts,ctl_mu_acc_off','Type',corrType);
[stats.exp_accVcfos_off,ps.exp_accVcfos_off] = corr(CT_exp.CfosCounts,exp_mu_acc_off','Type',corrType);
fig_cellcount_cfosVacc_off = plot_obc_cellcorr(CT_ctl.CfosCounts,CT_exp.CfosCounts,ctl_mu_acc_off',exp_mu_acc_off',cfosCols,0);
xlabel('cFos tag (# cells)'); ylabel('Off Accuracy (%)')
legend({'eYFP','ChR2'},'location','se'); ylim([0 1]);

%OL OFF accuracy
[stats.ctl_accVovlp_off,ps.ctl_accVovlp_off] = corr(CT_ctl.CfosXEYFPOverlapCounts,ctl_mu_acc_off','Type',corrType);
[stats.exp_accVovlp_off,ps.exp_accVovlp_off] = corr(CT_exp.CfosXEYFPOverlapCounts,exp_mu_acc_off','Type',corrType);
fig_cellcount_ovlpVacc_off = plot_obc_cellcorr(CT_ctl.CfosXEYFPOverlapCounts,CT_exp.CfosXEYFPOverlapCounts,ctl_mu_acc_off',exp_mu_acc_off',ovlpCols,0);
xlabel('Overlap (# cells)'); ylabel('Off Accuracy (%)')
legend({'eYFP','ChR2'},'location','se'); ylim([0 1]);

%Norm OL OFF accuracy
[stats.ctl_accVnrmovlp_off,ps.ctl_accVnrmovlp_off] = corr(nrm_ovlpeyfp_ctl,ctl_mu_acc_off','Type',corrType);
[stats.exp_accVnrmovlp_off,ps.exp_accVnrmovlp_off] = corr(nrm_ovlpeyfp_exp,exp_mu_acc_off','Type',corrType);
fig_cellcount_nrmovlpVacc_off = plot_obc_cellcorr(nrm_ovlpeyfp_ctl,nrm_ovlpeyfp_exp,ctl_mu_acc_off',exp_mu_acc_off',ovlpCols,0);
xlabel('eYFP Normalized Overlap'); ylabel('Off Accuracy (%)')
legend({'eYFP','ChR2'},'location','se'); ylim([0 1]);

if saveFlag == 1
    saveFigTypes(fig_cellcount_eyfpVacc_on,['cellcount_eyfpVacc_on']);
    saveFigTypes(fig_cellcount_cfosVacc_on,['cellcount_cfosVacc_on']);
    saveFigTypes(fig_cellcount_ovlpVacc_on,['cellcount_ovlpVacc_on']);
    saveFigTypes(fig_cellcount_nrmovlpVacc_on,['cellcount_nrmovlpVacc_on']);
    saveFigTypes(fig_cellcount_eyfpVacc_off,['cellcount_eyfpVacc_off']);
    saveFigTypes(fig_cellcount_cfosVacc_off,['cellcount_cfosVacc_off']);
    saveFigTypes(fig_cellcount_ovlpVacc_off,['cellcount_ovlpVacc_off']);
    saveFigTypes(fig_cellcount_nrmovlpVacc_off,['cellcount_nrmovlpVacc_off']);
    saveFigTypes(fig_raw_cfos,['cellcount_raw_cfos']);
    saveFigTypes(fig_raw_eyfp,['cellcount_raw_eyfp']);
    saveFigTypes(fig_raw_ovlp,['cellcount_raw_ovlp']);
    saveFigTypes(fig_nrm_ovlpeyfp,['cellcount_nrm_ovlp']);
    save('OBC_cohort_cellcount_bhvr_corr_stats','stats','ps');
    close all
end

%% Check processed x/y data 
cd(dataPath)
tmpmouse = 'OBC8';
csvlist = dir(fullfile(tmpmouse, '**', '*00.csv'));
disp([tmpmouse, ' csv Files: ',num2str(numel(csvlist))])
cmblist = dir(fullfile(tmpmouse, '**', '*CMB*'));
disp([tmpmouse, ' CMB Files: ',num2str(numel(cmblist))])

for i = 1:length(cmblist)
rawDLC = readtable(fullfile(csvlist(i).folder,csvlist(i).name));
% clnDLC = readtable(xlStruct(2).name);
load(fullfile(cmblist(i).folder,cmblist(i).name));
raw_x = cellfun(@str2num,rawDLC{3:end,11});
raw_y = cellfun(@str2num,rawDLC{3:end,12});
% cln_x = cellfun(@str2num,clnDLC{3:end,11});
% cln_y = cellfun(@str2num,clnDLC{3:end,12});
    figure; hold on
    plot(raw_x,raw_y,'Color',[0.5 0.5 0.5]);
    plot(root.x,root.y,'b');
end
%%
figure; hold on;
plot(raw_x,raw_y,'Color',[0.5 0.5 0.5])
% plot(cln_x,cln_y,'b')

%% Run behavior comparisons

% Wilcoxon Sign rank for non-parametric dependent samples test
% Rank sum for non-parametric independent samples test
% Spearman's Rho rank correlation non-parametric equivalent to Pearson

cd(mainPath)
load('OBC_cohort_n7_reanalysis_lapTable.mat')
% load('OBCC_Cohort01-06_lapTable.mat')

corrType = 'Spearman';

tagInd = find(any(ismember(bhvrT.day,0),2)==1);
exptT = bhvrT;
exptT(tagInd,:) = [];
nMice = length(exptT.day)/5;

%Average accuracy 
mAccOff = mean(reshape(exptT.totOffAcc,5,nMice)); mAccOn = mean(reshape(exptT.onAcc,5,nMice));
[ps.accOffOn,~,stats.accOffOn] = signrank(mAccOff,mAccOn);

%Average speed (cm/s)
mVelOff_trn = mean(reshape(exptT.velOff_trn,5,nMice)); mVelOn_trn = mean(reshape(exptT.velOn_trn,5,nMice));
mVelOff_tst = mean(reshape(exptT.velOff_tst,5,nMice)); mVelOn_tst = mean(reshape(exptT.velOn_tst,5,nMice));
normVelOff_trn = exptT.velOff_trn./exptT.velOff_trn; normVelOff_tst = exptT.velOff_tst./exptT.velOff_tst; 
normVelOn_trn = exptT.velOn_trn./exptT.velOff_trn; normVelOn_tst = exptT.velOn_tst./exptT.velOff_tst; 
% [p.velOffOn_trn,~,stat.velOffOn_trn] = signrank(exptT.velOff_trn,exptT.velOn_trn);
% [p.velOffOn_tst,~,stat.velOffOn_tst] = signrank(exptT.velOff_tst,exptT.velOn_tst);
[ps.velOffOn_trn,~,stats.velOffOn_trn] = signrank(mVelOff_trn,mVelOn_trn);
[ps.velOffOn_tst,~,stats.velOffOn_tst] = signrank(mVelOff_tst,mVelOn_tst);
[ps.normvelOn_trn,~,stats.normvelOn_trn] = signrank(normVelOn_trn-1);
[ps.normvelOn_tst,~,stats.normvelOn_tst] = signrank(normVelOn_tst-1);
[rhos.dayVvelOff_trn,ps.dayVvelOff_trn] = corr(exptT.day,exptT.velOff_trn,'Type',corrType);
[rhos.dayVvelOn_trn,ps.dayVvelOn_trn] = corr(exptT.day,exptT.velOn_trn,'Type',corrType);
[rhos.dayVvelOff_tst,ps.dayVvelOff_tst] = corr(exptT.day,exptT.velOff_tst,'Type',corrType);
[rhos.dayVvelOn_tst,ps.dayVvelOn_tst] = corr(exptT.day,exptT.velOn_tst,'Type',corrType);

%Average distance (cm)
mDstOff_trn = mean(reshape(exptT.dstOff_trn,5,nMice)); mDstOn_trn = mean(reshape(exptT.dstOn_trn,5,nMice));
mDstOff_tst = mean(reshape(exptT.dstOff_tst,5,nMice)); mDstOn_tst = mean(reshape(exptT.dstOn_tst,5,nMice));
normDstOff_trn = exptT.dstOff_trn./exptT.dstOff_trn; normDstOff_tst = exptT.dstOff_tst./exptT.dstOff_tst; 
normDstOn_trn = exptT.dstOn_trn./exptT.dstOff_trn; normDstOn_tst = exptT.dstOn_tst./exptT.dstOff_tst; 
% [p.dstOffOn_trn,~,stat.dstOffOn_trn] = signrank(exptT.dstOff_trn,exptT.dstOn_trn);
% [p.dstOffOn_tst,~,stat.dstOffOn_tst] = signrank(exptT.dstOff_tst,exptT.dstOn_tst);
[ps.dstOffOn_trn,~,stats.dstOffOn_trn] = signrank(mDstOff_trn,mDstOn_trn);
[ps.dstOffOn_tst,~,stats.dstOffOn_tst] = signrank(mDstOff_tst,mDstOn_tst);
[ps.normdstOn_trn,~,stats.normdstOn_trn] = signrank(normDstOn_trn-1);
[ps.normdstOn_tst,~,stats.normdstOn_tst] = signrank(normDstOn_tst-1);
[rhos.dayVdstOff_trn,ps.dayVdstOff_trn] = corr(exptT.day,exptT.dstOff_trn,'Type',corrType);
[rhos.dayVdstOn_trn,ps.dayVdstOn_trn] = corr(exptT.day,exptT.dstOn_trn,'Type',corrType);
[rhos.dayVdstOff_tst,ps.dayVdstOff_tst] = corr(exptT.day,exptT.dstOff_tst,'Type',corrType);
[rhos.dayVdstOn_tst,ps.dayVdstOn_tst] = corr(exptT.day,exptT.dstOn_tst,'Type',corrType);

%Average lap duration (s)
mLpTOff_trn = mean(reshape(exptT.lapTOff_trn,5,nMice)); mLpTOn_trn = mean(reshape(exptT.lapTOn_trn,5,nMice));
mLpTOff_tst = mean(reshape(exptT.lapTOff_tst,5,nMice)); mLpTOn_tst = mean(reshape(exptT.lapTOn_tst,5,nMice));
normLpTOff_trn = exptT.lapTOff_trn./exptT.lapTOff_trn; normLpTOff_tst = exptT.lapTOff_tst./exptT.lapTOff_tst; 
normLpTOn_trn = exptT.lapTOn_trn./exptT.lapTOff_trn; normLpTOn_tst = exptT.lapTOn_tst./exptT.lapTOff_tst; 
% [p.lapTOffOn_trn,~,stat.lapTOffOn_trn] = signrank(exptT.lapTOff_trn,exptT.lapTOn_trn);
% [p.lapTOffOn_tst,~,stat.lapTOffOn_tst] = signrank(exptT.lapTOff_tst,exptT.lapTOn_tst);
[ps.lapTOffOn_trn,~,stats.lapTOffOn_trn] = signrank(mLpTOff_trn,mLpTOn_trn);
[ps.lapTOffOn_tst,~,stats.lapTOffOn_tst] = signrank(mLpTOff_tst,mLpTOn_tst);
[ps.normLpTOn_trn,~,stats.normLpTOn_trn] = signrank(normLpTOn_trn-1);
[ps.normLpTOn_tst,~,stats.normLpTOn_tst] = signrank(normLpTOn_tst-1);
[rhos.dayVlapTOff_trn,ps.dayVlapTOff_trn] = corr(exptT.day,exptT.lapTOff_trn,'Type',corrType);
[rhos.dayVlapTOn_trn,ps.dayVlapTOn_trn] = corr(exptT.day,exptT.lapTOn_trn,'Type',corrType);
[rhos.dayVlapTOff_tst,ps.dayVlapTOff_tst] = corr(exptT.day,exptT.lapTOff_tst,'Type',corrType);
[rhos.dayVlapTOn_tst,ps.dayVlapTOn_tst] = corr(exptT.day,exptT.lapTOn_tst,'Type',corrType);

%Average time to start box (s)
mT2BOff_trn = mean(reshape(exptT.tm2boxOff_trn,5,nMice)); mT2BOn_trn = mean(reshape(exptT.tm2boxOn_trn,5,nMice));
mT2BOff_tst = mean(reshape(exptT.tm2boxOff_tst,5,nMice)); mT2BOn_tst = mean(reshape(exptT.tm2boxOn_tst,5,nMice));
normT2BOff_trn = exptT.tm2boxOff_trn./exptT.tm2boxOff_trn; normT2BOff_tst = exptT.tm2boxOff_tst./exptT.tm2boxOff_tst; 
normT2BOn_trn = exptT.tm2boxOn_trn./exptT.tm2boxOff_trn; normT2BOn_tst = exptT.tm2boxOn_tst./exptT.tm2boxOff_tst; 
% [p.tm2boxOffOn_trn,~,stat.tm2boxOffOn_trn] = signrank(exptT.tm2boxOff_trn,exptT.tm2boxOn_trn);
% [p.tm2boxOffOn_tst,~,stat.tm2boxOffOn_tst] = signrank(exptT.tm2boxOff_tst,exptT.tm2boxOn_tst);
[ps.tm2boxOffOn_trn,~,stats.tm2boxOffOn_trn] = signrank(mT2BOff_trn,mT2BOn_trn);
[ps.tm2boxOffOn_tst,~,stats.tm2boxOffOn_tst] = signrank(mT2BOff_tst,mT2BOn_tst);
[ps.normT2BOn_trn,~,stats.normT2BOn_trn] = signrank(normT2BOn_trn-1);
[ps.normT2BOn_tst,~,stats.normT2BOn_tst] = signrank(normT2BOn_tst-1);
[rhos.dayVtm2boxOff_trn,ps.dayVtm2boxOff_trn] = corr(exptT.day,exptT.tm2boxOff_trn,'Type',corrType);
[rhos.dayVtm2boxOn_trn,ps.dayVtm2boxOn_trn] = corr(exptT.day,exptT.tm2boxOn_trn,'Type',corrType);
[rhos.dayVtm2boxOff_tst,ps.dayVtm2boxOff_tst] = corr(exptT.day,exptT.tm2boxOff_tst,'Type',corrType);
[rhos.dayVtm2boxOn_tst,ps.dayVtm2boxOn_tst] = corr(exptT.day,exptT.tm2boxOn_tst,'Type',corrType);

%Choice point occupancy (probability)
mBOcOff_trn = mean(reshape(exptT.chcOccOff_trn,5,nMice)); mBOcOn_trn = mean(reshape(exptT.chcOccOn_trn,5,nMice));
mBOcOff_tst = mean(reshape(exptT.chcOccOff_tst,5,nMice)); mBOcOn_tst = mean(reshape(exptT.chcOccOn_tst,5,nMice));
normBOcOff_trn = exptT.chcOccOff_trn./exptT.chcOccOff_trn; normBOcOff_tst = exptT.chcOccOff_tst./exptT.chcOccOff_tst; 
normBOcOn_trn = exptT.chcOccOn_trn./exptT.chcOccOff_trn; normBOcOn_tst = exptT.chcOccOn_tst./exptT.chcOccOff_tst; 
% [p.chcOccOffOn_trn,~,stat.chcOccOffOn_trn] = signrank(exptT.chcOccOff_trn,exptT.chcOccOn_trn);
% [p.chcOccOffOn_tst,~,stat.chcOccOffOn_tst] = signrank(exptT.chcOccOff_tst,exptT.chcOccOn_tst);
[ps.chcOccOffOn_trn,~,stats.chcOccOffOn_trn] = signrank(mBOcOff_trn,mBOcOn_trn);
[ps.chcOccOffOn_tst,~,stats.chcOccOffOn_tst] = signrank(mBOcOff_tst,mBOcOn_tst);
[ps.normBOcOn_trn,~,stats.normBOcOn_trn] = signrank(normBOcOn_trn-1);
[ps.normBOcOn_tst,~,stats.normBOcOn_tst] = signrank(normBOcOn_tst-1);
[rhos.dayVchcOccOff_trn,ps.dayVchcOccOff_trn] = corr(exptT.day,exptT.chcOccOff_trn,'Type',corrType);
[rhos.dayVchcOccOn_trn,ps.dayVchcOccOn_trn] = corr(exptT.day,exptT.chcOccOn_trn,'Type',corrType);
[rhos.dayVchcOccOff_tst,ps.dayVchcOccOff_tst] = corr(exptT.day,exptT.chcOccOff_tst,'Type',corrType);
[rhos.dayVchcOccOn_tst,ps.dayVchcOccOn_tst] = corr(exptT.day,exptT.chcOccOn_tst,'Type',corrType);

%Average # pulses (correlations) vs days and accuracy
[rhos.dayVpulse,ps.dayVpulse] = corr(exptT.day,exptT.muPulses,'Type',corrType);
[rhos.pulsesVonAcc,ps.pulsesVonAcc] = corr(exptT.muPulses,exptT.onAcc,'Type',corrType);
[rhos.pulsesVtotAcc,ps.pulsesVtotAcc] = corr(exptT.muPulses,exptT.totAcc,'Type',corrType);

if saveFlag == 1
    save([plotDir,saveBase,'_stats'],'ps','rhos','stats');
end
%% Plot general accuracy using plot_cohort_etc functions

tagSide = 'OBC';    %Use string for OBC
spath = [plotDir,'OBCC_cohort01-06'];

rawAccCohort = [spath,'_grossCohort_Acc'];
[rawGrossCohortFig,kw_ps,kw_tbl,multcomps_tbl] = plot_cohort_grossStimAcc(bhvrTabs,rawAccCohort);
% save([rawAccCohort,'_kw_stats'],'kw_ps','kw_tbl','multcomps_tbl');

deltaLRCohort = strcat(spath,'_deltaLRCohort_Acc');
[deltaLRCohortFig,wilcPs,wilcStats] = plot_cohort_deltaLR(bhvrTabs,deltaLRCohort,tagSide);
% save([deltaLRCohort,'_wilcPs'],'wilcPs','wilcStats');

onoffDays = strcat(spath,'_onoffOverDays');
[onoffDaysFig,r_corrs,r_ps] = plot_cohort_onoffDays(bhvrTabs,onoffDays);
% save([onoffDays,'_r_corrs'],'r_corrs','r_ps');

accDeltaDays = strcat(mouseGrp,'_deltaXdays');
[accDeltaDaysFig,stats,ps] = plot_cohort_accdeltaXdays(combineT,accDeltaDays,ps,stats);

%% Plot mean fine-grain behavior bar graphs

fig_vel_mean = plot_obc_means(exptT.velOff_trn,exptT.velOn_trn,exptT.velOff_tst,exptT.velOn_tst,0);
ylabel('Velocity (cm/s)')
fig_vel_norm = plot_obc_means(normVelOff_trn,normVelOn_trn,normVelOff_tst,normVelOn_tst,0);
ylabel('Velocity (% of Off)')

fig_dst_mean = plot_obc_means(exptT.dstOff_trn,exptT.dstOn_trn,exptT.dstOff_tst,exptT.dstOn_tst,0);
ylabel('Distance (cm)')
fig_dst_norm = plot_obc_means(normDstOff_trn,normDstOn_trn,normDstOff_tst,normDstOn_tst,0);
ylabel('Distance (% of Off)')

fig_lpt_mean = plot_obc_means(exptT.lapTOff_trn,exptT.lapTOn_trn,exptT.lapTOff_tst,exptT.lapTOn_tst,0);
ylabel('Lap Time (s)')
fig_LpT_norm = plot_obc_means(normLpTOff_trn,normLpTOn_trn,normLpTOff_tst,normLpTOn_tst,0);
ylabel('Lap Time (% of Off)')

fig_t2b_mean = plot_obc_means(exptT.tm2boxOff_trn,exptT.tm2boxOn_trn,exptT.tm2boxOff_tst,exptT.tm2boxOn_tst,0);
ylabel('Time to Choice Point (s)')
fig_t2b_norm = plot_obc_means(normT2BOff_trn,normT2BOn_trn,normT2BOff_tst,normT2BOn_tst,0);
ylabel('Time to Choice Point (% of Off)')

fig_boc_mean = plot_obc_means(exptT.chcOccOff_trn,exptT.chcOccOn_trn,exptT.chcOccOff_tst,exptT.chcOccOn_tst,0);
ylabel('Choice Point Occupancy (%)')
fig_boc_norm = plot_obc_means(normBOcOff_trn,normBOcOn_trn,normBOcOff_tst,normBOcOn_tst,0);
ylabel('Choice Point Occupancy (% of Off)')

if saveFlag == 1
    saveFigTypes(fig_vel_mean,[plotDir,'Velocity_Mean_TrainTest'])
    saveFigTypes(fig_dst_mean,[plotDir,'Distance_Mean_TrainTest'])
    saveFigTypes(fig_lpt_mean,[plotDir,'LapTime_Mean_TrainTest'])
    saveFigTypes(fig_t2b_mean,[plotDir,'Time2Choice_Mean_TrainTest'])
    saveFigTypes(fig_boc_mean,[plotDir,'ChoiceOcc_Mean_TrainTest'])
    saveFigTypes(fig_vel_norm,[plotDir,'Velocity_Norm_TrainTest'])
    saveFigTypes(fig_dst_norm,[plotDir,'Distance_Norm_TrainTest'])
    saveFigTypes(fig_LpT_norm,[plotDir,'LapTime_Norm_TrainTest'])
    saveFigTypes(fig_t2b_norm,[plotDir,'Time2Choice_Norm_TrainTest'])
    saveFigTypes(fig_boc_norm,[plotDir,'ChoiceOcc_Norm_TrainTest'])
    close all
end 

%% Plot Correlation Comparisons

fig_vel_trn = plot_obc_corr(exptT.day,exptT.velOff_trn,exptT.velOn_trn,0);
ylabel('Train Velocity (cm/s)'); ylim([0 16])
legCell = {'Mean Off','Mean On'};
legend(legCell,'FontSize',16,'Location','se');

fig_vel_tst = plot_obc_corr(exptT.day,exptT.velOff_tst,exptT.velOn_tst,0);
ylabel('Test Velocity (cm/s)'); ylim([0 16])

fig_dst_trn = plot_obc_corr(exptT.day,exptT.dstOff_trn,exptT.dstOn_trn,0);
ylabel('Train Distance (cm)'); ylim([250 650])

fig_dst_tst = plot_obc_corr(exptT.day,exptT.dstOff_tst,exptT.dstOn_tst,0);
ylabel('Test Distance (cm)'); ylim([250 650])

fig_lpt_trn = plot_obc_corr(exptT.day,exptT.lapTOff_trn,exptT.lapTOn_trn,0);
ylabel('Train Lap Time (s)'); ylim([20 70])

fig_lpt_tst = plot_obc_corr(exptT.day,exptT.lapTOff_tst,exptT.lapTOn_tst,0);
ylabel('Test Lap Time (s)'); ylim([20 70])

fig_t2b_trn = plot_obc_corr(exptT.day,exptT.tm2boxOff_trn,exptT.tm2boxOn_trn,0);
ylabel('Train Time to Choice Pt (s)'); ylim([0 35])

fig_t2b_tst = plot_obc_corr(exptT.day,exptT.tm2boxOff_tst,exptT.tm2boxOn_tst,0);
ylabel('Test Time to Choice Pt (s)'); ylim([0 35])

fig_boc_trn = plot_obc_corr(exptT.day,exptT.chcOccOff_trn,exptT.chcOccOn_trn,0);
ylabel('Train Choice Pt Occupancy (%)'); ylim([0 15])

fig_boc_tst = plot_obc_corr(exptT.day,exptT.chcOccOff_tst,exptT.chcOccOn_tst,0);
ylabel('Test Choice Pt Occupancy (%)'); ylim([0 15])

if saveFlag == 1
    saveFigTypes(fig_vel_trn,[plotDir,'Velocity_Corr_Train'])
    saveFigTypes(fig_vel_tst,[plotDir,'Velocity_Corr_Test'])
    saveFigTypes(fig_dst_trn,[plotDir,'Distance_Corr_Train'])
    saveFigTypes(fig_dst_tst,[plotDir,'Distance_Corr_Test'])
    saveFigTypes(fig_lpt_trn,[plotDir,'LapTime_Corr_Train'])
    saveFigTypes(fig_lpt_tst,[plotDir,'LapTime_Corr_Test'])
    saveFigTypes(fig_t2b_trn,[plotDir,'Time2Choice_Corr_Train'])
    saveFigTypes(fig_t2b_tst,[plotDir,'Time2Choice_Corr_Test'])
    saveFigTypes(fig_boc_trn,[plotDir,'ChoiceOcc_Corr_Train'])
    saveFigTypes(fig_boc_tst,[plotDir,'ChoiceOcc_Corr_Test'])
    close all
end

%% Pulses separately

% Days Vs pulses
nMice = length(exptT.day)/5;
xs = reshape(exptT.day,5,nMice);
pulse_ys = reshape(exptT.muPulses,5,nMice);
mu_pulse = mean(pulse_ys,2);
fig_muPulse_trn = figure; hold on; axis square
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.25,0.45]);
plot(xs(:,1),mu_pulse,'Color',[0.5 0.5 1],'LineWidth',3);
plot(xs,pulse_ys,'Color',[0.5 0.5 1]);
xticks(1:5)
xlabel('Day');     %Relative to sample phase i.e. accuracy during test after left samples no stim
xlim([0.5 5.5]);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);
ylabel('Train Phase Pulses (n)')

% Pulses vs Accuracy
mdl_pulseVAcc = fitlm(exptT.muPulses,exptT.onAcc);
plsAcc_xs = [min(exptT.muPulses); max(exptT.muPulses)];
plsAcc_ys = predict(mdl_pulseVAcc,plsAcc_xs);

fig_pulseVacc = figure; hold on; axis square
plot(plsAcc_xs,plsAcc_ys,'k--')
plot(exptT.muPulses,exptT.onAcc,'o','Color',[0.5 0.5 1]);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.35,0.475,0.25,0.45]);
set(gca,'FontSize',15,'FontName','Times','LabelFontSizeMultiplier', 1.33);
xlabel('Train Phase Pulses (n)')
ylabel('Mean On Accuracy (%)')
legend('Linear Fit','Sessions')
ylim([0 1])

if saveFlag == 1
    saveFigTypes(fig_muPulse_trn,[plotDir,'muPulses_Train'])
    saveFigTypes(fig_pulseVacc,[plotDir,'pulsesVonAcc'])
    close all
end

%%
function [vout] = qckrshp(vin)
nmice = length(vin)/5;
vout = mean(reshape(vin,5,nmice));
end







