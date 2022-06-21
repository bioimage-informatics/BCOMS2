function varargout = BCOMS2(varargin)
% BCOMS2 MATLAB code for BCOMS2.fig
%      BCOMS2, by itself, creates a new BCOMS2 or raises the existing
%      singleton*.
%
%      H = BCOMS2 returns the handle to a new BCOMS2 or the handle to
%      the existing singleton*.
%
%      BCOMS2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BCOMS2.M with the given input arguments.
%
%      BCOMS2('Property','Value',...) creates a new BCOMS2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BCOMS2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BCOMS2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BCOMS2

% Last Modified by GUIDE v2.5 21-Jun-2022 14:30:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BCOMS2_OpeningFcn, ...
                   'gui_OutputFcn',  @BCOMS2_OutputFcn, ...
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


% --- Executes just before BCOMS2 is made visible.
function BCOMS2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BCOMS2 (see VARARGIN)

% Initialize
handles.flagRoiExtract = 0;
handles.flagEmbReg = 0;
handles.flagMemb = 0;
handles.collectionDiv = get(handles.checkbox1, 'Value');
% handles.membraneDir = './';
try
    handles.inputDir = get(handles.edit1, 'String');
catch
    handles.inputDir = './';
end
handles.z_select='radiobutton1';

% Choose default command line output for BCOMS2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BCOMS2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BCOMS2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Image data
% pushbutton
function pushbutton5_Callback(hObject, eventdata, handles)
% [fileName, pathName] = uigetdir('*','Select membrane image file');
% handles.membraneDir = pathName;

handles.inputDir = uigetdir('*','Select membrane image file');
handles.resultDir = regexprep(handles.inputDir, '\\\w*$q?', '');
handles.resultDir = [handles.resultDir, filesep, 'Output'];
% handles.memraneFilename = [pathName, fileName];
% if handles.memraneFilename == 0; return; end
% set(handles.edit1, 'String', num2str(handles.memraneFilename));
set(handles.edit1, 'String', num2str(handles.inputDir));
guidata(hObject, handles);


% function pushbutton5_Callback(hObject, eventdata, handles)
% [fileName, pathName] = uigetfile('*','Select membrane image file');
% handles.membraneDir = pathName;
% handles.memraneFilename = [pathName, fileName];
% if handles.memraneFilename == 0; return; end
% set(handles.edit1, 'String', num2str(handles.memraneFilename));
% guidata(hObject, handles);
% 
% function pushbutton6_Callback(hObject, eventdata, handles)
% [fileName, pathName] = uigetfile('*','Select nuclear segmentation file', handles.membraneDir);
% handles.nucleusFilename = [pathName, fileName];
% if handles.nucleusFilename == 0; return; end
% set(handles.edit2, 'String', num2str(handles.nucleusFilename));
% guidata(hObject, handles);
% 
% function pushbutton7_Callback(hObject, eventdata, handles)
% handles.resultDir = uigetdir(handles.membraneDir,'Select results directory');
% if handles.resultDir == 0; return; end
% set(handles.edit3, 'String', num2str(handles.resultDir));

% Folders
handles.zRangeDir = [handles.resultDir, filesep, 'ZRange'];
handles.membImgDir = [handles.resultDir, filesep, 'Membrane_image'];
handles.nucImgDir = [handles.resultDir, filesep, 'Nuclear_image'];
handles.embRegDir = [handles.resultDir, filesep, 'Embryonic_region'];
handles.membSegDir = [handles.resultDir, filesep, 'Membrane_segmentation'];
handles.nucSegDir = [handles.resultDir, filesep, 'Nuclear_segmentation'];
handles.embRegStackDir = [handles.resultDir, filesep, 'Embryonic_region', filesep, 'Stack'];
handles.membSegStackDir = [handles.membSegDir, filesep, 'MatFile'];
handles.morphFeatDir = [handles.resultDir, filesep, 'Morphological_features'];

guidata(hObject, handles);


function pushbutton1_Callback(hObject, eventdata, handles)

% edit
function edit1_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

handles.memraneFilename = get(hObject,'String');
guidata(hObject, handles);

function edit1_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% function edit2_Callback(hObject, eventdata, handles)
% handles.nucleusFilename = get(hObject,'String');
% guidata(hObject, handles);
% 
% function edit2_CreateFcn(hObject, eventdata, handles)
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% function edit3_Callback(hObject, eventdata, handles)
% handles.resultDir = get(hObject,'String');
% guidata(hObject, handles);
% 
% function edit3_CreateFcn(hObject, eventdata, handles)
% 
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


%% Image information

function pushbutton2_Callback(hObject, eventdata, handles)

function edit4_Callback(hObject, eventdata, handles)
handles.resXY = str2double(get(hObject,'String'));
guidata(hObject, handles);

function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit5_Callback(hObject, eventdata, handles)
handles.resZ = str2double(get(hObject,'String'));
guidata(hObject, handles);

function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_Callback(hObject, eventdata, handles)
handles.numZ = str2double(get(hObject,'String'));
guidata(hObject, handles);

function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_Callback(hObject, eventdata, handles)
handles.numT = str2double(get(hObject,'String'));
guidata(hObject, handles);

function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Image read & ROI extraction
function pushbutton8_Callback(hObject, eventdata, handles)

if ~isfield(handles, 'resXY') || ~isfield(handles, 'resZ') || ~isfield(handles, 'numZ') || ~isfield(handles, 'numT')
    ed = errordlg('Please set the Image information in advance','Error');
    set(ed, 'WindowStyle', 'modal');
    uiwait(ed);
    return
end

% inputDirのファイル名取得
filenames = dir(handles.inputDir);
filenames = {filenames.name};

% Membrane image
h = waitbar(0.1, 'Reading Membrane\_image file');
pos = contains(filenames, 'Membrane_image','IgnoreCase',true);
try
    filename = filenames{pos};
catch
    delete(h)
    ed = errordlg('Could not find Membrane\_image file','Error');
    set(ed, 'WindowStyle', 'modal');
end
try
    tifRead([handles.inputDir, filesep, filename], handles.numZ, handles.numT, handles.membImgDir)
catch
    delete(h)
    ed = errordlg('Could not read Membrane\_image file','Error');
    set(ed, 'WindowStyle', 'modal');
end
% delete(h)

% Nucleus image
waitbar(0.4, h, 'Reading Nucleus\_image file');
pos = contains(filenames, 'Nucleus_image','IgnoreCase',true);
try
    filename = filenames{pos};
catch
    delete(h)
    ed = errordlg('Could not find Nucleus\_image file','Error');
    set(ed, 'WindowStyle', 'modal');
end
try
    tifRead([handles.inputDir, filesep, filename], handles.numZ, handles.numT, handles.nucImgDir)
catch
    delete(h)
    ed = errordlg('Could not read Membrane\_image file','Error');
    set(ed, 'WindowStyle', 'modal');
end
waitbar(0.75, h);
% delete(h)

% Nucleus segmentation
if handles.collectionDiv
    waitbar(0.8, h, 'Reading Nucleus\_segmentation file');
    pos = contains(filenames, 'Nucleus_segmentation','IgnoreCase',true);
    try
        filename = filenames{pos};
    catch
        delete(h)
        ed = errordlg('Could not find Nucleus\_segmentation file','Error');
        set(ed, 'WindowStyle', 'modal');
    end
    try
        tifRead([handles.inputDir, filesep, filename], handles.numZ, handles.numT, handles.nucImgDir)
    catch
        delete(h)
        ed = errordlg('Could not read Nucleus\_segmentation file','Error');
        set(ed, 'WindowStyle', 'modal');
    end
    waitbar(0.95, h);
    delete(h)
end

% SVM model
if handles.collectionDiv
    h = waitbar(0.97, 'Reading Trained\_model file');
    pos = contains(filenames, 'Trained_model','IgnoreCase',true);
    try
        filename = filenames{pos};
    catch
        delete(h)
        ed = errordlg('Could not find Trained\_model file','Error');
        set(ed, 'WindowStyle', 'modal');
    end
    handles.svmModelDir = [handles.inputDir, filesep, filename];
    waitbar(0.99, h);
    delete(h)
end

handles.flagRoiExtract = 1;
guidata(hObject, handles);
delete(h);
h = msgbox('Finished reading');


%% Z range determination
function edit10_Callback(hObject, eventdata, handles)
val = get(hObject,'String');
val = strsplit(val, '-');
val = arrayfun(@str2double, val);
handles.zrange = sort(val);
set(handles.uibuttongroup1, 'SelectedObject', handles.radiobutton2)
guidata(hObject, handles);

function pushbutton9_Callback(hObject, eventdata, handles)
mkdir(handles.zRangeDir)
switch handles.z_select
    case 'radiobutton1'
        try
            h = waitbar(0.1, 'Computing Z range');
            z_range = zRange(handles.membImgDir, handles.zRangeDir);
            delete(h)
            msgbox(['Z range determination completed. Z range is ', num2str(z_range(1)), '-', num2str(z_range(2))]);
        catch
            ed = errordlg('Could not automatically determine. Please manually designate.','Error');
            set(ed, 'WindowStyle', 'modal');
            uiwait(ed);
        end
    case 'radiobutton2'
        parsaveData([handles.zRangeDir, filesep, 'zRange.mat'], handles.zrange);
        msgbox('Z range determination completed');
end
guidata(hObject, handles);

function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
handles.z_select=get(eventdata.NewValue, 'Tag');
guidata(hObject, handles);

function uibuttongroup1_CreateFcn(hObject, eventdata, handles)

function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Embryonic region segmentation

function pushbutton3_Callback(hObject, eventdata, handles)
if handles.flagRoiExtract == 0
    ed = errordlg('Run the ROI extraction in advance','Error');
    set(ed, 'WindowStyle', 'modal');
    uiwait(ed);
    return
end

h = waitbar(0.1, ['Computing embryonic region with the volume ratio: ', num2str(handles.volRatioThresh)]);
ME = 0;
try
    h = embryonicRegion(handles.membImgDir, handles.nucSegDir, handles.zRangeDir, handles.embRegDir, handles.volRatioThresh, h);
catch ME
    delete(h);
    h = errordlg([ME.identifier, newline, ME.message]);
    rethrow(ME)
end
delete(h);
if ME==0
    h = msgbox('Embryonic region segmentation completed');
end

handles.flagEmbReg = 1;
guidata(hObject, handles);

function edit8_Callback(hObject, eventdata, handles)
handles.volRatioThresh = str2double(get(hObject,'String'));
guidata(hObject, handles);

function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.volRatioThresh = str2double(get(hObject,'String'));
guidata(hObject, handles);

%% Membrane segmentation
function pushbutton4_Callback(hObject, eventdata, handles)
if handles.flagRoiExtract == 0
    ed = errordlg('Run the ROI extraction in advance','Error');
    set(ed, 'WindowStyle', 'modal');
    uiwait(ed);
    return
end
if ~exist([handles.embRegStackDir, filesep, 'embrayonicRegion.mat'], 'file')
    ed = errordlg('Run the Embryonic region segmentation in advance','Error');
    set(ed, 'WindowStyle', 'modal');
    uiwait(ed);
    return
end

h = waitbar(0.1, 'Computing membrane segmentation');
ME = 0;
try
    if handles.collectionDiv
        h = waterMembrane( handles.membImgDir, handles.nucSegDir, handles.embRegStackDir, ...
            handles.membSegDir, handles.resXY, handles.resZ, h,  handles.nucImgDir, handles.svmModelDir);
    else
        h = waterMembrane( handles.membImgDir, handles.nucSegDir, handles.embRegStackDir, ...
            handles.membSegDir, handles.resXY, handles.resZ, h );
    end
%     simpleWater( handles.membImgDir, handles.nucSegDir, handles.embRegStackDir, handles.membSegDir, handles.resXY, handles.resZ );
catch ME
    delete(h);
    h = errordlg([ME.identifier, newline, ME.message]);
    rethrow(ME)
end
delete(h);
if ME==0
    h = msgbox('Membrane segmentation completed');
end


%% Morphological features
function pushbutton10_Callback(hObject, eventdata, handles)

if ~exist([handles.membSegStackDir, filesep, 'cell.mat'], 'file')
    ed = errordlg('Run the Membrane segmentation in advance','Error');
    set(ed, 'WindowStyle', 'modal');
    uiwait(ed);
    return
end

h = waitbar(0.1, 'Extracting morphological features');
ME = 0;
try
    h = morphologicalFeatures( handles.membSegStackDir, handles.morphFeatDir, handles.resXY, handles.resZ, h );
catch ME
    delete(h);
    h = errordlg([ME.identifier, newline, ME.message]);
    rethrow(ME)
end
delete(h);
if ME==0
    h = msgbox('Morphological features extraction completed');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)

handles.collectionDiv = get(hObject,'Value');
guidata(hObject, handles);
