function varargout = MultiCamChoose(varargin)
% MULTICAMCHOOSE MATLAB code for MultiCamChoose.fig
%      MULTICAMCHOOSE, by itself, creates a new MULTICAMCHOOSE or raises the existing
%      singleton*.
%
%      H = MULTICAMCHOOSE returns the handle to a new MULTICAMCHOOSE or the handle to
%      the existing singleton*.
%
%      MULTICAMCHOOSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTICAMCHOOSE.M with the given input arguments.
%
%      MULTICAMCHOOSE('Property','Value',...) creates a new MULTICAMCHOOSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiCamChoose_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiCamChoose_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiCamChoose

% Last Modified by GUIDE v2.5 27-Jun-2012 11:25:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiCamChoose_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiCamChoose_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MultiCamChoose is made visible.
function MultiCamChoose_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiCamChoose (see VARARGIN)
global hcams_pnl hcams_pnl_btn hmode_pnl hmode_pnl_btn hfig_main
hfig_main.camera.cameraSize = [];
imaqreset
cams = imaqhwinfo('dcam');
numCams = length(cams.DeviceIDs);

camNames = cell(1,numCams);
camModes = cell(1,numCams);
numModes = nan(1,numCams);
for i = 1:numCams
    camNames{i} = ['CAM' num2str(i) ' (' cams.DeviceInfo(i).DeviceName ')'];
    camModes{i} = cams.DeviceInfo(i).SupportedFormats';
    numModes(i) = length(cams.DeviceInfo(i).SupportedFormats);
end
numItems = max([numCams numModes]);
btnHeight = 20;
panelWidth = 250;
figHeight = numItems*btnHeight+50;
figWidth = 2*panelWidth+15;
set(gcf,'units','pixels','position',[100 100 figWidth figHeight],'CloseRequestFcn',@sel_btn_Callback)

camPanelHeight = btnHeight*numCams+15;
hcams_pnl = uibuttongroup('title','Cameras','tag','cams_pnl','units','pixels','position',[5 figHeight-camPanelHeight-5 panelWidth camPanelHeight],'selectionchange',@cams_pnl_Callback);
for i = 1:numCams
    hcams_pnl_btn(i) = uicontrol(hcams_pnl,'style','radiobutton','units','pixels','tag',['cams_pnl' num2str(i)],'string',camNames{i},'position',[5 (camPanelHeight-12)-i*(btnHeight) 225 btnHeight],'userdata',i);
    hmode_pnl(i) = uibuttongroup('visible','off','title',camNames{i},'tag',['mode_pnl' num2str(i)],'units','pixels','position',[(5+( panelWidth+5)) (figHeight-(btnHeight*numModes(i)+15)-5) panelWidth (btnHeight*numModes(i)+15)],'selectionchange',@mode_pnl_Callback);
    modePanelHeight(i) = btnHeight*numModes(i)+15;
    for j = 1:numModes(i)
        hmode_pnl_btn(i,j) = uicontrol(hmode_pnl(i),'style','radiobutton','units','pixels','tag',['mode_pnl' num2str(i) num2str(j)],'string',camModes{i}{j},'position',[5 (modePanelHeight(i)-12)-j*(btnHeight) 150 btnHeight]);
    end
    set(hmode_pnl(i),'userdata',hmode_pnl_btn(i,1))
end
set(hmode_pnl(1),'visible','on')
for j = 1:numModes(1)
    if all(camModes{1}{j}(1:3) == 'Y16')
        set(hmode_pnl_btn(1,j),'value',1)
        break
    end
end

hsel_btn = uicontrol('style','pushbutton','string','Select','units','pixels','position',[5 figHeight-camPanelHeight-70 panelWidth 50],'callback',@sel_btn_Callback,'userdata',0);

% Choose default command line output for MultiCamChoose
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MultiCamChoose wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function cams_pnl_Callback(hObject, eventdata, handles)
global hcams_pnl hcams_pnl_btn hmode_pnl hmode_pnl_btn
for i = 1:length(hmode_pnl)
    set(hmode_pnl(i),'visible','off')
end
i = find(eventdata.NewValue==hcams_pnl_btn);
set(hmode_pnl(i),'visible','on');
for j = 1:length(hmode_pnl_btn(i,:))
    mdstr = get(hmode_pnl_btn(i,j),'string');
    if all(mdstr(1:3) == 'Y16')
        set(hmode_pnl_btn(i,j),'value',1)
        break
    end
end

function mode_pnl_Callback(hObject, eventdata, handles)
global hcams_pnl hcams_pnl_btn hmode_pnl hmode_pnl_btn


function sel_btn_Callback(hObject, eventdata, handles)
global hcams_pnl hcams_pnl_btn hmode_pnl hmode_pnl_btn hfig_main
hfig_main.camera.camera = get(get(hcams_pnl,'selectedobject'),'userdata');
hfig_main.camera.cameraMode = get(get(hmode_pnl(hfig_main.camera.camera),'selectedobject'),'string');
n1 = find(hfig_main.camera.cameraMode=='_',1,'last');
n2 = find(hfig_main.camera.cameraMode=='x',1,'last');
hfig_main.camera.cameraSize = fliplr([str2double(hfig_main.camera.cameraMode(n1+1:n2-1)) str2double(hfig_main.camera.cameraMode(n2+1:end))]);

delete(gcf)

% --- Outputs from this function are returned to the command line.
function varargout = MultiCamChoose_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
