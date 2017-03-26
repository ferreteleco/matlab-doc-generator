function exportKML( log, PathName, FileName, results, openMap )
%exportKML dumps the resulting grid in a kml file.
%   
%%--------------------------------------------------------------------------------------------------  
%   @desc Dumps the resulting grid in a kml file. The location of it is given by the string
%   path, which must be an absolute path to the file.
%
%   The parameters of this function are:
%   
%%--------------------------------------------------------------------------------------------------
%   The inputs for this function are:
%
%   - @iparam [graphics handle] log: handle of log console 
%   - @iparam [String] FileName: name of the file to be written 
%   - @iparam [String] FilePath: name of the path where the file will be written 
%   - @iparam [struct] results: structure containing the obtained results.
%       -> [struct] photoParams: it is a struct that contains the following_
%                       --> [float] cmpixel: centimeters per pixels ratio to be achieved {cm/px}
%                       --> [float] flyAlt: flight altitude in meters {m}
%                       --> [float] B: distance between photographs in meters {m}
%                       --> [float] A: separation between lines in meters {m}
%                       --> [float] mHeight: image height at ground in meters {m}
%                       --> [float] mWidth: image height at ground in meters {m}
%                       --> [float] fovhdeg: height of the field of view in degrees {deg}
%                       --> [float] fovwdeg: width of the field of view in degrees {deg}
%       -> [struct] Grid: structure containing the parameters of the generated grid.
%                       --> [float] area: area of the grid in square meters {m^2}
%                       --> [int]   noStrips: number of strips that covers the polygon
%                       --> [float] distanceOverPath: distance travelled to cover the area of the polygon {m^2}
%                       --> [struct] Path: struct containing the coordinates of the waypoints that define the grid.
%                               ---> [float] x: vector of Eastings of the waypoints in UTM {m}
%                               ---> [float] y: vector of Northings of the waypoints in UTM {m}
%
%       -> [struct] outerBox: structure containing the external bounds used as auxiliary
%       material to compute the grid 
%
%                   --> [float] TopRight: vector of UTM coordinates of the top right corner of the
%                   --> rectangle that circumbscribes the polygon plus more {m}
%
%                   --> [float] TopLeft:  vector of UTM coordinates of the top left corner of the
%                   --> rectangle that circumbscribes the polygon plus more {m}
%
%                   --> [float] BottomRight: vector of UTM coordinates of the bottom right corner of
%                   --> the rectangle that circumbscribes the polygon plus more {m}
%
%                   --> [float] BottomLeft: vector of UTM coordinates of the bottom left corner of the
%                   --> rectangle that circumbscribes the polygon plus more {m}
%
%                   --> [float] Width: width of the rectangle that circumbscribes the polygon plus more {m}
%
%                   --> [float] Height: height of the rectangle that circumbscribes the polygon plus
%                   --> more {m}
%
%                   --> [float] vertex: matrix of vertices of the bounding box plus more {m}
%
%                   --> [float] WPaux: matrix of waypoints of the external grid covering the bounding
%                   --> box plus more {m}
%
%       -> [struct] polyBounds: it is a structure (optional) containing the following fields:
%
%                   --> [float] TopLeft: vector containing the coordinates of the top left corner of
%                   --> the polygon {m} 
%
%                   --> [float] TopRight: vector containing the coordinates of the top right corner of
%                   --> the polygon {m} 
%
%                   --> [float] BottomLeft: vector containing the coordinates of the bottom left corner
%                   --> of the polygon {m} 
%
%                   --> [float] BottomRight: vector containing the coordinates of the bottom right
%                   --> corner of the polygon {m}
%
%                   --> [float] diagDist: diagonal distance of the rectangle circumbscribing the
%                   --> polygon {m} 
%
%                   --> [float] midWidth: half the width of the rectangle circumbscribing the polygon
%                   --> {m}
%
%                   --> [float] midHeight: half the height of the rectangle circumbscribing the polygon
%                   --> {m} 
%
%                   --> [float] vertex: matrix containing the coordinates of the polygon's vertices
%                   --> 'closed' (the last coordinate of the vertices and the first are the same one)
%                   --> {m} 
%
%                   --> [float] Width: width of the rectangle that circumbscribes the polygon {m} 
%
%                   --> [float] Height: height of the rectangle that circumbscribes the polygon {m} 
%
%                   --> [float] Rectvertex: matrix containing the coordinates of the polygon's Bounding
%                   --> Box vertices 'closed' (the last coordinate of the vertices and the first are the
%                   --> same one) {m} 
%
%                   --> [float] polyCenter: centroid of the polygon, vector containing x and y
%                   --> coordinates {m} 
%
%                   --> [float] minAngle: angle of rotation of the polygon of the polygon's vertices
%                   -->(a.c.sorted) {deg}
%       -> [int] Zone: UTM zone
%       -> [char] Band: UTM Band
%   - @oparam [int] openMap: flag enabling atomatic load (1) of the generated kml file in Google
%   Maps  
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 15/03/2017
%   ** @version 1.1
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

if nargin < 5
    
        error('Not enough input arguments. Type "help exportKML" in the command prompt for more info about function usage.');
        
elseif nargin > 5
    
        error('Too many input arguments. Type "help exportKML" in the command prompt for more info about function usage.');
            
end

lineWidth = 6;

path = strcat(PathName,FileName);
updateLog(log, '------EVENT------ Beggining data dump');

try
    
    fileID = fopen(path,'w+');
    % HEADER
    
    fprintf(fileID,'<?xml version="1.0" encoding="utf-8"?>\n');
    fprintf(fileID,'<kml xmlns="http://www.opengis.net/kml/2.2">\n');
    fprintf(fileID,'<Document>\n');
    fprintf(fileID,'<name>%s</name>\n',FileName);
    
    updateLog(log, '[1] HEADER OK!',1);
    
    % Begin with plotting the polygon
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [ latPoly, lonPoly ] = utmToGeo( results.PolyBounds.vertex(:,1), results.PolyBounds.vertex(:,2), results.Zone, results.Band );
    
    fprintf(fileID,'<Folder>\n');
    fprintf(fileID,'<name>Polygon</name>\n');
    fprintf(fileID,'<visibility>1</visibility>\n'); 
         
         
    for ii = 2 : length(latPoly)-1


        fprintf(fileID,'<Placemark>\n');
        fprintf(fileID,'<Snippet maxLines="0"> </Snippet>\n');
        fprintf(fileID,'<description> </description>\n');
        fprintf(fileID,'<name>Face %i</name>\n',ii-1);         % modificar numero segmento
        fprintf(fileID,'<Style>\n');
        fprintf(fileID,'<IconStyle>\n');
        fprintf(fileID,'<color>ffff0000</color>\n');        % modificar color
        fprintf(fileID,'</IconStyle>\n');
        fprintf(fileID, '<LineStyle>\n');
        fprintf(fileID,'<color>ffff0000</color>\n');       % modificar color
        fprintf(fileID,'<width>%i</width>\n',lineWidth);
        fprintf(fileID,'</LineStyle>\n');
        fprintf(fileID,'</Style>\n');
        fprintf(fileID,'<LineString>\n');
        fprintf(fileID,'<extrude>1</extrude>\n');
        fprintf(fileID,'<tessellate>1</tessellate>\n');
        fprintf(fileID,'<altitudeMode>clampToGround</altitudeMode>\n');

        locations='<coordinates>\n';
    
        locations = strcat(locations,sprintf(' %d,%d,%i\n',lonPoly(ii-1), latPoly(ii-1), 0));
        locations = strcat(locations,sprintf(' %d,%d,%i\n',lonPoly(ii), latPoly(ii), 0));
        locations=strcat(locations, '</coordinates>\n');


        fprintf(fileID,locations);
        fprintf(fileID,'</LineString>\n');
        fprintf(fileID,'</Placemark>\n');

    end
        
    fprintf(fileID,'</Folder>\n');   
    
    updateLog(log, '[2] POLYGON OK!',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 % And then, plot the BBox of the polygon
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [ latBB, lonBB ] = utmToGeo( results.PolyBounds.Rectvertex(:,1), results.PolyBounds.Rectvertex(:,2), results.Zone, results.Band );
    
    fprintf(fileID,'<Folder>\n');
    fprintf(fileID,'<name>Bounding Box</name>\n');
    fprintf(fileID,'<visibility>1</visibility>\n'); 
         
         
    for ii = 2 : length(latBB)


        fprintf(fileID,'<Placemark>\n');
        fprintf(fileID,'<Snippet maxLines="0"> </Snippet>\n');
        fprintf(fileID,'<description> </description>\n');
        fprintf(fileID,'<name>Face %i</name>\n',ii-1);         % modificar numero segmento
        fprintf(fileID,'<Style>\n');
        fprintf(fileID,'<IconStyle>\n');
        fprintf(fileID,'<color>ffff0000</color>\n');        % modificar color
        fprintf(fileID,'</IconStyle>\n');
        fprintf(fileID, '<LineStyle>\n');
        fprintf(fileID,'<color>ffff9269</color>\n');       % modificar color
        fprintf(fileID,'<width>%i</width>\n',lineWidth);
        fprintf(fileID,'</LineStyle>\n');
        fprintf(fileID,'</Style>\n');
        fprintf(fileID,'<LineString>\n');
        fprintf(fileID,'<extrude>1</extrude>\n');
        fprintf(fileID,'<tessellate>1</tessellate>\n');
        fprintf(fileID,'<altitudeMode>clampToGround</altitudeMode>\n');

        locations='<coordinates>\n';
    
        locations = strcat(locations,sprintf(' %d,%d,%i\n',lonBB(ii-1), latBB(ii-1), 0));
        locations = strcat(locations,sprintf(' %d,%d,%i\n',lonBB(ii), latBB(ii), 0));
        locations=strcat(locations, '</coordinates>\n');


        fprintf(fileID,locations);
        fprintf(fileID,'</LineString>\n');
        fprintf(fileID,'</Placemark>\n');

    end
        
    fprintf(fileID,'</Folder>\n');   
    
    updateLog(log, '[3] Bounding Box OK!',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 % And now, with Grid over polygon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [ latGrid, lonGrid ] = utmToGeo( results.Grid.Path.x, results.Grid.Path.y, results.Zone, results.Band );
    
    fprintf(fileID,'<Folder>\n');
    fprintf(fileID,'<name>Grid</name>\n');
    fprintf(fileID,'<visibility>1</visibility>\n'); 
         
         
    for ii = 2 : length(latGrid)


        fprintf(fileID,'<Placemark>\n');
        fprintf(fileID,'<Snippet maxLines="0"> </Snippet>\n');
        fprintf(fileID,'<description> </description>\n');
        fprintf(fileID,'<name>Strip %i</name>\n',ii-1);         % modificar numero segmento
        fprintf(fileID,'<Style>\n');
        fprintf(fileID,'<IconStyle>\n');
        fprintf(fileID,'<color>ffff0000</color>\n');        % modificar color
        fprintf(fileID,'</IconStyle>\n');
        fprintf(fileID, '<LineStyle>\n');
        fprintf(fileID,'<color>ff00ff00</color>\n');       % modificar color
        fprintf(fileID,'<width>%i</width>\n',lineWidth);
        fprintf(fileID,'</LineStyle>\n');
        fprintf(fileID,'</Style>\n');
        fprintf(fileID,'<LineString>\n');
        fprintf(fileID,'<extrude>1</extrude>\n');
        fprintf(fileID,'<tessellate>1</tessellate>\n');
        fprintf(fileID,'<altitudeMode>clampToGround</altitudeMode>\n');

        locations='<coordinates>\n';
    
        locations = strcat(locations,sprintf(' %d,%d,%i\n',lonGrid(ii-1), latGrid(ii-1), 0));
        locations = strcat(locations,sprintf(' %d,%d,%i\n',lonGrid(ii), latGrid(ii), 0));
        locations=strcat(locations, '</coordinates>\n');


        fprintf(fileID,locations);
        fprintf(fileID,'</LineString>\n');
        fprintf(fileID,'</Placemark>\n');

    end
        
    fprintf(fileID,'</Folder>\n');   
    
    updateLog(log, '[4] GRID OK!',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Next, the outerBox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [ latBB, lonBB ] = utmToGeo( results.outerBox.vertex(:,1), results.outerBox.vertex(:,2), results.Zone, results.Band );
    
    fprintf(fileID,'<Folder>\n');
    fprintf(fileID,'<name>BBox</name>\n');
    fprintf(fileID,'<visibility>0</visibility>\n'); 
         
         
    for ii = 2 : length(lonBB)


        fprintf(fileID,'<Placemark>\n');
        fprintf(fileID,'<Snippet maxLines="0"> </Snippet>\n');
        fprintf(fileID,'<description> </description>\n');
        fprintf(fileID,'<name>Face %i</name>\n',ii-1);         % modificar numero segmento
        fprintf(fileID,'<visibility>0</visibility>\n'); 
        fprintf(fileID,'<Style>\n');
        fprintf(fileID,'<IconStyle>\n');
        fprintf(fileID,'<color>ffff0000</color>\n');        % modificar color
        fprintf(fileID,'</IconStyle>\n');
        fprintf(fileID, '<LineStyle>\n');
        fprintf(fileID,'<color>ffffcf08</color>\n');       % modificar color
        fprintf(fileID,'<width>%i</width>\n',lineWidth/2);
        fprintf(fileID,'</LineStyle>\n');
        fprintf(fileID,'</Style>\n');
        fprintf(fileID,'<LineString>\n');
        fprintf(fileID,'<extrude>1</extrude>\n');
        fprintf(fileID,'<tessellate>1</tessellate>\n');
        fprintf(fileID,'<altitudeMode>clampToGround</altitudeMode>\n');

        locations='<coordinates>\n';
    
        locations = strcat(locations,sprintf(' %d,%d,%i\n',lonBB(ii-1), latBB(ii-1), 0));
        locations = strcat(locations,sprintf(' %d,%d,%i\n',lonBB(ii), latBB(ii), 0));
        locations=strcat(locations, '</coordinates>\n');


        fprintf(fileID,locations);
        fprintf(fileID,'</LineString>\n');
        fprintf(fileID,'</Placemark>\n');

    end
        
    fprintf(fileID,'</Folder>\n');   
    
    updateLog(log, '[5] OUTER BOX OK!',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Next, the outerBox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [ latOgrid, lonOgrid ] = utmToGeo( results.outerBox.WPaux(:,1), results.outerBox.WPaux(:,2), results.Zone, results.Band );
    
    fprintf(fileID,'<Folder>\n');
    fprintf(fileID,'<name>OuterGrid</name>\n');
    fprintf(fileID,'<visibility>0</visibility>\n'); 
         
         
    for ii = 2 : length(lonOgrid)


        fprintf(fileID,'<Placemark>\n');
        fprintf(fileID,'<Snippet maxLines="0"> </Snippet>\n');
        fprintf(fileID,'<description> </description>\n');
        fprintf(fileID,'<name>Strip %i</name>\n',ii-1);         % modificar numero segmento
        fprintf(fileID,'<visibility>0</visibility>\n'); 
        fprintf(fileID,'<Style>\n');
        fprintf(fileID,'<IconStyle>\n');
        fprintf(fileID,'<color>ffff0000</color>\n');        % modificar color
        fprintf(fileID,'</IconStyle>\n');
        fprintf(fileID, '<LineStyle>\n');
        fprintf(fileID,'<color>ff56ac77</color>\n');       % modificar color        
        fprintf(fileID,'<width>%i</width>\n',lineWidth/2);
        fprintf(fileID,'</LineStyle>\n');
        fprintf(fileID,'</Style>\n');
        fprintf(fileID,'<LineString>\n');
        fprintf(fileID,'<extrude>1</extrude>\n');
        fprintf(fileID,'<tessellate>1</tessellate>\n');
        fprintf(fileID,'<altitudeMode>clampToGround</altitudeMode>\n');

        locations='<coordinates>\n';
    
        locations = strcat(locations,sprintf(' %d,%d,%i\n',lonOgrid(ii-1), latOgrid(ii-1), 0));
        locations = strcat(locations,sprintf(' %d,%d,%i\n',lonOgrid(ii), latOgrid(ii), 0));
        locations=strcat(locations, '</coordinates>\n');


        fprintf(fileID,locations);
        fprintf(fileID,'</LineString>\n');
        fprintf(fileID,'</Placemark>\n');        

    end
        
    fprintf(fileID,'</Folder>\n');   
    
    updateLog(log, '[6] OUTER GRID OK!',1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % At last, print the markers
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf(fileID,'<Folder>\n');
    fprintf(fileID,'<name>Markers</name>\n'); 
    fprintf(fileID,'<visibility>1</visibility>\n'); 

    for mm = 1 :length(latGrid)
        
        fprintf(fileID,'<Placemark>\n');
        fprintf(fileID,'<Snippet maxLines="0"> </Snippet>\n');
                
        if mm == 1
             fprintf(fileID,'<name>Starting Point</name>\n');
          else
             fprintf(fileID,'<name>%i</name>\n',mm-1);         
        end
        
        fprintf(fileID,'<Style>\n');
        fprintf(fileID,'<IconStyle>\n');
        
        fprintf(fileID,'<Icon><href></href></Icon>\n');        % Custom icon here
        fprintf(fileID,'<scale>1</scale>\n');
        fprintf(fileID,'<color>ff000000</color>\n');  
        
        fprintf(fileID,'</IconStyle>\n');
        fprintf(fileID,'</Style>\n');
        
        fprintf(fileID,'<Point>\n');
        
        locations = '<coordinates>\n';
        locations = strcat(locations,sprintf(' %d,%d,%i\n',lonGrid(mm), latGrid(mm), 0));
        locations=strcat(locations, '</coordinates>\n');


        fprintf(fileID,locations);
        fprintf(fileID,'</Point>\n');
        fprintf(fileID,'</Placemark>\n');
        
    end     
         
    fprintf(fileID,'</Folder>\n');        
    
    updateLog(log, '[7] MARKERS OK!',1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         
         
    fprintf(fileID,'</Document>\n');
    fprintf(fileID,'</kml>\n');
                 
    fclose(fileID);
  
    updateLog(log, sprintf('File dumped to: %s', path));
    
    updateLog(log, '------EVENT------ Grid export process finished OK!',0);
    
         
    if openMap == 1

        updateLog(log, '------EVENT------ Opening generated file in Google Earth!',0);
        winopen(path); 
        
    end
    
catch err
    
     if fileID == -1
        
        updateLog(log, strcat('------FATAL ERROR------ ', ferror(fileID)));
    else
        
        fclose(fileID);
        updateLog(log, '------FATAL ERROR------ Something went wrong while writing kml file.', 1);
        updateLog(log, getReport(err), 0);
    end
end

end

