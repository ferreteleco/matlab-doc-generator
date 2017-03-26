function dumpToFile( log )
%dumpToFile dumps the console log into a .txt file.
% 
%%--------------------------------------------------------------------------------------------------   
%   @desc Dumps the console log into a .txt file. The location of it it's the folder
%   './Logs/' and the name of the saved log is the timestamp of it.
%
%   If folder doesn't exist, it creates it.
%
%%--------------------------------------------------------------------------------------------------  
%   The inputs for this function are:
%   
%   - @iparam [graphics handle] log: handle of log console 
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 15/03/2017
%   ** @version 1.1
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

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

