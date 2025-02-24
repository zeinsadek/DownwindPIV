%% Taiga and Zein Downwind Blending

%    Order of Images
%   |         ||         |
%   |   X1Z2  ||   X1Z2  |
%   |_________||_________|
%   |         ||         |
%   |   X1Z1  ||   X2Z1  |
%   |         ||         |

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PATHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;
addpath('/Users/zeinsadek/Desktop/Experiments/PIV/Processing/Downwind/Downwind_Functions');
addpath('/Users/zeinsadek/Desktop/Experiments/PIV/Processing/colormaps');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOADING MEANS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load data for all 4 planes all at once
project_path = '/Users/zeinsadek/Desktop/Experiments/Downwind/Processed/means';
orientation  = 'DW';

for i = 1:2
    for j = 1:2

        % Generate case name and path
        recording_name = strcat(orientation, '_LM00_CN00_PLXZ_X', num2str(i), '_Z', num2str(j), '_MEANS.mat');
        piv_path       = fullfile(project_path, recording_name);
        location_tag   = strcat('X', num2str(i), 'Z', num2str(j));
        
        % Load data into temp and store into structure
        tmp = load(piv_path);
        data.(location_tag) = tmp.output;
        
    end
end

% Clear finished variables to save memory
clear i j tmp location_tag piv_path recording_name

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CORRECT ORIENTATION + SIGN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

components = {'u', 'v', 'w','uu', 'vv','ww','uv','uw', 'vw'};

u_inf = 3;

for i = 1:2
    for j = 1:2
        location_tag   = strcat('X', num2str(i), 'Z', num2str(j));
        tmp = data.(location_tag);
        
        for c = 1:length(components)
            component = components{c};
            
            % Load mean
            tmp_mean = tmp.(component);

            % Rotate (or something else...)
            tmp_mean = fliplr(tmp_mean.');

            % Change sign of specific components
            if ismember(component, {'u', 'w', 'uv', 'vw'})
                tmp_mean = -1 * tmp_mean;
            end

            % Non-dimensionalize means
            if ismember(component, {'u', 'v', 'w'})
                tmp_mean = tmp_mean / u_inf;
            end

            % Non-dimensionalize stresses
             if ismember(component, {'uu', 'vv', 'ww', 'uv', 'uw', 'vw' })
                tmp_mean = tmp_mean / (u_inf^2);
             end

            % Save to new variable
            rotated_means.(location_tag).(component) = tmp_mean;
        end
    end
end

clear c component i j location_tag tmp tmp_mean

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT CHECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X = data.X1Z1.X;
Y = data.X1Z1.Y;
u = rotated_means.X1Z1.u;
v = rotated_means.X1Z1.v;
w = rotated_means.X1Z1.w;

figure();
tiledlayout(3,1);
sgtitle(orientation, 'interpreter', 'none')

ax1=nexttile;
contourf(X, Y, u, 100, 'linestyle', 'none')
colormap(ax1, 'parula');
axis equal
xline(100)
xline(-100)
yline(100)
yline(-100)
colorbar()
title('u')

ax2=nexttile;
contourf(X, Y, v, 100, 'linestyle', 'none')
colormap(ax2, 'coolwarm');
axis equal
xline(100)
xline(-100)
yline(100)
yline(-100)
colorbar()
title('v')

ax3=nexttile;
contourf(X, Y, w, 100, 'linestyle', 'none')
colormap(ax3, 'coolwarm');
axis equal
xline(100)
xline(-100)
yline(100)
yline(-100)
colorbar() 
title('w')

clear X Y u v w z ax1 ax2 ax3

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CROP DATA JUST TO PLATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

components = {'u', 'v', 'w', 'uu', 'vv', 'ww', 'uv', 'uw', 'vw'};

for i = 1:2
    for j = 1:2
        location_tag   = strcat('X', num2str(i), 'Z', num2str(j));
        tmp = rotated_means.(location_tag);
        tmp_x = data.(location_tag).X;
        tmp_y = data.(location_tag).Y;
        
        % Extract X Values from dataset 1
        x = tmp_x(1,:); 
        y = tmp_y(:,1);

        % Define where we want to cut
        right_cutoff  = 100;
        left_cutoff   = -100;
        top_cutoff    = 100;
        bottom_cutoff = -100;

        % Find closest values in x and y
        [~, right_idx] = min(abs(x - right_cutoff));
        [~, left_idx] = min(abs(x - left_cutoff));
        [~, top_idx] = min(abs(y - top_cutoff));
        [~, bottom_idx] = min(abs(y - bottom_cutoff)); 


        %Crop X and Y
        cropped.(location_tag).X = tmp_x(top_idx:bottom_idx, left_idx:right_idx);
        cropped.(location_tag).Y = tmp_y(top_idx:bottom_idx, left_idx:right_idx);


        for c = 1:length(components)
            component = components{c};
            temp_comp = tmp.(component);

            % Crop/ Index X1, Y1, X3, Y3 and all means and stresses and Save to new variable
            cropped.(location_tag).(component) = temp_comp(top_idx:bottom_idx, left_idx:right_idx);
        end
    end
end

clear left_cutoff right_cutoff top_cutoff bottom_cutoff
clear left_idx right_idx top_idx bottom_idx location_tag
clear tmp component temp_comp tmp_x tmp_y x y c i j


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT CHECK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X = cropped.X1Z1.X;
Y = cropped.X1Z1.Y;
u = cropped.X1Z1.u;
v = cropped.X1Z1.v;
w = cropped.X1Z1.w;

oldXMax = max(data.X1Z1.X, [], 'all');
oldXMin = min(data.X1Z1.X, [], 'all');
oldYMax = max(data.X1Z1.Y, [], 'all');
oldYMin = min(data.X1Z1.Y, [], 'all');

figure();
tiledlayout(3,1);
sgtitle('UW', 'interpreter', 'none')

ax1=nexttile;
contourf(X, Y, u, 100, 'linestyle', 'none')
colormap(ax1, 'parula');
axis equal
xlim([oldXMin, oldXMax])
ylim([oldYMin, oldYMax])
xline(100)
xline(-100)
yline(100)
yline(-100)
colorbar()
title('u')

ax2=nexttile;
contourf(X, Y, v, 100, 'linestyle', 'none')
colormap(ax2, 'coolwarm');
axis equal
xlim([oldXMin, oldXMax])
ylim([oldYMin, oldYMax])
xline(100)
xline(-100)
yline(100)
yline(-100)
colorbar()
title('v')

ax3=nexttile;
contourf(X, Y, w, 100, 'linestyle', 'none')
colormap(ax3, 'coolwarm');
axis equal
xlim([oldXMin, oldXMax])
ylim([oldYMin, oldYMax])
xline(100)
xline(-100)
yline(100)
yline(-100)
colorbar() 
title('w')

clear X Y u v w ax1 ax2 ax3
clear oldXMin oldXMax oldYMin oldYMax

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HORIZONTAL STITCH: BOTTOM ROW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load coordinates and u velocity
X11 = cropped.X1Z1.X;
Y11 = cropped.X1Z1.Y;
U11 = cropped.X1Z1.vw;

X21 = cropped.X2Z1.X;
Y21 = cropped.X2Z1.Y;
U21 = cropped.X2Z1.vw;

%%% ZEIN: figure out closest pixel shift based on how far we need to shift
designedOverlap = 40; % mm
plateHalfWidth = 100; % mm
[~, horizontalShift] = min(abs(cropped.X1Z1.X(1,:) - (plateHalfWidth - designedOverlap)));

% Horizontal Shift for alignment
% horizontalShift = 303;

% Horizontal padding (zero pad to make room for stitching)
[OGplaneHeight, OGplaneWidth] = size(X11);
zeroPad = zeros(OGplaneHeight, horizontalShift);

% Generate fading mask for overlap
fadeMask = ones(OGplaneHeight, OGplaneWidth);
horizontalOverlap = OGplaneWidth - horizontalShift;
fadeMask(:, horizontalShift+1:end) = repmat(linspace(1, 0, horizontalOverlap), OGplaneHeight, 1);

% Apply horizontal fading
U11Faded = fadeMask .* U11;
U21Faded = fliplr(fadeMask) .* U21;

% Add zero pads to planes
U11Padded = horzcat(U11Faded, zeroPad);
U21Padded = horzcat(zeroPad, U21Faded);

% Combine planes
combinedBottom = U11Padded + U21Padded;

% Extend the X and Y coordinate system accordingly
resolution = mean(diff(X11(1,:)));
extendedX = horzcat(X11, X11(:, 1:horizontalShift) + range(X11(1,:)) + resolution);
extendedY = horzcat(Y11, Y11(:, 1:horizontalShift));

clear zeroPad fadeMask U11Faded U21Faded

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT CHECK: BOTTOM ROW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure()
% tiledlayout(3,1)
% 
% U11_plot = U11Padded;
% U11_plot(U11_plot == 0) = nan;
% 
% U21_plot = U21Padded;
% U21_plot(U21_plot == 0) = nan;
% 
% nexttile
% contourf(extendedX, extendedY, U11_plot, 500, 'linestyle', 'none')
% axis equal
% 
% nexttile
% contourf(extendedX, extendedY, U21_plot, 500, 'linestyle', 'none')
% axis equal
% 
% nexttile
% contourf(extendedX, extendedY, combinedBottom, 500, 'linestyle', 'none')
% axis equal
% 
% clear ax1 ax2 ax3 U11_plot U21_plot U11Padded U21Padded


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HORIZONTAL STITCH: TOP ROW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load coordinates and velocity
X12 = cropped.X1Z2.X;
Y12 = cropped.X1Z2.Y;
U12 = cropped.X1Z2.vw;

X22 = cropped.X2Z2.X;
Y22 = cropped.X2Z2.Y;
U22 = cropped.X2Z2.vw;

%%% ZEIN: figure out closest pixel shift based on how far we need to shift
designedOverlap = 40; % mm
plateHalfWidth = 100; % mm
[~, horizontalShift] = min(abs(cropped.X1Z1.X(1,:) - (plateHalfWidth - designedOverlap)));

% Horizontal padding (zero pad to make room for stitching)
[OGplaneHeight, OGplaneWidth] = size(X11);
zeroPad = zeros(OGplaneHeight, horizontalShift);

% Apply horizontal fading (same as for U)
fadeMask = ones(OGplaneHeight, OGplaneWidth);
horizontalOverlap = OGplaneWidth - horizontalShift;
fadeMask(:, horizontalShift+1:end) = repmat(linspace(1, 0, horizontalOverlap), OGplaneHeight, 1);

% Apply horizontal fading
U12Faded = fadeMask .* U12;
U22Faded = fliplr(fadeMask) .* U22;

% Add zero pads
U12Padded = horzcat(U12Faded, zeroPad);
U22Padded = horzcat(zeroPad, U22Faded);

% Combine planes
combinedTop = U12Padded + U22Padded;

% Extend the X and Y coordinate system accordingly
resolution = mean(diff(X11(1,:)));
extendedX = horzcat(X11, X11(:, 1:horizontalShift) + range(X11(1,:)) +  resolution);
extendedY = horzcat(Y11, Y11(:, 1:horizontalShift));

clear zeroPad fadeMask U12Faded U22Faded

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT CHECK: TOP ROW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure()
% tiledlayout(3,1)
% 
% U12_plot = U12Padded;
% U12_plot(U12_plot == 0) = nan;
% 
% U22_plot = U22Padded;
% U22_plot(U22_plot == 0) = nan;
% 
% nexttile
% contourf(extendedX, extendedY, U12_plot, 500, 'linestyle', 'none')
% axis equal
% 
% nexttile
% contourf(extendedX, extendedY, U22_plot, 500, 'linestyle', 'none')
% axis equal
% 
% nexttile
% contourf(extendedX, extendedY, combinedTop, 500, 'linestyle', 'none')
% axis equal
% 
% clear ax1 ax2 ax3 U12_plot U22_plot U12Padded U22Padded


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VERTICAL STITCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


designedVerticalOverlap = 20; % mm
plateHalfWidth = 100; % mm
[~, verticalShift] = min(abs(cropped.X1Z1.Y(:,1) - (plateHalfWidth - designedVerticalOverlap)));
verticalShift = OGplaneHeight - verticalShift;

% Get image size
[combinedImageHeight, combinedImageWidth] = size(combinedTop);
zeroPad = zeros(verticalShift, combinedImageWidth);

% Compute blending mask (fades vertically now)
verticalOverlap  = combinedImageHeight - verticalShift;
fadeMask = ones(combinedImageHeight, combinedImageWidth);
fadeMask(verticalShift+1:end, :) = repmat(linspace(1, 0, verticalOverlap)', 1, combinedImageWidth);

% Apply blending mask
topFaded = fadeMask .* combinedTop;
bottomFaded = flipud(fadeMask) .* combinedBottom;

% Apply zero pads
topPadded = vertcat(topFaded, zeroPad);
bottomPadded = vertcat(zeroPad, bottomFaded);

% Combine rows
completeImage = topPadded + bottomPadded;

% Extend the coordinate system
resolution = mean(diff(X11(1,:)));
completeX = vertcat(extendedX, extendedX(1:verticalShift, :));
completeY = vertcat(extendedY(1:verticalShift, :) + range(extendedY(1:verticalShift,1)) +  resolution, extendedY);


%% Plot

% topPaddedPlot = topPadded;
% topPaddedPlot(topPaddedPlot == 0) = nan;
% 
% bottomPaddedPlot = bottomPadded;
% bottomPaddedPlot(bottomPaddedPlot == 0) = nan;
% 
% lineWidth = 3;
% 
% figure();
% tiledlayout(1,3)
% 
% nexttile
% contourf(completeX, completeY, topPaddedPlot, 100, 'linestyle', 'none');
% axis equal
% colormap jet
% clim([0, 1])
% 
% nexttile
% contourf(completeX, completeY, bottomPaddedPlot, 100, 'linestyle', 'none');
% axis equal
% colormap jet
% clim([0, 1])
% nexttile

figure()
contourf(completeX, completeY, completeImage, 500, 'linestyle', 'none');
axis equal
colormap coolwarm
colorbar()
% clim([0, 1])
xline(min(completeX, [], "all") + range(completeX(1,:)) / 2, "LineWidth", lineWidth)
yline(min(completeY, [], "all") + range(completeY(:,1)) / 2, "LineWidth", lineWidth)







