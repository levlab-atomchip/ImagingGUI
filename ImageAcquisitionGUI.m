function varargout = ImageAcquisitionGUI(varargin)
% IMAGEACQUISITIONGUI M-file for ImageAcquisitionGUI.fig
%      IMAGEACQUISITIONGUI, by itself, creates a new IMAGEACQUISITIONGUI or raises the existing
%      singleton*.
%
%      H = IMAGEACQUISITIONGUI returns the handle to a new IMAGEACQUISITIONGUI or the handle to
%      the existing singleton*.
%
%      IMAGEACQUISITIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEACQUISITIONGUI.M with the given input arguments.
%
%      IMAGEACQUISITIONGUI('Property','Value',...) creates a new IMAGEACQUISITIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageAcquisitionGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageAcquisitionGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageAcquisitionGUI

% Last Modified by GUIDE v2.5 28-Mar-2013 15:25:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ImageAcquisitionGUI_OpeningFcn, ...
    'gui_OutputFcn',  @ImageAcquisitionGUI_OutputFcn, ...
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

% --- Executes just before ImageAcquisitionGUI is made visible.
function ImageAcquisitionGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
clc
close all

global hfig_main
global hfig_dispAtomInfo
global hfig_dispCombined
global closeState
global rawImage
global runData

rawImage = [];
runData = [];

hfig_main = handles;

load('closeState')

hfig_main.calculation.atomicMass = closeState.atomicMass;
hfig_main.calculation.pixSize = closeState.pixSize;
hfig_main.calculation.M = closeState.M;
hfig_main.calculation.lambda = closeState.lambda;
hfig_main.display.imageRotation = closeState.imageRotation;

imaqreset
camInfo = imaqhwinfo('dcam');

chooseCamera = 1;
if chooseCamera || ~exist('prevCamera','var') || prevCamera>length(camInfo.DeviceInfo) || ~any(ismember(camInfo.DeviceInfo(prevCamera).SupportedFormats,prevCameraMode))
    eval('MultiCamChoose')
    while isempty(hfig_main.camera.cameraSize)
        drawnow
    end
else
    hfig_main.camera.camera = closeState.prevCamera;
    hfig_main.camera.cameraMode = closeState.prevCameraMode;
    hfig_main.camera.cameraSize = closeState.prevCameraSize;
end

hfig_main.calculation.fitOpt = optimset('Display','off','Jacobian','off','DerivativeCheck','off');

hfig_main.camera.cameraName = camInfo.DeviceInfo(hfig_main.camera.camera).DeviceName;

hfig_main.display.imageSize = size(imrotate(zeros(hfig_main.camera.cameraSize),hfig_main.display.imageRotation));
hfig_main.display.maxDispSize = [1537 1601];
hfig_main.display.dispSize = ceil(hfig_main.display.imageSize*min(hfig_main.display.maxDispSize./hfig_main.display.imageSize)/2.5);

hfig_main.display.sizeScale = .4;
hfig_main.display.dispScale = 64; % display of image (jet), NOT for fitting or any analysis

hfig_main.calculation.flucWinX = (hfig_main.display.imageSize(2)-10):hfig_main.display.imageSize(2);
hfig_main.calculation.flucWinY = (hfig_main.display.imageSize(1)-10):hfig_main.display.imageSize(1);
hfig_main.calculation.truncWinX = 1:hfig_main.display.imageSize(1);
hfig_main.calculation.truncWinY = 1:hfig_main.display.imageSize(2);

hfig_main.calculation.c1 = hfig_main.calculation.pixSize / hfig_main.calculation.M;
hfig_main.calculation.A = hfig_main.calculation.c1^2;

hfig_main.user.triggerWait = closeState.triggerWait;

set(hfig_main.cb_cs,'value',closeState.cs_sel)
set(hfig_main.cbox_mlr,'value',closeState.mlr_sel)
if get(hfig_main.cb_cs,'value')
    set(hfig_main.etxt_cs,'enable','on')
    hfig_main.calculation.s_lambda = closeState.s_lambda;
else
    set(hfig_main.etxt_cs,'enable','off')
    hfig_main.calculation.s_lambda = 3*hfig_main.calculation.lambda^2/(2*pi); %absorption cross-section at near-resonance, m^2
end

hfig_main.user.boxdispsize = 44;

hfig_main.user.run = 0;

hfig_main.user.baseColor = get(hfig_main.pushbutton_camera,'BackgroundColor');

hfig_main.user.truncbtn_BackgroundColor = get(hfig_main.truncbtn,'BackgroundColor');
hfig_main.user.fluctbtn_BackgroundColor = get(hfig_main.fluctbtn,'BackgroundColor');

eval('dispCombined')
eval('dispAtomInfo')

hfig_main.calculation.flucWinX = closeState.prevFlucWinX(closeState.prevFlucWinX<hfig_main.display.imageSize(2));
hfig_main.calculation.flucWinY = closeState.prevFlucWinY(closeState.prevFlucWinY<hfig_main.display.imageSize(1));
hfig_main.calculation.truncWinX = closeState.prevTruncWinX(closeState.prevTruncWinX<hfig_main.display.imageSize(2));
hfig_main.calculation.truncWinY = closeState.prevTruncWinY(closeState.prevTruncWinY<hfig_main.display.imageSize(1));

set(hfig_main.(closeState.nc_sel),'value',1)
set(hfig_main.(closeState.fwm_sel),'value',1)
set(hfig_main.(closeState.fws_sel),'value',1)
set(hfig_main.(closeState.npm_sel),'value',1)
set(hfig_main.(closeState.ft_sel),'value',1)
set(hfig_main.(closeState.rid_sel),'value',1)
set(hfig_main.(closeState.fc_sel),'value',1)
set(hfig_main.(closeState.fad_sel),'value',1)
set(hfig_main.(closeState.tp_sel),'value',1)
set(hfig_main.(closeState.is_sel),'value',1), is_panel_SelectionChangeFcn(hObject, eventdata)
set(hfig_main.as_off,'value',1)


set(hfig_main.sl_name,'enable','off')
set(hfig_main.sl_folder,'string',closeState.sl_folder)
set(hfig_main.sl_name,'string',closeState.sl_name)
set(hfig_main.etxt_cs,'string',num2str(hfig_main.calculation.s_lambda))
set(hfig_main.is_max,'string',closeState.is_max)
set(hfig_main.is_min,'string',closeState.is_min)

set(hfig_main.etxt_rdf,'string',closeState.rundata)

set(hfig_main.pushbutton_stop,'BackgroundColor',[.8 .1 .1])
set(hfig_main.npm_run,'userdata',1)
set(hfig_main.truncbtn,'userdata',0)
set(hfig_dispCombined.refit_btn,'userdata',0)
set(hfig_main.sl_load,'userdata',0)

set(hfig_main.camName_txt,'string',['CAM' num2str(hfig_main.camera.camera) ' ' hfig_main.camera.cameraName])
set(hfig_main.camMode_txt,'string',hfig_main.camera.cameraMode)

set(hfig_main.etxt_am,'string',num2str(hfig_main.calculation.atomicMass))
set(hfig_main.etxt_ir,'string',num2str(hfig_main.display.imageRotation))
set(hfig_main.etxt_ps,'string',num2str(hfig_main.calculation.pixSize*10^6))
set(hfig_main.etxt_m,'string',num2str(hfig_main.calculation.M))
set(hfig_main.etxt_l,'string',num2str(hfig_main.calculation.lambda*10^9))
set(hfig_main.etxt_tw,'string',num2str(hfig_main.user.triggerWait*10^3));


mainSize = get(hfig_main.figure,'position');
dispAtomInfoSize = get(hfig_dispAtomInfo.figure,'position');
dispCombinedSize = get(hfig_dispCombined.figure,'position');
set(hfig_main.figure, 'Position', [closeState.ImageAcquisitionGUIPos(1:2) mainSize(3:4)]);
set(hfig_dispAtomInfo.figure, 'Position', [closeState.dispAtomInfoPos(1:2) dispAtomInfoSize(3:4)]);
set(hfig_dispCombined.figure, 'Position', [closeState.dispCombinedPos(1:2) dispCombinedSize(3:4)]);


handles.output = hObject;
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = ImageAcquisitionGUI_OutputFcn(hObject, eventdata, handles)% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_run.
function pushbutton_run_Callback(hObject, eventdata, handles)
global hfig_main
global hfig_dispAtomInfo
global hfig_dispCombined
global hfig_rawImages
global rawImage
global runData

if hfig_main.user.run == 0;
    hfig_main.user.run = 1;
    delete(imaqfind)
    set(hfig_main.pushbutton_stop,'BackgroundColor',hfig_main.user.baseColor)
    set(hfig_main.pushbutton_run,'BackgroundColor',[.1 .8 .1])
    
    drawnow
    
    tic % Initial 'tic' so takeODImgXY doesn't throw error on first run
    while hfig_main.user.run == 1
        ImageAcquisitionScript
        if ~get(hfig_main.sl_load,'userdata') && ~get(hfig_dispCombined.refit_btn,'userdata') && (get(hfig_main.as_on,'value') || (exist('runData','var') && isfield(runData,'DataMode') && runData.DataMode))
            sl_save_Callback()
        end
        if get(hfig_main.sl_load,'userdata')
            hfig_main = hfig_save;
            clear hfig_save
            set(hfig_main.sl_load,'userdata',0)
            hfig_main.user.run = 0;
        end
        set(hfig_dispCombined.refit_btn,'userdata',0)
    end
    delete(imaqfind)
    
    set(hfig_main.pushbutton_run,'BackgroundColor',hfig_main.user.baseColor)
    set(hfig_main.pushbutton_stop,'BackgroundColor',[.8 .1 .1])
    drawnow
end


function pushbutton_stop_Callback(hObject, eventdata, handles)
global hfig_main
hfig_main.user.run = 0;


function figure_CloseRequestFcn(hObject, eventdata, handles)
global hfig_main
global hfig_dispAtomInfo
global hfig_dispCombined
global closeState
global runData

if ~hfig_main.user.run %Don't do anything if imaging is running
    delete(imaqfind)
    
    %Save figure positions and button options for next open
    closeState.nc_sel = get(get(hfig_main.nc_panel,'SelectedObject'),'tag');
    closeState.fwm_sel = get(get(hfig_main.fwm_panel,'SelectedObject'),'tag');
    closeState.fws_sel = get(get(hfig_main.fws_panel,'SelectedObject'),'tag');
    closeState.npm_sel = get(get(hfig_main.npm_panel,'SelectedObject'),'tag');
    closeState.ft_sel = get(get(hfig_main.ft_panel,'SelectedObject'),'tag');
    closeState.rid_sel = get(get(hfig_main.rid_panel,'SelectedObject'),'tag');
    closeState.fc_sel = get(get(hfig_main.fc_panel,'SelectedObject'),'tag');
    closeState.fad_sel = get(get(hfig_main.fad_panel,'SelectedObject'),'tag');
    closeState.is_sel = get(get(hfig_main.is_panel,'SelectedObject'),'tag');
    closeState.tp_sel = get(get(hfig_main.tp_panel,'SelectedObject'),'tag');
    
    closeState.mlr_sel = get(hfig_main.cbox_mlr,'value');
    closeState.cs_sel = get(hfig_main.cb_cs,'value');
    closeState.rundata = get(hfig_main.etxt_rdf,'string');
    
    closeState.sl_folder = get(hfig_main.sl_folder,'string');
    closeState.sl_name = get(hfig_main.sl_name,'string');
    
    closeState.is_max = get(hfig_main.is_max,'string');
    closeState.is_min = get(hfig_main.is_min,'string');
    
    closeState.dispAtomInfoPos = get(hfig_dispAtomInfo.figure, 'Position');
    closeState.ImageAcquisitionGUIPos = get(hfig_main.figure, 'Position');
    closeState.dispCombinedPos = get(hfig_dispCombined.figure,'Position');
    
    closeState.prevFlucWinX = hfig_main.calculation.flucWinX;
    closeState.prevFlucWinY = hfig_main.calculation.flucWinY;
    closeState.prevTruncWinX = hfig_main.calculation.truncWinX;
    closeState.prevTruncWinY = hfig_main.calculation.truncWinY;
    
    closeState.prevCamera = hfig_main.camera.camera;
    closeState.prevCameraMode = hfig_main.camera.cameraMode;
    closeState.prevCameraSize = hfig_main.camera.cameraSize;
    
    closeState.imageRotation = hfig_main.display.imageRotation;
    closeState.atomicMass = hfig_main.calculation.atomicMass;
    closeState.pixSize = hfig_main.calculation.pixSize; % pixel size, m
    closeState.M = hfig_main.calculation.M; %  magnification
    closeState.lambda = hfig_main.calculation.lambda; % wavelength of probe beam, m
    closeState.s_lambda = hfig_main.calculation.s_lambda;
    closeState.triggerWait = hfig_main.user.triggerWait;
    
    save('closeState','closeState');
    
    close all
    delete(hObject);
end


function truncbtn_Callback(hObject, eventdata, handles)
global hfig_main
set(hfig_main.truncbtn,'userdata',1,'BackgroundColor',[.8 .1 .1])


function fluctbtn_Callback(hObject, eventdata, handles)
global hfig_main
set(hfig_main.fluctbtn,'userdata',1,'BackgroundColor',[.8 .1 .1])


function numplot_reset_Callback(hObject, eventdata, handles)
global hfig_main
set(hfig_main.numplot_reset,'userdata',1)


function nc_panel_SelectionChangeFcn(hObject, eventdata, handles)


function npm_panel_SelectionChangeFcn(hObject, eventdata, handles)
global hfig_main
set(hfig_main.numplot_reset,'userdata',1)


function pushbutton_camera_Callback(hObject, eventdata, handles)
global hfig_main

hfig_main.prevState = hfig_main.user.run;
hfig_main.user.run = 0;

disp(' ')
boxdisp('Select Camera',hfig_main.user.boxdispsize)

hfig_main.camera.cameraSize = [];
eval('MultiCamChoose')

while isempty(hfig_main.camera.cameraSize)
    drawnow
end

set(hfig_main.camName_txt,'string',['CAM' num2str(hfig_main.camera.camera) ' ' hfig_main.camera.cameraName])
set(hfig_main.camMode_txt,'string',hfig_main.camera.cameraMode)

if hfig_main.prevState
    pushbutton_run_Callback()
end


function sl_save_Callback(hObject, eventdata, handles)
global hfig_main
global rawImage
global runData

date = datestr(clock,29);
time = strrep(datestr(clock,13),':','');
FileName = [date '_' time];
if get(hfig_main.sl_custom,'value')
    FileName = [FileName '_' get(hfig_main.sl_name,'string')];
end
FolderName = fullfile(get(hfig_main.sl_folder,'string'),date);
if ~exist(FolderName,'dir')
    mkdir(FolderName)
end
SaveFile = fullfile(FolderName,FileName);
save(SaveFile,'hfig_main','rawImage','runData');
disp(['Saved ' FileName])


function sl_load_Callback(hObject, eventdata, handles)
global hfig_main
global hfig_dispAtomInfo
global hfig_dispCombined
global hfig_rawImages

set(hfig_main.sl_load,'userdata',1)
pushbutton_run_Callback()


function etxt_l_Callback(hObject, eventdata, handles)
global hfig_main
if ~hfig_main.user.run
    hfig_main.calculation.lambda = str2double(get(hObject,'string'))*10^-9;
    if ~get(hfig_main.cb_cs,'value')
        hfig_main.calculation.s_lambda = 3*hfig_main.calculation.lambda^2/(2*pi); %absorption cross-section at near-resonance, m^2
    end
else
    set(hObject,'string',num2str(hfig_main.calculation.lambda*10^9))
end


function etxt_l_CreateFcn(hObject, eventdata, handles)
global hfig_main
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etxt_m_Callback(hObject, eventdata, handles)
global hfig_main
if ~hfig_main.user.run
    hfig_main.calculation.M = str2double(get(hObject,'string'));
    hfig_main.calculation.c1 = hfig_main.calculation.pixSize / hfig_main.calculation.M;
    hfig_main.calculation.A = hfig_main.calculation.c1^2;
else
    set(hObject,'string',num2str(hfig_main.calculation.M))
end


function etxt_m_CreateFcn(hObject, eventdata, handles)
global hfig_main
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function etxt_ps_Callback(hObject, eventdata, handles)
global hfig_main
if ~hfig_main.user.run
    hfig_main.calculation.pixSize = str2double(get(hObject,'string'))*10^-6;
    hfig_main.calculation.c1 = hfig_main.calculation.pixSize / hfig_main.calculation.M;
    hfig_main.calculation.A = hfig_main.calculation.c1^2;
else
    set(hObject,'string',num2str(hfig_main.calculation.pixSize*10^6))
end


function etxt_ps_CreateFcn(hObject, eventdata, handles)
global hfig_main
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function etxt_ir_Callback(hObject, eventdata, handles)
global hfig_main
if ~hfig_main.user.run
    hfig_main.display.imageRotation = str2double(get(hObject,'string'));
    hfig_main.display.imageSize = size(imrotate(single(zeros(hfig_main.camera.cameraSize)),hfig_main.display.imageRotation));
    hfig_main.display.dispSize = ceil(hfig_main.display.imageSize*min(hfig_main.display.maxDispSize./hfig_main.display.imageSize)/2.5);
    hfig_main.calculation.flucWinX = (hfig_main.display.imageSize(2)-10):hfig_main.display.imageSize(2);
    hfig_main.calculation.flucWinY = (hfig_main.display.imageSize(1)-10):hfig_main.display.imageSize(1);
    hfig_main.calculation.truncWinX = 1:hfig_main.display.imageSize(2);
    hfig_main.calculation.truncWinY = 1:hfig_main.display.imageSize(1);
else
    set(hObject,'string',num2str(hfig_main.display.imageRotation))
end


function etxt_ir_CreateFcn(hObject, eventdata, handles)
global hfig_main
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function etxt_am_Callback(hObject, eventdata, handles)
global hfig_main
if ~hfig_main.user.run
    hfig_main.calculation.atomicMass = str2double(get(hObject,'string'));
else
    set(hObject,'string',num2str(hfig_main.calcuation.atomicMass))
end


function etxt_am_CreateFcn(hObject, eventdata, handles)
global hfig_main
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function sl_choose_Callback(hObject, eventdata, handles)
global hfig_main
pathname = uigetdir(get(hfig_main.sl_folder,'string'));
if pathname
    set(hfig_main.sl_folder,'string',pathname)
end

function sl_name_Callback(hObject, eventdata, handles)


function sl_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function sl_panel_SelectionChangeFcn(hObject, eventdata, handles)
global hfig_main

if get(hfig_main.sl_custom,'value')
    set(hfig_main.sl_name,'enable','on')
elseif get(hfig_main.sl_default,'value')
    set(hfig_main.sl_name,'enable','off')
end


function rid_panel_SelectionChangeFcn(hObject, eventdata, handles)
global hfig_main

if get(hfig_main.rid_off,'value') && ~isempty(findobj('tag','rawimages'))
    close('rawImages')
    drawnow
end


function as_panel_SelectionChangeFcn(hObject, eventdata, handles)
global hfig_main
 if get(hfig_main.as_on,'value')
     set(hfig_main.sl_panel,'HighlightColor',[.8 .1 .1],'BorderType','line','BorderWidth',3)
 else
     set(hfig_main.sl_panel,'BorderType','etchedin','BorderWidth',1,'HighlightColor',[.5 .5 .5])
 end



function etxt_rdf_Callback(hObject, eventdata, handles)


function etxt_rdf_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function sl_pdf_Callback(hObject, eventdata, handles)
global hfig_main
global hfig_dispCombined
global hfig_dispAtomInfo
tempFig = figure('name','temp','units','pixels','colormap',get(hfig_dispCombined.figure,'colormap'),'visible','on');
dispFig = get(hfig_dispCombined.figure, 'Children');
infoFig = get(hfig_dispAtomInfo.figure, 'Children');

maxpos=0;
for i = 1:numel(dispFig)
    newH = copyobj(dispFig(i),tempFig);
    set(newH,'units','pixels')
    pos = get(newH,'position');
    if pos(1)+pos(3)>maxpos
        maxpos = pos(1)+pos(3);
    end
end

maxwid = 0;
for i = 1:numel(infoFig)
    newH = copyobj(infoFig(i),tempFig);
    set(newH,'units','pixels')
    pos = get(newH,'position');
    set(newH,'position',[(pos(1)+maxpos+40) pos(2:4)])
    if (pos(1)+pos(3)+maxpos+40)>maxwid
        maxwid = (pos(1)+pos(3)+maxpos+40);
    end
end

set(gcf,'position',[0 0 maxwid+20 850])
set(gcf,'units','points')
fsize = get(gcf,'position');
set(gcf,'PaperUnits','Points','PaperPosition', [30 30 fsize(3:4)],'papersize',fsize(3:4)+60);

date = datestr(clock,29);
time = strrep(datestr(clock,13),':','');
FileName = [date '_' time];
if get(hfig_main.sl_custom,'value')
    FileName = [FileName '_' get(hfig_main.sl_name,'string')];
end
FolderName = fullfile(get(hfig_main.sl_folder,'string'),date);
if ~exist(FolderName,'dir')
    mkdir(FolderName)
end

SaveFile = fullfile(FolderName,FileName);
print(tempFig,'-zbuffer','-dpdf','-r300',SaveFile)
disp(['Saved ' FileName])
close('temp')
open([SaveFile '.pdf'])


function reset_rdf_Callback(hObject, eventdata, handles)
global hfig_main
delete(get(hfig_main.etxt_rdf,'string'))
save(get(hfig_main.etxt_rdf,'string'),'')
fileattrib(get(hfig_main.etxt_rdf,'string'),'+w')
disp('RunData file reset.')


function cb_cs_Callback(hObject, eventdata, handles)
global hfig_main
if ~hfig_main.user.run
    if get(hObject,'value')
        set(hfig_main.etxt_cs,'enable','on')
        hfig_main.calculation.s_lambda = str2double(get(hfig_main.etxt_cs,'string'));
    else
        set(hfig_main.etxt_cs,'enable','off')
        hfig_main.calculation.s_lambda = 3*hfig_main.calculation.lambda^2/(2*pi);
    end
else
    set(hObject,'value',~get(hObject,'value'))
end


function etxt_cs_Callback(hObject, eventdata, handles)
global hfig_main
if ~hfig_main.user.run
    hfig_main.calculation.s_lambda = str2double(get(hObject,'string'));
else
    set(hObject,'string',num2str(hfig_main.calcuation.s_lambda))
end


function etxt_cs_CreateFcn(hObject, eventdata, handles)
global hfig_main
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function etxt_tw_Callback(hObject, eventdata, handles)
global hfig_main
if ~hfig_main.user.run
    hfig_main.user.triggerWait = str2double(get(hObject,'string'))*10^-3;
else
    set(hObject,'string',num2str(hfig_main.user.triggerWait*10^3));
end


function etxt_tw_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tp_panel_SelectionChangeFcn(hObject, eventdata, handles)
global hfig_main

if get(hfig_main.temp_off,'value') && ~isempty(findobj('tag','Temperature'))
    close('Temperature')
    drawnow
end



function is_max_Callback(hObject, eventdata, handles)
redraw_img()

function is_max_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function is_min_Callback(hObject, eventdata, handles)
redraw_img()

function is_min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function is_panel_SelectionChangeFcn(hObject, eventdata, handles)
global hfig_main

if get(hfig_main.is_auto,'value') || get(hfig_main.is_fit,'value')
    set(hfig_main.is_max,'enable','off')
    set(hfig_main.is_min,'enable','off')
else
    set(hfig_main.is_max,'enable','on')
    set(hfig_main.is_min,'enable','on')
end
redraw_img()


function redraw_img()
global hfig_main
global hfig_dispCombined
global rawImage

if ~isempty(rawImage)
    hfig_main.prevState = hfig_main.user.run;
    set(hfig_dispCombined.refit_btn,'userdata',1)
    pushbutton_run_Callback()
end


% --- Executes on button press in cbox_mlr.
function cbox_mlr_Callback(hObject, eventdata, handles)
% hObject    handle to cbox_mlr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbox_mlr
