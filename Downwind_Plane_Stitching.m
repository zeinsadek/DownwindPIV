%% Zein Downwind Blending

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

% Load data for all 4 planes all at once
project_path = '/Users/zeinsadek/Desktop/Experiments/Downwind/Processed/means';
orientation  = 'UW';

% Rotor diameter in mm
D = 200;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOADING MEANS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
% COMBINE PLANES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

components = {'u', 'v', 'w', 'uu', 'vv', 'ww', 'uv', 'uw', 'vw'};

for c = 1:length(components)
    component = components{c};

    %%% Blend Top / Bottom Row
    % Bottom Left
    X11 = cropped.X1Z1.X;
    Y11 = cropped.X1Z1.Y;
    U11 = cropped.X1Z1.(component);
    % Bottom Right
    X21 = cropped.X2Z1.X;
    Y21 = cropped.X2Z1.Y;
    U21 = cropped.X2Z1.(component);

    % Top Left
    X12 = cropped.X1Z2.X;
    Y12 = cropped.X1Z2.Y;
    U12 = cropped.X1Z2.(component);
    % Top Right
    X22 = cropped.X2Z2.X;
    Y22 = cropped.X2Z2.Y;
    U22 = cropped.X2Z2.(component);

    %%% ZEIN: figure out closest pixel shift based on how far we need to shift
    designedHorizontalOverlap = 40; % mm
    plateHalfWidth = 100; % mm
    [~, horizontalShift] = min(abs(cropped.X1Z1.X(1,:) - (plateHalfWidth - designedHorizontalOverlap)));

    % Horizontal padding (zero pad to make room for stitching)
    [OGplaneHeight, OGplaneWidth] = size(X11);
    zeroPad = zeros(OGplaneHeight, horizontalShift);
    
    % Generate fading mask for overlap
    fadeMask = ones(OGplaneHeight, OGplaneWidth);
    horizontalOverlap = OGplaneWidth - horizontalShift;
    fadeMask(:, horizontalShift+1:end) = repmat(linspace(1, 0, horizontalOverlap), OGplaneHeight, 1);
    
    %%% Apply horizontal fading
    % Bottom
    U11Faded = fadeMask .* U11;
    U21Faded = fliplr(fadeMask) .* U21;
    % Top 
    U12Faded = fadeMask .* U12;
    U22Faded = fliplr(fadeMask) .* U22;
    
    %%% Add zero pads to planes
    % Bottom
    U11Padded = horzcat(U11Faded, zeroPad);
    U21Padded = horzcat(zeroPad, U21Faded);
    % Top
    U12Padded = horzcat(U12Faded, zeroPad);
    U22Padded = horzcat(zeroPad, U22Faded);
    
    %%% Combine planes
    % Bottom
    combinedBottom = U11Padded + U21Padded;
    % Top
    combinedTop = U12Padded + U22Padded;
    
    % Extend the X and Y coordinate system accordingly
    resolution = mean(diff(X11(1,:)));
    extendedX = horzcat(X11, X11(:, 1:horizontalShift) + range(X11(1,:)) + resolution);
    extendedY = horzcat(Y11, Y11(:, 1:horizontalShift));


    %%% Combine Vertically
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
    completeX = vertcat(extendedX, extendedX(1:verticalShift, :));
    completeY = vertcat(extendedY(1:verticalShift, :) + range(extendedY(1:verticalShift,1)) +  resolution, extendedY);

    %%% Adjust origin
    % Center X at turbine (0.5D gap from turbine to edge of plate)
    completeX = completeX - min(completeX, [], "all") + (0.5 * D);
    % Center Y to hub height (~90mm above plate origin for X1Z1)
    completeY = completeY - 90;

    %%% Save output
    % Save image
    combined.(component) = completeImage;

    % Save coordinates
    combined.X = completeX;
    combined.Y = completeY;

    % Save were 'seams' are
    combined.X_seam = min(completeX, [], "all") + range(completeX(1,:)) / 2;
    combined.Y_seam = min(completeY, [], "all") + range(completeY(:,1)) / 2;


end

% Clear up RAM
clear X11 X12 X21 X22 Y11 Y12 Y21 Y22
clear U11 U11Faded U11Padded
clear U12 U12Faded U12Padded
clear U21 U21Faded U21Padded
clear U22 U22Faded U22Padded
clear zeroPad topPadded bottomPadded topFaded bottomFaded
clear plateHalfWidth OGplaneHeight OGplaneWidth fadeMask extendedX extendedY
clear combinedBottom combinedTop combinedImageWidth combinedImageHeight 
clear completeImage completeX completeY component c resolution
clear designedHorizontalOverlap designedVerticalOverlap 
clear verticalShift horizontalShift horizontalOverlap verticalOverlap

% Clear older version of data
clear rotated_means data

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD COMBINED DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Coordinates
X = combined.X / D;
Y = combined.Y / D;

X_seam = combined.X_seam / D;
Y_seam = combined.Y_seam / D;

% Velocity
u = combined.u;
v = combined.v;
w = combined.w;

% Normal stresses
uu = combined.uu;
vv = combined.vv;
ww = combined.ww;

% Shear stresses
uv = combined.uv;
uw = combined.uw;
vw = combined.vw;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING: VELOCITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

levels = 100;
lineWidth = 3;
fontSize = 20;

xMax = 2.3;
yMax = 0.9;

close all;
figure()
tiledlayout(1,3)
sgtitle(orientation);

ax1 = nexttile;
contourf(X, Y, u, levels, 'linestyle', 'none');
xline(X_seam, 'LineWidth', lineWidth)
yline(Y_seam, 'LineWidth', lineWidth)
axis equal
xlim([0, xMax])
ylim([-yMax, yMax])
title('$u / u_{\infty}$', 'Interpreter', 'latex', 'FontSize', fontSize)
colormap(ax1, 'jet')
colorbar()
clim([0.1, 1])
xlabel('$ x / D$', 'interpreter', 'latex', 'FontSize', fontSize)
ylabel('$ y / D$', 'interpreter', 'latex', 'FontSize', fontSize)


ax2 = nexttile;
contourf(X, Y, v, levels, 'linestyle', 'none')
xline(X_seam, 'LineWidth', lineWidth)
yline(Y_seam, 'LineWidth', lineWidth)
axis equal
xlim([0,xMax])
ylim([-yMax, yMax])
title('$v / u_{\infty}$', 'Interpreter', 'latex', 'FontSize', fontSize)
colormap(ax2, 'coolwarm')
colorbar()
clim([-0.1, 0.1])
xlabel('$ x / D$', 'interpreter', 'latex', 'FontSize', fontSize)


ax3 = nexttile;
contourf(X, Y, w, levels, 'linestyle', 'none')
xline(X_seam, 'LineWidth', lineWidth)
yline(Y_seam, 'LineWidth', lineWidth)
axis equal
xlim([0, xMax])
ylim([-yMax, yMax])
title('$w / u_{\infty}$', 'Interpreter', 'latex', 'FontSize', fontSize)
colormap(ax3, 'coolwarm')
colorbar()
clim([-0.3, 0.3])
xlabel('$ x / D$', 'interpreter', 'latex', 'FontSize', fontSize)


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING: NORMAL STRESSES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

levels = 100;
lineWidth = 3;
fontSize = 20;

xMax = 2.3;
yMax = 0.9;

close all;
figure()
tiledlayout(1,3)
sgtitle(orientation);

ax1 = nexttile;
contourf(X, Y, uu, levels, 'linestyle', 'none');
xline(X_seam, 'LineWidth', lineWidth)
yline(Y_seam, 'LineWidth', lineWidth)
axis equal
xlim([0, xMax])
ylim([-yMax, yMax])
title("$\overline{u'u'} / \left({u_{\infty}}\right)^2$", 'Interpreter', 'latex', 'FontSize', fontSize)
colormap(ax1, 'jet')
colorbar()
clim([0, 0.015])
xlabel('$ x / D$', 'interpreter', 'latex', 'FontSize', fontSize)
ylabel('$ y / D$', 'interpreter', 'latex', 'FontSize', fontSize)


ax2 = nexttile;
contourf(X, Y, vv, levels, 'linestyle', 'none')
xline(X_seam, 'LineWidth', lineWidth)
yline(Y_seam, 'LineWidth', lineWidth)
axis equal
xlim([0,xMax])
ylim([-yMax, yMax])
title("$\overline{v'v'} / \left({u_{\infty}}\right)^2$", 'Interpreter', 'latex', 'FontSize', fontSize)
colormap(ax2, 'jet')
colorbar()
clim([0, 0.015])
xlabel('$ x / D$', 'interpreter', 'latex', 'FontSize', fontSize)


ax3 = nexttile;
contourf(X, Y, ww, levels, 'linestyle', 'none')
xline(X_seam, 'LineWidth', lineWidth)
yline(Y_seam, 'LineWidth', lineWidth)
axis equal
xlim([0, xMax])
ylim([-yMax, yMax])
title("$\overline{w'w'} / \left({u_{\infty}}\right)^2$", 'Interpreter', 'latex', 'FontSize', fontSize)
colormap(ax3, 'jet')
colorbar()
clim([0, 0.015])
xlabel('$ x / D$', 'interpreter', 'latex', 'FontSize', fontSize)


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING: SHEAR STRESSES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

levels = 100;
lineWidth = 3;
fontSize = 20;

xMax = 2.3;
yMax = 0.9;

close all;
figure()
tiledlayout(1,3)
sgtitle(orientation);

ax1 = nexttile;
contourf(X, Y, uv, levels, 'linestyle', 'none');
xline(X_seam, 'LineWidth', lineWidth)
yline(Y_seam, 'LineWidth', lineWidth)
axis equal
xlim([0, xMax])
ylim([-yMax, yMax])
title("$\overline{u'v'} / \left({u_{\infty}}\right)^2$", 'Interpreter', 'latex', 'FontSize', fontSize)
colormap(ax1, 'coolwarm')
colorbar()
clim([-0.004, 0.004])
xlabel('$ x / D$', 'interpreter', 'latex', 'FontSize', fontSize)
ylabel('$ y / D$', 'interpreter', 'latex', 'FontSize', fontSize)


ax2 = nexttile;
contourf(X, Y, uw, levels, 'linestyle', 'none')
xline(X_seam, 'LineWidth', lineWidth)
yline(Y_seam, 'LineWidth', lineWidth)
axis equal
xlim([0,xMax])
ylim([-yMax, yMax])
title("$\overline{u'w'} / \left({u_{\infty}}\right)^2$", 'Interpreter', 'latex', 'FontSize', fontSize)
colormap(ax2, 'coolwarm')
colorbar()
clim([-0.002, 0.002])
xlabel('$ x / D$', 'interpreter', 'latex', 'FontSize', fontSize)


ax3 = nexttile;
contourf(X, Y, vw, levels, 'linestyle', 'none')
xline(X_seam, 'LineWidth', lineWidth)
yline(Y_seam, 'LineWidth', lineWidth)
axis equal
xlim([0, xMax])
ylim([-yMax, yMax])
title("$\overline{v'w'} / \left({u_{\infty}}\right)^2$", 'Interpreter', 'latex', 'FontSize', fontSize)
colormap(ax3, 'coolwarm')
colorbar()
clim([-0.002, 0.002])
xlabel('$ x / D$', 'interpreter', 'latex', 'FontSize', fontSize)

