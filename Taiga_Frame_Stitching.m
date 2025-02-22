%% Taiga and Zein Downwind Blending

%    Order of Images
%   |      ||      |
%   |   1  ||   2  |
%   |______||______|
%   |      ||      |
%   |   3  ||   4  |
%   |      ||      |

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
orientation  = 'UW';

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
% TO-DO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Have a loop that corrects all of the signs and flips for all the components

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

%% test plot x, y, and velocity after flipping

X = data.X1Z1.X;
Y = data.X1Z1.Y;
u = rotated_means.X1Z1.u;
v = rotated_means.X1Z1.v;
w = rotated_means.X1Z1.w;

figure();
tiledlayout(3,1);
sgtitle('UW', 'interpreter', 'none')

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

clear X Y u v w

%% Have a loop that crops each velocity/stress to just the plate area

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


%% test plot x, y, and velocity after cropping

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

clear X Y u v w
clear oldXMin oldXMax oldYMin oldYMax



%% test stitching of u, x, y horizontally

% Extract cropped X, Y, and U for each plane
X11 = cropped.X1Z1.X;
Y11 = cropped.X1Z1.Y;
U11 = cropped.X1Z1.u;

X12 = cropped.X1Z2.X;
Y12 = cropped.X1Z2.Y;
U12 = cropped.X1Z2.u;

X21 = cropped.X2Z1.X;
Y21 = cropped.X2Z1.Y;
U21 = cropped.X2Z1.u;

X22 = cropped.X2Z2.X;
Y22 = cropped.X2Z2.Y;
U22 = cropped.X2Z2.u;

%% Horizontal Stitching
% Horizontal Shift for alignment
horizontalShift = 190;  % Adjust based on your overlap

% Horizontal padding (zero pad to make room for stitching)
[OGplaneHeight, OGplaneWidth] = size(cropped.X1Z1.X);
zeroPad = zeros(OGplaneHeight, horizontalShift);

% Apply horizontal fading (same as for U)
fadeMask = ones(OGplaneHeight, OGplaneWidth);
horizontalOverlap = OGplaneWidth - horizontalShift;
fadeMask(:, horizontalShift+1:end) = repmat(linspace(1, 0, horizontalOverlap), OGplaneHeight, 1);

% Faded planes for X, Y, and U
X1Faded = fadeMask .* double(X11);
X3Faded = fadeMask .* double(X21);

X2Faded = fliplr(fadeMask) .* double(X12);
X4Faded = fliplr(fadeMask) .* double(X22);

Y1Faded = fadeMask .* double(Y11);
Y3Faded = fadeMask .* double(Y21);

Y2Faded = fliplr(fadeMask) .* double(Y12);
Y4Faded = fliplr(fadeMask) .* double(Y22);

U1Faded = fadeMask .* double(U11);
U3Faded = fadeMask .* double(U21);

U2Faded = fliplr(fadeMask) .* double(U12);
U4Faded = fliplr(fadeMask) .* double(U22);

% Padding for horizontal stitching
X1Padded = horzcat(X1Faded, zeroPad);
X3Padded = horzcat(X3Faded, zeroPad);
X2Padded = horzcat(zeroPad, X2Faded);
X4Padded = horzcat(zeroPad, X4Faded);

Y1Padded = horzcat(Y1Faded, zeroPad);
Y3Padded = horzcat(Y3Faded, zeroPad);
Y2Padded = horzcat(zeroPad, Y2Faded);
Y4Padded = horzcat(zeroPad, Y4Faded);

U1Padded = horzcat(U1Faded, zeroPad);
U3Padded = horzcat(U3Faded, zeroPad);
U2Padded = horzcat(zeroPad, U2Faded);
U4Padded = horzcat(zeroPad, U4Faded);

% Combine planes horizontally
combinedXTop = X1Padded + X2Padded;
combinedYTop = Y1Padded + Y2Padded;
combinedUTop = U1Padded + U2Padded;

combinedXBottom = X3Padded + X4Padded;
combinedYBottom = Y3Padded + Y4Padded;
combinedUBottom = U3Padded + U4Padded;

% Extend the X and Y coordinate system accordingly
extendedX = horzcat(X11, X11(:, 1:horizontalShift)+ OGplaneWidth);
extendedY = horzcat(Y11, Y11(:, 1:horizontalShift));

%% Vertical Stitching
verticalShift = 190;  % Adjust based on your vertical overlap

% Padding for vertical stitching
[combinedPlaneHeight, combinedPlaneWidth] = size(combinedXTop);
zeroPad = zeros(verticalShift, combinedPlaneWidth);

% Apply vertical fading (same as for U)
verticalOverlap = combinedPlaneHeight - verticalShift;
fadeMask = ones(combinedPlaneHeight, combinedPlaneWidth);
fadeMask(verticalShift+1:end, :) = repmat(linspace(1, 0, verticalOverlap)', 1, combinedPlaneWidth);

% Apply fading to the planes
topFadedX = flipud(fadeMask) .* double(combinedXTop);
bottomFadedX = fadeMask .* double(combinedXBottom);

topFadedY = flipud(fadeMask) .* double(combinedYTop);
bottomFadedY = fadeMask .* double(combinedYBottom);

topFadedU = flipud(fadeMask) .* double(combinedUTop);
bottomFadedU = fadeMask .* double(combinedUBottom);

% Pad images with zeroes for vertical stitching
topPaddedX = vertcat(zeroPad, topFadedX);
bottomPaddedX = vertcat(bottomFadedX, zeroPad);

topPaddedY = vertcat(zeroPad, topFadedY);
bottomPaddedY = vertcat(bottomFadedY, zeroPad);

topPaddedU = vertcat(zeroPad, topFadedU);
bottomPaddedU = vertcat(bottomFadedU, zeroPad);

% Combine images vertically
completeX = topPaddedX + bottomPaddedX;
completeY = topPaddedY + bottomPaddedY;
completeU = topPaddedU + bottomPaddedU;

% Extend the coordinate system vertically
completeX = vertcat(extendedX, extendedX(1:verticalShift, :));
completeY = vertcat(extendedY, extendedY(1:verticalShift, :) + combinedPlaneHeight);

%% Final Plotting

% Plot final stitched image for X, Y, U
figure;
colormap("parula");
contourf(completeX, completeY, completeU, 100, 'linestyle', 'none');
axis equal;
%xlim([0, OGplaneWidth + horizontalShift]);
%ylim([0, OGplaneHeight + verticalShift]);
title('Final Stitched Image for U (Velocity in X Direction)');

% % Show outline of four quadrants
% xline(completePlaneWidth / 2, 'color', 'blue', 'LineWidth', lineWidth, 'alpha', alpha)
% yline(completePlaneHeight / 2, 'color', 'blue', 'LineWidth', lineWidth, 'alpha', alpha)
% 
% % Show which regions were blended
% xline(completePlaneWidth / 2 + horizontalOverlap / 2, 'color', 'red', 'LineWidth', lineWidth, 'alpha', alpha)
% xline(completePlaneWidth / 2 - horizontalOverlap / 2, 'color', 'red', 'LineWidth', lineWidth, 'alpha', alpha)
% yline(completePlaneHeight / 2 + verticalOverlap / 2, 'color', 'red', 'LineWidth', lineWidth, 'alpha', alpha)
% yline(completePlaneHeight / 2 - verticalOverlap / 2, 'color', 'red', 'LineWidth', lineWidth, 'alpha', alpha)


% Begin the alignment and ovelapping...


% Overlap and blend just horizontally, and then verticaly

% shift to be correct distance from tower?




