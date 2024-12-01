%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PATHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;
addpath('/Users/zeinsadek/Desktop/Experiments/PIV/Processing/readimx-v2.1.8-osx/');
addpath('/Users/zeinsadek/Desktop/Experiments/PIV/Processing/Downwind/Downwind_Functions/');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT PARAMETERS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data paths
project_path   = '/Volumes/Zein_PIV/Downwind_1';
recording_name = 'WT50';
processing     = '/StereoPIV_MP(2x24x24_50%ov)';
inpt_name      = recording_name;


% Image paths
piv_path       = strcat(project_path, '/', recording_name, processing);

% Save paths
results_path = '/Users/zeinsadek/Desktop/Experiments/Downwind/';
mtlb_file    = strcat(results_path, 'data'   , '/', inpt_name, '_DATA.mat');
mean_file    = strcat(results_path, 'means'  , '/', inpt_name, '_MEANS.mat');
figure_file  = strcat(results_path, 'figures', '/', inpt_name);

% Make specific folder for figures of an experiment
if ~exist(figure_file, 'dir')
    mkdir(figure_file)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DAVIS TO MATLAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist(mtlb_file, 'file')
    fprintf('* Loading DATA from File\n')
    data = load(mtlb_file);
    data = data.output;
else
     data = vector2matlab(piv_path, mtlb_file);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB DATA TO ENSEMBLE/PHASE MEANS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if exist(mean_file, 'file')
%      fprintf('* Loading MEANS from File\n')
%      means = load(mean_file); 
%      means = means.output;
% else
%      means = data2means(mean_file, data);
% end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


speeds = 4.2:0.1:5.0;

figure()
hold on
for i = 1:length(speeds)
    
    speed = speeds(i);
    file  = strcat('WT', num2str(speed * 10), '_DATA');
    path  = strcat('/Users/zeinsadek/Desktop/Experiments/Downwind/data/', file);
   
    data  = load(path);
    data  = data.output;
   
    X = data.X;
    Y = data.Y;
    U = (data.U);
    U = rot90(-1 * mean(U, 3, 'omitnan'), -1);
    
    U(X < -100) = nan;
    U(X > 100)  = nan;
    U(Y < -100) = nan;
    U(Y > 100)  = nan;
    
   
    scatter(speed, mean(U, 'all', 'omitnan'), 100, 'fill')
   
end
hold on
xlabel('Wind Tunnel Fan Frequency [Hz]')
ylabel('Mean Streamwise Velocity')
xlim([4.1, 5.1])










