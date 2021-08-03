function varargout = IntensityMotifCompare3DProcessGUI(varargin)
% IntensityMotifCompare3DProcessgui M-file for IntensityMotifCompare3DProcessgui.fig
%      IntensityMotifCompare3DProcessgui, by itself, creates a new IntensityMotifCompare3DProcessgui or raises the existing
%      singleton*.
%
%      H = IntensityMotifCompare3DProcessgui returns the handle to a new IntensityMotifCompare3DProcessgui or the handle to
%      the existing singleton*.
%
%      IntensityMotifCompare3DProcessgui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IntensityMotifCompare3DProcessgui.M with the given input arguments.
%
%      IntensityMotifCompare3DProcessgui('Property','Value',...) creates a new IntensityMotifCompare3DProcessgui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IntensityMotifCompare3DProcessgui_openingfcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IntensityMotifCompare3DProcessgui_openingfcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%

% Edit the above text to modify the response to help IntensityMotifCompare3DProcessgui

% Last Modified by GUIDE v2.5 28-Jan-2019 16:37:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IntensityMotifCompare3DProcessGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @IntensityMotifCompare3DProcessGUI_OutputFcn, ...
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

% --- Executes just before IntensityMotifCompare3DProcessgui is made visible.
function IntensityMotifCompare3DProcessGUI_OpeningFcn(hObject, eventdata, handles, varargin)

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


paramNames = fieldnames(funParams);
for i = 1:numel(paramNames)
    paramName = paramNames{i};
    parVal = funParams.(paramName);
    if any(ismember(fieldnames(handles), ['edit_' paramName])) 
        if islogical(funParams.(paramName)) || strcmp(get(handles.(['edit_' paramName]),'Style'),'checkbox')
            set(handles.(['edit_' paramName]), 'Value', parVal);
%             parVal = get(handles.(['edit_' paramName]), 'Value');
%             funParams.(paramName)(iChan) = parVal;
        elseif iscell(funParams.(paramName))   
            set(handles.(['edit_' paramName]), 'String', parVal{:});
%             parVal = get(handles.(['edit_' paramName]), 'String');
%             funParams.(paramName)(iChan) = parVal;
        else
            set(handles.(['edit_' paramName]), 'String', parVal);
%             parVal = get(handles.(['edit_' paramName]), 'String');
%             funParams.(paramName)(iChan) = str2double(parVal);
        end
    end
end


%Update channel parameter selection dropdown
% popupmenu_CurrentChannel_Callback(hObject, eventdata, handles);
% Update GUI user data
set(handles.figure1, 'UserData', userData);
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = IntensityMotifCompare3DProcessGUI_OutputFcn(~, ~, handles) 
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

userData = get(handles.figure1,'UserData');
funParams = userData.crtProc.funParams_;

% Retrieve detection parameters
% funParams = get(handles.popupmenu_CurrentChannel,'UserData');
% Retrieve GUI-defined non-channel specific parameters

paramNames = fieldnames(funParams);
for i = 1:numel(paramNames)
    paramName = paramNames{i};
%     parVal = funParams.(paramName);
    if any(ismember(fieldnames(handles), ['edit_' paramName])) 
        if islogical(funParams.(paramName)) || strcmp(get(handles.(['edit_' paramName]),'Style'),'checkbox')
%             set(handles.(['edit_' paramName]), 'Value', parVal);
            parVal = get(handles.(['edit_' paramName]), 'Value');
            funParams.(paramName) = parVal;
        elseif iscell(funParams.(paramName))   
%             set(handles.(['edit_' paramName]), 'String', parVal{:});
            parVal = get(handles.(['edit_' paramName]), 'String');
            funParams.(paramName) = parVal;
        else
%             set(handles.(['edit_' paramName]), 'String', parVal);
            parVal = get(handles.(['edit_' paramName]), 'String');
            funParams.(paramName) = str2double(parVal);
        end
    end
end

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
% --- Executes on button press in edit_numDiffusionIterations.
function edit_numDiffusionIterations_Callback(hObject, eventdata, handles)
% hObject    handle to edit_numDiffusionIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edit_numDiffusionIterations


% --- Executes on button press in edit_analyzeOnlyFirst.
function edit_analyzeOnlyFirst_Callback(hObject, eventdata, handles)
% hObject    handle to edit_analyzeOnlyFirst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edit_analyzeOnlyFirst


% --- Executes on button press in edit_calculateVonMises.
function edit_calculateVonMises_Callback(hObject, eventdata, handles)
% hObject    handle to edit_calculateVonMises (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edit_calculateVonMises


% --- Executes on button press in edit_calculateProtrusionDiffusion.
function edit_calculateProtrusionDiffusion_Callback(hObject, eventdata, handles)
% hObject    handle to edit_calculateProtrusionDiffusion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edit_calculateProtrusionDiffusion


% --- Executes on button press in edit_analyzeOtherChannel.
function edit_analyzeOtherChannel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_analyzeOtherChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edit_analyzeOtherChannel


% --- Executes on button press in edit_analyzeForwardsMotion.
function edit_analyzeForwardsMotion_Callback(hObject, eventdata, handles)
% hObject    handle to edit_analyzeForwardsMotion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edit_analyzeForwardsMotion


% --- Executes on button press in edit_calculateDistanceTransformProtrusions.
function edit_calculateDistanceTransformProtrusions_Callback(hObject, eventdata, handles)
% hObject    handle to edit_calculateDistanceTransformProtrusions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edit_calculateDistanceTransformProtrusions
