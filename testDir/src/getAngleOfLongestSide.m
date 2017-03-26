function [ angleLS, distLS, index ] = getAngleOfLongestSide( lats, lons, mode )
%getAngleOfLongestSide gets the angle of the longest side of a plygon defined by its
%vertices.
%   
%%--------------------------------------------------------------------------------------------------   
%   @desc Computes the bearing of a poygon's longest face. 
%
%   Supports the use of vectors in latitude and longitude coordinates.
%   
%%--------------------------------------------------------------------------------------------------   
%   The inputs for this function are:
%   
%   - @iparam [float] lats: vector of latitudes or Northings {deg. or m}
%   - @iparam [float] lons: vector of longitudes or Eastings {deg. or m}
%   
%   - @iparam [String] mode: string that specifies the coordinates to be used in the
%   calculations. (Optional) Values:
%       -> 'Geo': Geographical coordinates, decimal deg. (default) 
%       -> 'UTM': UTM coordinates
%   
%%--------------------------------------------------------------------------------------------------
%   The outputs for this function are:
% 
%   - @oparam [float] angleLS: angle of the longest side {deg}
%   - @oparam [float] distLS: length of the longest side {m}
%   - @oparam [int] index: index of the initial position of the longest side of the polygon 
%   
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 28/02/2017
%   ** @version 1.2
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

if nargin < 2
    
        error('Not enough input arguments. Type "help getAngleOfLongestSide" in the command prompt for more info about function usage.');
        
elseif nargin > 3
    
            error('Too many input arguments. Type "help getAngleOfLongestSide" in the command prompt for more info about function usage.');
            
elseif nargin == 2
    
    mode = 'Geo';
            
end

angleLS = 0;
distLS = 0;

index = 0;

switch(mode)
    
    case 'Geo'
                
        for ii = 2 : length(lats)

            tdist = getDistance(lats(ii-1), lons(ii-1), lats(ii), lons(ii), 'Hav2');

            if tdist >= distLS

                angleLS = getBearing(lats(ii-1), lons(ii-1), lats(ii), lons(ii),'Geo');
                index = ii-1;

            end

        end
    
    case 'UTM'
        
        for ii = 2 : length(lats)

            tdist = getDistance(lats(ii-1), lons(ii-1), lats(ii), lons(ii), 'Pyt');

            if tdist > distLS

                angleLS = getBearing(lats(ii-1), lons(ii-1), lats(ii), lons(ii),'UTM');
                distLS = tdist;
                index = ii-1;

            end

        end
                   
    otherwise
        
       error('Unrecognized coordinates mode. Type "help getAngleOfLongestSide" in the command prompt for more info about function usage');

end

