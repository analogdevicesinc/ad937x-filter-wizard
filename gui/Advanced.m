function varargout = Advanced(varargin)
% ADVANCED MATLAB code for Advanced.fig
%      ADVANCED, by itself, creates a new ADVANCED or raises the existing
%      singleton*.
%
%      H = ADVANCED returns the handle to a new ADVANCED or the handle to
%      the existing singleton*.
%
%      ADVANCED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADVANCED.M with the given input arguments.
%
%      ADVANCED('Property','Value',...) creates a new ADVANCED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Advanced_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Advanced_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Advanced

% Last Modified by GUIDE v2.5 05-Dec-2016 16:18:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Advanced_OpeningFcn, ...
                   'gui_OutputFcn',  @Advanced_OutputFcn, ...
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


% --- Executes just before Advanced is made visible.
function Advanced_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Advanced (see VARARGIN)

% Choose default command line output for Advanced
if length(varargin) == 1 
    if varargin{1} == 0
        set(handles.force_snf,'Enable','off');
    end
end
if length(varargin) == 7
    set(handles.DEC_mode,'Value',varargin{1}+1);
    set(handles.rx_pfir_no_coefs,'Value',floor(varargin{2}/24));
    set(handles.force_rx,'Value',varargin{3});
    force_rx_Callback(hObject, eventdata, handles);
    set(handles.orx_pfir_no_coefs,'Value',floor(varargin{4}/24));
    set(handles.force_orx,'Value',varargin{5});
    force_orx_Callback(hObject, eventdata, handles);
    if varargin{6} ~= 0
        set(handles.snf_pfir_no_coefs,'Value',floor(varargin{6}/24));
        set(handles.force_snf,'Value',varargin{7});
        force_snf_Callback(hObject, eventdata, handles);
    else
        set(handles.force_snf,'Enable','off');
    end
end


handles.figure1.Name = 'Advanced Settings';
% Update handles structure
guidata(hObject, handles);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')
movegui(handles.figure1,'center');

% UIWAIT makes Advanced wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Advanced_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.profile;
varargout{2} = handles.cancelled;
delete(handles.figure1);


% --- Executes on button press in confirm_button.
function confirm_button_Callback(hObject, eventdata, handles)
profile.DEC_mode = get(handles.DEC_mode,'Value')-1;
profile.Rx.pfir_no_coefs = get(handles.rx_pfir_no_coefs,'Value')*24;
profile.Rx.force_pfir = get(handles.force_rx,'Value');
profile.ORx.pfir_no_coefs = get(handles.orx_pfir_no_coefs,'Value')*24;
profile.ORx.force_pfir = get(handles.force_orx,'Value');
profile.Snf.pfir_no_coefs = get(handles.snf_pfir_no_coefs,'Value')*24;
profile.Snf.force_pfir = get(handles.force_snf,'Value');

handles.profile = profile;
handles.cancelled = 0;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
handles.cancelled = 1;
handles.profile = 0;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press to close figure
function figure1_CloseRequestFcn(hObject, eventdata, handles)
handles.cancelled = 2;
handles.profile = 0;
guidata(hObject, handles);
uiresume(handles.figure1);

function DEC_mode_Callback(hObject, eventdata, handles)
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function DEC_mode_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'));
    set(hObject,'BackgroundColor','white');
end

function rx_pfir_no_coefs_Callback(hObject, eventdata, handles)
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function rx_pfir_no_coefs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in orx_pfir_no_coefs.
function orx_pfir_no_coefs_Callback(hObject, eventdata, handles)
% hObject    handle to orx_pfir_no_coefs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function orx_pfir_no_coefs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in snf_pfir_no_coefs.
function snf_pfir_no_coefs_Callback(hObject, eventdata, handles)
% hObject    handle to snf_pfir_no_coefs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function snf_pfir_no_coefs_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in force_rx.
function force_rx_Callback(hObject, eventdata, handles)
if get(handles.force_rx,'Value')
    set(handles.rx_pfir_no_coefs,'Enable','on');
else
    set(handles.rx_pfir_no_coefs,'Enable','off');
end


% --- Executes on button press in force_orx.
function force_orx_Callback(hObject, eventdata, handles)
if get(handles.force_orx,'Value')
    set(handles.orx_pfir_no_coefs,'Enable','on');
else
    set(handles.orx_pfir_no_coefs,'Enable','off');
end


% --- Executes on button press in force_snf.
function force_snf_Callback(hObject, eventdata, handles)
if get(handles.force_snf,'Value')
    set(handles.snf_pfir_no_coefs,'Enable','on');
else
    set(handles.snf_pfir_no_coefs,'Enable','off');
end

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.figure1.Position(3) = 58;
handles.figure1.Position(4) = 15;
movegui(handles.figure1,'center');

% Tx panel setting location
PosAdv = handles.uipanel1.Position;
PosAdv(1) = 0.25;
PosAdv(2) = 5;
PosAdv(3) = handles.figure1.Position(3) - 2*PosAdv(1); %width
PosAdv(4) = handles.figure1.Position(4) - 5;    %height
handles.uipanel1.Position = PosAdv;

% Settings Confirmation text location
handles.confirm_text.Position = [14.5 3.5 29 1];

% Settings Confirmation button location
handles.confirm_button.Position = [12 0.8 12.5 2];

% Settings Confirmation button location
handles.cancel_button.Position = [33.5 0.8 12.5 2];

guidata(hObject, handles);
