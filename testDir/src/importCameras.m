function [ cameras, status ] = importCameras( log, path )
%importCameras imports all the camera objects found in 'path'.
%   
%%-------------------------------------------------------------------------------------------------- 
%   @desc Imports all the camera objects found in 'path', where a number of XML files of the
%   form: 
%
%   <?xml version="1.0" encoding="us-ascii"?>
%   <Cameras>
%   <Camera>
%     <name> </name>
%     <flen> </flen>
%     <imgh> </imgh>
%     <imgw> </imgw>
%     <senh> </senh>
%     <senw> </senw>
%   </Camera>
%   ...
%   </Cameras> 
%
%   has to be located.
%
%%--------------------------------------------------------------------------------------------------  
%   The inputs for this function are:
%   
%   - @iparam [graphics handle] log: handle of log console 
%   - @iparam [String] path: Path to the directory containing all the XML archives. 
%   
%%--------------------------------------------------------------------------------------------------
%   The outputs for this function are:
%   
%   - @oparam [struct] cameras: it is an array of structures with the following parameters:
%       -> [String] model: string containing camera name               
%       -> [float] focallen: focal length of the camera {mm}
%       -> [int] imwidth: width of the image {px}
%       -> [int] imheight: height of the image {px}
%       -> [float] sensorwidth: physical width of the sensor {mm}
%       -> [float] sensorheight: physical height of the sensor {mm}
%
%   - @oparam [int] status: flag that indicates if everithing went fine (1) or not (-1)
%   
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 13/03/2017
%   ** @version 1.2
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

if nargin < 2
    
        error('Not enough input arguments. Type "help importCameras" in the command prompt for more info about function usage.');
        
elseif nargin > 2
    
        error('Too many input arguments. Type "help importCameras" in the command prompt for more info about function usage.');
            
end

fileList = dir(path);
fileList = fileList(~[fileList.isdir]);      % remove directories
[~ , sortorder] = sort([fileList.datenum]);
fileList = fileList(sortorder);              % list is now in ascending date order

numArch = numel(fileList);
index = 1;
noXML = 0;

updateLog(log, '------EVENT------ Fetching cameras from disc at ''./Archives/''');

if numArch > 1

    % Loop trhought directory
    for ii = 1 : numArch

        try

            tokens = strsplit(fileList(ii).name,'.');
            
            if ~strcmp(tokens{end}, 'xml') && ~strcmp(tokens{end}, 'XML') 

                updateLog(log, sprintf('The file %s is not a XML camera file', fileList(ii).name), 1);
                noXML = noXML + 1;
                continue;
                
            end
            
            % Open each archive
            fileID = fopen(strcat(path,fileList(ii).name));

            % Read lines
            s = textscan(fileID, '%s', 'delimiter', '\n'); 
            fclose(fileID);
            cell = strcat(s{1});

            for ll = 1 : length(cell)

                line = cell{ll};
                header = line(1:6);

                switch(header)

                    case '<name>'

                        ind = strfind(line, '</name>');

                        cameras(index).model = line(7:ind-1);                   

                    case '<flen>'

                        ind = strfind(line, '</flen>');
                        cameras(index).focallen = str2double(line(7:ind-1));

                    case '<imgh>'

                        ind = strfind(line, '</imgh>');
                        cameras(index).imheight = str2double(line(7:ind-1));

                    case '<imgw>'

                        ind = strfind(line, '</imgw>');
                        cameras(index).imwidth = str2double(line(7:ind-1));

                    case '<senh>'

                        ind = strfind(line, '</senh>');
                        cameras(index).sensorheight = str2double(line(7:ind-1));

                    case '<senw>'

                        ind = strfind(line, '</senw>');
                        cameras(index).sensorwidth = str2double(line(7:ind-1));
                        index = index + 1;

                    otherwise

                        continue;

                end
            end            
            
            status = 1;
            
        catch err

            status = -1;
            updateLog(log, sprintf('------FATAL ERROR------ Something bad happened while reading %s', fileList(ii).name));
            updateLog(log, err.getReport());
            cameras = struct([]);
        end
    end
    
    
    if status == 1
        
        updateLog(log, sprintf('------EVENT------ Found %i cameras in %i archives', index, numArch - noXML));
    end
    
else
   
    updateLog(log, '------FATAL ERROR------ There are no camera files in its folder (./Archives/)');
    cameras = struct([]);
    status = -1;
    
end

end

