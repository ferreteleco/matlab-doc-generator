function [ area ] = getPolyArea( vertex, coord )
%getPolyArea returns the area of a polygon.
%   
%%--------------------------------------------------------------------------------------------------  
%   @desc Computes the area of a polygon defined by its vertices.
%
%   Supports the use of both geographical and UTM coordinates.
%   
%%--------------------------------------------------------------------------------------------------
%   The inputs for this function are:
%   
%   - @iparam [float] vertex: matrix containing the coordinates of the polygon's vertices
%   'closed' (the last coordinate of the vertices and the first are the same one) {m or deg.}
%
%   - @iparam [String] coord: String that defines te input coordinates
%       -> 'UTM': input as UTM coordinates (default)
%       -> 'Geo': input as geographical coordinates
%
%%--------------------------------------------------------------------------------------------------
%   The output of this function is:
%
%   - @oparam [float] area: area of the polygon in meters {m} 
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 20/02/2017
%   ** @version 1.2
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------


if nargin < 1
  
    error('Not enough input arguments. Type "help getPolyArea" in the command prompt to get more info about function usage');
    
elseif nargin > 2
    
    error('Too many input arguments. Type "help getPolyArea" in the command prompt for more info about function usage.');

elseif nargin == 1
    
    coord = 'UTM';

end

polyx = vertex(:,1);
polyy = vertex(:,2);


if strcmp(coord, 'Geo')
        
    [polyx, polyy, ~, ~] = geoToUTM(polyy, polyx);
        
end
    
area = 0;

if polyx(1) ~= polyx(end)

    polyx1 = [polyx polyx(1)];
    polyy1 = [polyy polyy(1)];

else
    
    polyx1 = polyx;
    polyy1 = polyy;
    
end

for ii = 1 : length(polyy1) - 1
    
   
    prod1 = polyx1(ii)*polyy1(ii+1);
    prod2 = polyy1(ii)*polyx1(ii+1);
    
    area = area + (prod1 - prod2);
end

area = abs(area/2);




end

