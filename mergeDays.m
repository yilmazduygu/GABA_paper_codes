function mergedT = mergeDays(T, cond)

% make sure condition is categorical
T.condition = categorical(T.condition);
% find same type of sessions for each animal
g = findgroups(T.condition,T.animal);
% 1-10s are baseline, 11-20s are ll300, 21-30s are ll5
mergedT = table;
mergedT.animal = NaN;
mergedT.group = NaN;
mergedT.numPress = NaN;
mergedT.numReward = NaN;
mergedT.numLaser = NaN;
mergedT.numXtraPress = NaN;
mergedT.numHead = NaN;

%
for i = 1:max(g)
    minit = T(g == i,:);
    % pull single liners
    mergedT.animal(i) = minit.animal(1);
    mergedT.group(i) = minit.group(1);
    mergedT.condition(i) = minit.condition(1);
    mergedT.numPress(i) = sum(minit.numPress(:));
    mergedT.numReward(i) = sum(minit.numReward(:));
    mergedT.numLaser(i) = sum(minit.numLaser(:));
    mergedT.numXtraPress(i) = sum(minit.numXtraPress(:));
    mergedT.numHead(i) = sum(minit.numHead(:));
    
    % stitch cell arrays
    mergedT.seqLen{i} = cat(1,minit.seqLen{:,:});
    mergedT.seqDur{i} = cat(1,minit.seqDur{:,:});
    mergedT.magCheckDur{i} = cat(1,minit.magCheckDur{:,:});
    mergedT.normAll{i} = cat(1,minit.normAll{:,:});
    mergedT.R{i} = cat(1,minit.R{:,:});
    mergedT.L{i} = cat(1,minit.L{:,:});
    mergedT.NL{i} = cat(1,minit.NL{:,:});
    mergedT.notTrial{i} = cat(1,minit.notTrial{:,:});
    if strcmp(cond, 'roi')
        mergedT.E{i} = cat(1,minit.E{:,:});
        mergedT.entries{i} = cat(1,minit.entries{:,:});
        mergedT.normCatEntries{i} = cat(1,minit.normCatEntries{:,:});
    else
        mergedT.E{i} = [];
        mergedT.entries{i} = [];
        mergedT.normCatEntries{i} = [];
    end
end

mergedT = sortrows(mergedT,{'animal','condition'});

end
