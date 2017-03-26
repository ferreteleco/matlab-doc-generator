function [ center ] = getPolyCenter( vertex, coord )
%getPolyCenter computes the centroid of the polygon specified by vertex.
%   
%%-------------------------------------------------------------------------------------------------- 
%   @desc Computes the centroid of the polygon specified by vertex.
%   It supports the use of both geographical or UTM coordinates, as well as any other
%   cartesian system.
%
%%--------------------------------------------------------------------------------------------------
%   @ref http://foro.gabrielortiz.com/index.asp?Topic_ID=5168
%
%%--------------------------------------------------------------------------------------------------
%   The inputs of this function are:
%   
%   - @iparam [float] vertex: matrix containing the coordinatesof the polygon's vertices
%   'closed' (the last coordinate of the vertices and the first are the same one) {m}
%
%   - @iparam [String] coord: String that defines te input coordinates
%       -> 'UTM': input as UTM coordinates (default)
%       -> 'Geo': input as geographical coordinates
%   
%%--------------------------------------------------------------------------------------------------
%   The output of this function is:
%   - @oparam [float] env:coordinates of the rectangle's vertices 'closed' (the last
%   coordinate of the vertices and the first are the same one) {m or deg}
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 17/03/2017
%   ** @version 1.1
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------


if nargin < 1
    
        error('Not enough input arguments. Type "help getPolyCenter" in the command prompt for more info about function usage.');
        
elseif nargin > 2
    
        error('Too many input arguments. Type "help getPolyCenter" in the command prompt for more info about function usage.');
        
elseif nargin == 1
    
    coord = 'UTM';
end


% If it has negative coordinates, shift to positive and tat the end undo the shift
if strcmp(coord, 'Geo')
    
    vertex = vertex + 100000;
end

% Area of the polygon
[ A ] = getPolyArea( vertex );

center(1) = abs(1/(6*A)*sum((vertex(1:end-1,1) + vertex(2:end,1)).*(vertex(1:end-1,1).*vertex(2:end,2) - vertex(2:end,1).*vertex(1:end-1,2))));
center(2) = abs(1/(6*A)*sum((vertex(1:end-1,2) + vertex(2:end,2)).*(vertex(1:end-1,1).*vertex(2:end,2) - vertex(2:end,1).*vertex(1:end-1,2))));

if strcmp(coord, 'Geo')
    
    center = center - 100000;
end

end

