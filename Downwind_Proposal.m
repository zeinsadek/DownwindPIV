%% Downwind Figures for Proposal

clc; clear; close all;
addpath('/Users/zeinsadek/Desktop/Experiments/PIV/Processing/readimx-v2.1.8-osx/');
addpath('/Users/zeinsadek/Desktop/Experiments/PIV/Processing/Downwind/Downwind_Functions/');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT PARAMETERS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data paths
smooth_name  = 'UW_LM00_CN00_PLXZ_X1_Z1';
whisker_name = 'UW_LM1B_CN00_PLXZ_X1_Z1';

figure_path  = '/Users/zeinsadek/Desktop/Experiments/PIV/Processing/Downwind/Proposal_Figs';
results_path = '/Users/zeinsadek/Desktop/Experiments/PIV/Processing/Downwind/';
smooth_file  = strcat(results_path, 'means', '/', smooth_name,  '_MEANS.mat');
whisker_file = strcat(results_path, 'means', '/', whisker_name, '_MEANS.mat');

smooth_means  = load(smooth_file);
smooth_means  = smooth_means.output;
whisker_means = load(whisker_file);
whisker_means = whisker_means.output;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X = smooth_means.X.';
Y = smooth_means.Y.';

close all
ax = figure();
% t  = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'loose');

component    = 'w';
smooth_data  = flipud(smooth_means.(component));
whisker_data = flipud(whisker_means.(component));

percent   = 0.1;
min_range = (1 + percent) * min([min(smooth_data, [], 'all'), min(whisker_data, [], 'all')]);
max_range = (1 - percent) * max([max(smooth_data, [], 'all'), max(whisker_data, [], 'all')]);

% nexttile()
contourf(X, Y, smooth_data, 100, 'linestyle', 'none')
axis equal
colormap jet
clim([min_range, max_range])
colorbar()
xlim([-100,100])
ylim([-100,100])
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])

exportgraphics(ax, fullfile(figure_path, 'smooth_w.png'), 'Resolution', 300)

% nexttile()
% contourf(X, Y, whisker_data, 100, 'linestyle', 'none')
% axis equal
% colormap jet
% clim([min_range, max_range])
% colorbar()
% xlim([-100,100])
% ylim([-100,100])
% set(gca,'xtick',[])
% set(gca,'xticklabel',[])
% set(gca,'ytick',[])
% set(gca,'yticklabel',[])




