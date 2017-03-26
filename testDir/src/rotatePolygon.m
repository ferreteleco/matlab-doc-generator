function [ rotPol ] = rotatePolygon( vertex, center, angle )
%rotatePolygon performs a rotation of the polygon specified by angle arround specified center. 
%  
%%--------------------------------------------------------------------------------------------------   
%   @desc Performs a rotation of the given polygon (specified by its vertices coordinates either
%   geographical, UTM or another cartesian system) by angle arround specified center. 
%
%%--------------------------------------------------------------------------------------------------
%   @ref https://es.mathworks.com/matlabcentral/answers/93554-how-can-i-rotate-a-set-of-points-in-a-plane-by-a-certain-angle-about-an-arbitrary-point
%
%%-------------------------------------------------------------------------------------------------- 
%   The inputs of this function are:
%
%   - @iparam [float] vertex: matrix containing the coordinates of the polygon's vertices 'closed'
%   (the last coordinate of the vertices and the first are the same one) {m or deg.}
%   - @iparam [float] center: vector containing the coordinates of the polygon's centroid {m or
%   deg.}
%   - @iparam [float] angle: angle of rotation of the polygon {deg}
%
%%--------------------------------------------------------------------------------------------------
%   The output of this function is:
%   
%   - @oparam [float] rotPol: coordinates of the rotated polygon {m or deg.}
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 17/03/2017
%   ** @version 1.1
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

if nargin < 3
    
        error('Not enough input arguments. Type "help rotatePolygon" in the command prompt for more info about function usage.');
        
elseif nargin > 3
    
        error('Too many input arguments. Type "help rotatePolygon" in the command prompt for more info about function usage.');
        
end

x_center = center(1);
y_center = center(2);

vertex = vertex';
center = repmat([x_center; y_center], 1, length(vertex));

R = [cosd(angle) -sind(angle); sind(angle) cosd(angle)];

rotPol = (R*(vertex - center) + center)';

end

