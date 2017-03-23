function [Grid, externalBounds, polyBounds] = testfunct(polygon, photoParams, StartPos, cryteria)
%testfunct computes the grid required to cover the specified polygon.
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
%   - @iparam (float) polygon: matrix that defines the UTM coordinates of the polygon to be
%     surveyed. Eastings in Row 1, and Northings in Row 2 [meters]
%
%   - @iparam (struct) photoParams: it is a struct that contains the following:
%
%       -> (float) cmpixel:     centimeters per pixels ratio to be achieved         [cm/px]
%       -> (float) flyAlt:      flight altitude in meters                           [m]
%       -> (float) B:           distance between photographs in meters              [m]
%       -> (float) A:           separation between lines in meters                  [m]
%       -> (float) mHeight:     image height at ground in meters                    [m]
%       -> (float) mWidth:      image height at ground in meters                    [m]
%       -> (float) fovhdeg:     height of the field of view in degrees              [deg.]
%       -> (float) fovwdeg:     width of the field of view in degrees               [deg.]
%
%   - @iparam (String) StartPos: it is a string that defines the initial location of the survey over the
%     grid. {default} Values:
%
%       -> 'BottomLeft': bottom left side of the grid
%       -> 'BotomRight': bottom right side of thr grid {default}
%       -> 'TopRight':   top right side of the grid
%       -> 'TopLeft':    top left side of the grid
%
%   - @iparam (String) cryteria: string that defines te criteria used to survey the polygon.
%     {optional} Values:
%
%       -> 'MinD': minimun distance between strips {default}
%       -> 'Pol':  connect strips trancing lines over polygon's faces
%
%%--------------------------------------------------------------------------------------------------
%   The outputs for thhis function are:
%
%   - @oparam (struct) Grid: structure containing the parameters of the generated grid:
%
%       -> (float)     area: area of the grid in square meters [m^2]
%       -> (int)       noStrips: number of strips that covers the polygon
%       -> (float)     distanceOverPath: distance travelled to cover the area  of the polygon in [m]
%       -> (struct)    Path: struct containing the coordinates of the waypoints that define the grid:
%                       -->(float) x: vector of Eastings of the waypoints in UTM [m]
%                       -->(float) y: vector of Northings of the waypoints in UTM [m]
%
%   - @oparam (int) flag: it indicates whether the computed grid  is correct {1} for the
%     given polygon, or has warnings {2} or it is not correct {0}
%
%   - @oparam (struct) externalBounds: structure containing the external bounds used as auxiliary material to compute
%     the grid {optional}
%
%       -> (float) TopRight: vector of UTM coordinates of the top right corner of the rectangle that
%       -> circumbscribes the polygon plus more [m]
%
%       -> (float) TopLeft: vector of UTM coordinates of the top left corner of the rectangle that
%       -> circumbscribes the polygon plus more [m]
%
%       -> (float) BottomRight: vector of UTM coordinates of the bottom right corner of the rectangle that
%       -> circumbscribes the polygon plus more [m]
%
%       -> (float) BottomLeft: vector of UTM coordinates of the bottom left corner of the rectangle that
%       -> circumbscribes the polygon plus more [m]
%
%       -> (float) Width: width of the rectangle that circumbscribes the polygon plus more [m]
%
%       -> (float) Height: height of the rectangle that circumbscribes the polygon plus more [m]
%
%       -> (float) vertex: matrix of vertices of the bounding box plus more [m]
%
%       -> (float) WPaux: matrix of waypoints of the external grid covering the bounding box plus more [m]
%
%   - @oparam (struct) polyBounds: it is a {optional} structure containing the following fields:
%
%       -> (float) TopLeft: vector containing the coordinates of the top left corner of the polygon [m]
%
%       -> (float) TopRight: vector containing the coordinates of the top right corner of the polygon [m]
%
%       -> (float) BottomLeft: vector containing the coordinates of the bottom left corner of the polygon [m]
%
%       -> (float) BottomRight: vector containing the coordinates of the bottom right corner of the polygon [m]
%
%       -> (float) diagDist: diagonal distance of the rectangle circumbscribing the polygon [m]
%
%       -> (float) midWidth: half the width of the rectangle circumbscribing the polygon [m]
%
%       -> (float) midHeight: half the height of the rectangle circumbscribing the polygon [m]
%
%       -> (float) vertex: matrix containing the coordinates of the polygon's vertices 'closed'
%       -> (the last coordinate of the vertices and the first are the same one) [m]
%
%       -> (float) Width: width of the rectangle that circumbscribes the polygon [m]
%
%       -> (float) Height: height of the rectangle that circumbscribes the polygon [m]
%
%       -> (float) Rectvertex: matrix containing the coordinates of the polygon's Bounding Box vertices
%       -> 'closed' (the last coordinate of the vertices and the first are the same one) [m]
%
%       -> (float) polyCenter: centroid of the polygon, vector containing x and y coordinates [m]
%
%       -> (float) minAngle: angle of rotation of the polygon of the polygon's vertices (sorted) [deg]
%
%%--------------------------------------------------------------------------------------------------
%   ** @auhor Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 22/02/2017
%   ** @version 1.8
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

testfunctDue
testfunctOne
testscript

if nargin < 1

        error('Not enough input arguments. Type "help dumpToFile" in the command prompt for more info about function usage.');

elseif nargin > 1

        error('Too many input arguments. Type "help dumpToFile" in the command prompt for more info about function usage.');
end

try

    str = get(log, 'String');

    if isempty(str)

        updateLog(log, '------WARNING------ There is nothing to dump. Aborted', 0);

    else

        pat = '<[^>]*>';
        str = regexprep(str, pat, '');
        str = strrep(str, '&nbsp;', ' ');


        updateLog(log, '------EVENT------ Starting log dump on memory...', 0);

        if ~exist('./Logs/', 'dir')

            mkdir('./Logs/');

        end

        FileName =  sprintf('%02i%02i%02i%02i%02i%01.0f.txt',year(now), ...
                                        month(now), day(now), hour(now), minute(now), second(now));

        FilePath = './Logs/';

        fullpath = strcat(FilePath, FileName);

        fileID = fopen(fullpath, 'w');

        for ii = 1 : numel(str)

            fprintf(fileID, '[%04i]   %s\n', ii, str{ii});

        end

        fclose(fileID);
        updateLog(log, sprintf('------EVENT------ Log dumped succesfully at %s',fullpath), 0);

    end

catch err

    if fileID == -1

        updateLog(log, strcat('------FATAL ERROR------ ', ferror(fileID)));
    else

        fclose(fileID);
        updateLog(log, '------FATAL ERROR------ Something went wrong while writing text file.', 1);
        updateLog(log, getReport(err), 0);
    end
end
end