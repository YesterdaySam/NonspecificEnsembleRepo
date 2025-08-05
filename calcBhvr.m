function [session] = calcBhvr(session)
    %Requires testSeq subfield of session struct to be filled first
    
    session.trials = numel(session.testSeq);
    session.smplBinary = 0;
    session.testBinary = 0;

    if 'NaN' == session.smplSeq(1:3)
        session.reps = numel(session.testSeq)-1;
        session.alts = 0;
        session.bhvrScore = zeros(1,numel(session.testSeq));
        session.accuracy = 0;
        return
    end
    
    %Create binary array of R turn = 0 and L turn = 1
    for i = 1:numel(session.smplSeq)
        %Read in Sample Phase
        if session.smplSeq(i) == 'R'
            session.smplBinary(i) = 0;
        elseif session.smplSeq(i) == 'L'
            session.smplBinary(i) = 1;
        else
            session.smplBinary(i) = NaN;
        end
        
        %Read in Test Phase
        if session.testSeq(i) == 'R'
            session.testBinary(i) = 0;
        elseif session.testSeq(i) == 'L'
            session.testBinary(i) = 1;
        else
            session.testBinary(i) = NaN;
        end

    end
    
    %Calculate Alternations
    session.alts = sum(abs(session.smplBinary - session.testBinary));
    session.reps = sum(session.smplBinary - session.testBinary == 0);
    session.bhvrScore = abs(session.smplBinary - session.testBinary);
    session.accuracy = session.alts / session.trials;
end
