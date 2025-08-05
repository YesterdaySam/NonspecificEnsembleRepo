function [session] = calcOpto(session)
    %Turns a single, multi-digit number to individual digits
%     if ischar(session.optoSeq{:}) || isempty(session.optoSeq)
    if 'NaN' == session.optoSeq(1:3) %|| isempty(session.optoSeq)
        session.optoSeq = zeros(1,numel(session.testSeq));
    else
        optoInt = str2double(regexp(num2str(session.optoSeq),'\d','match'));
        session.optoSeq = optoInt;
    end
end