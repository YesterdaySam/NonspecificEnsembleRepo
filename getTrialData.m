function [rawLapDat,sumLapDat] = getTrialData(root,lapMat,optoTS,lapBuffer)
% Gets data for DNMP trials and returns raw data and summary type data
% 8/1/2022 LKW
% Inputs:
% root = CMBHome root object
% lapMat = table formatted XL data including lap start/stop times (e.g. 2.43 min.sec)
% optoTS = time of opto peaks found by getOptoTS2.m
% lapBuffer = integer. Seconds to pad out laps on either side of start/stop
% Outputs: 
% rawLapDat = struct containing info on each lap: trial #, lap #, 
% type (train = 0, test = 1), spatially_scaled x and y data, timestamps, 
% opto pulse timestamps and opto presence (if over 100 pulses)
% sumLapDat = table with following info on each lap: trial #, lap #, lap
% type (train = 0, test = 1), mean velocity (cm/s), total distance traveled
% (cm), lap length (sec), opto pulses (n), opto presence (if over 100
% pulses), time from lap start to choice pt, and normalized choice pt occupancy

nLaps = size(lapMat,1);

varTypes = {'double','double','double','double','double','double','double','double','double','double'};
varNames = {'trial_N','lap_N','lap_type','opto_type','muVel','dTrav','lap_len','nPulses','tm2box','probInBox'};
sumLapDat = table('Size',[nLaps length(varTypes)],'VariableTypes',varTypes,'VariableNames',varNames);

startTS = time2secs(lapMat.lap_start)-lapBuffer;
stopTS = time2secs(lapMat.lap_end)+lapBuffer;

% Calculate choice point box
[~,tmpY] = kmeans(root.sy,5,'Replicates',2);
[~,tmpX] = kmeans(root.sx,5,'Replicates',2);
boxWidth = 10;
tmpY = mean([max(tmpY),min(tmpY)]);
tmpX = min(tmpX);
tmp_y1 = tmpY - boxWidth;
tmp_y2 = tmpY + boxWidth;
tmpBox_yv = [tmp_y1 tmp_y1 tmp_y2 tmp_y2 tmp_y1];
tmp_x1 = tmpX - boxWidth;
tmp_x2 = tmpX + boxWidth;
tmpBox_xv = [tmp_x1 tmp_x2 tmp_x2 tmp_x1 tmp_x1];

figure;
plot(root.sx,root.sy);
hold on
plot(tmpBox_xv,tmpBox_yv)

saveas(gcf,'choice_box.png')
close(gcf)

for i = 1:nLaps
    % Ensure epochs +/- buffer fall within the recording session
    if startTS(i) < 0
        warning(['Lap ', num2str(i), ' start time less than 0, using 0 instead'])
        startTS(i) = 0;
    end
    if stopTS(i) > root.b_ts(end) 
        warning(['Lap ', num2str(i), ' stop time exceeds max ts, using max ts instead'])
        stopTS(i) = root.b_ts(end);
    end
        
    root.epoch = [startTS(i) stopTS(i)];
        
    % Find basic trial, lap, type, x/y, velocity, distance, ts data
    rawLapDat(i).trial = lapMat.trial_N(i);
    rawLapDat(i).lap = lapMat.lap_N(i);
    rawLapDat(i).type = double(mod(i,2) == 0);
    sumLapDat.trial_N(i) = lapMat.trial_N(i);
    sumLapDat.lap_N(i) = lapMat.lap_N(i);
    sumLapDat.lap_type(i) = mod(i,2) == 0;
    rawLapDat(i).x = root.sx;
    rawLapDat(i).y = root.sy;
    sumLapDat.muVel(i) = nanmean(root.svel);
    sumLapDat.dTrav(i) = nansum(sqrt(diff(root.sx).^2 + diff(root.sy).^2));
    rawLapDat(i).ts = root.ts;
    sumLapDat.lap_len(i) = root.epoch(end) - root.epoch(1);
    
    % Find Opto Info
    if ~isempty(optoTS)
        rawLapDat(i).optoPulses = find(optoTS > startTS(i) & optoTS < stopTS(i));
    else
        rawLapDat(i).optoPulses = [];
    end
    sumLapDat.nPulses(i) = numel(rawLapDat(i).optoPulses);
    
    if sumLapDat.nPulses(i) > 100
        sumLapDat.opto_type(i) = 1;
        rawLapDat(i).optoType = 1; 
    else
        sumLapDat.opto_type(i) = 0;
        rawLapDat(i).optoType = 0;
    end
    
    % Find choice occupancy data
    tmp_in = inpolygon(root.sx,root.sy,tmpBox_xv,tmpBox_yv);
%     disp(i)
    sumLapDat.tm2box(i) = root.ts(find(tmp_in == 1,1,'first')) - startTS(i) - lapBuffer;
    sumLapDat.probInBox(i) = 100*sum(double(tmp_in))./numel(root.ts);
end

end