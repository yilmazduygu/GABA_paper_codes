function [newT, oldT] = addIndexArrays(T, condition)

oldT = T(:,:);
CUTOFFSEC = 20;
R = length(T.trials);

for rowNr=1:R
    sz = length(T.trials{rowNr});
    T.nanFilled{rowNr} = nan(sz,24);
    T.seqLen{rowNr} = nan(sz,1);
    
    for j = 1:sz
        seqlen = length(T.trials{rowNr}{j,:});
        T.seqLen{rowNr}(j)= seqlen;
        if seqlen > 24
            seqlen = 24;
        end
        bout = T.trials{rowNr}{j};
        T.nanFilled{rowNr}(j,1:seqlen) = ...
            T.trials{rowNr}{j}(1,1:seqlen);
    end
    
    T.seqDur{rowNr} = max(T.nanFilled{rowNr},[],2) - T.nanFilled{rowNr}(:,1);    
    T.IPIall{rowNr} = diff(T.nanFilled{rowNr},1,2);
    T.normAll{rowNr} = T.nanFilled{rowNr}(:,:)-T.nanFilled{rowNr}(:,1);
    
    % interval between the last press and proceding head check
    pLast = max(T.nanFilled{rowNr},[],2);
    headEntries = nan(sz,1);
    for h = 1:sz
        ix = find(T.headEntries{rowNr} > pLast(h), 1);
        if isempty(ix)
            continue; 
        else
            headEntries(h) = T.headEntries{rowNr}(ix);
        end
    end

    T.magCheckDur{rowNr} = headEntries - pLast;
    
    T.R{rowNr} = ismember(T.nanFilled{rowNr}(:,T.seqLength(rowNr)),T.rewards{rowNr});
    
    
    if strcmp(condition, 'll')
        T.L{rowNr} = ismember(T.nanFilled{rowNr}(:,1),T.laserOn{rowNr});
        T.NL{rowNr} = ~T.L{rowNr}; 
        
    elseif strcmp(condition, 'roi')        
        % make the logicals to index cases
        T.E{rowNr} = false(sz,1); % all ROI crosses
        T.L{rowNr} = false(sz,1);
        T.entries{rowNr} = false(sz,1);
        p1 = T.nanFilled{rowNr}(:,1);
        for j = 1:length(T.roiEntries{rowNr})
            ix = find(p1 > T.roiEntries{rowNr}(j), 1);
            T.entries{rowNr}(ix) = T.roiEntries{rowNr}(j);
            if isempty(ix); break; end
            T.E{rowNr}(ix) = true;
            if ismember(T.roiEntries{rowNr}(j), T.laserOn{rowNr})
                T.L{rowNr}(ix) = true;
            end
        end
        T.NL{rowNr} = logical(T.E{rowNr}-T.L{rowNr});
    end
    
    T.notTrial{rowNr} = T.normAll{rowNr}(:,2) >= CUTOFFSEC | ...
        isnan(T.normAll{rowNr}(:,2)) ...
        | isnan(T.normAll{rowNr}(:,3)) | T.seqLen{rowNr} < 3;

end

if strcmp(condition, 'roi')
    % concatenate entries and nanfilled arrays
    % FOR RASTER PLOTS
    T.catEntries = cellfun(@horzcat,T.entries,T.nanFilled,'UniformOutput',false);
    % this has all trials including those that were not started with an entry
    T.normCatEntries = cellfun(@(x) x-x(:,1), T.catEntries,'UniformOutput', false);
end
newT = T(:,:);

end
