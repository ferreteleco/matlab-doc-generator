function varargout = gridInspector(varargin)
% gridInspector MATLAB code for gridInspector.fig
%
%%--------------------------------------------------------------------------------------------------
%      @desc gridInspector, by itself, creates a new gridInspector or raises the existing
%      singleton*.
%
%      H = GRIDINSPECTOR returns the handle to a new GRIDINSPECTOR or the handle to
%      the existing singleton*.
%
%      GRIDINSPECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GRIDINSPECTOR.M with the given input arguments.
%
%      GRIDINSPECTOR('Property','Value',...) creates a new GRIDINSPECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gridInspector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gridInspector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%%--------------------------------------------------------------------------------------------------
%   The inputs for this function are:
%
%   - @iparam [var] varargin: variable number of input arguments. Not Used.
%
%%--------------------------------------------------------------------------------------------------
%   The outputs of this function are:
%
%   - @oparam [var] varargout: variable number of output arguments. Not Used.
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 13/03/2017
%   ** @version 2.5
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gridInspector_OpeningFcn, ...
                   'gui_OutputFcn',  @gridInspector_OutputFcn, ...
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


% --- Executes just before gridInspector is made visible.
function gridInspector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gridInspector (see VARARGIN)

% Choose default command line output for mainWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainWindow wait for user response (see UIRESUME)
% uiwait(handles.main);

screensize = get(0,'ScreenSize');

sz(1) = ceil(screensize(3)*2/3);
sz(2) = ceil(screensize(4)*4/5);

xpos = ceil((screensize(3)-sz(1))/2); % center the figure on the screen horizontally
ypos = ceil((screensize(4)-sz(2))/2); % center the figure on the screen vertically

set(gcf, 'Units', 'Pixels', 'Position', [xpos ypos sz(1) sz(2)])

% Cargamos logo proyecto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes(handles.logo)  
cla(handles.logo)
hold(handles.logo,'on')

[A, map, alpha] = imread('./Icons/logo_POLARYS.png');
h = imshow(A, map);

set(h, 'AlphaData', alpha);
hold(handles.logo,'off')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 axes(handles.pltRes);
 box off
 grid off
 axis off

 [cameras, status] = importCameras(handles.logRes, './Archives/');

if status ~= 1 
    
    updateLog(handles.logRes, '------FATAL ERROR------: Error happened while trying to load cameras to window');
    errordlg('Unexpected error while trying to load cameras', 'ERROR', 'modal');
    
else
   
    str = '';
    for ll = 1 : numel(cameras)
        
        str = sprintf('%s\n%s', str, cameras(ll).model);
    end
    set(handles.selCamera,'String', deblank(str))
end

handles.results = struct([]);
handles.polygon = [];
handles.statusPoly = -1;
handles.cameras = cameras;
guidata(hObject, handles);
 

% --- Outputs from this function are returned to the command line.
function varargout = gridInspector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function logRes_Callback(hObject, eventdata, handles)
% hObject    handle to logRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of logRes as text
%        str2double(get(hObject,'String')) returns contents of logRes as a double


% --- Executes during object creation, after setting all properties.
function logRes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to logRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadPoly.
function loadPoly_Callback(hObject, eventdata, handles)
% hObject    handle to loadPoly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.busyFlag,'String','Busy...');
pause(0.0005) 
updateLog(handles.logRes, '------EVENT------ Load Polygon ongoing', 0);
[FileName,PathName] = uigetfile({'*.poly','Mission Planner Polygon Files';'*.KML', ...
    'Keyhole Markup Language (KML) Files';'*', 'All files'},'Select the polygon file');

if ~isequal(FileName,0) && ~isequal(PathName,0)
    
    set(handles.selectedPolygonLabel,'String',strcat(PathName,FileName));    
    updateLog(handles.logRes, sprintf('Selected file: ''%s''', strcat(PathName,FileName)), 0);
    [ polygon, statusPoly ] = importPolygon( handles.logRes, strcat(PathName,FileName) );

    if statusPoly ~= 1
    
        errordlg('Something happened while tying to load polygon file. Please check console log','ERROR');
        set(handles.selectedPolygonLabel,'String','');  
        updateLog(handles.logRes, '------FATAL ERROR------ Polygon not loaded, see console log for more information', 0);
    else
       
        updateLog(handles.logRes, '------EVENT------ Polygon load finished', 0);
    end
    
    handles.statusPoly = statusPoly;
    handles.polygon = polygon;
    
    % Update handles structure
    guidata(hObject, handles);

else
   
    set(handles.selectedPolygonLabel,'String','');    
    handles.statusPoly = -1;
    handles.polygon = [];
    % Update handles structure
    guidata(hObject, handles);
    
end
set(handles.busyFlag,'String','');

% --- Executes on selection change in selCamera.
function selCamera_Callback(hObject, eventdata, handles)
% hObject    handle to selCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selCamera contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selCamera

val = get(handles.selCamera, 'Value');

if val ~= 1
   
    val = val - 1;
    updateLog(handles.logRes, sprintf('------EVENT------ Selected camera (%s) parameters:', handles.cameras(val).model), 0);
    updateLog(handles.logRes, sprintf('Focal Length: %2.2f [mm]', handles.cameras(val).focallen), 1);
    updateLog(handles.logRes, sprintf('Image width: %i [px]', handles.cameras(val).imwidth), 1);
    updateLog(handles.logRes, sprintf('Image height: %i [px]', handles.cameras(val).imheight), 1);    
    updateLog(handles.logRes, sprintf('Sensor width: %2.2f [mm]', handles.cameras(val).sensorwidth), 1);
    updateLog(handles.logRes, sprintf('Sensor height: %2.2f [px]', handles.cameras(val).sensorheight), 0);    

end


% --- Executes during object creation, after setting all properties.
function selCamera_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cameraPos.
function cameraPos_Callback(hObject, eventdata, handles)
% hObject    handle to cameraPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cameraPos contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cameraPos


% --- Executes during object creation, after setting all properties.
function cameraPos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function overlap_Callback(hObject, eventdata, handles)
% hObject    handle to overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overlap as text
%        str2double(get(hObject,'String')) returns contents of overlap as a double
percent = round(get(handles.overlap,'Value'));
set(handles.overlapLabel, 'String', sprintf('(%i%%)', percent))

% --- Executes during object creation, after setting all properties.
function overlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sidelap_Callback(hObject, eventdata, handles)
% hObject    handle to sidelap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sidelap as text
%        str2double(get(hObject,'String')) returns contents of sidelap as a double
percent = round(get(handles.sidelap,'Value'));
set(handles.sidelapLabel, 'String', sprintf('(%i%%)', percent))


% --- Executes during object creation, after setting all properties.
function sidelap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sidelap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function detSize_Callback(hObject, eventdata, handles)
% hObject    handle to detSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of detSize as text
%        str2double(get(hObject,'String')) returns contents of detSize as a double


% --- Executes during object creation, after setting all properties.
function detSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPx_Callback(hObject, eventdata, handles)
% hObject    handle to nPx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of nPx as text
%        str2double(get(hObject,'String')) returns contents of nPx as a double


% --- Executes during object creation, after setting all properties.
function nPx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in compute.
function compute_Callback(hObject, eventdata, handles)
% hObject    handle to compute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.busyFlag,'String','Busy...');
pause(0.0005) 

inputs = struct('selCamera', get(handles.selCamera,'Value'), 'cameraPos', ...
    get(handles.cameraPos,'Value'), 'overlap', round(get(handles.overlap,'Value')), ...
    'sidelap', round(get(handles.sidelap,'Value')), 'detSize', str2double(get(handles.detSize,'String')), ...
    'nPx', str2double(get(handles.nPx,'String')), 'startPos', get(handles.startPos,'Value'));

if handles.statusPoly ~= 1
  
    errordlg('Please, import a valid polygon file before updating grid','ERROR', 'modal');
    updateLog(handles.logRes, '------FATAL ERROR------ Polygon not loaded, check console log for more info', 0);

else
    
    updateLog(handles.logRes, '------EVENT------ Starting grid computing',0);
    
    display.plot = handles.pltRes;
    display.pol = handles.plotPolygon;
    display.bbox = handles.plotBBox;
    display.grid = handles.plotGrid;
    display.obox = handles.plotOuterBox;
    display.ogrid = handles.plotOGrid;
    display.start = handles.plotStart;
    
    [ results ] = onComputeClick( handles.logRes, display, inputs, handles.polygon, handles.cameras );
    handles.results = results;
    % Update handles structure
    guidata(hObject, handles);    
end

if ~isempty(handles.results)
    
    updateLog(handles.logRes, '------EVENT------ Grid Computation process finished',0);
else
    updateLog(handles.logRes, '------FATAL ERROR------ Grid not computed, check console log for more info', 0); 
end
set(handles.busyFlag,'String','');
pause(0.0005) 


% --- Executes on button press in resetAll.
function resetAll_Callback(hObject, eventdata, handles)
% hObject    handle to resetAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[status, handles] = resetAll(handles);

% Update handles structure
guidata(hObject, handles);

if status ~=1
    
   updateLog(handles.logRes, '------FATAL ERROR------ Unexpected error during reset. Try again later.');
end
    


% --- Executes on button press in exportGrid.
function exportGrid_Callback(hObject, eventdata, handles)
% hObject    handle to exportGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.busyFlag,'String','Busy');
pause(0.0005) 

[FileName, PathName] = uiputfile('*.kml', 'Save As...');


if ~isequal(FileName,0) && ~isequal(PathName,0) && ~isempty(handles.results)
    
    exportKML( handles.logRes, PathName, FileName, handles.results,1 );
end

set(handles.busyFlag,'String','');
pause(0.0005) 


% --- Executes on button press in plotPolygon.
function plotPolygon_Callback(hObject, eventdata, handles)
% hObject    handle to plotPolygon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotPolygon

stat = get(handles.plotPolygon,'Value');

switch(stat)
    
    case 0
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hPoly.Visible,'on')
                
                handles.results.handGraphics.hPoly.Visible = 'off';
            end
        end
        
    case 1
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hPoly.Visible,'off')
                
                handles.results.handGraphics.hPoly.Visible = 'on';
            end
        end        
end

if ~isempty(handles.results)
    
    hold(handles.pltRes,'on')

    if strcmp(handles.results.handGraphics.hOutBox(1).Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGridBox.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hStart.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGrid.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hPoly.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hBBox.Visible,'off')

            axis off
            box off
            grid off        
            legend HIDE
            set(handles.leg,'State', 'off');
    else

         axis on   
         handles.pltRes.XMinorGrid = 'on';
         handles.pltRes.YMinorGrid = 'on';
    end

    hold(handles.pltRes,'off')

    % Update handles structure
    guidata(hObject, handles);
end

% --- Executes on button press in plotGrid.
function plotGrid_Callback(hObject, eventdata, handles)
% hObject    handle to plotGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotGrid

stat = get(handles.plotGrid,'Value');

switch(stat)
    
    case 0
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hGrid.Visible,'on')
                
                handles.results.handGraphics.hGrid.Visible = 'off';
            end
        end
        
    case 1
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hGrid.Visible,'off')
                
                handles.results.handGraphics.hGrid.Visible = 'on';
            end
        end        
end


if ~isempty(handles.results)
    
    hold(handles.pltRes,'on')

    if strcmp(handles.results.handGraphics.hOutBox(1).Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGridBox.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hStart.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGrid.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hPoly.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hBBox.Visible,'off')

            axis off
            box off
            grid off        
            legend HIDE
            set(handles.leg,'State', 'off');
    else

         axis on   
         handles.pltRes.XMinorGrid = 'on';
         handles.pltRes.YMinorGrid = 'on';
    end

    hold(handles.pltRes,'off')

    % Update handles structure
    guidata(hObject, handles);
end

% --- Executes on button press in plotStart.
function plotStart_Callback(hObject, eventdata, handles)
% hObject    handle to plotStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotStart

stat = get(handles.plotStart,'Value');

switch(stat)
    
    case 0
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hStart.Visible,'on')
                
                handles.results.handGraphics.hStart.Visible = 'off';
            end
        end
        
    case 1
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hStart.Visible,'off')
                
                handles.results.handGraphics.hStart.Visible = 'on';
            end
        end        
end


if ~isempty(handles.results)
    
    hold(handles.pltRes,'on')

    if strcmp(handles.results.handGraphics.hOutBox(1).Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGridBox.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hStart.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGrid.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hPoly.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hBBox.Visible,'off')

            axis off
            box off
            grid off        
            legend HIDE
            set(handles.leg,'State', 'off');
    else

         axis on   
         handles.pltRes.XMinorGrid = 'on';
         handles.pltRes.YMinorGrid = 'on';
    end

    hold(handles.pltRes,'off')

    % Update handles structure
    guidata(hObject, handles);
end


% --- Executes on button press in plotOuterBox.
function plotOuterBox_Callback(hObject, eventdata, handles)
% hObject    handle to plotOuterBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotOuterBox

stat = get(handles.plotOuterBox,'Value');

switch(stat)
    
    case 0
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hOutBox(1).Visible,'on')
                
                
                for ll = 1 : length(handles.results.handGraphics.hOutBox)
                    
                    handles.results.handGraphics.hOutBox(ll).Visible = 'off';
                end
            end
        end
        
    case 1
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hOutBox(1).Visible,'off')
                
                for ll = 1 : length(handles.results.handGraphics.hOutBox)
                    
                    handles.results.handGraphics.hOutBox(ll).Visible = 'on';
                end
            end
        end        
end

if ~isempty(handles.results)

    hold(handles.pltRes,'on')

    if strcmp(handles.results.handGraphics.hOutBox(1).Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGridBox.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hStart.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGrid.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hPoly.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hBBox.Visible,'off')

            axis off
            box off
            grid off        
            legend HIDE
            set(handles.leg,'State', 'off');

    else

         axis on   
         handles.pltRes.XMinorGrid = 'on';
         handles.pltRes.YMinorGrid = 'on';
    end

    hold(handles.pltRes,'off')


    % Update handles structure
    guidata(hObject, handles);
end


% --- Executes on selection change in startPos.
function startPos_Callback(hObject, eventdata, handles)
% hObject    handle to startPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns startPos contents as cell array
%        contents{get(hObject,'Value')} returns selected item from startPos


% --- Executes during object creation, after setting all properties.
function startPos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startPos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotOGrid.
function plotOGrid_Callback(hObject, eventdata, handles)
% hObject    handle to plotOGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotOGrid

stat = get(handles.plotOGrid,'Value');

switch(stat)
    
    case 0
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hGridBox.Visible,'on')
                
                handles.results.handGraphics.hGridBox.Visible = 'off';
            end
        end
        
    case 1
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hGridBox.Visible,'off')
                
                handles.results.handGraphics.hGridBox.Visible = 'on';
            end
        end        
end


if ~isempty(handles.results)
    
    hold(handles.pltRes,'on')

    if strcmp(handles.results.handGraphics.hOutBox(1).Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGridBox.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hStart.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGrid.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hPoly.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hBBox.Visible,'off')

            axis off
            box off
            grid off        
            legend HIDE
    else

         axis on   
         handles.pltRes.XMinorGrid = 'on';
         handles.pltRes.YMinorGrid = 'on';
         set(handles.leg,'State', 'off');
    end

    hold(handles.pltRes,'off')


    % Update handles structure
    guidata(hObject, handles);
    
end



% --------------------------------------------------------------------
function leg_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to leg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stat = get(handles.leg,'State');

switch(stat)
    
    case 'off'
    
        hold(handles.pltRes,'on')
        legend HIDE
        hold(handles.pltRes,'off')
        
    case 'on'
        
        hold(handles.pltRes,'on')
        legend SHOW
        hold(handles.pltRes,'off')
        
end


% --- Executes on button press in resLog.
function resLog_Callback(hObject, eventdata, handles)
% hObject    handle to resLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[~, ~] = resetAll(handles, 1);


% --- Executes on button press in logDump.
function logDump_Callback(hObject, eventdata, handles)
% hObject    handle to logDump (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.busyFlag,'String','Busy...');
pause(0.0005) 

button = questdlg('Are you sure?','Dump log to .txt file');

if strcmp(button, 'Yes')
    
    dumpToFile( handles.logRes );
    
end
set(handles.busyFlag,'String','');
pause(0.0005) 



% --- Executes on button press in plotBBox.
function plotBBox_Callback(hObject, eventdata, handles)
% hObject    handle to plotBBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of plotBBox

stat = get(handles.plotBBox,'Value');

switch(stat)
    
    case 0
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hBBox.Visible,'on')
                
                handles.results.handGraphics.hBBox.Visible = 'off';
            end
        end
        
    case 1
        
        if ~isempty(handles.results)
           
            if strcmp(handles.results.handGraphics.hBBox.Visible,'off')
                
                handles.results.handGraphics.hBBox.Visible = 'on';
            end
        end        
end

if ~isempty(handles.results)
    
    hold(handles.pltRes,'on')

    if strcmp(handles.results.handGraphics.hOutBox(1).Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGridBox.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hStart.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hGrid.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hPoly.Visible,'off') && ...
            strcmp(handles.results.handGraphics.hBBox.Visible,'off')

            axis off
            box off
            grid off        
            legend HIDE
            set(handles.leg,'State', 'off');
    else

         axis on   
         handles.pltRes.XMinorGrid = 'on';
         handles.pltRes.YMinorGrid = 'on';
    end

    hold(handles.pltRes,'off')

    % Update handles structure
    guidata(hObject, handles);
end
