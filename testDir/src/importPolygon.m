function [ polygon, status ] = importPolygon( log, Path )
%importPolygon gets polygon boundaries from the file specified in path.
%   
%%--------------------------------------------------------------------------------------------------
%   @desc Gets polygon boundaries from the file specified in path. Supports the use of kml
%   generated files and .poly files (Mission Planner).
%
%   TAKE CARE!!: decimal degrees format.
%%--------------------------------------------------------------------------------------------------
%   The inputs for this function are:
%
%   - @iparam [graphics handle] log: handle of log console 
%   - @iparam [String] Path: Path to polygon file
%   
%%--------------------------------------------------------------------------------------------------
%   The outputs of this function are:
%   
%   - @oparam [float] polygon: matrix with lats, lons and alts in rows {deg}
%   - @oparam [int] status: flag that indicates if everithing went fine (1) or not (-1)
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 14/03/2017
%   ** @version 1.0
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

if nargin < 1
    
        error('Not enough input arguments. Type "help importPolygon" in the command prompt for more info about function usage.');
        
elseif nargin > 2
    
        error('Too many input arguments. Type "help importPolygon" in the command prompt for more info about function usage.');
            
end

lats = [];
lons = [];
elevs = [];

try
    
    tokens = strsplit(Path,'.');
    
    switch(tokens{end})
        
        case'kml'  % if it's a kml file, we get the values
    
            % First, open file and dump it on memory

            fileID = fopen(Path,'r');

            s = textscan(fileID, '%s', 'delimiter', '\n'); 
            cell = strcat(s{1});

            fclose(fileID);

            % Then index of tags (<Point> and </Point>)
            IPoint = strfind(cell, '<Placemark>');
            IndexPoint = find(not(cellfun('isempty', IPoint)));  

            ISlashPoint = strfind(cell, '</Placemark>');
            IndexSlashPoint = find(not(cellfun('isempty', ISlashPoint)));  

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Import coordinates for each waypoint
            for ii = 1 : length(IndexPoint)

            pointstr = strcat(cell{IndexPoint(ii):IndexSlashPoint(ii)});

                if (isempty(strfind(pointstr, '<name>WP H')) && isempty(strfind(pointstr, '<name>WPs</name>'))...
                        && isempty(strfind(pointstr, '<name>onground</name>')))  % If it's not a 'Home' Waypoint

                    coordindex = strfind(pointstr,'<coordinates>');
                    coordslashindex = strfind(pointstr,'</coordinates>');

                    str = pointstr(coordindex+13:coordslashindex-1);

                    spltstr = strsplit(str,',');

                    lats = [lats str2double(spltstr{1,2}) ];
                    lons = [lons str2double(spltstr{1,1}) ];
                    elevs = [elevs str2double(spltstr{1,3}) ];

                end

            end
            
            status = 1;
            polygon = [ lats;lons;elevs];
    
        case 'poly'        % .poly file
    
             % First, open file and dump it on memory

            fileID = fopen(Path,'r');

            s = textscan(fileID, '%s', 'delimiter', '\n'); 
            cell = strcat(s{1});

            fclose(fileID);

            for ll = 2 : length(cell)

                line = strrep(cell{ll}, ',', '.');
                spltstr = strsplit(line, ' ');

                lats = [lats str2double(spltstr{1,1}) ];
                lons = [lons str2double(spltstr{1,2}) ];

            end

            elevs = zeros(1,length(lats));
            
            status = 1;
            polygon = [ lats;lons;elevs];
        
        otherwise
                        
            updateLog(log, sprintf('------FATAL ERROR------ Unsupported file extension (.%s)', tokens{end}), 0);
            polygon = [];
            status = -1;
    end
catch
    
    status = -1;
    polygon = [];
    
    updateLog(log, '------FATAL ERROR------ The polygon file is not well constructed, please check it',0);
    
end
end

