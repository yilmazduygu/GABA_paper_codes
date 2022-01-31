function makeRoiDataT(myFolder, matFileName)
% FUNCTION makeRoiDataT(myFolder, matFileName) 
% Goes through the folder specified by the user in "myFolder", reads the MED-PC
% text files in that folder, creates a data struct in the workspace called "data".
% Turns that data struct into a data table, cleans and prepares the table to
% analysis. 
% Also parses the trials now (7/26/19). 
% Saves the variables in the workspace, to the current path, with the 
% name "matFileName".
%   INPUTS: 
%       myFolder = a string array specifying the complete path to the folder
%       with ROI data files, that needs to be gone through.
%       matFileName = a string array specifying the .mat file name the
%       variables will be saved into.
%

% Check if the folder actually exists. Warn user if it doesn't.
if exist(myFolder, 'dir') ~= 7
  errorMessage = sprintf('The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all txt files in the folder.
filePattern = fullfile(myFolder, '*.txt');
allFiles = dir(filePattern);

% Loop through myFolder for text files, inform user of the progress.
for ii = 1 : length(allFiles)
  baseFileName = allFiles(ii).name;
  fullFileName = fullfile(myFolder, baseFileName);
  % Lets user know of what the script is doing.
  fprintf(1, '%d. Now reading %s\n', ii, baseFileName);
  data(ii) = readRoiFR8txt(fullFileName); 
end
if ii ~= length(allFiles) % Sanity check
    error('Problem with reading all the files in %s\n', myFolder);
else
    fprintf(1, 'Finished reading all files in %s\n', myFolder);
end

% Clean and sort the data
rawT= struct2table(data, 'AsArray',1); % first save the raw data
T = rmmissing(rawT, 'DataVariables', 'numPress'); % remove 
        % the cases with no data in numPress
T = sortrows(T,[1 2]);

% add the condition column
comments = T.comments;
habit = contains(comments, 'habit', 'IgnoreCase',true);
roi300 = contains(comments, 'roi3', 'IgnoreCase',true);
roi5 = contains(comments, 'roi5', 'IgnoreCase',true);

n = height(T);
T.condition = cell(n,1);
T.condition(habit) = {'baseline'};
T.condition(roi300) = {'roi300'};
T.condition(roi5) = {'roi5'};
misc = habit + roi300 + roi5;
T.condition(~misc) = {'baseline'};
T.condition = categorical(T.condition);

% % swap 14 and 7 (because they got mixed up before ROI)
% % 7/4/20
% T.animal(T.animal == 19007) = 14;
% T.animal(T.animal == 19014) = 7;
% T.animal(T.animal == 7) = 19007;
% T.animal(T.animal == 14) = 19014;
% T.group(T.animal == 19007) = 1;
% T.group(T.animal == 19014) = 0;
% T = sortrows(T, [1,2]);

% Parse trials
trials = {};
for s=1:length(T.presses)
    h0 = 0;
    ix = 1;
    for h=1:length(T.headEntries{s})
        h1 = T.headEntries{s}(h);
        p = find(T.presses{s} <= h1 & T.presses{s} > h0);
        if isempty(p)
            continue;
        else
            presses = (T.presses{s}(p))';
            trials{s,1}{ix,1} = presses;
            ix = ix+1;
            h0 = h1;
        end
    end
    if ~isempty(p) % to get the last presses, that were made after the last head entry
        xtra = p(end)+1;
        if length(T.presses{s}) >= xtra
            presses = (T.presses{s}(xtra:end))';
            trials{s,1}{ix,1} = presses;
        end
    end
     T.efficiency(s) = (T.numReward(s).* T.seqLength(s))./T.numPress(s);
end

T.trials = trials(:,:);
save(matFileName, 'T','rawT','data');

