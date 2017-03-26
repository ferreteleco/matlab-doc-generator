function [parsedInputs, status] = parseInputs( log, inputs, camerasSet )
%parseInputs parses the inputs provided in the GridInspector Window
%   
%%-------------------------------------------------------------------------------------------------- 
%   @desc Parses the inputs provided in the GridInspector Window. In addition, inwraps the
%   parameters of the camera and adds them to the inputs structure.
%
%%-------------------------------------------------------------------------------------------------- 
%   The inputs for this function are:
% 
%   - @iparam [graphics handle] log: handle of log console 
%   - @iparam [struct] inputs: structure with the following fields:
%       -> [int] selCamera: selected camera
%       -> [int] cameraPos: positiion of the camera. 
%               --> Landscape (0)
%               --> Portrait (1)
%       -> [float] overlap: percentage of overlap between consecutive photos {%}
%       -> [float] sidelap: percentage of overlap between strips {%}
%       -> [float] detSize: minimum object size to allow detection {cm}
%       -> [float] nPx: number of pixels needed to allow detection {px}
%   - @iparam [struct] camerasSet: structure containing all available cameras
%
%%-------------------------------------------------------------------------------------------------- 
%   The outputs for this function are:
%   
%   - @oparam [struct] parsedInputs: structure with the following fields:
%       -> [int] selCamera: selected camera
%       -> [int] cameraPos: positiion of the camera. 
%               --> Landscape (0)
%               --> Portrait (1)
%       -> [float] overlap: percentage of overlap between consecutive photos {%}
%       -> [float] sidelap: percentage of overlap between strips {%}
%       -> [float] detSize: minimum object size to allow detection {cm}
%       -> [float] nPx: number of pixels needed to allow detection {px}
%
%   - @oparam [int] status: flag that indicates if everithing went fine (1) or not (-1)
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 13/03/2017
%   ** @version 1.1
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

status = 1;

if nargin < 3
    
        error('Not enough input arguments. Type "help parseInputs" in the command propt for more info about function usage.');
        
elseif nargin > 3
    
        error('Too many input arguments. Type "help parseInputs" in the command propt for more info about function usage.');
            
end

if inputs.selCamera == 1
    
    updateLog(log, 'A camera must be selected', 1);
    status = 0;
    
else
    
    index = inputs.selCamera - 1;
end

if inputs.nPx < 1 || isempty(inputs.nPx) || isnan(inputs.nPx)
    
    str = get(log, 'String');
    updateLog(log, str, 'Number of pixels needed for detection has to be equal or higher than 1',1);
    status = 0;
end

if inputs.detSize < 1 || isempty(inputs.detSize) || isnan(inputs.detSize)
    
    updateLog(log, 'Size of detection has to be higher than 0 cm',0);
    status = 0;
end

if status == 0 
    
    updateLog(log, '<<<<<<EVENT>>>>>> End of parse', 0);    
    errordlg('Errors found in inputs. Please check console log.', 'ERROR', 'modal');
    
    parsedInputs = inputs;
    parsedInputs.model = NaN;
    parsedInputs.focallen = NaN;
    parsedInputs.imwidth = NaN;
    parsedInputs.imheight = NaN;
    parsedInputs.sensorwidth = NaN;
    parsedInputs.sensorheight = NaN;
    
else
   
    parsedInputs = inputs;
    parsedInputs.selCamera = index;
    parsedInputs.model = camerasSet(index).model;
    parsedInputs.focallen = camerasSet(index).focallen;
    parsedInputs.imwidth = camerasSet(index).imwidth;
    parsedInputs.imheight = camerasSet(index).imheight;
    parsedInputs.sensorwidth = camerasSet(index).sensorwidth;
    parsedInputs.sensorheight = camerasSet(index).sensorheight;
    
    
end

end

