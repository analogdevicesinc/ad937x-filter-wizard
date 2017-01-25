function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      The control stays in the app until the figure is closed. This is
%      done to be able to return the profile as an output argument. In case
%      the an output isn't desired, commenting out the whole lines with the
%      end comment 'Comment this' returns control back to the command window
%      immediately and allows for execution of other programs while the
%      Filter wizard is open.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 08-Dec-2016 08:20:15

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
    [varargout{1:nargout}] = gui_mainfcn(gui_State, [varargin{:} {'out'}]);
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
movegui('center');
%set(handles.figure1, 'resize', 'off');
handles.figure1.Name = 'AD9371 Filter Wizard v1.8';
handles.welcomeTab = uitab('Parent', handles.tgroup, 'Title', 'Instructions');
handles.tab1 = uitab('Parent', handles.tgroup, 'Title', 'Tx Summary');
handles.tab2 = uitab('Parent', handles.tgroup, 'Title', 'ORx Summary');
handles.tab3 = uitab('Parent', handles.tgroup, 'Title', 'Rx Summary');
handles.tab4 = uitab('Parent', handles.tgroup, 'Title', 'Sniffer Rx Summary');

%Place panels into each tab
set(handles.uipanelTxSummary,'Parent', handles.tab1);
set(handles.uipanelOrxSummary,'Parent', handles.tab2);
set(handles.uipanelRxSummary,'Parent', handles.tab3);
set(handles.uipanelSnRxSummary,'Parent', handles.tab4);
%set(handles.uipanelMykSummary,'Parent', handles.tab5)
%set(handles.P3,'Parent',handles.tab3)

%create Instruction Tab/Panel
handles.uipanelInstructions = uipanel('Parent', handles.welcomeTab);

handles.instrtxt = ['<html><head><style type="text/css">p{margin:50%;}</style></head>' ...        
     '<body style="background-color:white;"> '...
     '<h2 style="text-align:left;">Welcome to the AD9371 Filter Wizard</h2> '...
     '<p style="color:black;"> '...
        'This application is used to design the AD9371 transmitter and receiver '...
        'programmable FIR filters. This tool creates FIR filters which equalize '...
        'the desired passband, taking into account the signal transfer functions '...
        'through the entire analog and digital signal path in the AD9371 transceiver.'... 
        'Any custom configuration of sampling rates and bandwidths must use this tool '...
        'to create a profile which can be used by a customer system as well as the '...
        'Evaluation and Prototype Software packages.'...
        'The Filter Wizard is available as MATLAB source code, a MATLAB app, '...
        'and as a stand-alone executable.'...
     '</p>'...
    '<h3>With this wizard, customers can perform the following tasks:</h3>'...
    '<ul>'...
        '<li>Design programmable FIR filters based on custom sampling rate, bandwidth, '...
        'and weighting parameters which affect passband ripple and stopband attenuation</li>'...        
        '<li>Save the input parameters and FIR coefficients to file which can be '...
        'loaded into the AD9371</li>'...
    '</ul>'...
    '<h3>Filter Wizard User Guide:</h3>'...
    '<p>'...
        'The Wiki site which provides the link to the Filter Wizard application '...
        'is also the user guide for the application.  Information about the general '...
        'operation, release notes, known issues, and limitations are all included '...
        'on the Wiki page.  See the link at the bottom of this window.'...
    '</p>'...   
    '<p>'...
        '<b>Any questions not addressed by the Wiki site should be posted to the API Engineer Zone Forum.</b>'...
    '</p>'...    
    '<h3>Filter Wizard Rules</h3>'...
    '<p>'...
        'The Filter Wizard checks user input and resulting clock rates within the '...
        'AD9371 against a set of rules.  The Filter Wizard will not generate an output '...
        'file if these parameters break the built-in rules.  In that case, the Filter '...
        'Wizard will display which rule(s) have been broken and why.'...
        'The full set of rules used by the Filter Wizard is located on the Wiki site mentioned above.'...
    '</p>'...    
    '<h3>Pass/Stop Band Weights</h3>'...
    '<p>'...
        'Pass band ripple and stop band rejection can be traded off to improve one or the other.'...
        'To <b>improve passband ripple</b> increase the pass band weight, and reduce stop band weight. '...
        'To <b>improve stopband rejection</b> increase the stop band weight, and reduce pass band weight. '...
    '</p>'...
     '</body></html>'];

%Tried to use Matlab text or button uicontrol, but could not control text
%formatting...used java edit pane below instead.
%handles.instrText = uicontrol('Parent', handles.uipanelInstructions,...
%    'Style','pushbutton',...    
%    'Units', 'normalized',...
%    'pos',[0,0,1,1],...
%    'HorizontalAlignment', 'center',...
%    'BackgroundColor', 'white',...
%    'string',handles.instrtxt,...
%    'Enable','inactive');
 
% Create a figure with a scrollable JEditorPane
je = javax.swing.JEditorPane('text/html', handles.instrtxt);
jp = javax.swing.JScrollPane(je);
[hcomponent, hcontainer] = javacomponent(jp, [], handles.uipanelInstructions);
set(hcontainer, 'units', 'normalized', 'position', [0,0,1,1]);
je.setEditable(false);
    
handles.webLink = uicontrol('Parent', handles.uipanelInstructions,...
    'string','<html><a href="">ADI Wiki</a></html>',...
    'Style','pushbutton',...    
    'pos',[20,20,150,35],...
    'ButtonDownFcn', 'web(''https://wiki.analog.com/resources/eval/user-guides/mykonos/software/filters'');',...
    'Units', 'characters',...
    'Enable', 'inactive');

handles.webLink = uicontrol('Parent', handles.uipanelInstructions,...
    'string','<html><a href="">ADI Support Forum</a></html>',...
    'Style','pushbutton',...    
    'pos',[180,20,150,35],...
    'ButtonDownFcn', 'web(''https://ez.analog.com/community/wide-band-rf-transceivers/wideband-transceiver-api'');',...
    'Units', 'characters',...
    'Enable', 'inactive');

%redraw GUI
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
if ~(isempty(varargin))
    if strcmp(varargin{end},'out')
        handles.out = 'out';
        guidata(handles.figure1, handles);
        uiwait(handles.figure1);
    end
else
    handles.out = [];
    guidata(handles.figure1, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
if isfield(handles,'profile')
    output = getfield(handles, 'profile');
else
    output =[];
end
varargout{1} = output;
if isempty(handles.out)==0
    delete(handles.figure1);
end

% --- Executes on button press in generateProfiles.
function generateProfiles_Callback(hObject, eventdata, handles)
% hObject    handle to generateProfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%axes(handles.rxPlot);
%cla;
%plot(sin(1:0.01:25.99));

%addpath ../delsig7p4mykonos/


addpath ../common/;
addpath ../delsig_public/;
addpath ../adc/;
addpath ../profilegen/;

profile = init_Mykonos_config();
set(handles.error_info,'String','Status');
set(handles.error_info,'ForegroundColor','black');

% Update Tx profile parameters from user entered values 
profile.Tx.input_rate_MHz = str2double(get(handles.txInputRate_MHz,'String'));
profile.Tx.synthesis_RFBW_MHz = str2double(get(handles.txRfBw_MHz,'String'));
profile.Tx.prim_sgl_RFBW_MHz = str2double(get(handles.txPriSigBw_MHz,'String'));
profile.Tx.pfir_passband_weight = str2double(get(handles.txPassBandWeight,'String'));
profile.Tx.pfir_stopband_weight = str2double(get(handles.txStopBandWeight,'String'));

% Update ORx parameters from GUI
profile.ORx.output_rate_MHz = str2double(get(handles.orxOutputSampleRate_MHz,'String'));
profile.ORx.RFBW_MHz = str2double(get(handles.orxRfBw_MHz,'String'));
profile.ORx.pfir_passband_weight = str2double(get(handles.orxPassBandWeight,'String'));
profile.ORx.pfir_stopband_weight = str2double(get(handles.orxStopBandWeight,'String'));

% Update Rx parameters from GUI
profile.Rx.output_rate_MHz = str2double(get(handles.rxOutputSampleRate_MHz,'String'));
profile.Rx.RFBW_MHz = str2double(get(handles.rxRfBw_MHz,'String'));
profile.Rx.pfir_passband_weight = str2double(get(handles.rxPassbandWeight,'String'));
profile.Rx.pfir_stopband_weight = str2double(get(handles.rxStopBandWeight,'String'));

% check to confirm that the ORx rate is a multiple of the Rx rate. 
rx_valid_rates = profile.Rx.output_rate_MHz * [1 2 4 8];
k = find(rx_valid_rates == profile.ORx.output_rate_MHz);
if isempty(k)
    % return error to GUI
    error_info = sprintf('ORx output rate should be a power of 2 multiple of Rx output rate. Rx output rate was %0.2fMSPS. ORx output rate was %0.2fMHz.',...
        profile.Rx.output_rate_MHz, profile.ORx.output_rate_MHz);
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end

snrx_enabled = get(handles.snrxProfileEnabled,'Value');
if (snrx_enabled)
    profile.Snf.profileEnabled = 1;
else
    profile.Snf.profileEnabled = 0;
end

if (snrx_enabled)
    % Update Sniffer parameters from GUI
    profile.Snf.output_rate_MHz = str2double(get(handles.snrxOutputSampleRate_MHz,'String'));
    profile.Snf.RFBW_MHz = str2double(get(handles.snrxRfBw_MHz,'String'));
    profile.Snf.pfir_passband_weight = str2double(get(handles.snrxPassBandWeight,'String'));
    profile.Snf.pfir_stopband_weight = str2double(get(handles.snrxStopBandWeight,'String'));

    % check to confirm that the ORx rate is a multiple of the Rx rate. 
    snf_valid_rates = profile.Snf.output_rate_MHz * [1 2 4 8 16];
    k = find(snf_valid_rates == profile.ORx.output_rate_MHz);
    if isempty(k)
        % return error to GUI
        error_info = sprintf('ORx output rate should be a power of 2 multiple of Sniffer output rate. Sniffer output rate was %0.2fMSPS. ORx output rate was %0.2f.',...
            profile.Snf.output_rate_MHz, profile.ORx.output_rate_MHz);
        set(handles.error_info,'String',error_info);
        set(handles.error_info,'ForegroundColor','red');
        errordlg(error_info,'Error');
        return;
    end
end

if (handles.advanced_settings.Value == 1)
    profile.Rx.pfir_no_of_coefs = handles.adv_set.Rx.pfir_no_of_coefs;
    profile.Rx.force_pfir = handles.adv_set.Rx.force_pfir;
    profile.Rx.dec5_enable = handles.adv_set.Rx.dec5_enable;
    profile.Rx.Advanced = 1;
    profile.ORx.pfir_no_of_coefs = handles.adv_set.ORx.pfir_no_of_coefs;
    profile.ORx.force_pfir = handles.adv_set.ORx.force_pfir;
    profile.ORx.dec5_enable = handles.adv_set.Rx.dec5_enable;
    profile.ORx.Advanced = 1;
    if get(handles.snrxProfileEnabled, 'Value')
        profile.Snf.pfir_no_of_coefs = handles.adv_set.Snf.pfir_no_of_coefs;
        profile.Snf.force_pfir = handles.adv_set.Snf.force_pfir;
        profile.Snf.dec5_enable = handles.adv_set.Rx.dec5_enable;
        profile.Snf.Advanced = 1;
    end
end

try
    profile = generate_Mykonos_datapath_config(profile, handles.txPlot, handles.rxPlot, handles.orxPlot, handles.snrxPlot);
catch err
    error_info = sprintf('%s', err.message);
    set(handles.error_info,'String',error_info);
    set(handles.error_info,'ForegroundColor','red');
    errordlg(error_info,'Error');
    return;
end

if handles.VCXO_en.Value == 1
    profile.CLK.VCOX_en = get(handles.VCXO_en,'Value');
    profile.CLK.VCOX_MHz = str2double(get(handles.VCXO_MHz,'String'));
    try
        [possible_dev_clk_rate, M1, N2, out_div] = AD9528_rates( str2double(get(handles.VCXO_MHz,'String')) , profile.CLK.DEV_CLK_rate_MHz);
    catch err
        error_info = sprintf('%s', err.message);
        set(handles.error_info,'String',error_info);
        set(handles.error_info,'ForegroundColor','red');
        errordlg(error_info,'Error');
        handles.cmboDeviceClock_kHz.String = ' ';
        handles.cmboDeviceClock_kHz.Value = 1;
        return;
    end
    profile.CLK.VCOX_M1 = M1;
    profile.CLK.VCOX_N2 = N2;
    profile.CLK.VCOX_out_div = out_div;
else
    profile.CLK.VCOX_en = 0;
    possible_dev_clk_rate = profile.CLK.DEV_CLK_rate_MHz;
end

formatSpec = '%7.3f\n';
devClkStr = num2str(possible_dev_clk_rate, formatSpec);
handles.cmboDeviceClock_kHz.String = devClkStr;
handles.cmboDeviceClock_kHz.Value = 1;
handles.ref_clk_div.Value = 1;

profile.CLK.selectedDEV_CLK_rate_MHz = profile.CLK.DEV_CLK_rate_MHz(1);

handles.adv_set.Rx.dec5_enable = profile.Rx.dec5_enable;
handles.adv_set.Rx.pfir_no_of_coefs = profile.Rx.pfir_no_of_coefs;
handles.adv_set.Rx.force_pfir = profile.Rx.force_pfir;
handles.adv_set.ORx.pfir_no_of_coefs = profile.ORx.pfir_no_of_coefs;
handles.adv_set.ORx.force_pfir = profile.ORx.force_pfir;
if (snrx_enabled)
    handles.adv_set.Snf.pfir_no_of_coefs = profile.Snf.pfir_no_of_coefs;
    handles.adv_set.Snf.force_pfir = profile.Snf.force_pfir;
else
    handles.adv_set.Snf.pfir_no_of_coefs = 24;
    handles.adv_set.Snf.force_pfir = 0;
end

handles.profile = profile;
guidata(handles.figure1, handles);

status = sprintf('Profiles have been generated and updated!');
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
logoZoom = zoom(handles.radioVerseLogo);
logoZoom.Enable = 'off';

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

%Set Advanced Settings location
posAdvSet = handles.advanced_settings.Position;
posAdvSet(2) = (posSnrx(2) - .5) - posAdvSet(4);
handles.advanced_settings.Position = posAdvSet;

%Set VCXO Settings location
posVCXO = handles.VCXO_en.Position;
posVCXO(2) = (posAdvSet(2) - 0.4) - posVCXO(4);
handles.VCXO_en.Position = posVCXO;
handles.VCXO_MHz.Position(2) = posVCXO(2);

% Set Generate button location
posGenBtn = handles.generateProfiles.Position;
posGenBtn(2) = (posVCXO(2) - 0.4) - posGenBtn(4);
handles.generateProfiles.Position = posGenBtn;

% Set Ref clock divider combo location
posRefDiv = handles.ref_clk_div.Position;
posRefDiv(2) = (posGenBtn(2) - 0.4) - posRefDiv(4);
handles.ref_clk_div.Position = posRefDiv;
handles.ref_clk_div_text.Position(2) = posRefDiv(2);

%Set Device clock drop down combo location
posDeviceClkCombo = handles.cmboDeviceClock_kHz.Position;
posDeviceClkCombo(2) = (posRefDiv(2) - 0.4) - posDeviceClkCombo(4);
handles.cmboDeviceClock_kHz.Position = posDeviceClkCombo;
handles.deviceClkLabel.Position(2) = posDeviceClkCombo(2);

% Set Output File button location
posOutputBtn = handles.outputToFile.Position;
posOutputBtn(2) = (posDeviceClkCombo(2) - 0.4) - posOutputBtn(4);
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
contents = cellstr(get(handles.cmboDeviceClock_kHz,'String'));
clkfreq = contents{get(handles.cmboDeviceClock_kHz,'Value')};
if (isempty(clkfreq) ~= 1)
    [filename, pathname] = uiputfile({'*.txt;','Mykonos Filter Profile'}...
      ,'Save Mykonos Filter Profile', 'profile.txt');

    if isequal(filename,0) || isequal(pathname,0)
    handles.error_info.String = 'Profile output was canceled';
    handles.error_info.ForegroundColor = 'red';    
    else
    writeProfilesToFile(handles.profile, fullfile(pathname, filename));
    handles.error_info.String = sprintf('Profiles have been output to %s', fullfile(pathname, filename));
    handles.error_info.ForegroundColor = 'black';    
    end
    
end

% --- Executes on selection change in cmboDeviceClock_kHz.
function cmboDeviceClock_kHz_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
clkfreq = contents{get(hObject,'Value')};
handles.profile.CLK.selectedDEV_CLK_rate_MHz = str2num(clkfreq);
if handles.VCXO_en.Value == 1
    handles.profile.CLK.VCOX_selected_index = get(handles.cmboDeviceClock_kHz, 'Value');
else
    handles.profile.CLK.VCOX_selected_index = 1;
end
guidata(handles.figure1, handles);

% --- Executes on button press in advanced_settings.
function advanced_settings_Callback(hObject, eventdata, handles)
% Opens a modal window with advanced setting options. The advanced settings
% are stored in the adv_set field and copied to 'profile' when generate
% profiles button is hit.
if (isfield(handles,'adv_set')==0)
	[profile, cancelled] = Advanced(handles.snrxProfileEnabled.Value);
elseif (handles.snrxProfileEnabled.Value == 1)
    [profile, cancelled] = Advanced(handles.adv_set.Rx.dec5_enable,...
                                handles.adv_set.Rx.pfir_no_of_coefs, handles.adv_set.Rx.force_pfir,...
                                handles.adv_set.ORx.pfir_no_of_coefs, handles.adv_set.ORx.force_pfir,...
                                handles.adv_set.Snf.pfir_no_of_coefs, handles.adv_set.Snf.force_pfir);
else
    [profile, cancelled] = Advanced(handles.adv_set.Rx.dec5_enable,...
                                handles.adv_set.Rx.pfir_no_of_coefs, handles.adv_set.Rx.force_pfir,...
                                handles.adv_set.ORx.pfir_no_of_coefs, handles.adv_set.ORx.force_pfir,...
                                0,0);
end
if cancelled == 1
    handles.adv_set.Rx.dec5_enable = 0;
    handles.adv_set.Rx.pfir_no_of_coefs = 24;
    handles.adv_set.Rx.force_pfir = 0;
    handles.adv_set.ORx.pfir_no_of_coefs = 24;
    handles.adv_set.ORx.force_pfir = 0;
	handles.adv_set.Snf.pfir_no_of_coefs = 24;
    handles.adv_set.Snf.force_pfir = 0;
    set(handles.advanced_settings,'value',0);
    handles.profile.Advanced = 0;
    guidata(hObject, handles);
elseif cancelled == 0
    set(handles.advanced_settings,'value',1);
    handles.adv_set.Rx.dec5_enable = profile.DEC_mode;
    handles.adv_set.Rx.pfir_no_of_coefs = profile.Rx.pfir_no_coefs;
    handles.adv_set.Rx.force_pfir = profile.Rx.force_pfir;
    handles.adv_set.ORx.pfir_no_of_coefs = profile.ORx.pfir_no_coefs;
    handles.adv_set.ORx.force_pfir = profile.ORx.force_pfir;
    if handles.snrxProfileEnabled.Value == 1
        handles.adv_set.Snf.pfir_no_of_coefs = profile.Snf.pfir_no_coefs;
        handles.adv_set.Snf.force_pfir = profile.Snf.force_pfir;
	else
		handles.adv_set.Snf.pfir_no_of_coefs = 24;
        handles.adv_set.Snf.force_pfir = 0;
    end
    guidata(hObject, handles);    
else
    val = get(handles.advanced_settings,'value');
    set(handles.advanced_settings,'value',abs(val-1));
end

% --- Executes on button press in VCXO_en.
function VCXO_en_Callback(hObject, eventdata, handles)
if handles.VCXO_en.Value == 1
    set(handles.VCXO_MHz, 'Enable', 'on');
else
    set(handles.VCXO_MHz, 'Enable', 'off');
end
guidata(hObject, handles);
ref_clk_div_Callback(hObject, eventdata, handles);


function VCXO_MHz_Callback(hObject, eventdata, handles)
ref_clk_div_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function VCXO_MHz_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ref_clk_div.
function ref_clk_div_Callback(hObject, eventdata, handles)
if (isfield(handles,'profile')~=0)
    ref_clk_div = cellstr(get(handles.ref_clk_div,'String'));
    ref_clk_div = str2num(ref_clk_div{get(handles.ref_clk_div,'Value')});
    handles.profile.CLK.REF_CLK_divider = ref_clk_div;
    guidata(handles.figure1, handles);
    
    handles.profile.CLK.DEV_CLK_rate_MHz = handles.profile.CLK.REF_CLK_rate_MHz*ref_clk_div;

    if handles.VCXO_en.Value == 1
        handles.profile.CLK.VCOX_en = get(handles.VCXO_en,'Value');
        handles.profile.CLK.VCOX_MHz = str2double(get(handles.VCXO_MHz,'String'));
        try
            [possible_dev_clk_rate, M1, N2, out_div] = AD9528_rates( str2double(get(handles.VCXO_MHz,'String')) , handles.profile.CLK.DEV_CLK_rate_MHz);
        catch err
            error_info = sprintf('%s', err.message);
            set(handles.error_info,'String',error_info);
            set(handles.error_info,'ForegroundColor','red');
            errordlg(error_info,'Error');
            handles.cmboDeviceClock_kHz.String = ' ';
            handles.cmboDeviceClock_kHz.Value = 1;
            return;
        end
        handles.profile.CLK.VCOX_M1 = M1;
        handles.profile.CLK.VCOX_N2 = N2;
        handles.profile.CLK.VCOX_out_div = out_div;
    else
        handles.profile.CLK.VCOX_en = 0;
        possible_dev_clk_rate = handles.profile.CLK.DEV_CLK_rate_MHz;
    end

    formatSpec = '%7.3f\n';
    devClkStr = num2str(possible_dev_clk_rate, formatSpec);
    handles.cmboDeviceClock_kHz.String = devClkStr;
    handles.cmboDeviceClock_kHz.Value = 1;

    handles.profile.CLK.selectedDEV_CLK_rate_MHz = possible_dev_clk_rate(1);
    guidata(hObject, handles); 
end

% --- Executes during object creation, after setting all properties.
function ref_clk_div_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
