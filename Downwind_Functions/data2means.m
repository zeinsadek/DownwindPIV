% This function converts the Matlab vector data from PIV to Means 
% and Reynolds Stresses for further processing.
% Ondrej Fercak, Zein Sadek, 3/21/2022

% out_path:     Folder where new struct file will be saved.
% out_name:     Name of new struct file.
% inst_struct:  Matlab data struct as input for calculations.

function output = data2means(out_path, inst_struct, depth)

%     Dia     = 33.63;    % mm

    % Check if Save Folder Exists. [if not, create]
    if exist(out_path, 'file')
        fprintf('<data2means> *Save Folder was Previously Created. \n')
    else
        fprintf('<data2means> *Creating New Save Floder. \n')
        %mkdir(out_path);
    end
   
    if nargin == 2
        % Extract Image Depth/Length [D].
        D = inst_struct.D;
    elseif nargin == 3
        D = depth;
    else
        fprintf('Input Error!')
    end

    fprintf('D Check = %d! \n', D)

    % Extract Instantaneous Velocities from Struct.
    inst_u  = inst_struct.U;
    inst_v  = inst_struct.V;
    inst_w  = inst_struct.W;
    x       = inst_struct.X;
    y       = inst_struct.Y;

    % Calculate Velocity Means
    output.u = mean(inst_u, 3, 'omitnan');
    output.v = mean(inst_v, 3, 'omitnan');
    output.w = mean(inst_w, 3, 'omitnan');

    % Create Reynolds Stress Objects
    uu_p = zeros(length(y(1,:)), length(x(:,1)), D);
    vv_p = zeros(length(y(1,:)), length(x(:,1)), D);
    ww_p = zeros(length(y(1,:)), length(x(:,1)), D);
    
    uv_p = zeros(length(y(1,:)), length(x(:,1)), D);
    uw_p = zeros(length(y(1,:)), length(x(:,1)), D);
    vw_p = zeros(length(y(1,:)), length(x(:,1)), D);

    % Loop Through Each Frame in Struct.
    fprintf('\n<data2means> PROGRESS: ');
    for frame_number = 1:D
        
        % Print Progress.
        progressbarText(frame_number/D);
        
        % Instantaneous Fluctuations.
        u_pi = inst_u(:, :, frame_number) - output.u;
        v_pi = inst_v(:, :, frame_number) - output.v;
        w_pi = inst_w(:, :, frame_number) - output.w;

        % Instantaneous Stresses.
        uu_pi = u_pi.*u_pi;
        vv_pi = v_pi.*v_pi;
        ww_pi = w_pi.*w_pi;

        uv_pi = u_pi.*v_pi;
        uw_pi = u_pi.*w_pi;
        vw_pi = v_pi.*w_pi;

        % Array of Mean Stresses.
        uu_p(:, :, frame_number) = uu_pi;
        vv_p(:, :, frame_number) = vv_pi;
        ww_p(:, :, frame_number) = ww_pi;

        uv_p(:, :, frame_number) = uv_pi;
        uw_p(:, :, frame_number) = uw_pi;
        vw_p(:, :, frame_number) = vw_pi;

    end

    % Mean Stresses.
    output.uu = mean(uu_p, 3, 'omitnan');
    output.vv = mean(vv_p, 3, 'omitnan');
    output.ww = mean(ww_p, 3, 'omitnan');

    output.uv = mean(uv_p, 3, 'omitnan');
    output.uw = mean(uw_p, 3, 'omitnan');
    output.vw = mean(vw_p, 3, 'omitnan');
    
    output.X = x;
    output.Y = y;
    output.D = D;
    
    % Save Matlab File.
    fprintf('\n<data2means> Saving Data to File... \n');
    save(out_path, 'output');
    clc; fprintf('\n<data2means> Data Save Complete \n')
end
