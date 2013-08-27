function varargout = dispCombined(varargin)
%DISPCOMBINED M-file for dispCombined.fig
%      DISPCOMBINED, by itself, creates a new DISPCOMBINED or raises the existing
%      singleton*.
%
%      H = DISPCOMBINED returns the handle to a new DISPCOMBINED or the handle to
%      the existing singleton*.
%
%      DISPCOMBINED('Property','Value',...) creates a new DISPCOMBINED using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to dispCombined_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DISPCOMBINED('CALLBACK') and DISPCOMBINED('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DISPCOMBINED.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dispCombined

% Last Modified by GUIDE v2.5 22-Jun-2011 19:37:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @dispCombined_OpeningFcn, ...
    'gui_OutputFcn',  @dispCombined_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


function dispCombined_OpeningFcn(hObject, eventdata, handles, varargin)
global hfig_dispCombined
global hfig_main

hfig_dispCombined = handles;
handles.output = hObject;

set(hfig_dispCombined.figure,'position',[0 0 hfig_main.display.dispSize([2 1])+120])
set(hfig_dispCombined.img_axes,'Color',[0 0 0],'position',[10 110 hfig_main.display.dispSize(2) hfig_main.display.dispSize(1)],'xlim',[1 hfig_main.display.imageSize(2)],'ylim',[1 hfig_main.display.imageSize(1)])
set(hfig_dispCombined.refit_btn,'units','pixels','position',[20+hfig_main.display.dispSize(2) 30 70 70])

c1 = hfig_main.calculation.c1;
set(hfig_dispCombined.xden_axes,'position',[10 30 hfig_main.display.dispSize(2) 70],'XTick',[0:.001:(c1*hfig_main.display.imageSize(2))]*1000,'XLim',c1*[1 hfig_main.display.imageSize(2)]*1000,'XMinorTick','on','XTickMode','auto','ytick',[])
set(hfig_dispCombined.yden_axes,'position',[20+hfig_main.display.dispSize(2) 110 70 hfig_main.display.dispSize(1)],'YTick',[0:.001:(c1*hfig_main.display.imageSize(1))]*1000,'YLim',c1*[1 hfig_main.display.imageSize(1)]*1000,'YMinorTick','on','YTickMode','auto','xtick',[])

hfig_dispCombined.pan.down = 0;
hfig_dispCombined.pan.xmax = hfig_main.display.imageSize(2);
hfig_dispCombined.pan.ymax = hfig_main.display.imageSize(1);
hfig_dispCombined.zoom.xmax = hfig_main.display.imageSize(2);
hfig_dispCombined.zoom.ymax = hfig_main.display.imageSize(1);

guidata(hObject, handles);
img = ones(hfig_main.display.imageSize);
img1 = (1:hfig_main.display.imageSize(2))./hfig_main.display.imageSize(2)*64;
for i = 1:hfig_main.display.imageSize(1)
    img(i,:) = abs((img1+i-1)-hfig_main.display.imageSize(2))/hfig_main.display.imageSize(2)*64;
end
image(img,'Parent',hfig_dispCombined.img_axes)


function varargout = dispCombined_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


function figure_WindowScrollWheelFcn(hObject, eventdata, handles)
global hfig_dispCombined
global hfig_main
c1 = hfig_main.calculation.c1;

mouseover = get(get(hittest,'parent'),'tag');
if strcmp(mouseover,'img_axes')
    axes(hfig_dispCombined.img_axes);
    center = get(gca,'CurrentPoint');
    if eventdata.VerticalScrollCount < 0
        zoom(2)
    elseif eventdata.VerticalScrollCount > 0
        zoom(.5)
    end
    xlim = get(gca,'xlim');
    ylim = get(gca,'ylim');
    xmid = round(mean(xlim));
    xdelta = center(1) - xmid;
    ymid = round(mean(ylim));
    ydelta = center(3) - ymid;
    xlimnew = xlim + xdelta;
    ylimnew = ylim + ydelta;
    
    if (xlimnew(2)-xlimnew(1)) > (hfig_dispCombined.zoom.xmax-1)
        xlimnew = [1 hfig_dispCombined.zoom.xmax];
    elseif xlimnew(2) > hfig_dispCombined.zoom.xmax
        xlimnew = xlim + (hfig_dispCombined.zoom.xmax - xlim(2));
    elseif xlimnew(1) < 1
        xlimnew = xlim + (1 - xlim(1));
    end
    
    if (ylimnew(2)-ylimnew(1)) > (hfig_dispCombined.zoom.ymax-1)
        ylimnew = [1 hfig_dispCombined.zoom.ymax];
    elseif ylimnew(2) > hfig_dispCombined.zoom.ymax
        ylimnew = ylim + (hfig_dispCombined.zoom.ymax - ylim(2));
    elseif ylimnew(1) < 1
        ylimnew = ylim + (1 - ylim(1));
    end
    set(gca,'xlim',xlimnew,'ylim',ylimnew)
    set(hfig_dispCombined.xden_axes,'XLim',c1*xlimnew*1000)
    set(hfig_dispCombined.yden_axes,'YLim',c1*sort(abs(ylimnew-hfig_main.display.imageSize(1))+1)*1000)
end


function figure_WindowButtonDownFcn(hObject, eventdata, handles)
global hfig_dispCombined
global hfig_main
c1 = hfig_main.calculation.c1;

if strcmp(get(get(hittest,'parent'),'tag'),'img_axes')
    switch get(gcf,'selectiontype')
        case 'normal'
            setptr(gcf,'closedhand')
            hfig_dispCombined.pan.down = 1;
            hfig_dispCombined.pan.prevpnt = get(gca,'CurrentPoint');
        case 'alt'
            setptr(gcf,'crosshair')
            point1 = get(gca,'CurrentPoint');
            rbbox;
            point2 = get(gca,'CurrentPoint');
            if point2(1) < 1
                point2(1) = 1;
            end
            if point2(1)  > hfig_dispCombined.zoom.xmax
                point2(1) = hfig_dispCombined.zoom.xmax;
            end
            if point2(3) < 1
                point2(3) = 1;
            end
            if point2(3) > hfig_dispCombined.zoom.ymax
                point2(3) = hfig_dispCombined.zoom.ymax;
            end
            if [point1(1) point1(3)] ~= [point2(1) point2(3)]
                xlimnew = sort([point1(1) point2(1)]);
                ylimnew = sort([point1(3) point2(3)]);
                set(gca,'xlim',xlimnew,'ylim',ylimnew)
                set(hfig_dispCombined.xden_axes,'XLim',c1*xlimnew*1000)
                set(hfig_dispCombined.yden_axes,'YLim',c1*sort(abs(ylimnew-hfig_main.display.imageSize(1))+1)*1000)
            end
        case 'open'
            xlimnew = [1 hfig_dispCombined.zoom.xmax];
            ylimnew = [1 hfig_dispCombined.zoom.ymax];
            set(gca,'xlim',xlimnew,'ylim',ylimnew)
            set(hfig_dispCombined.xden_axes,'XLim',c1*xlimnew*1000)
            set(hfig_dispCombined.yden_axes,'YLim',c1*sort(abs(ylimnew-hfig_main.display.imageSize(1))+1)*1000)
        case ''
    end
end


function figure_WindowButtonUpFcn(hObject, eventdata, handles)

global hfig_dispCombined
setptr(gcf,'arrow')
hfig_dispCombined.pan.down = 0;


function figure_WindowButtonMotionFcn(hObject, eventdata, handles)
global hfig_dispCombined
global hfig_main
c1 = hfig_main.calculation.c1;

if hfig_dispCombined.pan.down == 1 && strcmp(get(gca,'tag'),'img_axes')
    hfig_dispCombined.pan.currpnt = get(gca,'CurrentPoint');
    xlim = get(gca,'xlim');
    ylim = get(gca,'ylim');
    delta = hfig_dispCombined.pan.currpnt - hfig_dispCombined.pan.prevpnt;
    xlimnew = xlim - delta(1);
    if max(xlimnew) > hfig_dispCombined.pan.xmax || min(xlimnew) < 1
        xlimnew = xlim;
    end
    ylimnew = ylim - delta(3);
    if max(ylimnew) > hfig_dispCombined.pan.ymax || min(ylimnew) < 1
        ylimnew = ylim;
    end
    set(gca,'xlim',xlimnew,'ylim',ylimnew);
    set(hfig_dispCombined.xden_axes,'XLim',c1*xlimnew*1000)
    set(hfig_dispCombined.yden_axes,'YLim',c1*sort(abs(ylimnew-hfig_main.display.imageSize(1))+1)*1000)
    hfig_dispCombined.pan.prevpnt = get(gca,'CurrentPoint');
end


function refit_btn_Callback(hObject, eventdata, handles)
global hfig_main
global hfig_dispCombined
global rawImage

if ~isempty(rawImage)
    hfig_main.prevState = hfig_main.user.run;
    set(hfig_dispCombined.refit_btn,'userdata',1)
    set(hfig_main.truncbtn,'userdata',1)
    runcallback = get(hfig_main.pushbutton_run,'Callback');
    runcallback(hObject,eventdata)
end