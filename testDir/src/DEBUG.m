%   @desc Script used for debugging o the ComputeGrid and gridInspector functions
%%--------------------------------------------------------------------------------------------------
%   @author Andres Ferreiro Gonzalez (@aferreiro)
%   @company Galician Research and Development Center in Advanced Telecommunications (GRADIANT)
%   @date 14/03/17
%   @version 1.0
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------
polygon = [539859.168 539935.677 539971.455 539924.661 ; 4687039.661 4687029.326 4687035.254 4687101.229 ];


% Coordinates that define the vertics of the polygon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
polyx = polygon(1,:);
polyy = polygon(2,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Boundaries of the polygon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   a. Get convex hull
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% It uses http://www.qhull.org/
k = convhull(polyx, polyy);

% Clockwise order for vertex
k = flipud(k);

vertex = [polyx(k)', polyy(k)'];

vertex = [[vertex(:,1);vertex(1,1)] [vertex(:,2);vertex(1,2)]];

% % Do Debug
% plot(vertex(:,1), vertex(:,2),'r')

%	b. Get centroid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ref. ArcGIS http://foro.gabrielortiz.com/index.asp?Topic_ID=5168

% Area of the polygon
[ A ] = getPolyArea( vertex(:,1), vertex(:,2) );

x_center = abs(1/(6*A)*sum((vertex(1:end-1,1) + vertex(2:end,1)).*(vertex(1:end-1,1).*vertex(2:end,2) - vertex(2:end,1).*vertex(1:end-1,2))));
y_center = abs(1/(6*A)*sum((vertex(1:end-1,2) + vertex(2:end,2)).*(vertex(1:end-1,1).*vertex(2:end,2) - vertex(2:end,1).*vertex(1:end-1,2))));

% % Do Debug
% plot(vertex(:,1), vertex(:,2),'r')
% hold on
% plot(cx, cy,'bx', 'MarkerSize', 8)

% c. Compute Smallest Surrounding Rectangle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ref: https://sourceforge.net/p/opencarto/code/HEAD/tree/trunk/server/src/main/java/org/opencarto/algo/base/SmallestSurroundingRectangle.java#l41
% and https://es.mathworks.com/matlabcentral/answers/93554-how-can-i-rotate-a-set-of-points-in-a-plane-by-a-certain-angle-about-an-arbitrary-point

minArea = 9999999999999;
minAngle = 0;

ssr = zeros(4,2);

ci = vertex(1,:);

for ii = 1 : length(vertex(:,1))-1
   
    cii = vertex(ii+1,:);
    
    angle = atan2d(cii(2) - ci(2), cii(1) - ci(1));
    
    [ rotPol ] = rotatePolygon( vertex, [x_center y_center], -angle );
    
    rect = getEnvelope(rotPol);
    
    [ area ] = getPolyArea( rect );
    
    if area < minArea
        
        ssr = rect;
        minArea = area;
        minAngle = angle;        
    end
    
    ci = cii;
end

ssr = rotatePolygon( ssr, [x_center y_center], minAngle );

% Do Debug
plot(ssr(:,1), ssr(:,2))
hold on
plot(vertex(:,1), vertex(:,2),'r')
plot(cx, cy,'bx', 'MarkerSize', 8)



% %  Draw large bounding box:
% 
% N = 100;
% 
% xstart = 0;
% ystart = 0;
% 
% xlen = N;
% ylen = N;
% 
% rectangle('position', [xstart, ystart, xlen, ylen])
% 
% % Draw smaller boxes
% dx = 1;
% dy = 1;
% 
% nx = floor(xlen/dx);
% ny = floor(ylen/dy);
% 
% for i = 1:nx
%     x = xstart + (i-1)*dx;
%     for j = 1:ny
% 
%         color = [rand(1,1) rand(1,1) rand(1,1)];
%         y = ystart + (j-1)*dy;
%         rectangle('position', [x, y, dx, dy], 'FaceColor', color)
%     end
% end
% 
% 
