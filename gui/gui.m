function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 19-May-2016 13:06:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;


%Create tab group
handles.tgroup = uitabgroup('Parent', handles.figure1,'TabLocation', 'top');
handles.tgroup.Units = 'characters';

%start up GUI size
handles.figure1.Position = [0.0 0.0 250.0 55.0];
%set(handles.figure1, 'resize', 'off');


handles.tab1 = uitab('Parent', handles.tgroup, 'Title', 'Tx Summary');
handles.tab2 = uitab('Parent', handles.tgroup, 'Title', 'ORx Summary');
handles.tab3 = uitab('Parent', handles.tgroup, 'Title', 'Rx Summary');
handles.tab4 = uitab('Parent', handles.tgroup, 'Title', 'Sniffer Rx Summary');
%handles.tab5 = uitab('Parent', handles.tgroup, 'Title', 'Mykonos Summary');

%Place panels into each tab
set(handles.uipanelTxSummary,'Parent', handles.tab1);
set(handles.uipanelOrxSummary,'Parent', handles.tab2);
set(handles.uipanelRxSummary,'Parent', handles.tab3);
set(handles.uipanelSnRxSummary,'Parent', handles.tab4);
%set(handles.uipanelMykSummary,'Parent', handles.tab5)
%set(handles.P3,'Parent',handles.tab3)

figure1_SizeChangedFcn(hObject, eventdata, handles);

axes(handles.radioVerseLogo);
[X1,map1, alpha1] = imread('RadioVerse-RGB-FullColor.png');
f1 = imshow(X1, map1);
set(f1, 'AlphaData', alpha1);


axes(handles.adiLogo);
[X2,map2, alpha2] = imread('ADILogo.png');
f2 = imshow(X2, map2);
set(f2, 'AlphaData', alpha2);

initialize_gui(hObject, handles, false);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in generateProfiles.
function generateProfiles_Callback(hObject, eventdata, handles)
% hObject    handle to generateProfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%axes(handles.rxPlot);
%cla;
%plot(sin(1:0.01:25.99));
addpath ../common/
%addpath ../delsig7p4mykonos/
addpath ../delsig_public/
addpath ../adc/
addpath ../profilegen/
profile = init_Mykonos_config();
set(handles.error_info,'String','Status');
set(handles.error_info,'ForegroundColor','black');
% Update Tx profile parameters from user entered values 
profile.Tx.input_rate_MHz = str2double(get(handles.txInputRate_MHz,'String'))
if (profile.Tx.input_rate_MHz < 30) || (profile.Tx.input_rate_MHz > 320)
    % return error to GUI
    error_info = sprintf('Tx input rate should be greater than 30MHz and less than 320MHz. Tx input rate was %0.2fMSPS. ERROR_CODE1',...
        profile.Tx.input_rate_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end
profile.Tx.synthesis_RFBW_MHz = str2double(get(handles.txRfBw_MHz,'String'))
if (profile.Tx.synthesis_RFBW_MHz < 20) || (profile.Tx.synthesis_RFBW_MHz > 240)
    % return error to GUI
    error_info = sprintf('Tx Synthesis BW should be greater than 20MHz and less than 240MHz. Tx syn BW was %0.2fMHz. ERROR_CODE1',...
        profile.Tx.synthesis_RFBW_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end
if (profile.Tx.synthesis_RFBW_MHz > profile.Tx.input_rate_MHz*0.82)     % ratio is based on 200MHz/245.76MSPS
    % return error to GUI
    error_info = sprintf('Tx Synthesis BW should be less than 82%% of Tx input rate. Tx syn BW was %0.2fMHz. ERROR_CODE1',...
        profile.Tx.synthesis_RFBW_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end
profile.Tx.prim_sgl_RFBW_MHz = str2double(get(handles.txPriSigBw_MHz,'String'))
if (profile.Tx.prim_sgl_RFBW_MHz < 5) || (profile.Tx.prim_sgl_RFBW_MHz > 100)
    % return error to GUI
    error_info = sprintf('Tx primary signal BW should be greater than 5MHz and less than 100MHz. Tx primary sgl BW was %0.2fMHz. ERROR_CODE1',...
        profile.Tx.prim_sgl_RFBW_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end
if (profile.Tx.prim_sgl_RFBW_MHz > profile.Tx.input_rate_MHz*0.33)      % ratio is based on 100MHz/307.2MSPS
    % return error to GUI
    error_info = sprintf('Tx primary signal BW should be less than 33%% of Tx input rate. Tx primary sgl BW was %0.2fMHz. ERROR_CODE1',...
        profile.Tx.prim_sgl_RFBW_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end

profile.Tx.pfir_passband_weight = str2double(get(handles.txPassBandWeight,'String'))
profile.Tx.pfir_stopband_weight = str2double(get(handles.txStopBandWeight,'String'))

% Update ORx parameters from GUI
profile.ORx.output_rate_MHz = str2double(get(handles.orxOutputSampleRate_MHz,'String'))
if (profile.ORx.output_rate_MHz < 30) || (profile.ORx.output_rate_MHz > 320)
    % return error to GUI
    error_info = sprintf('ORx output rate should be greater than 30MHz and less than 320MHz. ORx output rate was %0.2f. ERROR_CODE1',...
        profile.ORx.output_rate_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end
profile.ORx.RFBW_MHz = str2double(get(handles.orxRfBw_MHz,'String'))
if (profile.ORx.RFBW_MHz < 5) || (profile.ORx.RFBW_MHz > 240)
    % return error to GUI
    error_info = sprintf('ORx RF BW should be greater than 5MHz and less than 240MHz. ORx RF BW was %0.2fMHz. ERROR_CODE1',...
        profile.ORx.RFBW_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end
if ( ( profile.ORx.RFBW_MHz < profile.ORx.output_rate_MHz*0.40 ) || ( profile.ORx.RFBW_MHz > profile.ORx.output_rate_MHz*0.82 ) )
    % return error to GUI. This check is required based on filtering
    % ability and on the low side it is limited by RxQEC algorithm in ARM
    error_info = sprintf('ORx RF BW should be greater than 33%% and less than 82%% of the Rx output rate. ORx RF BW was %0.2fMHz. ERROR_CODE1',...
        profile.ORx.RFBW_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end
profile.ORx.pfir_passband_weight = str2double(get(handles.orxPassBandWeight,'String'))
profile.ORx.pfir_stopband_weight = str2double(get(handles.orxStopBandWeight,'String'))

% Update Rx parameters from GUI
profile.Rx.output_rate_MHz = str2double(get(handles.rxOutputSampleRate_MHz,'String'))
if (profile.Rx.output_rate_MHz < 20) || (profile.Rx.output_rate_MHz > 200)
    % return error to GUI
    error_info = sprintf('Rx output rate should be greater than 20MHz and less than 200MHz. Rx output rate was %0.2fMSPS. ERROR_CODE1',...
        profile.Rx.output_rate_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end
profile.Rx.RFBW_MHz = str2double(get(handles.rxRfBw_MHz,'String'))
if (profile.Rx.RFBW_MHz < 5) || (profile.Rx.RFBW_MHz > 100)
    % return error to GUI
    error_info = sprintf('Rx RF BW should be greater than 5MHz and less than 100MHz. Rx RF BW was %0.2fMSPS. ERROR_CODE1',...
        profile.Rx.RFBW_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end

if ( ( profile.Rx.RFBW_MHz < profile.Rx.output_rate_MHz*0.40 ) || ( profile.Rx.RFBW_MHz > profile.Rx.output_rate_MHz*0.82 ) )
    % return error to GUI. This check is required based on filtering
    % ability and on the low side it is limited by RxQEC algorithm in ARM
    error_info = sprintf('Rx RF BW should be greater than 33%% and less than 82%% of the Rx output rate. Rx RF BW was %0.2fMHz. ERROR_CODE1',...
        profile.Rx.RFBW_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end

profile.Rx.pfir_passband_weight = str2double(get(handles.rxPassbandWeight,'String'))
profile.Rx.pfir_stopband_weight = str2double(get(handles.rxStopBandWeight,'String'))

% check to confirm that the ORx rate is a multiple of the Rx rate. 
rx_valid_rates = profile.Rx.output_rate_MHz * [1 2 4 8];
k = find(rx_valid_rates == profile.ORx.output_rate_MHz)
if isempty(k)
    % return error to GUI
    error_info = sprintf('ORx output rate should be a power of 2 multiple of Rx output rate. Rx output rate was %0.2fMSPS. ORx output rate was %0.2f. ERROR_CODE1',...
        profile.Rx.output_rate_MHz, profile.ORx.output_rate_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end

% check to confirm that the Tx rate matches ORx rate
if ( profile.ORx.output_rate_MHz ~= profile.Tx.input_rate_MHz )
    % return error to GUI
    error_info = sprintf('Tx input rate and ORx output rate should match. ORx output rate was %0.2fMSPSMSPS. ERROR_CODE1',...
        profile.ORx.output_rate_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end

snrx_enabled = get(handles.snrxProfileEnabled,'Value');

if (snrx_enabled)
% Update Sniffer parameters from GUI
profile.Snf.output_rate_MHz = str2double(get(handles.snrxOutputSampleRate_MHz,'String'))
if (profile.Snf.output_rate_MHz < 20) || (profile.Snf.output_rate_MHz > 200)
    % return error to GUI
    error_info = sprintf('Sniffer output rate should be greater than 20MHz and less than 200MHz. Sniffer output rate was %0.2fMSPS. ERROR_CODE1',...
        profile.Snf.output_rate_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end
profile.Snf.RFBW_MHz = str2double(get(handles.snrxRfBw_MHz,'String'))
if (profile.Snf.RFBW_MHz < 5) || (profile.Snf.RFBW_MHz > 100)
    % return error to GUI
    error_info = sprintf('Sniffer RF BW should be greater than 5MHz and less than 100MHz. Sniffer RF BW was %0.2fMSPS. ERROR_CODE1',...
        profile.Snf.RFBW_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end

if ( ( profile.Snf.RFBW_MHz < profile.Snf.output_rate_MHz*0.40 ) || ( profile.Snf.RFBW_MHz > profile.Snf.output_rate_MHz*0.82 ) )
    % return error to GUI. This check is required based on filtering
    % ability and on the low side it is limited by RxQEC algorithm in ARM
    error_info = sprintf('Sniffer RF BW should be greater than 33%% and less than 82%% of the Rx output rate. Sniffer RF BW was %0.2fMHz. ERROR_CODE1',...
        profile.Snf.RFBW_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end

profile.Snf.pfir_passband_weight = str2double(get(handles.snrxPassBandWeight,'String'))
profile.Snf.pfir_stopband_weight = str2double(get(handles.snrxStopBandWeight,'String'))


% check to confirm that the ORx rate is a multiple of the Rx rate. 
snf_valid_rates = profile.Snf.output_rate_MHz * [1 2 4 8 16];
k = find(snf_valid_rates == profile.ORx.output_rate_MHz)
if isempty(k)
    % return error to GUI
    error_info = sprintf('ORx output rate should be a power of 2 multiple of Sniffer output rate. Sniffer output rate was %0.2fMSPS. ORx output rate was %0.2f. ERROR_CODE1',...
        profile.Snf.output_rate_MHz, profile.ORx.output_rate_MHz)
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end

end


profile = generate_Mykonos_datapath_config(profile, handles.txPlot, handles.rxPlot, handles.orxPlot, handles.snrxPlot, snrx_enabled);

if (snrx_enabled)
    profile.Snf.profileEnabled = 1;
else
    profile.Snf.profileEnabled = 0;
end
    
handles.profile = profile;

formatSpec = '%.6g\n';
devClkStr = num2str(profile.CLK.DEV_CLK_rate_MHz, formatSpec);

handles.cmboDeviceClock_kHz.String = devClkStr;
handles.cmboDeviceClock_kHz.Value = 1;

profile.CLK.selectedDEV_CLK_rate_MHz = profile.CLK.DEV_CLK_rate_MHz(1);
%num2str(profile.CLK.DEV_CLK_rate_MHz(handles.cmboDeviceClock_kHz.Value))
guidata(handles.figure1, handles);
status = sprintf('Profiles have been generated and updated!')
set(handles.error_info,'String',status);
set(handles.error_info,'ForegroundColor','black');

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
%if isfield(handles, 'metricdata') && ~isreset
%    return;
%end

% Update handles structure
guidata(handles.figure1, handles);


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%hObject
%RESIZE
%Set input panel position

handles.uiPanelInputs.Position = [0.8 1.8 52 (handles.figure1.Position(4) - 2.1)];

handles.radioVerseLogo.Position(1) = 0; %Left
handles.radioVerseLogo.Position(2) = -3; %bottom
handles.radioVerseLogo.Position(3) = handles.uiPanelInputs.Position(3) - 1; %width
handles.radioVerseLogo.Position(4) = 10; %height

%Set Tx Profile input Panel position
posTx = handles.uipanelTxProfile.Position;
posTx(2) = (handles.uiPanelInputs.Position(4) - 1.1) - posTx(4);
handles.uipanelTxProfile.Position = posTx;

%Set ORx Profile input Panel position
posOrx = handles.uipanelOrxProfile.Position;
posOrx(2) = (posTx(2) - .1) - posOrx(4);
handles.uipanelOrxProfile.Position = posOrx;

%Set Rx Profile input Panel position
posRx = handles.uipanelRxProfile.Position;
posRx(2) = (posOrx(2) - .1) - posRx(4);
handles.uipanelRxProfile.Position = posRx;

%Set SnRx Profile input Panel position
posSnrx = handles.uipanelSnrxSettings.Position;
posSnrx(2) = (posRx(2) - .1) - posSnrx(4);
handles.uipanelSnrxSettings.Position = posSnrx;

% Set Generate button location
posGenBtn = handles.generateProfiles.Position;
posGenBtn(2) = (posSnrx(2) - 1) - posGenBtn(4);
handles.generateProfiles.Position = posGenBtn;

%Set Device clock drop down combo location
posDeviceClkCombo = handles.cmboDeviceClock_kHz.Position;
posDeviceClkCombo(2) = (posGenBtn(2) - 1) - posDeviceClkCombo(4);
handles.cmboDeviceClock_kHz.Position = posDeviceClkCombo;
handles.deviceClkLabel.Position(2) = posDeviceClkCombo(2);

% Set Output File button location
posOutputBtn = handles.outputToFile.Position;
posOutputBtn(2) = (posDeviceClkCombo(2) - 1) - posOutputBtn(4);
handles.outputToFile.Position = posOutputBtn;


% Set position of status text box
posErrorInfo = handles.error_info.Position;
posErrorInfo(1) = 0.05;
posErrorInfo(2) = 0.05;
posErrorInfo(3) = handles.figure1.Position(3) - handles.adiLogo.Position(3) - 0.2;
%posErrorInfo(4) = (posOutputBtn(2) - .1) - .12;
posErrorInfo(4) = 1.5;
handles.error_info.Position = posErrorInfo;

handles.uipanelTxSummary.Position(1) = handles.uiPanelInputs.Position(1) + handles.uiPanelInputs.Position(3) + 1; %Left
handles.uipanelTxSummary.Position(2) = handles.uiPanelInputs.Position(2); % Bottom
handles.uipanelTxSummary.Position(3) = handles.figure1.Position(3) - handles.uiPanelInputs.Position(3) - 1.9; %width
handles.uipanelTxSummary.Position(4) = handles.figure1.Position(4) - 2.51; %height

handles.tgroup.Position = handles.uipanelTxSummary.Position;

%Reposition each panel to same location as panel 1
tabPos = handles.uipanelTxSummary.Position;
handles.uipanelTxSummary.Position = [0 0 tabPos(3)-0.5 tabPos(4)-0.5];
handles.uipanelRxSummary.Position = handles.uipanelTxSummary.Position;
handles.uipanelOrxSummary.Position = handles.uipanelTxSummary.Position;
handles.uipanelSnRxSummary.Position = handles.uipanelTxSummary.Position;

handles.txPlot.Position = [9.7 5 (handles.uipanelTxSummary.Position(3) - 15) (handles.uipanelTxSummary.Position(4) - 11)];
handles.rxPlot.Position = [9.7 5 (handles.uipanelRxSummary.Position(3) - 15) (handles.uipanelRxSummary.Position(4) - 11)];
handles.orxPlot.Position = [9.7 5 (handles.uipanelOrxSummary.Position(3) - 15) (handles.uipanelOrxSummary.Position(4) - 11)];
handles.snrxPlot.Position = [9.7 5 (handles.uipanelSnRxSummary.Position(3) - 15) (handles.uipanelSnRxSummary.Position(4) - 11)];

handles.adiLogo.Position(3) = 18; %width
handles.adiLogo.Position(4) = 1.77; %height
handles.adiLogo.Position(1) = handles.figure1.Position(3)- handles.adiLogo.Position(3);
handles.adiLogo.Position(2) = 0;



guidata(handles.figure1, handles);


function txInputRate_MHz_Callback(hObject, eventdata, handles)
% hObject    handle to txInputRate_MHz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txInputRate_MHz as text
%        str2double(get(hObject,'String')) returns contents of txInputRate_MHz as a double



% --- Executes on button press in outputToFile.
function outputToFile_Callback(hObject, eventdata, handles)
% hObject    handle to outputToFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    writeProfilesToFile(handles.profile, 'profile.txt');
    handles.error_info.String = 'Profiles have been output to profile.txt';
    handles.error_info.ForegroundColor = 'black';
    


% --- Executes on selection change in cmboDeviceClock_kHz.
function cmboDeviceClock_kHz_Callback(hObject, eventdata, handles)
% hObject    handle to cmboDeviceClock_kHz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cmboDeviceClock_kHz contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmboDeviceClock_kHz
contents = cellstr(get(hObject,'String'));
clkfreq = contents{get(hObject,'Value')};
handles.profile.CLK.selectedDEV_CLK_rate_MHz = str2num(clkfreq);
guidata(handles.figure1, handles);


