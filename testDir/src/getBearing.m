function [ bearing ] = getBearing( lat0, lon0, lat1, lon1, mode )
%getBearing gets the bearing between two locations.
%   
%%--------------------------------------------------------------------------------------------------
%   @desc Computes the bearing between two locations specified by its coordinates, either
%   Geographical or UTM.
%
%   Supports the use of vectors in latitude and longitude coordinates.
%   
%%--------------------------------------------------------------------------------------------------
%   @ref http://www.movable-type.co.uk/scripts/latlong.html
%
%%--------------------------------------------------------------------------------------------------
%   The inputs for this function are:
%   
%   - @iparam [float] lat0: initial latitude or Northing {deg. or m}
%   - @iparam [float] lon0: initial longitude or Easting {deg. or m}
%   - @iparam [float] lat1: final latitude or Northing {deg. or m}
%   - @iparam [float] lon1: final longitude or Easting {deg. or m}
%   
%   - @iparam [String] mode: string that specifies the coordinates to be used in the
%   calculations. (Optional) Values:
%       -> 'Geo': Geographical coordinates, decimal deg. (default) 
%       -> 'UTM': UTM coordinates
%   
%%--------------------------------------------------------------------------------------------------
%   The output of this function is:
%   
%   - @oparam [float] bearing: bearing to destination from start position {deg}   
%   
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 20/02/2017
%   ** @version 1.3
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

if nargin < 4
    
        error('Not enough input arguments. Type "help getBearing" in the command prompt for more info about function usage.');
        
elseif nargin > 5
    
            error('Too many input arguments. Type "help getBearing" in the command prompt for more info about function usage.');
            
elseif nargin == 4
    
    mode = 'Geo';
            
end

switch(mode)
    
    case 'Geo'
        
        deltaLon = lon1 - lon0;
        y = sind(deltaLon)*cosd(lat1);
        x = cosd(lat0)*sind(lat1) - sind(lat0)*cosd(lat1)*cosd(deltaLon);

        bearing = mod(atan2(y,x) + 360, 360);

    case 'UTM'
        
        bearing = mod(atan2(lon1 - lon0, lat1 - lat0)*180/pi,360);
        
    otherwise
        
        error('Unrecognized coordinates mode. Type "help getBearing" in the command prompt for more info about function usage');

end

