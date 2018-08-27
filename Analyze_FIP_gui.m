function varargout = Analyze_FIP_gui(varargin)
% ANALYZE_FIP_GUI MATLAB code for Analyze_FIP_gui.fig
%      ANALYZE_FIP_GUI, by itself, creates a new ANALYZE_FIP_GUI or raises the existing
%      singleton*.
%
%      H = ANALYZE_FIP_GUI returns the handle to a new ANALYZE_FIP_GUI or the handle to
%      the existing singleton*.
%
%      ANALYZE_FIP_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYZE_FIP_GUI.M with the given input arguments.
%
%      ANALYZE_FIP_GUI('Property','Value',...) creates a new ANALYZE_FIP_GUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Analyze_FIP_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Analyze_FIP_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Analyze_FIP_gui

% Last Modified by GUIDE v2.5 26-Aug-2018 16:47:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Analyze_FIP_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Analyze_FIP_gui_OutputFcn, ...
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

% --- Executes just before Analyze_FIP_gui is made visible.
function Analyze_FIP_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Analyze_FIP_gui (see VARARGIN)

% --- SET DEFAULTS FOR ALL SETTINGS --- %
handles.output_flag = 1; % calculate dF/F instead of zscore
handles.bleach_flag = 1; % de-bleach both sig and ref before subtraction
handles.lowpass_filt = []; % no filtering
set(handles.enter_lowpassfilter, 'Enable', 'off'); % no filtering
handles.smooth_points = []; % no smoothing
set(handles.enter_lowpassfilter, 'Enable', 'off'); % no smoothing
handles.ai=zeros(1,7); % plot flags for analog inputs
handles.ai_labels=["Stimulus 1", "Stimulus 2", "Stimulus 3", "Stimulus 4",...
    "Stimulus 5", "Stimulus 6", "Stimulus 7"']; % labels for each stimulus
handles.plot_pre = 2; % plot 2 s before stimulus
handles.plot_post = 5; % plot 5 s after stimulus

% Choose default command line output for Analyze_FIP_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Analyze_FIP_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Analyze_FIP_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Data input --- %


% --- Executes during object creation, after setting all properties.
function enter_filepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function enter_filepath_Callback(hObject, eventdata, handles)
% hObject    handle to enter_filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_filepath as text
%        str2double(get(hObject,'String')) returns contents of enter_filepath as a double
filepath = get(hObject, 'String');
display(filepath);
handles.filepath=filepath;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function enter_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function enter_filename_Callback(hObject, eventdata, handles)
% hObject    handle to enter_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_filename as text
%        str2double(get(hObject,'String')) returns contents of enter_filename as a double
filename = get(hObject, 'String');
display(filename);
handles.filename = filename;
guidata(hObject,handles)

% --- Executes on button press in pushbutton3_selectfile.
function pushbutton3_selectfile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3_selectfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('', 'Select a .mat file to analyze');
set(handles.enter_filename,'String',filename);
set(handles.enter_filepath,'String',pathname);
handles.filename = filename;
handles.filepath = pathname;
guidata(hObject,handles)



% --- Data output format --- %



% --- Executes when selected object is changed in uibuttongroup_output.
function uibuttongroup_output_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup_output 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue, 'Tag')
    case 'radiobutton1_dfF'
        handles.output_flag = 1;
        display('Calculate dF/F');
    case 'radiobutton2_zscore'
        handles.output_flag = 0;
        display('Calculate Zscore');
end
guidata(hObject,handles)


% --- Executes on button press in checkbox1_subtractbleaching.
function checkbox1_subtractbleaching_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1_subtractbleaching (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1_subtractbleaching
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.bleach_flag = 1;
    display('Subtract bleaching from sig and ref');
else
    handles.bleach_flag = 0;
    display('No bleaching subtraction');
end
guidata(hObject,handles)


% --- Executes on button press in checkbox2_lowpassfilter.
function checkbox2_lowpassfilter_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2_lowpassfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2_lowpassfilter
if (get(hObject,'Value') == get(hObject,'Max'))
    set(handles.enter_lowpassfilter, 'Enable', 'on');
    try
        enter_lowpassfilter_Callback;
    catch
        display('Enter Low-pass filter cut-off frequency');
    end
else
    set(handles.enter_lowpassfilter, 'Enable', 'off');
    handles.lowpass_filt=[];
end
guidata(hObject,handles)


function enter_lowpassfilter_Callback(hObject, eventdata, handles)
% hObject    handle to enter_lowpassfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_lowpassfilter as text
%        str2double(get(hObject,'String')) returns contents of enter_lowpassfilter as a double
handles.low_pass_filt = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function enter_lowpassfilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_lowpassfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox3_smooth.
function checkbox3_smooth_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3_smooth
if (get(hObject,'Value') == get(hObject,'Max'))
    set(handles.enter_smooth, 'Enable', 'on');
    try
        enter_smooth_Callback;
    catch
        display('Enter number of datapoints to smooth');
    end
else
    set(handles.enter_smooth, 'Enable', 'off');
    handles.smooth_points=[];
end
guidata(hObject,handles)



function enter_smooth_Callback(hObject, eventdata, handles)
% hObject    handle to enter_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_smooth as text
%        str2double(get(hObject,'String')) returns contents of enter_smooth as a double
handles.smooth_points = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function enter_smooth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton1_plotprocesseddata.
function pushbutton1_plotprocesseddata_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1_plotprocesseddata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Analyze_FIP(handles.filepath,handles.filename,handles.output_flag,handles.bleach_flag,handles.lowpass_filt,handles.smooth_points);



% --- Stimulus-triggered responses --- %

function enter_plotpre_Callback(hObject, eventdata, handles)
% hObject    handle to enter_plotpre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_plotpre as text
%        str2double(get(hObject,'String')) returns contents of enter_plotpre as a double
handles.plot_pre=str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function enter_plotpre_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_plotpre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function enter_plotpost_Callback(hObject, eventdata, handles)
% hObject    handle to enter_plotpost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_plotpost as text
%        str2double(get(hObject,'String')) returns contents of enter_plotpost as a double
handles.plot_post=str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function enter_plotpost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_plotpost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2_plotstimulustriggeredresponses.
function pushbutton2_plotstimulustriggeredresponses_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2_plotstimulustriggeredresponses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if sum(handles.ai)<1
    f = msgbox('Error: Please select AI to plot');
else
    Stimulus_Responses(handles.filepath,handles.filename,handles.plot_pre,handles.plot_post,handles.ai,handles.ai_labels);
end

% --- Executes on button press in checkbox5_ai1.
function checkbox5_ai1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5_ai1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5_ai1
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.ai(1)=1;
else
    handles.ai(1)=0;
end
guidata(hObject,handles)

function enter_ai1_Callback(hObject, eventdata, handles)
% hObject    handle to enter_ai1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_ai1 as text
%        str2double(get(hObject,'String')) returns contents of enter_ai1 as a double
handles.ai_labels(1)=get(hObject,'String');
guidata(hObject,handles)



% --- Executes on button press in checkbox6_ai2.
function checkbox6_ai2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6_ai2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6_ai2
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.ai(2)=1;
else
    handles.ai(2)=0;
end
guidata(hObject,handles)

function enter_ai2_Callback(hObject, eventdata, handles)
% hObject    handle to enter_ai2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_ai2 as text
%        str2double(get(hObject,'String')) returns contents of enter_ai2 as a double
handles.ai_labels(2)=get(hObject,'String');
guidata(hObject,handles)


% --- Executes on button press in checkbox7_ai3.
function checkbox7_ai3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7_ai3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7_ai3
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.ai(3)=1;
else
    handles.ai(3)=0;
end
guidata(hObject,handles)


function enter_ai3_Callback(hObject, eventdata, handles)
% hObject    handle to enter_ai3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_ai3 as text
%        str2double(get(hObject,'String')) returns contents of enter_ai3 as a double
handles.ai_labels(3)=get(hObject,'String');
guidata(hObject,handles)


% --- Executes on button press in checkbox8_ai4.
function checkbox8_ai4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8_ai4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8_ai4
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.ai(4)=1;
else
    handles.ai(4)=0;
end
guidata(hObject,handles)


function enter_ai4_Callback(hObject, eventdata, handles)
% hObject    handle to enter_ai4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_ai4 as text
%        str2double(get(hObject,'String')) returns contents of enter_ai4 as a double
handles.ai_labels(4)=get(hObject,'String');
guidata(hObject,handles)


% --- Executes on button press in checkbox9_ai5.
function checkbox9_ai5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9_ai5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9_ai5
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.ai(5)=1;
else
    handles.ai(5)=0;
end
guidata(hObject,handles)


function enter_ai5_Callback(hObject, eventdata, handles)
% hObject    handle to enter_ai5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_ai5 as text
%        str2double(get(hObject,'String')) returns contents of enter_ai5 as a double
handles.ai_labels(5)=get(hObject,'String');
guidata(hObject,handles)


% --- Executes on button press in checkbox10_ai6.
function checkbox10_ai6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10_ai6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10_ai6
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.ai(6)=1;
else
    handles.ai(6)=0;
end
guidata(hObject,handles)


function enter_ai6_Callback(hObject, eventdata, handles)
% hObject    handle to enter_ai6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_ai6 as text
%        str2double(get(hObject,'String')) returns contents of enter_ai6 as a double
handles.ai_labels(6)=get(hObject,'String');
guidata(hObject,handles)


% --- Executes on button press in checkbox11_ai7.
function checkbox11_ai7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11_ai7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11_ai7
if (get(hObject,'Value') == get(hObject,'Max'))
    handles.ai(7)=1;
else
    handles.ai(7)=0;
end
guidata(hObject,handles)


function enter_ai7_Callback(hObject, eventdata, handles)
% hObject    handle to enter_ai7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of enter_ai7 as text
%        str2double(get(hObject,'String')) returns contents of enter_ai7 as a double
handles.ai_labels(7)=get(hObject,'String');
guidata(hObject,handles)

% --- create functions --- %
 
% --- Executes during object creation, after setting all properties.
function enter_ai0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_ai0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function enter_ai1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_ai1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function enter_ai2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_ai2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function enter_ai3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_ai3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function enter_ai4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_ai4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function enter_ai5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_ai5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function enter_ai6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_ai6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function enter_ai7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to enter_ai7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
