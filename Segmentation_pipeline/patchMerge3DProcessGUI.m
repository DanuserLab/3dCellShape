function varargout = patchMerge3DProcessGUI(varargin)
% patchmerge3dprocessgui M-file for patchmerge3dprocessgui.fig
%      patchmerge3dprocessgui, by itself, creates a new patchmerge3dprocessgui or raises the existing
%      singleton*.
%
%      H = patchmerge3dprocessgui returns the handle to a new patchmerge3dprocessgui or the handle to
%      the existing singleton*.
%
%      patchmerge3dprocessgui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in patchmerge3dprocessgui.M with the given input arguments.
%
%      patchmerge3dprocessgui('Property','Value',...) creates a new patchmerge3dprocessgui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before patchmerge3dprocessgui_openingfcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to patchmerge3dprocessgui_openingfcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES


% Edit the above text to modify the response to help patchmerge3dprocessgui

% Last Modified by GUIDE v2.5 23-Jul-2018 13:26:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @patchMerge3DProcessGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @patchMerge3DProcessGUI_OutputFcn, ...
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

% --- Executes just before patchmerge3dprocessgui is made visible.
function patchMerge3DProcessGUI_OpeningFcn(hObject, eventdata, handles, varargin)

processGUI_OpeningFcn(hObject, eventdata, handles, varargin{:},'initChannel',1);

% Set-up parameters
userData = get(handles.figure1,'UserData');
funParams = userData.crtProc.funParams_;
%Remove the output directory as we don't want to replicate it to other
%movies if the "apply to all movies" box is checked. Ideally we would
%explicitly only replicate the parameters we set in this GUI but this is a
%quick fix. - HLE
if isfield(funParams,'OutputDirectory')
    funParams = rmfield(funParams,'OutputDirectory');
end
% set(handles.popupmenu_CurrentChannel,'UserData',funParams);
set(handles.popupmenu_CurrentChannel,'UserData',funParams);

% handles
% handles
% handles.edit_svmPath.String = funParams.svmPath;

iChan = get(handles.popupmenu_CurrentChannel,'Value');
if isempty(iChan)
    iChan = 1;
    set(handles.popupmenu_CurrentChannel,'Value',1);
end

%Update channel parameter selection dropdown
popupmenu_CurrentChannel_Callback(hObject, eventdata, handles);
% Update GUI user data
set(handles.figure1, 'UserData', userData);
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = patchMerge3DProcessGUI_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(~, ~, handles)
% Delete figure
delete(handles.figure1);

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, ~, handles)
% Notify the package GUI that the setting panel is closed
userData = get(handles.figure1, 'UserData');
if(isempty(userData)), userData = struct(); end;

if isfield(userData, 'helpFig') && ishandle(userData.helpFig)
   delete(userData.helpFig) 
end

set(handles.figure1, 'UserData', userData);
guidata(hObject,handles);

% --- Executes on key press with focus on pushbutton_done and none of its controls.
function pushbutton_done_KeyPressFcn(~, eventdata, handles)

if strcmp(eventdata.Key, 'return')
    pushbutton_done_Callback(handles.pushbutton_done, [], handles);
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(~, eventdata, handles)

if strcmp(eventdata.Key, 'return')
    pushbutton_done_Callback(handles.pushbutton_done, [], handles);
end

% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)

% -------- Check user input --------

if isempty(get(handles.listbox_selectedChannels, 'String'))
    errordlg('Please select at least one input channel from ''Available Channels''.','Setting Error','modal')
    return;
end


if isempty(get(handles.edit_svmPath, 'String'))
    errordlg('Please provide svm .mat file path ','Setting Error','modal')
    return;
end

%Save the currently set per-channel parameters
pushbutton_saveChannelParams_Callback(hObject, eventdata, handles)


% Retrieve detection parameters
funParams = get(handles.popupmenu_CurrentChannel,'UserData');
% Retrieve GUI-defined non-channel specific parameters

%Get selected image channels
channelIndex = get(handles.listbox_selectedChannels, 'Userdata');
if isempty(channelIndex)
    errordlg('Please select at least one input channel from ''Available Channels''.','Setting Error','modal')
    return;
end
funParams.ChannelIndex = channelIndex;

processGUI_ApplyFcn(hObject, eventdata, handles,funParams);

% --- Executes on selection change in popupmenu_CurrentChannel.
function popupmenu_CurrentChannel_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_CurrentChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_CurrentChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_CurrentChannel
userData=get(handles.figure1,'UserData');
funParams = get(handles.popupmenu_CurrentChannel,'UserData');

selChan = 1:numel(userData.MD.channels_);%For now just let them set parameters for all channels.
%selChan = get(handles.listbox_selectedChannels,'UserData');
chanStr = arrayfun(@(x)(['Channel ' num2str(x)]),selChan,'Unif',0);
set(handles.popupmenu_CurrentChannel,'String',chanStr);
iChan = get(handles.popupmenu_CurrentChannel,'Value');
%set(handles.popupmenu_CurrentChannel,'UserData',iChan);

% set(handles.popupmenu_deconMode, 'String', {'weiner','richLucy'},...
%      'Value', find(ismember(funParams.deconMode,{'weiner','richLucy'})))

% Set-up parameters
for i =1 : numel(funParams.PerChannelParams)
    paramName = funParams.PerChannelParams{i};
    parVal = funParams.(paramName)(iChan);
    if islogical(funParams.(paramName)) || strcmp(get(handles.(['edit_' paramName]),'Style'),'checkbox')
         set(handles.(['edit_' paramName]), 'Value', parVal);
    elseif iscell(funParams.(paramName))   
        set(handles.(['edit_' paramName]), 'String', parVal{:});
    else
        set(handles.(['edit_' paramName]), 'String', parVal);
    end
end

% --- Executes during object creation, after setting all properties.
function popupmenu_CurrentChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_CurrentChannel (see GCBO) 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton_saveChannelParams.
function pushbutton_saveChannelParams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveChannelParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get settings for the current channel before switching to another
iChan = get(handles.popupmenu_CurrentChannel,'Value');

%userData=get(handles.figure1,'UserData');
funParams = get(handles.popupmenu_CurrentChannel,'UserData');

for i =1 : numel(funParams.PerChannelParams)
    paramName = funParams.PerChannelParams{i};
    if islogical(funParams.(paramName)) || strcmp(get(handles.(['edit_' paramName]),'Style'),'checkbox')
        parVal = get(handles.(['edit_' paramName]), 'Value');
        funParams.(paramName)(iChan) = parVal;
    elseif iscell(funParams.(paramName))   
        parVal = get(handles.(['edit_' paramName]), 'String');
        funParams.(paramName)(iChan) = {parVal};
    else
        parVal = get(handles.(['edit_' paramName]), 'String');
        funParams.(paramName)(iChan) = str2double(parVal);
    end
end

set(handles.popupmenu_CurrentChannel,'UserData',funParams);

% --- Executes on button press in pushbutton_svmPath.
function pushbutton_svmPath_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_svmPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist(handles.edit_svmPath.String,'dir') == 7
    [fileSVM, pathSVM] = uigetfile('*.mat',...
               'Select SVM model .mat file',handles.edit_svmPath.String);
else
    [fileSVM, pathSVM] = uigetfile('*.mat',...
               'Select SVM model .mat file');    
end
handles.edit_svmPath.String = fullfile(pathSVM,fileSVM);
