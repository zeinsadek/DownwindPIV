%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PATHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;
addpath('C:\Users\ofercak\Desktop\Zein\PIV\readimx-v2.1.9-win64');
addpath('C:\Users\ofercak\Desktop\Zein\PIV\DownwindPIV\Downwind_Functions');
addpath('C:\Users\ofercak\Desktop\Zein\PIV\colormaps')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT PARAMETERS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data paths
caze = 'DW_LM00_CN20_PLYZ';
position = 'X3_Z2';

caze_position  = strcat(caze, '_', position);
project_path   = fullfile('G:\PIVYZ', caze(1:end - 5), caze(1:end - 5));
recording_name = caze_position;
processing     = 'StereoPIV_MPd(2x24x24_50%ov)_GPU';
inpt_name      = recording_name;

% Image paths
piv_path = fullfile(project_path, recording_name, processing);

% Save paths
results_path = 'G:\PIVYZ\new_results';
mtlb_file    = fullfile(results_path, 'data', strcat(inpt_name, '_DATA.mat'));
mean_file    = fullfile(results_path, 'means', strcat(inpt_name, '_MEANS.mat'));
figure_file  = fullfile(results_path, 'figures', inpt_name);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DAVIS TO MATLAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist(mtlb_file, 'file')
    fprintf('* Loading DATA from File\n')
    data = load(mtlb_file);
    data = data.output;
else
    data = vector2matlabPIVYZ(piv_path, mtlb_file);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB DATA TO ENSEMBLE/PHASE MEANS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist(mean_file, 'file')
     fprintf('* Loading MEANS from File\n')
     means = load(mean_file); 
     means = means.output;
else
     means = data2means(mean_file, data);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
% Coordinates
X = means.X;
Y = means.Y;

% Means
U = means.u;
V = means.v;
W = means.w;

% Normal Stresses
uu = means.uu;
vv = means.vv;
ww = means.ww;

% Shear Stresses
uv = means.uv;
uw = means.uw;
vw = means.vw;

%% Means Plots

ax = figure();
tiledlayout(1,3);
sgtitle(inpt_name, 'interpreter', 'none')

ax1 = nexttile();
colormap(ax1, "jet")
contourf(X, Y, U, 100, 'linestyle', 'none')
axis equal
xlim([-100,100])
ylim([-100,100])
colorbar()
title('u')

ax2 = nexttile();
colormap(ax2, "coolwarm")
contourf(X, Y, V, 100, 'linestyle', 'none')
axis equal
xlim([-100,100])
ylim([-100,100])
colorbar()
title('v')

ax3 = nexttile();
colormap(ax3, "coolwarm")
contourf(X, Y, W, 100, 'linestyle', 'none')
axis equal
xlim([-100,100])
ylim([-100,100])
colorbar()
title('w')

%% Stresses Plots

ax = figure();
tiledlayout(2,3);
sgtitle(inpt_name, 'interpreter', 'none')

% Normal Stresses
nexttile()
colormap jet
contourf(X, Y, uu, 100, 'linestyle', 'none')
axis equal
xlim([-100,100])
ylim([-100,100])
colorbar()
title('uu')

nexttile()
colormap jet
contourf(X, Y, vv, 100, 'linestyle', 'none')
axis equal
xlim([-100,100])
ylim([-100,100])
colorbar()
title('vv')

nexttile()
colormap jet
contourf(X, Y, ww, 100, 'linestyle', 'none')
axis equal
xlim([-100,100])
ylim([-100,100])
colorbar()
title('ww')

% Shear Stresses
nexttile()
colormap jet
contourf(X, Y, uv, 100, 'linestyle', 'none')
axis equal
xlim([-100,100])
ylim([-100,100])
colorbar()
title('uv')

nexttile()
colormap jet
contourf(X, Y, uw, 100, 'linestyle', 'none')
axis equal
xlim([-100,100])
ylim([-100,100])
colorbar()
title('uw')

nexttile()
colormap jet
contourf(X, Y, vw, 100, 'linestyle', 'none')
axis equal
xlim([-100,100])
ylim([-100,100])
colorbar()
title('vw')





















