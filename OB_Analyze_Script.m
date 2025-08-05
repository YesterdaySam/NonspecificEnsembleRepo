%%% OB Analyze Script
% Runs all functions to analyze single animals and cohorts for OB Project
% Place all .xlsx files in mainPath directory
% LKW 2/25/2022

addpath('G:\Shared drives\HasselmoUsers\lwilmerd\Code')
addpath('G:\Shared drives\HasselmoUsers\lwilmerd\Code\OB_project_code')
mainPath = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OBC_Analysis\';
cd(mainPath)

rerunSoloFlag = 0; 
rerunCohortFlag = 0;

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
% mouseInclude = [1 0 1 1 1 0 0 0 0];     %All OB mice
% mouseInclude = [1 0 1 1 1 0 0 0 0 0 0 0 0];     %OB cohort 3
% mouseInclude = [1 1 1 1]; %OB Test Phase and OBC seizure mice
% mouseInclude = [1 0 1 1 1 0 0 0 0 0 0]; %OB Train Phase
mouseInclude = [0 0 0 0 0 0 1 1 0 1 0 0 1 0 1 0 1 1 0]; %OBC 3,7,8,20,23
% mouseInclude = [1 1 1 1 1 1]; %OBCC all; or subset OB Train (n 6)
clear bhvrTabs

tagSide = 'OBC';    %Use string for OBC
% tagSide = [1 1 0 0];   %Vector; OBT = [1 1 0 0]; OB = 0 0 1 0 1 0; OBCSeizure = [1 0 0 1]
% mouseGrp = 'OBCC_Cohort01-06';
% mouseGrp = 'OBC_cohort_n7_reanalysis';
mouseGrp = 'OBC_hilus_cohort';

% Works for OBC animals only atm
% varTypes = {'string','double','double','double','double','double','double','double','double','double','double','double','double','double'};
% varNames = {'mouseID','totAcc','baseAcc','offAcc','totOffAcc','onAcc','leftOffAcc','rightOffAcc','nTrials','leftOnAcc','rightOnAcc','eyfp_ct','cfos_ct','OL_ct'};
% fullOBCT = table('Size',[sum(mouseInclude),numel(varTypes)],'VariableTypes',varTypes,'VariableNames',varNames);
%%%%%
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
%         fullOBCT.mouseID(ct) = mouse;
%         fullOBCT{ct,2:11} = nanmean(bhvrTabs(ct).animalBhvrT{end-4:end,3:end});
%         fullOBCT{ct,12:14} = randn(1,3)*20+300;
        ct = ct+1;
    end
end

cohortDir = fullfile(mainPath,mouseGrp);
save([cohortDir,'_bhvrTabs'],'bhvrTabs')
save([cohortDir,'_combineT'],'combineT')

%% Cohort-level accuracy analyses
load('OBC_hilus_cohort_combineT.mat')
% combineT([14 45 61],:) = []; %Remove OBC Seizure Cohort Last day for OBC10, 14, 9

cohortDir = fullfile(mainPath,mouseGrp);
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
%% Prepare table for OB speed/distance analysis

dataPath = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\OB_TestPhase';
mainPath = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\Analysis\OB_TestPhase';

cd(mainPath)
load('cohort_bhvrTabs.mat')
clear OB_Table

sz = [0 5];
varTypes = {'string','string','double','double','string'};
varNames = {'sessionID','cGrp','dTravel','muSpeed','day'};
bhvrT = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
cd(dataPath);
mouseFolders = dir(dataPath); tmp = [mouseFolders.isdir]; mouseFolders = mouseFolders(tmp); clear tmp
OB_Table = table;

for j = 3:numel(mouseFolders)
    mouseDirTmp = fullfile(dataPath,mouseFolders(j).name);
    cd(mouseDirTmp)
    disp(mouseFolders(j).name)
    tagInd = find(any(ismember(bhvrTabs(j-2).animalBhvrT.stimType,'tagging'),2)==1);
    OB_Table = [OB_Table; bhvrTabs(j-2).animalBhvrT(tagInd:end,:)];
    recFolders = dir(mouseDirTmp); tmp = [recFolders.isdir]; recFolders = recFolders(tmp); clear tmp
    for i = 3:numel(recFolders) %3 Skips first two '.' and '..' dirs
        subDirTmp = fullfile(mouseDirTmp, recFolders(i).name);
        cd(subDirTmp)
        disp(recFolders(i).name)
        if ~isempty(dir('CMBH*'))
            rootStruct = dir('CMBH*');
            load(rootStruct.name); clear rootStruct
            disp(['root loaded for ', recFolders(i).name])
        end
        mouse = recFolders(i).name(1:4);
        if mouse(1:3) == 'OBT'
            cGrp = 'OBT';
        elseif mouse(1:3) == 'OBC'
            cGrp = 'OBC';
        else
            cGrp = 'OB';
        end
        
        dTrav = nansum(sqrt(diff(root.sx).^2 + diff(root.sy).^2));
        muSp = mean(root.svel);
        
        bhvrT = [bhvrT; {recFolders(i).name,cGrp,dTrav,muSp,i-3}];
    end
end
cd(mainPath)

OB_fullbhvrT = [OB_Table, bhvrT(:,3:5)];
save('OB_fullbhvrT','OB_fullbhvrT')




