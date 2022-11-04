%% Description
%   This code reads in paths to folders containing sequences of images
%   of a spherical ball that the animal is running on. It then
%   computes difference images to detect ball movement, and saves the
%   results to Excel file.
%   Note: this code makes use of two helper functions ('natsortfiles' and 
%   'xlsColNum2Str'), which were retrieved from MATLAB File Exchange:
%   Stephen23 (2022). Natural-Order Filename Sort (https://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort), MATLAB Central File Exchange. Retrieved March 4, 2022.
%   Matt G (2022). Excel Column Number To Column Name (https://www.mathworks.com/matlabcentral/fileexchange/15748-excel-column-number-to-column-name), MATLAB Central File Exchange. Retrieved March 4, 2022.

clc; clear all; close all;

% Read paths
[~,paths] = xlsread('Ball tracking Path.xlsx'); locomotionTraces = cell(length(paths),2);

% Process data
for path = 1:length(paths)
    
    tic; disp(['Working on file ' int2str(path) ' of ' int2str(length(paths))]);
    
    imgFiles = dir([paths{path} '/*.tiff']); imgFiles = natsortfiles({imgFiles.name}); numImages = length(imgFiles);
    numRows = size(imread([paths{path} '/' imgFiles{3}]),1); numCols = size(imread([paths{path} '/' imgFiles{3}]),2);
    
    I = zeros(numRows,numCols,numImages);
    for n = 1:numImages
        I(:,:,n) = imread([paths{path} '/' imgFiles{n}]);
    end
    
    pixSum = zeros(numImages-1,2); diffImg = single(zeros(numRows,numCols,numImages-1));
    
    for i = 1:numImages-1
        im1 = single(I(:,:,i)); im2 = single(I(:,:,i+1));
        diffImg(:,:,i) = imabsdiff(im2,im1); % Absolute difference image
        pixSum(i,1) = i*(180/numImages); % Time (s)
        pixSum(i,2) = sum(diffImg(:,:,i),'all'); % Total frame intensity
    end
    
    temp = pixSum(:,2);
    temp = (temp - min(temp)) / (max(temp) - min(temp)); % Optional max-min normalization
    locomotionTraces{path,1} = ['File' int2str(path)]; locomotionTraces{path,2} = temp; toc;
    
end

% Save results
for file = 1:length(locomotionTraces)
    range = xlsColNum2Str(file); range = range{1}; % Call a helper function for saving to specific Excel range
    writecell(locomotionTraces(file,1),'Results.xlsx','WriteMode','inplace','Range',[range int2str(1)]);
    writematrix(locomotionTraces{file,2},'Results.xlsx','WriteMode','inplace','Range',[range int2str(2)]);
end
