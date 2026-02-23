%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PATHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;
clc; clear; close all;
addpath('C:\Users\sadek\Desktop\readimx-v2.1.9-win64');
addpath('C:\Users\sadek\Desktop\ZeinPIVCodes_Github\DownwindPIV\Downwind_Functions');
addpath('C:\Program Files\MATLAB\slanCM')

% Load data for all 2 planes all at once
orientation  = 'DW';
coning = 'CN00';
tower = 'LM4B';
x_location = '3';

caze_folder = strcat(orientation, '_', tower, '_', coning);
project_path = 'F:\PIVYZ\new_results'; 

% Rotor diameter in mm
D = 200;
u_inf = 3;
components = {'u', 'v', 'w','uu', 'vv','ww','uv','uw', 'vw'};


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOADING MEANS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:2
    % Generate case name and path
    recording_name = strcat(orientation, '_', tower, '_', coning, '_PLYZ_X', x_location, '_Z', num2str(i), '_MEANS.mat');
    piv_path       = fullfile(project_path, 'means', recording_name);
    location_tag   = strcat('X', x_location, 'Z', num2str(i));
    
    % Load data into temp and store into structure
    tmp = load(piv_path);
    data.(location_tag) = tmp.output;
end

clear i location_tag recording_name tmp piv_path

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NORMALIZE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:2
    location_tag   = strcat('X', x_location, 'Z', num2str(i));
    tmp = data.(location_tag);
    
    for c = 1:length(components)
        component = components{c};
        
        % Load mean
        tmp_mean = tmp.(component);

        % Non-dimensionalize means
        if ismember(component, {'u', 'v', 'w'})
            tmp_mean = tmp_mean / u_inf;
        end

        % Non-dimensionalize stresses
         if ismember(component, {'uu', 'vv', 'ww', 'uv', 'uw', 'vw' })
            tmp_mean = tmp_mean / (u_inf^2);
         end

        % Save to new variable
        data.(location_tag).(component) = tmp_mean;
    end
end

clear c component i location_tag tmp tmp_mean


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CROP DATA JUST TO PLATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:2

    location_tag   = strcat('X', x_location, 'Z', num2str(i));
    tmp = data.(location_tag);
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
    cropped.(location_tag).X = -tmp_x(top_idx:bottom_idx, right_idx:left_idx);
    cropped.(location_tag).Y = tmp_y(top_idx:bottom_idx, right_idx:left_idx);


    for c = 1:length(components)
        component = components{c};
        temp_comp = tmp.(component);

        % Crop/ Index X1, Y1, X3, Y3 and all means and stresses and Save to new variable
        cropped.(location_tag).(component) = fliplr(temp_comp(top_idx:bottom_idx, right_idx:left_idx));
    end
end

clear left_cutoff right_cutoff top_cutoff bottom_cutoff
clear left_idx right_idx top_idx bottom_idx location_tag
clear tmp component temp_comp tmp_x tmp_y x y c i

%% test plot

loc = ['X', x_location, 'Z1'];

figure()
hold on
contourf((cropped.(loc).X - 65) / D, (cropped.(loc).Y - 90) / D, cropped.(loc).u, 100, 'linestyle', 'none')
circle(0,0,0.5);
hold off
axis equal

%% Combine planes: loop through components

plateHalfWidth = 100; % mm
designedVerticalOverlap = 20; % mm

for c = 1:length(components)
    component = components{c};

    image1 = cropped.(['X', x_location, 'Z1']).(component);
    image2 = cropped.(['X', x_location, 'Z2']).(component);
    
    X = cropped.(['X', x_location, 'Z1']).X;
    Y = cropped.(['X', x_location, 'Z1']).Y;
    
    % Get image size
    [imageHeight, imageWidth] = size(image1);
    
    
    % Vertical shift amoun
    [~, verticalShift] = min(abs(Y(:,1) - (plateHalfWidth - designedVerticalOverlap)));
    verticalShift = imageHeight - verticalShift;
    
    % Compute blending mask (fades vertically now)
    overlap  = imageHeight - verticalShift;
    fadeMask = ones(imageHeight, imageWidth);
    fadeMask(verticalShift+1:end, :) = repmat(linspace(1, 0, overlap)', 1, imageWidth);
    
    % Apply blending mask
    image1Faded = flipud(fadeMask) .* double(image1);
    image2Faded = fadeMask .* double(image2);
    
    % Pad images with zeroes in order to combine
    zeroPad = zeros(verticalShift, imageWidth);
    image1Padded = vertcat(zeroPad, image1Faded);
    image2Padded = vertcat(image2Faded, zeroPad);
    
    % Combine images by adding
    combinedImage = image1Padded + image2Padded;
    
    % Extend the coordinate system
    resolution = mean(diff(X(1,:)));
    extendedX = vertcat(X, X(1:verticalShift, :));
    extendedY = vertcat(Y(1:verticalShift, :) + range(Y(1:verticalShift,1)) +  resolution, Y);

    % Save values
    combined.(component) = combinedImage;
    combined.X = (extendedX - 65) / D;
    combined.Y = (extendedY - 90) / D;
end

clear image1 image2 X Y zeroPad verticalShift overlap fadeMask component data cropped
clear designedVerticalOverlap imageHeight imageWidth plateHalfWidth
clear image1Faded image1Padded image2Faded image2Padded
clear resolution extendedX extendedY combinedImage c j

%% Plot: mean velocities

figure()
tiledlayout(1,3)

ax1 = nexttile;
contourf(combined.X, combined.Y, combined.u, 100, 'linestyle', 'none')
axis equal
colormap(ax1, slanCM('parula'))
colorbar
title('u')

ax2 = nexttile;
contourf(combined.X, combined.Y, combined.v, 100, 'linestyle', 'none')
axis equal
colormap(ax2, slanCM('coolwarm'))
colorbar
title('v')

ax3 = nexttile;
contourf(combined.X, combined.Y, combined.w, 100, 'linestyle', 'none')
axis equal
colormap(ax3, slanCM('coolwarm'))
colorbar
title('w')

clc;

%% Plot: normal stresses

figure()
tiledlayout(1,3)

ax1 = nexttile;
contourf(combined.X, combined.Y, combined.uu, 100, 'linestyle', 'none')
axis equal
colorbar()
colormap(ax1, 'parula')
title('uu')

ax2 = nexttile;
contourf(combined.X, combined.Y, combined.vv, 100, 'linestyle', 'none')
axis equal
colorbar()
colormap(ax2, 'parula')
title('vv')

ax3 = nexttile;
contourf(combined.X, combined.Y, combined.ww, 100, 'linestyle', 'none')
axis equal
colorbar()
colormap(ax3, 'parula')
title('ww')

clc;

%% Plot: shear stresses

figure()
tiledlayout(1,3)

ax1 = nexttile;
contourf(combined.X, combined.Y, combined.uv, 100, 'linestyle', 'none')
axis equal
colorbar()
colormap(ax1, slanCM('coolwarm'))
title('uv')

ax2 = nexttile;
contourf(combined.X, combined.Y, combined.uw, 100, 'linestyle', 'none')
axis equal
colorbar()
colormap(ax2, slanCM('coolwarm'))
title('uw')

ax3 = nexttile;
contourf(combined.X, combined.Y, combined.vw, 100, 'linestyle', 'none')
axis equal
colorbar()
colormap(ax3, slanCM('coolwarm'))
title('vw')
clc;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE TO MATFILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save_path = fullfile(project_path, 'combined', caze_folder);
save_name = strcat(orientation, '_', tower, '_', coning, '_PIVYZ_X', x_location, '_COMBINED.mat');

if ~exist(save_path, 'dir')
    mkdir(save_path);
end

save(fullfile(save_path, save_name), 'combined');
fprintf('Saved matfile!\n')


%% Functions

function h = circle(x,y,r)
    hold on
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    h = plot(xunit, yunit);
    hold off
end


