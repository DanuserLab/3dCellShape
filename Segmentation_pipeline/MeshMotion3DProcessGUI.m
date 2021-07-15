function varargout = MeshMotion3DProcessGUI(varargin)
% meshmotion3dprocessgui M-file for meshmotion3dprocessgui.fig
%      meshmotion3dprocessgui, by itself, creates a new meshmotion3dprocessgui or raises the existing
%      singleton*.
%
%      H = meshmotion3dprocessgui returns the handle to a new meshmotion3dprocessgui or the handle to
%      the existing singleton*.
%
%      meshmotion3dprocessgui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in meshmotion3dprocessgui.M with the given input arguments.
%
%      meshmotion3dprocessgui('Property','Value',...) creates a new meshmotion3dprocessgui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before meshmotion3dprocessgui_openingfcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to meshmotion3dprocessgui_openingfcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES


% Edit the above text to modify the response to help meshmotion3dprocessgui

% Last Modified by GUIDE v2.5 23-Jul-2018 15:04:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MeshMotion3DProcessGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MeshMotion3DProcessGUI_OutputFcn, ...
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

% --- Executes just before meshmotion3dprocessgui is made visible.
function MeshMotion3DProcessGUI_OpeningFcn(hObject, eventdata, handles, varargin)

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

strSet = {'backwards','forwards','backwardsForwards'};
handles.popupmenu_motionMode.String = strSet;
handles.popupmenu_motionMode.Value = find(ismember(strSet,funParams.motionMode));
handles.edit_numNearestNeighbors.String = num2str(funParams.numNearestNeighbors);
handles.edit_registerImages.Value = funParams.registerImages;

% set(handles.popupmenu_CurrentChannel,'UserData',funParams);

% handles
% handles.edit_svmPath.String = funParams.svmPath;

% iChan = get(handles.popupmenu_CurrentChannel,'Value');
% if isempty(iChan)
%     iChan = 1;
%     set(handles.popupmenu_CurrentChannel,'Value',1);
% end

%Update channel parameter selection dropdown
% popupmenu_CurrentChannel_Callback(hObject, eventdata, handles);
% Update GUI user data
set(handles.figure1, 'UserData', userData);
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = MeshMotion3DProcessGUI_OutputFcn(~, ~, handles) 
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

%Save the currently set per-channel parameters
% pushbutton_saveChannelParams_Callback(hObject, eventdata, handles)


% Retrieve detection parameters
% funParams = get(handles.popupmenu_CurrentChannel,'UserData');
% Retrieve GUI-defined non-channel specific parameters

strSet = handles.popupmenu_motionMode.String;
val = handles.popupmenu_motionMode.Value;
funParams.motionMode = strSet{val};
funParams.numNearestNeighbors = str2double(handles.edit_numNearestNeighbors.String);
funParams.registerImages = handles.edit_registerImages.Value;

%Get selected image channels
channelIndex = get(handles.listbox_selectedChannels, 'Userdata');
if isempty(channelIndex)
    errordlg('Please select at least one input channel from ''Available Channels''.','Setting Error','modal')
    return;
end
funParams.ChannelIndex = channelIndex;
funParams.channels = funParams.ChannelIndex;
processGUI_ApplyFcn(hObject, eventdata, handles,funParams);

% --- Executes on button press in popupmenu_motionMode.
function popupmenu_motionMode_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_motionMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of popupmenu_motionMode


% --- Executes on button press in edit_numNearestNeighbors.
function edit_numNearestNeighbors_Callback(hObject, eventdata, handles)
% hObject    handle to edit_numNearestNeighbors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edit_numNearestNeighbors


% --- Executes on button press in edit_registerImages.
function edit_registerImages_Callback(hObject, eventdata, handles)
% hObject    handle to edit_registerImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edit_registerImages
