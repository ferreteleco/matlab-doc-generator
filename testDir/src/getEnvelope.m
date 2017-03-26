function [ env ] = getEnvelope( vertex )
%getEnvelope gets the rectangle surronding the polygon specified by vertex.
%   
%%--------------------------------------------------------------------------------------------------  
%   @desc Gets the rectangle surronding the polygon specified by vertex.
%
%%--------------------------------------------------------------------------------------------------
%   The inputs of this function are:
%   
%   - @iparam [float] vertex: matrix containing the coordinates of the polygon's vertices
%   'closed' (the last coordinate of the vertices and the first are the same one) {deg. or m}
%
%%--------------------------------------------------------------------------------------------------
%   The output of this function is:
%
%   - @oparam [float] env: coordinates of the rectangle's vertices 'closed' (the last
%   coordinate of the vertices and the first are the same one) {deg. or m}
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 17/03/2017
%   ** @version 1.0
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------


if nargin < 1
    
        error('Not enough input arguments. Type "help getEnvelope" in the command prompt for more info about function usage.');
        
elseif nargin > 2
    
        error('Too many input arguments. Type "help getEnvelope" in the command prompt for more info about function usage.');
end

minx = min(vertex(:,1));
maxx = max(vertex(:,1));

miny = min(vertex(:,2));
maxy = max(vertex(:,2));


env =[ minx miny; minx maxy; maxx maxy;maxx miny; minx miny];

end

