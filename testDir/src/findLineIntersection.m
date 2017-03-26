function [ intersx, intersy ] = findLineIntersection( start1, end1, start2, end2 )
%findLineIntersection returns the coordinates of the intersection of two lines.
%
%%--------------------------------------------------------------------------------------------------  
%   @desc Computes the intersection between tho lines defined by its initial and final
%   coordinates
%
%   Supports the use of UTM coordinates or any other cartesian system. In order to use UTM
%   coordinates, it is asumed that both lines lay in the same UTM Zone and Band
% 
%%--------------------------------------------------------------------------------------------------   
%   The inputs for this function are:
%
%   - @iparam [float] start1: vector storing the initial coordinates of the first line {m}
%   - @iparam [float] end1: vector storing the final coordinates of the first line {m}
%   - @iparam [float] start2: vector storing the initial coordinates of the second line {m}
%   - @iparam [float] end2: vector storing the final coordinates of the second line {m}
%
%%-------------------------------------------------------------------------------------------------- 
%   The otputs for this function are:
%
%   - @oparam [float] intersx: Easting or longitude coordinate of the intersection {m}   
%   - @oparam [float] intersx: Northing or latitude coordinate of the intersection {m}
%
%%-------------------------------------------------------------------------------------------------- 
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 20/02/2017
%   ** @vrsion 1.2
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

if nargin < 4
  
    error('Not enough input arguments. Type "help findLineIntersection" in the command prompt to get more info about function usage');
    
elseif nargin > 4
    
    error('Too many input arguments. Type "help findLineIntersection" in the command prompt for more info about function usage.');
end


denom = ( ( end1(1) - start1(1) )*( end2(2) - start2(2) ) ) - ( ( end1(2) - start1(2) )*( end2(1) - start2(1) ) );

% There's no intersections at all
if denom == 0
    
    intersx = NaN;
    intersy = NaN;
else
   
    numer = ( ( (start1(2) - start2(2) )*( end2(1) - start2(1) ) ) - ( ( start1(1) - start2(1) ) )*( end2(2) - start2(2) ) );
    
    r = numer / denom;
    
    numer2 = ( ( start1(2) - start2(2) )*( end1(1) - start1(1) ) ) - ( ( start1(1) - start2(1) )*( end1(2) - start1(2) ) );
    
    s = numer2 / denom;

    if ((r < 0 || r > 1) || (s < 0 || s > 1))
       
        intersx = NaN;
        intersy = NaN;
        
    else
        
        % Find intersection point
        intersx = start1(1) + ( r*( end1(1) - start1(1) ) );
        intersy = start1(2) + ( r*( end1(2) - start1(2) ) );
        
    end
end
end

