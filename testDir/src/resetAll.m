function [ status, handles ] = resetAll( handles, varargin )
%resetAll clears all elements in GridInspector Window.
%   
%%--------------------------------------------------------------------------------------------------
%   @desc Clears all elements in GridInspector Window.
%
%%--------------------------------------------------------------------------------------------------
%   The inputs of this function are:
%   
%   - @iparam [graphic handles] handles: handles of the window. 
%   - @iparam [int] flag: flag indicating (1) to reset only the log console
%
%%--------------------------------------------------------------------------------------------------
%   The outputs of this function are:
%   
%   - @oparam [int] status: flag that indicates if everithing went fine (1) or not (0)
%   - @oparam [graphics handles] handles: updated handles of the window
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 13/03/2017
%   ** @version 1.4
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

if nargin < 1
    
        error('Not enough input arguments. Type "help resetAll" in the command prompt for more info about function usage.');
        
elseif nargin > 2
    
        error('Too many input arguments. Type "help resetAll" in the command prompt for more info about function usage.');
            
elseif nargin == 1
    
    flag = 0;
else
    
    flag = varargin{1};

end

try
    
    if flag ~= 1
        
        set(handles.selCamera,'Value',1);
        set(handles.cameraPos,'Value',1);
        set(handles.overlap,'Value', 25);
        set(handles.sidelap,'Value', 25);
        set(handles.overlapLabel,'String', '(25%)');
        set(handles.sidelapLabel,'String', '(25%)');
        set(handles.detSize,'String', '');
        set(handles.selectedPolygonLabel,'String', '');
        set(handles.nPx,'String', '');
        set(handles.busyFlag,'String', '');
        set(handles.startPos,'Value', 1);

        set(handles.plotPolygon,'Value',0);
        set(handles.plotBBox,'Value',0);
        set(handles.plotGrid,'Value',0);
        set(handles.plotOuterBox,'Value',0);
        set(handles.plotOGrid,'Value',0);
        set(handles.plotStart,'Value',0);



        handles.statusPoly = -1;
        handles.polygon = [];
        handles.results = struct([]);



        hold(handles.pltRes,'on')
        cla(handles.pltRes) %resets properties for the specified axes.
        axis off
        box off
        grid off
        hold(handles.pltRes,'off')
        
    end
    
    set(handles.logRes,'String', '');
    status = 1;


catch

    status = 0;

end
end

