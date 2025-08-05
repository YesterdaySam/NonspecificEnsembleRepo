function [sessionList,tagSide] = createBhvrSessions(xlFile,saveDir,sessSave)
% 5/11/2021 LKW
%Inputs:
%   xlFile = xlsx file with columns recFolderName, sessionID, context,
%   optoType, optoFreq, bhvrSeq, optoSeq, wt
%   Rows of table must be single sessions
%   saveDir = string of directory path to output location for session vars
%
%Behavior Binary vector of alternation choices. R = 0; L = 1.
%Outputs:
%   Cell of strings, each identifying the name of a saved session table

if ~exist('calcBhvr')
    addpath('F:\Research\Code\OB_project')
end

datTable = readtable(xlFile);
parentDir = pwd;
cd(saveDir);

for i = 1:height(datTable)
    clear session
    %Read in Table info
    session.recName     = datTable.recFolderName{i};
    session.sessionType = datTable.sessionID{i};
    session.ctxt        = datTable.context{i};
    session.optoType    = datTable.optoType{i};
    session.optoFreq    = datTable.optoFreq(i);
    session.smplSeq     = datTable.smplSeq{i};
    session.testSeq     = datTable.testSeq{i};
    if iscell(datTable.optoSeq); session.optoSeq = datTable.optoSeq{i}; 
    else;                        session.optoSeq = zeros(1,length(session.smplSeq)); end
    
    session.wt          = datTable.wt(i);
    session.tagSide     = datTable.tagSide(1);
    if iscell(session.tagSide); session.tagSide = session.tagSide{:}; end
        
    %Calculate behavior and opto sequences
    if ~isempty(session.smplSeq)
        session         = calcBhvr(session);
        session         = calcOpto(session);
    end
    if length(session.smplSeq) == length(session.optoSeq)
        session.optoBhvrMatch = 1;
    else
        session.optoBhvrMatch = 0;
    end
    
    sName = ['session_', session.recName()];
    save(sName,'session');
    sessionList{i} = sName;
    tagSide = session.tagSide;
end

save(sessSave,'sessionList');

cd(parentDir)

end