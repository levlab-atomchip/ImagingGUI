function varargout = dispAtomInfo(varargin)
% SINGLEMODE_DISPATOMINFO M-file for singleMode_dispAtomInfo.fig
%      SINGLEMODE_DISPATOMINFO, by itself, creates a new SINGLEMODE_DISPATOMINFO or raises the existing
%      singleton*.
%
%      H = SINGLEMODE_DISPATOMINFO returns the handle to a new SINGLEMODE_DISPATOMINFO or the handle to
%      the existing singleton*.
%
%      SINGLEMODE_DISPATOMINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINGLEMODE_DISPATOMINFO.M with the given input arguments.
%
%      SINGLEMODE_DISPATOMINFO('Property','Value',...) creates a new SINGLEMODE_DISPATOMINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before singleMode_dispAtomInfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to singleMode_dispAtomInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help singleMode_dispAtomInfo

% Last Modified by GUIDE v2.5 12-Feb-2010 13:46:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @singleMode_dispAtomInfo_OpeningFcn, ...
                   'gui_OutputFcn',  @singleMode_dispAtomInfo_OutputFcn, ...
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


% --- Executes just before singleMode_dispAtomInfo is made visible.
function singleMode_dispAtomInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to singleMode_dispAtomInfo (see VARARGIN)

global hfig_dispAtomInfo
hfig_dispAtomInfo = handles;

% Choose default command line output for singleMode_dispAtomInfo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes singleMode_dispAtomInfo wait for user response (see UIRESUME)
% uiwait(handles.figure);


% --- Outputs from this function are returned to the command line.
function varargout = singleMode_dispAtomInfo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
