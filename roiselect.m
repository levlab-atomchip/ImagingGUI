function [row, col] = roiselect(inputimg,figurename)
global var
global h_fig
var.DONE = 0;
var.open = 1;
var.line = zeros(1,4);
var.md = 0;
inputimg = inputimg/max(max(inputimg))*64;
[M N] = size(inputimg);
var.X = N;
var.Y = M;
var.M = M;
h_fig = figure('name',figurename,'numbertitle','off','MenuBar','none','unit','pixels','WindowButtonDownFcn',@mousedown,'WindowButtonMotionFcn',@mousemove,'WindowButtonUpFcn',@mouseup,'CloseRequestFcn',@closerequest,'KeyPressFcn',@closerequest,'resize','off');
set(gcf,'colormap',colormap([linspace(0,0,3)' linspace(0,0,3)' linspace(0,.55,3)'; jet(61)]))
h_axes = axes('unit','pixels');
image(inputimg)
set(gca,'Position',[1 1 N M],'XLim', [1 N],'YLim', [1 M])
figPosition = get(h_fig,'Position');
set(h_fig,'Position',[342 214 N M])
if N > 700
    set(h_fig,'Position',[ -1 98 N M])
end
while var.open == 1
    drawnow
end
row = var.Y(var.Y<M);
row = row(row>=1);
col = var.X(var.X<N);
col = col(col>=1);



function mousedown(src,eventdata)
global var
global h_fig
var.md = 1;
var.p1 = get(h_fig,'CurrentPoint');



function mousemove(src,eventdata)
global var
global h_fig
if var.md == 1
        P1 = var.p1;
        P2 = get(h_fig,'CurrentPoint');
        set(var.line,'visible','off');
        var.line(1) = line([P1(1) P2(1)],var.M - [P1(2) P1(2)],'color','w');
        var.line(2) = line([P2(1) P2(1)],var.M - [P1(2) P2(2)],'color','w');
        var.line(3) = line([P1(1) P2(1)],var.M - [P2(2) P2(2)],'color','w');
        var.line(4) = line([P1(1) P1(1)],var.M - [P1(2) P2(2)],'color','w');
        set(var.line,'visible','on');
end



function mouseup(src,eventdata)
global var
global h_fig
var.md = 0;
P1 = var.p1;
P2 = get(h_fig,'CurrentPoint');
if P1(1) > P2(1)
    smallX = P2(1);
    largeX = P1(1);
else
    largeX = P2(1);
    smallX = P1(1);
end

if P1(2) > P2(2)
    smallY = P2(2);
    largeY = P1(2);
else
    largeY = P2(2);
    smallY = P1(2);
end
var.X = round(smallX : largeX);
var.Y = var.M - round(smallY : largeY);
var.Y = fliplr(var.Y);
var.DONE = 1;


function closerequest(src,eventdata)
global var
if var.DONE == 1
var.open = 0;
% get(gcf,'Position')
delete(gcf);
end