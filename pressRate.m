% calculate the press rate trial-by-trial

function pr = pressRate(trials)

numTrials = size(trials,1);
pr = nan(numTrials,1);
for i=1:numTrials
    currentTrial = trials(i,:);
    seqLen = length(currentTrial(~isnan(currentTrial)));
    if seqLen<3;continue;end
    % press rate = number of presses over duration of the trial
    pr(i) = seqLen/max(currentTrial,[],2, 'omitnan'); 
end
end
