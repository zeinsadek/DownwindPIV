
clear; clc; 
addpath('/Users/zeinsadek/Desktop/Experiments/PIV/Processing/readimx-v2.1.8-osx/');
data = readimx("/Volumes/Downwind/Crossplane/DW_LM00_C00_PLYZ_X1_Z2/DW_LM00_CN00_PLYZ_X1_Z2/StereoPIV_MPd(2x24x24_50%ov)_GPU/B00001.vc7");

names       = data.Frames{1,1}.ComponentNames;        
U0_index    = find(strcmp(names, 'U0'));
V0_index    = find(strcmp(names, 'V0'));
W0_index    = find(strcmp(names, 'W0'));

UF = data.Frames{1,1}.Components{U0_index,1}.Scale.Slope.*data.Frames{1,1}.Components{U0_index,1}.Planes{1,1} + data.Frames{1,1}.Components{U0_index,1}.Scale.Offset;
VF = data.Frames{1,1}.Components{V0_index,1}.Scale.Slope.*data.Frames{1,1}.Components{V0_index,1}.Planes{1,1} + data.Frames{1,1}.Components{V0_index,1}.Scale.Offset;
WF = data.Frames{1,1}.Components{W0_index,1}.Scale.Slope.*data.Frames{1,1}.Components{W0_index,1}.Planes{1,1} + data.Frames{1,1}.Components{W0_index,1}.Scale.Offset;
%%


% UF_rotated = flipud(rot90(UF, 1));
% VF_rotated = flipud(rot90(VF, 1));
% WF_rotated = flipud(rot90(WF, 1));
% nf = size(WF_rotated);

%%
nf = size(output.U);
x = data.Frames{1,1}.Scales.X.Slope.*linspace(1, nf(1), nf(1)).*data.Frames{1,1}.Grids.X + data.Frames{1,1}.Scales.X.Offset;
y = data.Frames{1,1}.Scales.Y.Slope.*linspace(1, nf(2), nf(2)).*data.Frames{1,1}.Grids.Y + data.Frames{1,1}.Scales.Y.Offset;
[X, Y] = meshgrid(x, y);
%%

figure()
tiledlayout(1,3)

nexttile
contourf(X,Y, UF, 100, 'linestyle', 'none')
axis equal

nexttile
contourf(X,Y, VF, 100, 'linestyle', 'none')
axis equal

nexttile
contourf(X,Y, WF, 100, 'linestyle', 'none')
axis equal

