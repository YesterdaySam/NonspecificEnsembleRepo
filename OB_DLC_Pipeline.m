%%% OB_Pipeline
% LKW 6/16/21
% Based largely on trodes2MatlabPipeline.m
% Requires CMBHome
% Before running: have all files from Trodes session in one folder

%% Imports and Paths
addpath(genpath('C:\Users\cornu\Trodes_2-2-3_Windows64'))
addpath('G:\Shared drives\HasselmoUsers\lwilmerd\Code')
addpath('G:\Shared drives\HasselmoUsers\lwilmerd\Code\OB_project_code\')
% addpath 'D:\Research\Code'
addpath(genpath('C:\Users\cornu\Documents\GitHub\CMBHOME'))
addpath('G:\Shared drives\HasselmoUsers\wchapman\Projects\other\kelton') %For updated importTrode.m file

% ## Main Directory Containing list of Trodes Output Recording Folders
% parentDir = 'D:\Research\Data\Pre-Processing\OBC1';
parentDir = 'G:\Shared drives\HasselmoUsers\lwilmerd\MindMazeProject\MMFT7';
%% Download Cloud Data to Local
% Does not overwrite existing folders -- in case of analysis already done
% in the local copies

cloudDir = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\OBC1';
localDir = 'D:\Research\Data\Pre-Processing\OBC1';
recFolders = dir(cloudDir); tmp = [recFolders.isdir]; recFolders = recFolders(tmp); clear tmp
for i = 3:numel(recFolders)
    cloudDirTmp = fullfile(cloudDir, recFolders(i).name);
    localDirTmp = fullfile(localDir, recFolders(i).name);
    cd(localDir)
    if ~exist(localDirTmp,'dir')
        disp(['Copying files for ',recFolders(i).name, ' from Hasselmo Team Drive to local']);
% %         copyfile(cloudDirTmp,fullfile(localDir,recFolders(i).name))
    else
        disp(['Local copy of ',recFolders(i).name, ' already exists at ', localDir]);
    end
end

%% Create MP4s
% WIP -- should automatically create .mp4 video using ffmpeg and then send
% to DLC trained network for analysis and labeling, creating CSV style
% output and labeled .mp4 file in a folder titled 'filename.dlcout'

parentDir = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\OBC Group\OBC24';
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
            command = ['ffmpeg -i "', vh264, '" "', vmp4, '"']; %Need double quotes for paths with spaces
            system(command,'-echo');
        end
    else
        disp(['Already tried mp4 preprocessing of ',recFolders(i).name]);
    end
end

%% Run DLC Analysis (Batch Files)

% Open Anaconda Prompt and run 
% Run in terminal: 
cd C:\Users\cornu\Desktop\DeepLabCut
conda activate dlc-windowsGPU
python dlc_abbrv_script.py
% This assumes a trained DLC algorithm 
% Must set up names and definitions in the dlc_abbrv_script.py file

%% Import to CMBHome (Batch files)
% Relies on importTrode.m function by Bill Chapman (see CMBHome on Github
% and make sure 'G:\Shared drives\HasselmoUsers\wchapman\Projects\other\kelton'
% is on path
%Requires a working epochTable Excel sheet for the cohort

parentDir = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\OBC Group';

cd(parentDir);
mouseFolders = dir(parentDir); tmp = [mouseFolders.isdir]; mouseFolders = mouseFolders(tmp); clear tmp
% epochTable = dir('*epochtimes.xlsx'); epochTable = readtable(fullfile(epochTable(1).folder, epochTable(1).name));
ct = 0; 
for j = 19:19 %numel(mouseFolders)    %Cohort
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
            rootStruct = dir('CMBH*');
            load(rootStruct.name); clear rootStruct
            disp('root loaded')
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
%         if exist('root','var')
%             ct = ct+1;
%             root.epoch = [str2num(epochTable.start_time{ct}) str2num(epochTable.end_time{ct})];
%             try
%                optoStruc = dir('*optoTS*');
%                load(optoStruc.name); clear optoStruc
%                disp('opto TS loaded')
%             catch
%                 optoTS = getOptoTS2(subDirTmp);
%                 save(strcat(sname,'_optoTS'),'optoTS');
%             end
%             if ~isempty(optoTS)     %Ignore tag/training days
%                 [optoBlocks,offBlocks] = getBlockTS(root, optoTS);
%                 save(strcat(sname,'_optoBlocks'),'optoBlocks','offBlocks');
%             end
%             r_loop = logical(epochTable.right_T(ct));
%             trialBlocks = getTrialBlocks(root,subDirTmp,epochTable.maze_type(ct),r_loop);     %Assumes Mako G-131c camera 1024 x 1280 pixels
%             save(strcat(sname,'_trialBlocks'),'trialBlocks');
%         end
    end
end

%% Manually check and add/remove laps
tr2Add = [10.20,10.37];
tr2Del = [15];
sname = 'OBC1_20210502_134155_tag_trialBlocks';
trialBlocks = addTrials(root,trialBlocks,tr2Add,sname);
trialBlocks = delTrials(trialBlocks,tr2Del,sname);

%% Create Spatial Occupancy Maps
parentDir = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoBehaviorProject\OBC Group';

cd(parentDir);
mouseFolders = dir(parentDir); tmp = [mouseFolders.isdir]; mouseFolders = mouseFolders(tmp); clear tmp

for i = 3:6 %numel(mouseFolders)
    mouseDirTmp = fullfile(parentDir, mouseFolders(i).name);
    cd(mouseDirTmp)
    recFolders = dir(mouseDirTmp); tmp = [recFolders.isdir]; recFolders = recFolders(tmp); clear tmp
    for j = 3:numel(recFolders)
        subDirTmp = fullfile(mouseDirTmp, recFolders(j).name);
        cd(subDirTmp)
        
        if subDirTmp(end-2:end) == 'rec'    %Correct for trodes 2.1 name scheme
            sname = recFolders(j).name(1:end-4);
        else
            sname = recFolders(j).name;
        end
        
        if ~isempty(dir('CMBH*')) && ~isempty(dir('*_trialBlocks.mat')) && isempty(dir('*.spOcc'))
            rootStruct = dir('CMBH*');
            load(rootStruct.name); clear rootStruct
            disp(['root loaded for ', sname])
            disp(['Beginning to create spatial occupancy maps for ',recFolders(i).name])
            trialName = dir('*_trialBlocks.mat');
            load(trialName.name); clear trialName   %Loads in trialBlocks var
            if epochTable.open_field(j-2) == 0  %For DNMP Maze Only
                warning('off','all')
                spOcc_sess = getSpOcc(root,4);  %Bin size 2cm
                spOcc_trials = getSpOcc_trials(root,trialBlocks,4);
                warning('on','all')
                mkdir(strcat(sname,'.spOcc'));
                spOccDir = dir('*.spOcc'); cd(spOccDir.name);
                save(strcat(recFolders(j).name,'_spOcc_vars'),'spOcc_sess','spOcc_trials');
                plot_spOcc(spOcc_sess,strcat(sname,'_spOcc_sess'));
                for k = 1:size(trialBlocks,1)
                    plot_spOcc(spOcc_trials(k).trOcc,[sname,'_spOcc_lap_',num2str(k)]);
                end
            else
                spOcc_sess = root.sOccupancy;
                plot_spOcc(spOcc_sess,strcat(sname,'_spOcc_sess'));
            end
            cd(subDirTmp)

        end
        
    end
end

%% Upload Local data to Cloud
cloudDir = 'G:\Shared drives\HasselmoUsers\lwilmerd\OptoEphysProject\OB3';
localDir = 'D:\Research\Data\Pre-Processing\OB3';
recFolders = dir(localDir); tmp = [recFolders.isdir]; recFolders = recFolders(tmp); clear tmp
for i = 3:numel(recFolders)
    localDirTmp = fullfile(localDir, recFolders(i).name);
    cd(cloudDir)
    disp(['Copying files for ',recFolders(i).name, ' from local to Hasselmo Team Drive']);
    copyfile(localDirTmp,fullfile(cloudDir,recFolders(i).name))
end



