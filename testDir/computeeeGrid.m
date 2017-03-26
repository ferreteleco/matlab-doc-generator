function [ Grid, flag, varargout ] = computeeeGrid( polygon, photoParams, StartPos, cryteria )
%computeGrid computes the grid required to cover the specified polygon. 
%
%%--------------------------------------------------------------------------------------------------
%   @desc Computes the grid required to cover the specified polygon returning the waypoints
%   needed to cover it among other parameters that are defined below.
%
%   Take into account that there is one structure defined as input parameter, and all the
%   fields must be included.
%
%   This function was designed to manage UTM coordinates and it does not suport the use of
%   geographical coordinates. Future releases may allow it, but that is not the case.
%
%%--------------------------------------------------------------------------------------------------
%   The inputs for this funtion are:
%
%   - @iparam [float] polygon: matrix that defines the UTM coordinates of the polygon to be
%     surveyed. Eastings in Row 1 and Northings in Row 2 {m}
%
%   - @iparam [struct] photoParams: it is a struct that contains the following:
%
%       -> [float] cmpixel: centimeters per pixels ratio to be achieved {cm/px}
%       -> [float] flyAlt: flight altitude in meters {m}
%       -> [float] B: distance between photographs in meters {m}
%       -> [float] A: separation between lines in meters {m}
%       -> [float] mHeight: image height at ground in meters {m}
%       -> [float] mWidth: image height at ground in meters {m}
%       -> [float] fovhdeg: height of the field of view in degrees {deg}
%       -> [float] fovwdeg: width of the field of view in degrees {deg}
%
%   - @iparam [String] StartPos: it is a string that defines the initial location of the survey over the
%     grid. (Optional) Values:
%
%       -> 'BottomLeft': bottom left side of the grid
%       -> 'BotomRight': bottom right side of thr grid (optional)
%       -> 'TopRight': top right side of the grid
%       -> 'TopLeft': top left side of the grid
%
%   - @iparam [String] cryteria: string that defines te criteria used to survey the polygon.
%	  (Optional) Values:
%
%       -> 'MinD': minimun distance between strips (optional)
%       -> 'Pol': connect strips trancing lines over polygon's faces
%
%%--------------------------------------------------------------------------------------------------
%   The outputs for this function are:
%
%   - @oparam [struct] Grid: structure containing the parameters of the generated grid:
%
%       -> [float] area: area of the grid in square meters {m^2}
%       -> [int]   noStrips: number of strips that covers the polygon
%       -> [float] distanceOverPath: distance travelled to cover the area of the polygon {m^2}
%       -> [struct] Path: struct containing the coordinates of the waypoints that define the grid.
%               --> [float] x: vector of Eastings of the waypoints in UTM {m}
%               --> [float] y: vector of Northings of the waypoints in UTM {m}
%
%   - @oparam [int] flag: it indicates whether the computed grid  is correct (1) for the
%     given polygon, or has warnings (2) or it is not correct(0).
%
%   - @oparam [struct] externalBounds: structure containing the external bounds used as
%   auxiliary material to compute the grid (optional)
%
%       -> [float] TopRight: vector of UTM coordinates of the top right corner of the
%       -> rectangle that circumbscribes the polygon plus more {m}
%
%       -> [float] TopLeft:  vector of UTM coordinates of the top left corner of the
%       -> rectangle that circumbscribes the polygon plus more {m}
%
%       -> [float] BottomRight: vector of UTM coordinates of the bottom right corner of
%       -> the rectangle that circumbscribes the polygon plus more {m}
%
%       -> [float] BottomLeft: vector of UTM coordinates of the bottom left corner of the
%       -> rectangle that circumbscribes the polygon plus more {m}
%
%       -> [float] Width: width of the rectangle that circumbscribes the polygon plus more {m}
%
%       -> [float] Height: height of the rectangle that circumbscribes the polygon plus
%       -> more {m}
%
%       -> [float] vertex: matrix of vertices of the bounding box plus more {m}
%
%       -> [float] WPaux: matrix of waypoints of the external grid covering the bounding
%       -> box plus more {m}
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
%       -> [float] diagDist: diagonal distance of the rectangle circumbscribing the polygon {m} 
%
%       -> [float] midWidth: half the width of the rectangle circumbscribing the polygon {m}
%
%       -> [float] midHeight: half the height of the rectangle circumbscribing the polygon {m} 
%
%       -> [float] vertex: matrix containing the coordinates of the polygon's vertices
%       -> 'closed' (the last coordinate of the vertices and the first are the same one) {m} 
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
%   ** @date 22/02/2017
%   ** @version 1.8
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

if nargin < 2
    
        error('Not enough input arguments. Type "help computeGrid" in the command propt for more info about function usage.');
        
elseif nargin > 4
    
        error('Too many input arguments. Type "help computeGrid" in the command propt for more info about function usage.');

elseif nargin == 2
    
        cryteria = 'MinD';
        StartPos = 'BottomRight';
        
elseif nargin == 3
    
        cryteria = 'MinD';

end

Grid = struct('area', 0, 'noStrips', 0, 'distanceOverPath', 0, 'Path', struct('x', [], 'y', []));


% Coordinates that define the vertics of the polygon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
polyx = polygon(1,:);
polyy = polygon(2,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 2. Boundaries of the polygon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[PolyBounds] = getPolyBounds(polyx, polyy);

[ alpha, distLS,  indexLS] = getAngleOfLongestSide( PolyBounds.Rectvertex(:,2), PolyBounds.Rectvertex(:,1), 'UTM' );

alpha = mod(alpha,180);

if indexLS > 1
    
    distSS = getDistance(PolyBounds.Rectvertex(indexLS,2), PolyBounds.Rectvertex(indexLS,1),...
        PolyBounds.Rectvertex(indexLS-1,2), PolyBounds.Rectvertex(indexLS-1,1),'Pyt');
    
else
    
    distSS = getDistance(PolyBounds.Rectvertex(end,2), PolyBounds.Rectvertex(end,1),...
       PolyBounds.Rectvertex(end-1,2), PolyBounds.Rectvertex(end-1,1),'Pyt');
end


extent = ceil((photoParams.A/2) + distSS/2);
extent1 = ceil((photoParams.A/2) + distLS/2);

[xx,yy] = newPos(PolyBounds.midWidth, PolyBounds.midHeight, alpha - 90, extent);
[xx1,yy1] = newPos(PolyBounds.midWidth, PolyBounds.midHeight, alpha + 90, extent);

[x(1),y(1)] = newPos(xx, yy, alpha + 180, extent1);
[x(2),y(2)] = newPos(xx, yy, alpha, extent1);

[x(3),y(3)] = newPos(xx1, yy1, alpha + 180, extent1);
[x(4),y(4)] = newPos(xx1, yy1, alpha, extent1);

ang = atan2(x -PolyBounds.polyCenter(1), y - PolyBounds.polyCenter(2));

[~,I] = sort(ang);

x = x(I);
y = y(I);
x(end+1) = x(1);
y(end+1) = y(1);

externalBounds.vertex = [x', y'];

externalBounds.TopRight = [x(3) y(3)];
externalBounds.BottomRight = [x(4) y(4)];
externalBounds.TopLeft = [x(2) y(2)];
externalBounds.BottomLeft = [x(1) y(1)];

externalBounds.Width = 2*extent;
        
externalBounds.Height = 2*extent1;  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Area of the polygon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ Grid.area ] = getPolyArea( PolyBounds.vertex );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 4. Get the start position over the outer box
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here, if we previouslly measure the distance from previous WP in the route and the
% vertices of the polygon, we can know the point where begin the grid

noStripsGross = round( ((2*extent) / photoParams.A) ) + 1;  

distLongTrip = 2*extent1;

switch(StartPos)
    
    case 'TopRight'
        RectStartPos = [ externalBounds.TopRight(1) externalBounds.TopRight(2) ];                 
        bearingLongTrip = mod((alpha)+180, 360);   
        bearingShortTrip =  mod((alpha)+90, 360);     
                
    case 'TopLeft'
        
        RectStartPos = [ externalBounds.TopLeft(1) externalBounds.TopLeft(2) ];        
        bearingLongTrip = mod((alpha), 360);            
        bearingShortTrip = mod(round(alpha)+90, 360);          
        
    case 'BottomRight'
        
        RectStartPos = [ externalBounds.BottomRight(1) externalBounds.BottomRight(2) ];         
        bearingLongTrip = mod((alpha)+180, 360);   
        bearingShortTrip = mod(round(alpha)-90, 360);        
        
    case 'BottomLeft'
        
        RectStartPos = [ externalBounds.BottomLeft(1) externalBounds.BottomLeft(2) ];         
        bearingLongTrip = alpha;              
        bearingShortTrip = mod(round(alpha)-90, 360);
        
    otherwise
        
        error('Unrecognized starting position. Type "help computeGrid" in the command propt for more info about function usage.');
        
end


% 5. Compute the waypoints of the grid overing the outer rectangle that 
%    circumscribes the polygon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WPaux = zeros(2*noStripsGross, 2);
WPaux(1,:) = RectStartPos;
Current = RectStartPos;

% For the number of strips needed to cover the entire rectangle
for kk = 1 : noStripsGross
    
    [Next(1), Next(2)] = newPos(Current(1), Current(2), bearingLongTrip, distLongTrip, 'GeoUTM');
    WPaux(2*kk,:) = Next;
    Current = Next;
    
    if kk < noStripsGross

        [Next(1), Next(2)] = newPos(Current(1), Current(2), bearingShortTrip, photoParams.A, 'GeoUTM'); 
        WPaux(kk+(kk+1),:) = Next;
        Current = Next;
        bearingLongTrip = mod(bearingLongTrip + 180, 360);
    end
 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 6. Find intersections with the polygon lines defined by its vertices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Path = struct('x',[],'y',[]);
indexWP = 1;

noStrips = 0;
distanceOfPath = 0;

numberCrossings = zeros(length(PolyBounds.Rectvertex),1);

for mm = 1 : noStripsGross
    
    
    indtemp = 1;
    tempintx = [];
    tempinty = [];
    
    for ll = 1 : length(PolyBounds.Rectvertex)-1

    
       
        [ intersx, intersy ] = findLineIntersection( WPaux(mm + (mm-1),:), WPaux(2*mm,:),...
            PolyBounds.Rectvertex(ll,:), PolyBounds.Rectvertex(ll+1,:) );
    
        if ~isnan(intersx)

            numberCrossings(ll,1) = numberCrossings(ll,1) +1;
            tempintx(indtemp) = intersx;
            tempinty(indtemp) = intersy;
            
            indtemp = indtemp + 1;
                     
        end
    end
    
    % If polygon and strip intersects
    if ~isempty(tempintx)
        
        % Get the index of the highest and lowest Y-coordinate intersections        
        [~,Imin] = min(tempinty);
        [~,Imax] = max(tempinty);
        
        % If they are equals, take the highest and lowest X-coordinate intersections
        if Imin == Imax
            
            [~,Imin] = min(tempintx);
            [~,Imax] = max(tempintx);
        end
        
        % Get the direction of movement over the final grid
        switch(indexWP)
            
            case 1      % for the first strip, take always the direction of the waypoints over the outer grid
                
                 dir = sign(cosd(getBearing(WPaux(1,2), WPaux(1,1), WPaux(2,2), WPaux(2,1), 'UTM')));
                
            otherwise   % for the following, 
                
                switch(cryteria)
                    
                    case 'MinD'
                        
                        dist1 = getDistance(tempinty(Imin), tempintx(Imin), Path.y(indexWP-1), Path.x(indexWP-1), 'Pyt');
                        dist2 = getDistance(tempinty(Imax), tempintx(Imax), Path.y(indexWP-1), Path.x(indexWP-1),'Pyt');
                        dir =  sign(dist2 - dist1);                                  
                        
                    case 'Pol'
                        
                        dir = sign(-1*dir);
                        
                    otherwise
                                
                        error('Unrecognized cryteria to perform the route. Type "help computeGrid" in the command propt for more info about function usage.');
                        
                end
        end

        % Act depending on the value of the direction of movement
        switch(dir)

            case 0  % Here, the movements in the  axis (perpendicular to North) are taken into account        
                
                switch(indexWP)
            
                    case 1
                    
                        dir = sign(sind(getBearing(WPaux(1,2), WPaux(1,1), WPaux(2,2), WPaux(2,1), 'UTM')));

                    otherwise

                        switch(cryteria)
                    
                            case 'MinD'
                                
                                 dist1 = getDistance(tempinty(Imin), tempintx(Imin), Path.y(indexWP-1), Path.x(indexWP-1), 'Pyt');
                                 dist2 = getDistance(tempinty(Imax), tempintx(Imax), Path.y(indexWP-1), Path.x(indexWP-1),'Pyt');
                                 dir =  sign(dist2 - dist1);

                            case 'Pol'

                                dir = sign(-1*dir);
                                
                            otherwise
                                
                                error('Unrecognized cryteria to perform the route. Type "help computeGrid" in the command propt for more info about function usage.');
                        
                        end

                end
                
                switch(dir)
                    
                    case 1  % Moves from left to right

                        Path.x(indexWP) = tempintx(Imin);
                        Path.y(indexWP) = tempinty(Imin);

                        indexWP = indexWP + 1;

                        Path.x(indexWP) = tempintx(Imax);
                        Path.y(indexWP) = tempinty(Imax);
                        
                        noStrips = noStrips + 1;


                    case -1 % Moves from right to left

                        Path.x(indexWP) = tempintx(Imax);
                        Path.y(indexWP) = tempinty(Imax);

                        indexWP = indexWP + 1;
                        
                        Path.x(indexWP) = tempintx(Imin);
                        Path.y(indexWP) = tempinty(Imin);
                        
                        noStrips = noStrips + 1;

                    otherwise
                        
                    % Bad, shouldn't happen
                    string = 'If you please, show some code-monkey this info:';
                    string1 = sprintf('Error: \n - Zero exit value for direction of movement: %dth strip and %dth polygon face.',mm,ll);
                    error('Something went very bad while computing intersections between plygons.\n %s\n%s', string, string1);

                end
 
            case 1 % Moves from down to up

                Path.x(indexWP) = tempintx(Imin);
                Path.y(indexWP) = tempinty(Imin);

                indexWP = indexWP + 1;

                Path.x(indexWP) = tempintx(Imax);
                Path.y(indexWP) = tempinty(Imax);
               
                noStrips = noStrips + 1;         

            case -1 % Moves from up to down

                Path.x(indexWP) = tempintx(Imax);
                Path.y(indexWP) = tempinty(Imax);

                indexWP = indexWP + 1;

                Path.x(indexWP) = tempintx(Imin);
                Path.y(indexWP) = tempinty(Imin);
           
                noStrips = noStrips + 1;                                                               

            otherwise

            % Bad, shouldn't happen
            string = 'If you please, show some code-monkey this info:';
            string1 = sprintf('Error: \n - Zero exit value for direction of movement: %dth strip and %dth polygon face.',mm,ll);
            error('Something went very bad while computing intersections between plygons.\n %s\n%s', string, string1);
        end   
        
        indexWP = indexWP + 1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 7. Get the distance over the path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for index = 2 : length(Path.x)

    distanceOfPath = distanceOfPath + getDistance(Path.y(index-1), Path.x(index-1),  Path.y(index), Path.x(index), 'Pyt');
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if the route covers all the grid or not. This piece of code covers the case that
% the limits of the polygon aren't covered by finding the nearest vertex to the starting
% and ending points of the first and last strips over the polygon. Then, if the distance
% is smaller than half the width of a photograph, the route is correct.
% 
% In addition it also tests if the number of crossings of the longest side perpendicular
% to the direction of movement is enough to cover it.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
INI1 = min(getDistance(Path.y(1), Path.x(1), PolyBounds.Rectvertex(:,2), ...
    PolyBounds.Rectvertex(:,1),'Pyt'));
END1 = min(getDistance(Path.y(2), Path.x(2), PolyBounds.Rectvertex(:,2),...
    PolyBounds.Rectvertex(:,1),'Pyt'));
INI2 = min(getDistance(Path.y(end-1), Path.x(end-1), PolyBounds.Rectvertex(:,2),...
    PolyBounds.Rectvertex(:,1),'Pyt'));
END2 = min(getDistance(Path.y(end), Path.x(end), PolyBounds.Rectvertex(:,2),...
    PolyBounds.Rectvertex(:,1),'Pyt'));

[maxa, I] = max(numberCrossings);

dd = getDistance(PolyBounds.Rectvertex(I,2), PolyBounds.Rectvertex(I,1), PolyBounds.Rectvertex(I+1,2),PolyBounds.Rectvertex(I+1,1), 'Pyt');

nSt = ceil(dd / photoParams.A);

if (INI1 < photoParams.mWidth/2 && END1 < photoParams.mWidth/2) && (INI2 < photoParams.mWidth/2 && ...
        END2 < photoParams.mWidth/2) && (nSt <= maxa)

    flag = 1;
    
elseif (INI1 < photoParams.mWidth/2 && END1 < photoParams.mWidth/2) && (INI2 < photoParams.mWidth/2 && ...
        END2 < photoParams.mWidth/2) || (nSt <= maxa)
    
    flag = 2;
    
else 
    
    flag = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Grid.Path = Path;
Grid.noStrips = noStrips;
Grid.distanceOverPath = distanceOfPath;
externalBounds.WPaux = WPaux;
varargout{1} = externalBounds;
varargout{2} = PolyBounds;

end

