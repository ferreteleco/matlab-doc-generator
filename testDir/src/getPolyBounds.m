function [ PolyBounds ] = getPolyBounds(polyx, polyy)
%getPolyBounds returns the bounds of a polygon defined by its vertices X - Y coordinates.
%   
%%--------------------------------------------------------------------------------------------------   
%   @desc Computes the bounds of a polygon defined by its coordinates.
%
%   Supports the use of both geographical and UTM coordinates.
%
%%--------------------------------------------------------------------------------------------------
%  @ref https://sourceforge.net/p/opencarto/code/HEAD/tree/trunk/server/src/main/java/org/opencarto/algo/base/SmallestSurroundingRectangle.java#l41
%  @ref https://es.mathworks.com/matlabcentral/answers/93554-how-can-i-rotate-a-set-of-points-in-a-plane-by-a-certain-angle-about-an-arbitrary-point
%  @ref http://www.qhull.org/
%  @ref http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.155.5671&rep=rep1&type=pdf
%  @ref http://dl.acm.org/citation.cfm?id=360919
%  @ref https://geidav.wordpress.com/tag/convex-hull/ 
%   
%%--------------------------------------------------------------------------------------------------
%   The inputs of this function are:
%
%   - @iparam [float] polyx: vector containing either UTM Easting or longitudes {m or deg.} 
%   - @iparam [float] polyy: vector containing either UTM Northing or latitudes {m or deg.}
%
%%--------------------------------------------------------------------------------------------------
%   The outputs for this function are:
%
%   - @oparam [struct] polyBounds: it is a structure (optional) containing the following fields:
%
%       -> [float] TopLeft: vector containing the coordinates of the top left corner of
%       -> the polygon {m} 
%
%       -> [float] TopRight: vector containing the coordinates of the top right corner of
%       -> the polygon {m} 
%
%       -> [float] BottomLeft: vector containing the coordinates of the bottom left corner
%       -> of the polygon {m} 
%
%       -> [float] BottomRight: vector containing the coordinates of the bottom right
%       -> corner of the polygon {m}
%
%       -> [float] diagDist: diagonal distance of the rectangle circumbscribing the
%       -> polygon {m} 
%
%       -> [float] midWidth: half the width of the rectangle circumbscribing the polygon
%       -> {m}
%
%       -> [float] midHeight: half the height of the rectangle circumbscribing the polygon
%       -> {m} 
%
%       -> [float] vertex: matrix containing the coordinates of the polygon's vertices
%       -> 'closed' (the last coordinate of the vertices and the first are the same one)
%       -> {m} 
%
%       -> [float] Width: width of the rectangle that circumbscribes the polygon {m} 
%
%       -> [float] Height: height of the rectangle that circumbscribes the polygon {m} 
%
%       -> [float] Rectvertex: matrix containing the coordinates of the polygon's Bounding
%       -> Box vertices 'closed' (the last coordinate of the vertices and the first are the
%       -> same one) {m} 
%
%       -> [float] polyCenter: centroid of the polygon, vector containing x and y
%       -> coordinates {m} 
%
%       -> [float] minAngle: angle of rotation of the polygon of the polygon's vertices
%       ->(a.c.sorted) {deg}
%   
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 20/02/2017
%   ** @version 1.5
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------


if nargin < 2
  
    error('Not enough input arguments. Type "help getPolyBounds" in the command prompt to get more info about function usage');
    
elseif nargin > 2
    
    error('Too many input arguments. Type "help getPolyBounds" in the command prompt for more info about function usage.');
    
end

PolyBounds = struct('TopLeft', [],'TopRight', [], 'BottomLeft', [], 'BottomRight', [],'diagDist', 0,...
    'midWidth', 0, 'midHeight', 0, 'vertex', []);

% 1. Boundaries of the polygon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   a. Get convex hull
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% It uses http://www.qhull.org/
k = convhull(polyx, polyy);

vertex = [polyx(k)', polyy(k)'];

vertex = [[vertex(:,1);vertex(1,1)] [vertex(:,2);vertex(1,2)]];

%	b. Get centroid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

center = getPolyCenter(vertex);

% c. Compute Smallest Surrounding Rectangle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

minArea = 1e99;
minAngle = 0;

ssr = zeros(4,2);

ci = vertex(1,:);

for ii = 1 : length(vertex(:,1))-1
   
    cii = vertex(ii+1,:);
    
    angle = atan2d(cii(2) - ci(2), cii(1) - ci(1));
    
    [ rotPol ] = rotatePolygon( vertex, center, -angle );
    
    rect = getEnvelope(rotPol);
    
    [ area ] = getPolyArea( rect );
    
    if area < minArea
        
        ssr = rect;
        minArea = area;
        minAngle = angle;        
    end
    
    ci = cii;
end

ssr = rotatePolygon( ssr, center, minAngle );

% Sort the vertex in order to display the polygon correctly 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vertex = [polyx',polyy'];           

meanx = max(ssr(:,1)) - (max(ssr(:,1)) - min(ssr(:,1)))/2;
meany = max(ssr(:,2)) - (max(ssr(:,2)) - min(ssr(:,2)))/2;
                             
PolyBounds.BottomLeft = [ssr(1,1) ssr(1,2)];
PolyBounds.TopLeft = [ssr(2,1) ssr(2,2)];
PolyBounds.TopRight = [ssr(3,1) ssr(3,2)];
PolyBounds.BottomRight = [ssr(4,1) ssr(4,2)];

PolyBounds.vertex = [[vertex(:,1);vertex(1,1)] [vertex(:,2);vertex(1,2)]];

PolyBounds.Rectvertex = ssr;

PolyBounds.diagDist = getDistance(ssr(1,2), ssr(1,1), ssr(3,2), ssr(3,1), 'Pyt');

PolyBounds.polyCenter = center;

PolyBounds.midWidth = meanx;
PolyBounds.midHeight = meany;

PolyBounds.minAngle = minAngle;

PolyBounds.Width = getDistance(PolyBounds.BottomRight(2), PolyBounds.BottomRight(1),...
            PolyBounds.BottomLeft(2), PolyBounds.BottomLeft(1), 'Pyt');
        
PolyBounds.Height = getDistance(PolyBounds.BottomRight(2), PolyBounds.BottomRight(1),...
            PolyBounds.TopRight(2), PolyBounds.TopRight(1), 'Pyt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

