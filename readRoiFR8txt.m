function S = readRoiFR8txt(filename)
% FUNCTION S = readRoiFR8txt(filename)
% Reads FR8 ROI data files produced by MED-PC line-by-line, and puts the
% information in the file into a struct.
%   INPUT:
%       filename = a string specifying the complete path to the file to be
%       read by readFR8txt.
%   OUTPUT:
%       S = a struct of arrays, containing the information extracted from
%       "filename". It has 16 fields:
%           - S.animal = doubles array, stores animal ID
%           - S.date = datetime array, stores the date of the session
%           - S.group = doubles array, stores the treatment group #
%           - S.box = doubles array, stores the box #
%           - S.duration = duration information of the session
%           - S.program = string array, stores the code run in MED-PC in
%           that session
%           - S.numPress = doubles array, stores the total # of lever
%           presses
%           - S.numReward = doubles array, stores the total # of rewards
%           collected
%           - S.numLaser = Stores the total # of TTL signals initiated
%           during the session
%           - S.numXtraPress = Stores the total # of extra presses the
%           animal has made to get a reward before checking the magazine
%           (those that are on top of the necessary 8 presses)
%           - S.presses = a column vector of doubles, stores the timestamps
%           of each lever press
%           - S.rewards = a column vector of doubles, stores the timestamps
%           of each reward
%           - S.headEntries = a column vector of doubles, stores the timestamps
%           of each head entry to magazine
%           - S.comments = string array, stores the comments written in
%           that session in "filename"
%           - S.start = datetime array, stores the complete date and time
%           the session has started
%           - S.name = string array, stores the file name
%
%   2/19/19 deleted the warning code gives when it reads data of a session
%           that is longer than 65 min
%   2/20/19 the readArray local function now converts the timestamps into
%           seconds (divides the MPC generated ones with 100). rawT doesn't
%           have it, only T has it.

% Open text file, give error if not possible
fid = fopen(filename);
if fid<0
    error('Error opening the file %s.\n', filename);
end

% Set up the struct S, assign default values to each field
S = struct;
S.animal = NaN;
S.date = NaT;
S.group = NaN;
S.box = NaN;
S.duration = NaT;
S.seqLength = NaN;
S.program = '';
S.numPress = NaN;
S.numReward = NaN;
S.numLaser = NaN;
S.numXtraPress = NaN;
S.numHead = NaN;
S.presses = NaN;
S.rewards = NaN;
S.headEntries = NaN;
S.laserOn = NaN;
S.roiEntries = NaN;
S.comments = '';
S.start = NaT;
S.name = '';
% Read header info, write each bit to its corresponding field in S
while true
    line = fgetl(fid);
    if isempty(line) || length(line) == 0;continue;end % Skip empty lines: 
      % I cannot fix the warning Matlab gives here, because for my files, with fgetl, 
      % isempty function does not work, only length does
    if line(1) == 'A';break;end % Exit the loop to get the arrays in the next step
    tagValue = strsplit(line,': '); 
    tag = tagValue{1}; 
    value = tagValue{2};
    % Because of windows' directory naming, strsplit function splits 
    % 'C:directory\filename' as well. Go around this as follows:
    if length(tagValue) > 2; value = cat(2, tagValue{2}, ':', tagValue{3});end 
    switch upper(tag)
        case 'FILE'
            % Found the file name
            S.name = char(value);
        case 'START DATE'
            % Found the session date
            S.date = datetime(value, 'InputFormat', 'MM/dd/yy');
            recDate = char(value); % for later use
        case 'END DATE'
            % Found the date session ended, not important, continue
            continue;
        case 'SUBJECT'
            % Found the animal ID #
            S.animal = str2double(value);
            if ~(str2double(S.name(42:46)) == S.animal)
                warning('Animal ID possibly read incorrectly');
            end
        case 'EXPERIMENT'
            % experiment name, not important, continue
            continue;
        case 'GROUP'
            % Found the treatment group
            S.group = str2double(value); 
            if S.group > 1 % 
                warning('Possible typo in group info in this file');
            end
        case 'BOX'
            % Found the box the animal's been tested
            S.box = str2double(value); 
        case 'START TIME'
            % Found the time session has started
            recTime = char(value);
            S.start= datetime([recDate, ' ', recTime], 'InputFormat', 'MM/dd/yy HH:mm:ss');
        case 'END TIME'
            % Found the time session has ended, use this to find out
            % session duration
            recTimeEnd = char(value);
            endTime = datetime([recDate, ' ', recTimeEnd], 'InputFormat', 'MM/dd/yy HH:mm:ss');
            S.duration = endTime - S.start;
%             if S.duration > minutes(65) % Sanity check
%                 warning('Session duration longer than an hour for this one');
%             end
        case 'MSN'
            % Found the program run that day
            S.program = char(value);
%             earlyTraining = {'FR8_training_actSeq3','FR8_training_actSeq5'};
%             if ismember(S.program,earlyTraining)
%                 return; % I don't want the data for earlier stages of training
%             end
        case 'B'
            % Found the set minimum number of presses to get a reward
            % (action sequence length)
            S.seqLength = str2double(value);
        case 'F'
            % Irrelevant info about MED-PC
            continue;
        case 'H'
            % Found the total number of head entries
            S.numHead = str2double(value);
        case 'L'
            % Found the total number of presses the animal did
            S.numPress = str2double(value);
        case 'R'
            % Found the total number of rewards the animal got
            S.numReward = str2double(value);
        case 'U'
            % Found the total number of laser activations
            S.numLaser = str2double(value);
        case 'V'
            % Found the total number of inactive (extra) presses
            S.numXtraPress = str2double(value);
        otherwise
            error(['Found an unknown tag ' tag]);
    end
end
% Now fid should be right below the line "A: "
if ~(line(1)=='A')
    error('Cursor is at an unintended line');
end
line = fgetl(fid); % irrelevant info on this line, do not store

% Read Lever Press Array (C):
line = fgetl(fid); % next line, 'C:'
if line(1) == 'C' % fid is at lever press array
    S.presses = readArray('C', 'D');
else
    error('Cursor is at an unintended line');
end

% Read Rewards Array (D):
if line(1) == 'D' % fid is at rewards array
    S.rewards = readArray('D','E');
else
    error('Cursor is at an unintended line');
end

% Read Head Entries Array (E):
if line(1) == 'E' % fid is at head entry array
    S.headEntries = readArray('E', 'O');
end

% Read ROI Entries Array (O):
if line(1) == 'O' % fid is at head entry array
    S.roiEntries = readArray('O', 'Q');
end

% Read Laser On Array (Q):
if line(1) == 'Q' % fid is at laser on array
    [S.laserOn, S.comments] = readArray('Q', 'X');
end

% Function to read data arrays:
    function [array, comment] = readArray(whichArray, untilWhere)
        allArrays = {'C', 'D', 'E', 'O', 'Q'};
        if ~ismember(whichArray, allArrays)
            error('Local function called wrong');
        end
        
        counter = 0;
        temp = {};
        comment = '';
        while true
            line = fgetl(fid); % next line, where the data starts
            if line(1) == untilWhere;break;end
            if line(1) == '\'
                comment = line(2:end);
                continue;
            end
            if line == -1;break;end
            counter = counter + 1; % counts the lines it reads
            values = extractAfter(line, ': ');
            A = sscanf(values, '%f');
            temp{counter} = A./100; 
        end
        array = cat(1, temp{:}); 
    end

% Close the file
fclose(fid);
end