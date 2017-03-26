function updateLog( log, strin, multiline )
%updateLog updates the console log in the GridInspector Window.
%   
%%--------------------------------------------------------------------------------------------------   
%   @desc Updates the console log in the GridInspector Window.
%
%%--------------------------------------------------------------------------------------------------   
%   The inputs of this function are:
%
%   - @iparam [graphics handle] log: handle of log console 
%   - @iparam [String] strin: new information to be updated on log 
%   - @iparam [int] multiline: when enabled (1) does not display the trailing '-------' at the end
%   of a log. 
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 13/03/2017
%   ** @version 1.2
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------


if nargin < 2
    
        error('Not enough input arguments. Type "help updateLog" in the command prompt for more info about function usage.');
        
elseif nargin > 3
    
        error('Too many input arguments. Type "help updateLog" in the command prompt for more info about function usage.');
            
elseif nargin == 2
    
    multiline = 0;
        
end

str = get(log, 'String');
[rows,cols]=size(str);

strin = sprintf('@%02i%02i%02.0f:   %s',hour(now), minute(now), second(now), strin);
if strfind(strin, 'FATAL ERROR')
    
    strin = strcat('<HTML><FONT color="orange"><b>',strin,'</b></FONT></HTML>');
    strin = strrep(strin, ' ', '&nbsp;'); 
    
elseif strfind(strin, 'EVENT')
    
    strin = strcat('<HTML><FONT color="#00FF00" ><b>',strin,'</b></FONT></HTML>');
    strin = strrep(strin, ' ', '&nbsp;'); 
    
elseif strfind(strin, 'WARNING')
    
    strin = strcat('<HTML><FONT color="#FFFF00"><b>',strin,'</b></FONT></HTML>');
    strin = strrep(strin, ' ', '&nbsp;'); 
    
elseif strfind(strin, '--DATA--')
        
    strin = strcat('<HTML><FONT color="#FF00FF"><b>',strin,'</b></FONT></HTML>');
    strin = strrep(strin, ' ', '&nbsp;');
else
        
    strin = strcat('<HTML>',strin,'</HTML>');
    strin = strrep(strin, ' ', '&nbsp;'); 

end
if isempty(str)

    switch(multiline)
        
        case 1 
            
            strout(1) = {strin};

        otherwise
            
            strout(1) = {strin};
            strout(2) = {''};
    end

else
    
    strout = cell(1,rows);
    for ii=1:rows

        strout(ii) = str(ii,1:cols);  

    end

   switch(multiline)
       
       case 1
        
           strout(end+1) = {strin};

       otherwise
           
           strout(end+1) = {strin};
           strout(end+1) = {''};
   end
    
   strout=textwrap(log,strout);
end

set(log,'String',strout);

len = length(get(log, 'String'));

set(log, 'Value', len);
set(log, 'ListboxTop', len);


end

