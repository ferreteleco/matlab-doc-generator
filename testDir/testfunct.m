function [param1, param2, paramn] = testfunct(in1, in2, in3)
%testfunctn Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
%eiusmod tempor incididunt ut labore et dolore magna aliqua.
%%-------------------------------------------------------------------------------------
%   @desc Ut enim ad minim veniam, quis nostrud exercitation ullamco
%   laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in
%   reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
%%-------------------------------------------------------------------------------------
%   @ref http://www.google.com
%   @ref http://www.github.com
%%-------------------------------------------------------------------------------------
%   - Inputs
%     @iparam [type] in1 description of param 1
%     @iparam [type] in2 description of param 2, much longer than previous one so it
%     has to be wrapped
%     @iparam [type] in3 description of param 3
%%-------------------------------------------------------------------------------------
%   - Outputs
%     @oparam [type] out1 description of param 1
%     @oparam [type] out2 description of param 2, much longer than previous one so it
%     has to be wrapped
%%-------------------------------------------------------------------------------------
%   @author Andres Ferreiro
%   @company Galician Research and Development Center in Advanced Telecommunications
%   @date 17/03/17
%   @version 1.0
%%-------------------------------------------------------------------------------------
%%%------------------------------------------------------------------------------------

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