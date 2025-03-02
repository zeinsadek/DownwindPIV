
clear; clc; 
addpath('C:\Users\ofercak\Desktop\Zein\PIV\readimx-v2.1.9-win64');
data = readimx('G:\Crossplane\DW_LM00_C00_PLYZ_X1_Z2\DW_LM00_CN00_PLYZ_X1_Z2\StereoPIV_MPd(2x24x24_50%ov)_GPU\B00001.vc7');

names       = data.Frames{1,1}.ComponentNames;        
U0_index    = find(strcmp(names, 'U0'));
V0_index    = find(strcmp(names, 'V0'));
W0_index    = find(strcmp(names, 'W0'));

UF = data.Frames{1,1}.Components{U0_index,1}.Scale.Slope.*data.Frames{1,1}.Components{U0_index,1}.Planes{1,1} + data.Frames{1,1}.Components{U0_index,1}.Scale.Offset;
VF = data.Frames{1,1}.Components{V0_index,1}.Scale.Slope.*data.Frames{1,1}.Components{V0_index,1}.Planes{1,1} + data.Frames{1,1}.Components{V0_index,1}.Scale.Offset;
WF = data.Frames{1,1}.Components{W0_index,1}.Scale.Slope.*data.Frames{1,1}.Components{W0_index,1}.Planes{1,1} + data.Frames{1,1}.Components{W0_index,1}.Scale.Offset;

%%
nf = size(UF);
x = data.Frames{1,1}.Scales.X.Slope.*linspace(1, nf(1), nf(1)).*data.Frames{1,1}.Grids.X + data.Frames{1,1}.Scales.X.Offset;
y = data.Frames{1,1}.Scales.Y.Slope.*linspace(1, nf(2), nf(2)).*data.Frames{1,1}.Grids.Y + data.Frames{1,1}.Scales.Y.Offset;
[X, Y] = meshgrid(x, y);

%% corrections

U = WF.';
V = VF.';
W = UF.';

X = -X;

%%

figure()
tiledlayout(1,3)

nexttile
contourf(X, Y, U, 100, 'linestyle', 'none')
axis equal
xlim([-100, 100])
ylim([-100, 100])
colorbar()

nexttile
contourf(X,Y, V, 100, 'linestyle', 'none')
axis equal
xlim([-100, 100])
ylim([-100, 100])
colorbar()

nexttile
contourf(X, Y, W, 100, 'linestyle', 'none')
axis equal
xlim([-100, 100])
ylim([-100, 100])
colorbar()

