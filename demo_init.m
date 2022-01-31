% DEMO CODE TO REPRODUCE GRAPHS REPORTED IN GUT ET AL. 2022
% 

% housekeeping
clear; close all; 

%% Turn individual data files into one .mat data table
% Enter here, the folder name (including the path) that the data files are
% in and the name that you want to save the output as. The txt files in the
% folders are exemplary, and not all the data that we collected. But this
% snipped of code is how we did it for the whole data set.

myFolder = 'init_example_raw_data'; % NAMEOFTHEFOLDER
matFileName = 'init_example_dataT'; % OUTPUTFILENAME

makeRoiDataT(myFolder, matFileName);
load(matFileName)

%% Load all the data and calculate necessary variables
% The part above is run on the whole data set, and saved as T.
% From here on, going through the script will produce the plots and data
% as they were presented in the paper, using the whole data set.
clear;clc;

load('init_all.mat') % load data
% exclude data that belong to mice that were excluded after histology
excludedAnimals = [19003, 19004, 19008]; 
T(ismember(T.animal, excludedAnimals),:) = [];

[newT, oldT] = addIndexArrays(T, 'roi'); % calculate and add the 
                            % additional variables, like padded trial
                            % matrices (nanFilled), inter-press-intervals,
                            % sequence lengths and durations etc.
                            
mergedT = mergeDays(newT, 'roi'); % concatenate data from consecutive testing days

%% Figure 5I. Lever Press Raster Plot of example mice
ex_roi = mergedT([3,9],:); % choose two example mice, one for ChR2 and one for YFP
fr8rasterROI(ex_roi); % produce the raster plots, laser vs blank trials

%% Figure 5J. Average number of presses early vs late in trials

first5 = 5;
second5 = 10;
newT = mergedT(mergedT.condition == 'roi5',:);
for i= 1:height(newT)
    data = newT.normAll{i}(:,:);
    n = size(data,1);
    
    p_L_NL_rest = zeros(n,3);% ALL TRIALS: col1: #press 0-5 sec
                       %               col2: #press 5-10 sec
                       %               col3: #press 10-: sec
    for j = 1:n
        l = sum(~isnan(data(j,1:end)));
        c = 1;
        p_L_NL_rest(j,1) = sum(data(j,c:end)<=first5);
        p_L_NL_rest(j,2) = sum(data(j,c:end)>first5 & data(j,c:end)<=second5);
        p_L_NL_rest(j,3) = sum(data(j,c:end)>second5);
    end
    
    newT.p_L_NL_rest{i} = p_L_NL_rest(:,1:3);
    newT.mp_laser{i} = [mean(p_L_NL_rest((newT.L{i} & ~newT.notTrial{i}),1),'omitnan') ...
        mean(p_L_NL_rest((newT.L{i} & ~newT.notTrial{i}),2),'omitnan')];
    newT.mp_noLaser{i} = [mean(p_L_NL_rest((newT.NL{i} & ~newT.notTrial{i}),1),'omitnan') ...
        mean(p_L_NL_rest((newT.NL{i} & ~newT.notTrial{i}),2),'omitnan')];
end

mpress = [newT.mp_noLaser{:,:} ...
    newT.mp_laser{:,:}];
mpress = reshape(mpress,2,[]).';
mpress = [mpress(1:10,:) mpress(11:end,:)];

fr8plotSEM(mpress(logical(newT.group(:)),:), mpress(~newT.group,:));
xticklabels({'early','late','early','late'});
title('Avg #presses early vs late trial')

%% Figure 5K. Average press rates (#press/sec) in laser vs blank trials

% FIND PRESS RATES FOR ROI
% excluding sequences with <3 presses (pressRate function operates that
% way)
for s=1:height(newT)
   newT.pressRatesAll{s} = pressRate(newT.normAll{s});
   newT.pressRatesLaser{s} = pressRate(newT.normAll{s}(newT.L{s} & ~newT.notTrial{s},:));
   newT.pressRatesNoLaser{s} = pressRate(newT.normAll{s}(newT.NL{s} & ~newT.notTrial{s},:));
end
% Find average press rates
for i= 1:height(newT)
    newT.avgPRall(i) = mean(newT.pressRatesAll{i},'omitnan');
    newT.avgPRlaser(i) = mean(newT.pressRatesLaser{i},'omitnan');
    newT.avgPRnoLaser(i) = mean(newT.pressRatesNoLaser{i},'omitnan');
end

mpr = [newT.avgPRnoLaser(:), ...
    newT.avgPRlaser(:)];
fr8plotNLvsL(mpr(logical(newT.group(:)),:), mpr(~newT.group,:));
title('Avg press rates (Hz)')
ylim([0 5])

%% Figure 5M. Total number of trials: ChR2 vs YFP mice

for i = 1:height(mergedT)
    mergedT.not1{i} = mergedT.seqLen{i}>2; % exclude non-sequence trials
end

numTrials(:,1) = cellfun(@sum, mergedT.not1(mergedT.condition == 'baseline'));
numTrials(:,2) = cellfun(@sum, mergedT.not1(mergedT.condition == 'roi300'));
numTrials(:,3) = cellfun(@sum, mergedT.not1(mergedT.condition == 'roi5'));

fr8plotDaysBar(numTrials(1:7,:),numTrials(8:end,:));
xticklabels({'baseline', 'roi300', 'roi5', 'baseline', 'roi300', 'roi5'})
ylabel('Total number of trials ROI')
text(1,600,'(trial = seqLen>2)')

%% Figure 5N. Total number of presses laser vs blank trials: ChR2 vs YFP
% number of presses L vs NL 
% numPress(:,1) = NL
% numPress(:,2) = L

for i = 1:height(newT)
    numPress(i,1) = sum(newT.seqLen{i}(newT.NL{i}));
    numPress(i,2) = sum(newT.seqLen{i}(logical(newT.L{i})));
end
fr8plotNLvsL(numPress(1:7,:),numPress(8:10,:))
ylabel('total presses')
ylim([0 1300])
title('lever presses ROI')

%% Figure 6A. Percent unsuccessful trials

n = height(newT);
unSuccLaser = NaN(n,3);
unSuccNoLaser = NaN(n,3);
for i = 1:n
    unSuccLaser(i,:) = [sum(~newT.R{i}&newT.L{i} & ~newT.notTrial{i}),...
        sum(newT.L{i} & ~newT.notTrial{i}),...
        sum(~newT.R{i}&newT.L{i} & ~newT.notTrial{i})/sum(newT.L{i} & ~newT.notTrial{i})];
    unSuccNoLaser(i,:) = [sum(~newT.R{i}&newT.NL{i} & ~newT.notTrial{i}),...
        sum(newT.NL{i} & ~newT.notTrial{i}),...
        sum(~newT.R{i}&newT.NL{i} & ~newT.notTrial{i})/sum(newT.NL{i} & ~newT.notTrial{i})];
    newT.unSuccLaser{i} = unSuccLaser(i,:);
    newT.unSuccNoLaser{i} = unSuccNoLaser(i,:);
end

unsuccProp(:,1) = unSuccNoLaser(:,3); % non-laser trials
unsuccProp(:,2) = unSuccLaser(:,3); % laser trials
unsuccProp = unsuccProp.*100;

fr8plotNLvsL(unsuccProp(logical(newT.group),:),unsuccProp(~newT.group,:));
ylim([0 100])
ylabel('Unsuccessful trials (%) ROI')
