function [animalBhvrT] = getExpmtBhvr(sessDir,fileCell,sName)
% 3/2/2021 LKW
%Inputs: 
%   sessDir = string to directory of data files
%   fileCell = 1xN cell of strings, each a name to a session data file i.e.
%   'session_OE2_20200706_1.mat'
%   sName = name of file to be saved containing output table
%   Ignores sessions where behavior tally and opto tally mismatch
%   tagSide = side of engram tag 0 = Right; 1 = Left
%Outputs: 
%   A table with 1 row/session, and the following columns:
%   sessionID = string name of session
%   stimType = string name of stimulation frequency/shape
%   totAcc = mean accuracy of the animal's behavior across the whole session
%   totSeq = a vector of binarized behavior across the whole session -1
%   baseAcc = mean accuracy of the first 5 trials
%   baseSeq = a vector of binarized behavior from the first 5 trials -1
%   offAcc = mean accuracy of all trials without stim
%   offSeq = vector of binarized behavior score from no-stim trials
%   onAcc = mean accuracy of the behavior on stim trials
%   onSeq = vector of binarized behavior from stim trials
%   on+1Acc = mean accuracy of behavior on the trials following stim
%   on+1Seq = vector of binarized behavior from trials following sitm
%   nTrials = all counted trials (ignores first)


parentDir = pwd;
cd(sessDir);
sz = [length(fileCell),12];
varTypes = {'string','string','double','double','double','double','double','double','double','double','double','double'};
varNames = {'sessionID','stimType','totAcc','baseAcc','offAcc','totOffAcc','onAcc','leftOffAcc','rightOffAcc','matchAcc','misMatchAcc','nTrials'};
animalBhvrT = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);

for i = 1:length(fileCell)
    clear tmp bhvrtmp tmpOpto tmpBhvr;
    load(fileCell{i});
    %Look only at DNMP sessions with matching bhvr and opto
%     if length(session.bhvrScore) < 5; continue; end     %Ignore super short sessions
    
    if session.optoType(1:4) == 'None'
        tagSide                     = session.tagSide;
        animalBhvrT.sessionID(i)    = session.recName;
        animalBhvrT.stimType(i)     = session.sessionType;
        animalBhvrT.nTrials(i)      = session.trials;
        
        animalBhvrT.totAcc(i)       = session.accuracy;                        %Whole session accuracy
        if length(session.bhvrScore) < 5
            animalBhvrT.baseAcc(i)  = mean(session.bhvrScore);
        else
        animalBhvrT.baseAcc(i)      = mean(session.bhvrScore(1:5));             %Baseline 5 trials accuracy
        end
        animalBhvrT.offAcc(i)       = session.accuracy;                         %Whole session accuracy
        animalBhvrT.totOffAcc(i)    = session.accuracy;                         %Whole session accuracy
        leftSampInds                = session.testBinary == 1;                  %Left sample phases
        rightSampInds               = session.testBinary == 0;                  %Right sample phases
        animalBhvrT.leftOffAcc(i)   = mean(session.bhvrScore(leftSampInds));    %Right test phases accuracy
        animalBhvrT.rightOffAcc(i)  = mean(session.bhvrScore(rightSampInds));   %Test test phases accuracy

elseif session.optoBhvrMatch == 1
        tagSide                     = session.tagSide;
        animalBhvrT.sessionID(i)    = session.recName;
        animalBhvrT.stimType(i)     = session.sessionType;
        animalBhvrT.nTrials(i)      = session.trials;

        animalBhvrT.totAcc(i)       = session.accuracy;             %Whole session accuracy
        animalBhvrT.baseAcc(i)      = mean(session.bhvrScore(1:5)); %Baseline 5 trials accuracy
        
        tmpOpto                     = session.optoSeq(6:end);
        tmpBhvr                     = session.bhvrScore(6:end);
        tmp                         = tmpBhvr(tmpOpto == 0);
        animalBhvrT.offAcc(i)       = mean(tmp);                    %Off trials after baseline accuracy

        tmp                         = session.bhvrScore(session.optoSeq == 0);
        animalBhvrT.totOffAcc(i)    = mean(tmp);                    %All off trials including baseline accuracy
        
        tmp                         = session.optoSeq == 1;
        animalBhvrT.onAcc(i)        = mean(session.bhvrScore(tmp)); %All stim trials accuracy
                
        if tagSide == 1
            stimMatchInds               = (session.smplBinary + session.optoSeq) == 2;              %Sample phase with match-side stim
            stimMisMatchInds            = logical(session.optoSeq - stimMatchInds);                 %Sample phase with mis-match-side stim
            leftSampInds                = logical((session.smplBinary == 1) - stimMatchInds);       %Left sample phases no stim
            rightSampInds               = logical((session.smplBinary == 0) - stimMisMatchInds);    %Right sample phases no stim
            animalBhvrT.leftOffAcc(i)   = mean(session.bhvrScore(leftSampInds));                    %Left test phases no stim accuracy
            animalBhvrT.rightOffAcc(i)  = mean(session.bhvrScore(rightSampInds));                   %Right test phases no stim accuracy
            animalBhvrT.matchAcc(i)     = mean(session.bhvrScore(stimMatchInds));                   %Stim Left Match test accuracy
            animalBhvrT.misMatchAcc(i)  = mean(session.bhvrScore(stimMisMatchInds));                %Stim Right Mis-match test accuracy
        elseif tagSide == 0
            stimMatchInds               = (session.optoSeq - session.smplBinary) == 1;              %Sample phase with match-side stim
            stimMisMatchInds            = logical(session.optoSeq - stimMatchInds);                 %Sample phase with mis-match-side stim
            leftSampInds                = logical((session.smplBinary == 1) - stimMisMatchInds);    %Left sample phases no stim
            rightSampInds               = logical((session.smplBinary == 0) - stimMatchInds);       %Right sample phases no stim
            animalBhvrT.leftOffAcc(i)   = mean(session.bhvrScore(leftSampInds));                    %Left test phases no stim accuracy
            animalBhvrT.rightOffAcc(i)  = mean(session.bhvrScore(rightSampInds));                   %Right test phases no stim accuracy
            animalBhvrT.matchAcc(i)     = mean(session.bhvrScore(stimMatchInds));                   %Stim Right Match accuracy
            animalBhvrT.misMatchAcc(i)  = mean(session.bhvrScore(stimMisMatchInds));                %Stim Left Mis-match accuracy
        elseif tagSide(1:3) == 'OBC'
            leftOnInds                  = (session.smplBinary + session.optoSeq) == 2;                                           %Sample phase with left-side stim
            rightOnInds                 = logical(session.optoSeq - leftOnInds);                    %Sample phase with right-side stim
            leftOffInds                 = logical((session.smplBinary == 1) - leftOnInds);          %Left sample phases no stim
            rightoffInds                = logical((session.smplBinary == 0) - rightOnInds);         %Right sample phases no stim
            animalBhvrT.leftOffAcc(i)   = mean(session.bhvrScore(leftOffInds));                     %Left test phases no stim accuracy
            animalBhvrT.rightOffAcc(i)  = mean(session.bhvrScore(rightoffInds));                    %Right test phases no stim accuracy
            animalBhvrT.leftOnAcc(i)    = mean(session.bhvrScore(leftOnInds));                      %Stim Left Match test accuracy
            animalBhvrT.rightOnAcc(i)   = mean(session.bhvrScore(rightOnInds));                     %Stim Right Mis-match test accuracy
        end
    end
end

%Remove missing sessions
animalBhvrT = rmmissing(animalBhvrT,'DataVariables',@isstring);
if tagSide == 'OBC'; animalBhvrT.matchAcc = []; animalBhvrT.misMatchAcc = []; end
save(sName,'animalBhvrT');

cd(parentDir)
end