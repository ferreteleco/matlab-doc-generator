function [ photoParams ] = getFlightPhotoParams( camera, cameraPos, detSize, nPx, overlap, sidelap)
%getFlightPhotoParams computes required parameters for planning a flight that makes use of a
%camera as payload.
%   
%%--------------------------------------------------------------------------------------------------
%   @desc Taking into acount the parameters of the camera to be used and other user-defined ones,  
%   this function obtains some vital parameters needed to perform other route planning
%   tasks.
%    
%   All its imputs are needed, taking into account that the first two are structures, and
%   its fields must be the same as defined here.
%    
%%--------------------------------------------------------------------------------------------------
%   The inputs of this function are:
%   
%   - @iparam [struct] camera: it is a struct with the following parameters:
%       -> [String] model: string containing camera name               
%       -> [float] focallen: focal length of the camera {mm}
%       -> [int] imwidth: width of the image {px}
%       -> [int] imheight: height of the image {px}
%       -> [float] sensorwidth: physical width of the sensor {mm}
%       -> [float] sensorheight: physical height of the sensor {mm}
%
%   - @iparam [int] cameraPos: defines the orientation of the camera on board the airborne
%   patform:
%       -> Landscape: 1    
%       -> Portrait:  2
%
%   - @iparam [float] detSize: minimum object size to allow detection {cm}
%   - @iparam [float] nPx: number of pixels needed to allow detection {px}
%   - @iparam [float] overlap: percentage of overlap between consecutive photos {%}
%   - @iparam [float] sidelap: percentage of overlap between strips {%}
%   
%%--------------------------------------------------------------------------------------------------
%   The output of this function is:

%   - @oparam [struct] photoParams: it is a struct that contains the following:
%         -> [float] cmpixel: centimeters per pixels ratio to be achieved {cm/px}
%         -> [float] flyAlt: flight altitude in meters {m}
%         -> [float] B: distance between photographs in meters {m}
%         -> [float] A: separation between lines in meters {m}
%         -> [float] mHeight: image height at ground in meters {m}
%         -> [float] mWidth: image height at ground in meters {m}
%         -> [float] fovhdeg: height of the field of view in degrees {deg}
%         -> [float] fovwdeg: width of the field of view in degrees {deg}
%   
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 22/02/2017
%   ** @version 1.2
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------


if nargin < 6
    
        error('Not enough input arguments. Type "help getFlightPhotoParams" in the command prompt for more info about function usage.');
        
elseif nargin > 6
    
            error('Too many input arguments. Type "help getFlightPhotoParams" in the command prompt for more info about function usage.');

end

% Output struct definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
photoParams = struct('cmpixel', 0, 'flyAlt', 0, 'B', 0, 'A', 0, 'mHeight', 0, 'mWidth', 0, 'fovhdeg', 0,...
    'fovwdeg', 0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% BEGIN COMPUTATIONS

photoParams.cmpixel = detSize/nPx;                              % Cm per pixel in order to achieve target detection

% Determine flight altitude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
photoParams.mHeight = round(photoParams.cmpixel*camera.imheight/100,1);      % Image height at ground [m]
photoParams.mWidth = round(photoParams.cmpixel*camera.imwidth/100,1);        % Image width at ground [m]
flscale = photoParams.mHeight*1000/camera.sensorheight;                      % Flight scale denominator [mm / mm]
photoParams.flyAlt = round(flscale*camera.focallen/1000,2);                  % Flight altitude [m]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Determine spacing B (Distance between photographs) and distance A (Separation between lines)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if cameraPos == 1     

    photoParams.B = round( ( 1 - ( overlap/100 ) )*photoParams.mHeight, 1 );               % Distance between photographs [m]
    photoParams.A = round( ( 1 - ( sidelap/100 ) )*photoParams.mWidth, 1 );                % Separation between lines [m]
    
    photoParams.fovwdeg = 2*atan2d(camera.sensorwidth,(2 * camera.focallen));
    photoParams.fovhdeg = 2*atan2d(camera.sensorheight, (2 * camera.focallen));
else
    
    photoParams.B = round( ( 1 - ( overlap/100 ) )*photoParams.mWidth, 1 );                % Distance between photographs [m]
    photoParams.A = round( ( 1 - ( sidelap/100 ) )*photoParams.mHeight, 1 );               % Separation between lines [m]
    
    photoParams.fovwdeg = 2*atan2d(camera.sensorheight,(2 * camera.focallen));
    photoParams.fovhdeg = 2*atan2d(camera.sensorwidth, (2 * camera.focallen));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

