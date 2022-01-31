% DEMO CODE TO REPRODUCE GRAPHS REPORTED IN GUT ET AL. 2022
% 

% housekeeping
clear; close all; 

%% Turn individual data files into one .mat data table
% Enter here, the folder name (including the path) that the data files are
% in and the name that you want to save the output as. The txt files in the
% folders are exemplary, and not all the data that we collected. But this
% snipped of code is how we did it for the whole data set.

myFolder = 'exec_example_raw_data'; % NAMEOFTHEFOLDER
matFileName = 'exec_example_dataT'; % OUTPUTFILENAME

makeNewDataT(myFolder, matFileName);
load(matFileName)

%% Load all the data and calculate necessary variables
% The part above is run on the whole data set, and saved as T.
% From here on, going through the script will produce the plots and data
% as they were presented in the paper, using the whole data set.
clear;clc;

load([basepath 'exec_all.mat']) % load data
% exclude data that belong to mice that were excluded after histology
excludedAnimals = [19003, 19004, 19008]; 
T(ismember(T.animal, excludedAnimals),:) = [];

[newT, oldT] = addIndexArrays(T, 'll'); % calculate and add the 
                            % additional variables, like padded trial
                            % matrices (nanFilled), inter-press-intervals,
                            % sequence lengths and durations etc.
                            
mergedT = mergeDays(newT, 'll'); % concatenate data from consecutive testing days

%% Figure 5B. Lever Press Raster Plot of example mice
ex_ll = mergedT([3,24],:); % choose two example mice, one for ChR2 and one for YFP
fr8rasterAS(ex_ll); % produce the raster plots, laser vs blank trials

%% Figure 5C. Average number of presses early vs late in trials

first5 = 5;
second5 = 10;
newT = mergedT(mergedT.condition == 'll5',:);
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
mpress = [mpress(1:9,:) mpress(10:end,:)];

fr8plotSEM(mpress(logical(newT.group(:)),:), mpress(~newT.group,:));
xticklabels({'early','late','early','late'});
title('Avg #presses early vs late trial')

%% Figure 5D. Average press rates (#press/sec) in laser vs blank trials
% FIND PRESS RATES FOR LL
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

%% Figure 5F. Total number of trials: ChR2 vs YFP mice

for i = 1:height(mergedT)
    mergedT.not1{i} = mergedT.seqLen{i}>2; % exclude non-sequence trials
end

numTrials(:,1) = cellfun(@sum, mergedT.not1(mergedT.condition == 'baseline'));
numTrials(:,2) = cellfun(@sum, mergedT.not1(mergedT.condition == 'll300'));
numTrials(:,3) = cellfun(@sum, mergedT.not1(mergedT.condition == 'll5'));

fr8plotDaysBar(numTrials(1:6,:),numTrials(7:end,:));
xticklabels({'baseline', 'll300', 'll5', 'baseline', 'll300', 'll5'})
ylabel('Total number of trials ROI')
text(1,600,'(trial = seqLen>2)')

%% Figure 5G. Total number of presses laser vs blank trials: ChR2 vs YFP

% number of presses L vs NL 
% numPress(:,1) = NL
% numPress(:,2) = L

for i = 1:height(newT)
    numPress(i,1) = sum(newT.seqLen{i}(newT.NL{i}));
    numPress(i,2) = sum(newT.seqLen{i}(logical(newT.L{i})));
end
fr8plotNLvsL(numPress(1:6,:),numPress(7:9,:))
ylabel('total presses')
ylim([0 1300])
title('lever presses LL')

%% Supplementary Figure 4A: behavioral microstructure

NUM =  6;
figure();clf
fr8plotLLmicrostr(T.presses{NUM},T.rewards{NUM},T.laserOn{NUM},T.headEntries{NUM})
xlabel('Time (sec)');
ylabel('Number of presses');
legend('Press','Laser','Reward','Head entry')
title(T.animal(NUM))

%% Supplementary Figure 4B: training time to reach 8-press long sequences
% This script is to count how many days it took for each mouse to reach
% "testing" criterium. This criterium is earning >100 Rewards on minimum 2
% consecutive days

% load and prepare data
load('as_trainingToAnalyze.mat')

% data tidy up
% exclude data that belong to mice that were excluded after histology
excludedAnimals = [19003, 19004, 19008]; 
T(ismember(T.animal, excludedAnimals),:) = [];

maxDays = 15; % max num of days to reach testing criteria (19014s)
animals = unique(T.animal);
C = ~T.group; % index array for control animals
E = ~C; % index array for experimental animals

% make the training array using the criteria
trainingMatrix = NaN(maxDays,3,length(animals));

for i = 1:length(animals)
    currentAnimal = animals(i);
    days = T(T.animal == currentAnimal,:).date; % take all the days that 
                            % currentAnimal has gone through the training
    rewards = T(T.animal == currentAnimal,:).numReward;
    meanSeqLengths = T(T.animal == currentAnimal,:).meanSeqLength;
    n = find(rewards>100);
    n_diff = diff(n);
    idx = find(n_diff == 1,1);
    tillWhere = n(idx+1);
    if isempty(idx)
        tillWhere = n+2; % 19014 didn't have two consecutive days of >100 
        % rewards, so instead I'll take the last day of the two occurrences
        % with a day in between
    end
    
    if tillWhere < maxDays
        tillWhere = maxDays; % Just so I can collect the data for other animals 
        % for the remainder days (because it took 19014 longer to reach
        % testing criteria
    end
    
    trainingMatrix(1:tillWhere,:,i) = [datenum(days(1:tillWhere)) ...
                                        rewards(1:tillWhere) ...
                                        meanSeqLengths(1:tillWhere) ...
                                        ];
end
    
% plot training 
SEM = @(x)std(x)./sqrt(length(x));
seqLengths = squeeze(trainingMatrix(:,3,:)); % 2 is #rewards, 3 is sequence lengths
seqLengths = seqLengths.';

trainingDays = 1:maxDays;
means = mean(seqLengths);
sems = SEM(seqLengths);

figure;clf;
%expe = errorbar(trainingDays, means(E), sems(E));
hold on
%ctrl = errorbar(trainingDays, means(C), sems(C));
errorbar(trainingDays, means, sems);
ax = gca;
ax.XTick = 1:maxDays;
ax.YLim = [0.5 8.5];
ax.XLim = [0.5 15.5];
xlabel('training days')
ylabel('sequence length')
annotation(gcf,'line',[0.132142857142857 0.903571428571428],...
    [0.873809523809524 0.873809523809524],...
    'Color',[0.850980392156863 0.325490196078431 0.098039215686274],...
    'LineStyle','--');
