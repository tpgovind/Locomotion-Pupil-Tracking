clc; clear all; close all;
files = dir('Your-Directory\*.csv');
filenames = cell(size(files,1),1);

maxCols = size(files,1); % number of recordings
maxRows = 5000; % frames of interest within recording
for i = 1:size(files,1)
    temp = split(files(i).name,'D');
    temp = temp{1,1}; filenames{i,1} = temp; % Create recordings IDs from filenames
end
vert = array2table(zeros(maxRows,maxCols),'VariableNames',filenames);
horz = array2table(zeros(maxRows,maxCols),'VariableNames',filenames);

% Computer pairwise distances
for col = 1:size(files,1)
    disp(['Working on File: ' int2str(col) '. ' filenames{col}])
    dataMatrix = csvread([files(col).folder '\' files(col).name],3,0);
    for row = 1:size(dataMatrix,1)
        [north_x,north_y,east_x,east_y,south_x,south_y,west_x,west_y] = ...
            deal(dataMatrix(row,2),dataMatrix(row,3),dataMatrix(row,5),dataMatrix(row,6),dataMatrix(row,8),dataMatrix(row,9),dataMatrix(row,11),dataMatrix(row,12));
        vert_dist = pdist([north_x,north_y;south_x,south_y],'euclidean'); horz_dist = pdist([east_x,east_y;west_x,west_y],'euclidean');
        [vert.(filenames{col})(row,1),horz.(filenames{col})(row,1)] = deal(vert_dist,horz_dist);
    end
end

% Save raw diameter traces
vert{:,:}(vert{:,:}==0) = NaN; horz{:,:}(horz{:,:}==0) = NaN;
writetable(vert,'C:\Users\GORDON LAB\Documents\ADAM_ANALYSIS\Pupil tracking\RESULTS\May 9th\Pupil_Tracking_Results-NoZeros.xlsx','Sheet','Vertical_Distance');
writetable(horz,'C:\Users\GORDON LAB\Documents\ADAM_ANALYSIS\Pupil tracking\RESULTS\May 9th\Pupil_Tracking_Results-NoZeros.xlsx','Sheet','Horizontal_Distance');

% Perform median filtering
for k = 1:length(vert.Properties.VariableNames)
    data = vert.(k); vert.(k) = medfilt1(data,10,'omitnan');
end
for k = 1:length(horz.Properties.VariableNames)
    data = horz.(k); horz.(k) = medfilt1(data,10,'omitnan');
end

% Save filtered diameter traces
writetable(vert,'C:\Users\GORDON LAB\Documents\ADAM_ANALYSIS\Pupil tracking\RESULTS\May 9th\Pupil_Tracking_Results-NoZeros-Smoothed.xlsx','Sheet','Vertical_Distance');
writetable(horz,'C:\Users\GORDON LAB\Documents\ADAM_ANALYSIS\Pupil tracking\RESULTS\May 9th\Pupil_Tracking_Results-NoZeros-Smoothed.xlsx','Sheet','Horizontal_Distance');
