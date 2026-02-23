%% Generate a movie of the Downwind PIV


clc; close all; clear
addpath('/Users/zeinsadek/Desktop/Experiments/PIV/Processing/Farm/Farm_Functions');
addpath('/Users/zeinsadek/Desktop/Experiments/PIV/Processing/Farm/Farm_Functions/Inpaint_nans/Inpaint_nans');

data = load('/Users/zeinsadek/Library/Mobile Documents/com~apple~CloudDocs/Data/Downwind/data/PIVXY/DW_LM00_CN00_PLXY_X1_Z2_DATA.mat');
data = data.output;

X = data.X;
Y = data.Y;

U = data.U;
V = data.V;
W = data.W;

%%

num_images = 50;
FPS        = 5;
levels     = 100;

v = VideoWriter('/Users/zeinsadek/Downloads/DownwindTestMovie_W.mp4','MPEG-4');
v.FrameRate = FPS;
open(v)

clc; close all;
for i = 1:num_images
    progressbarText(i/num_images);
    ax = figure('Visible', 'off');

    % Remove Ticks
    set(gca,'YTickLabel',[]);
    set(gca,'XTickLabel',[]);

    hold on
    colormap(ax, jet)
    contourf(X, Y, fliplr(-W(:,:,i).'), levels, 'linestyle', 'none')
    axis equal
    axis tight
    xlim([-100,100])
    ylim([-100,100])
    clim([-1, 1])
    c = colorbar();
    hold off

    frame = getframe(ax);
    close all
    writeVideo(v,frame);
end
close(v);