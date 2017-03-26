function [ results ] = onComputeClick( log, display, inputs, polygon, camerasSet )
%onComputeClick executes the callback for the compute button in the GridInspector GUI.
%
%%--------------------------------------------------------------------------------------------------
%   @desc this function serves as a suite of oerations which both computes a grid over a
%   polygon specified by its vertices and the flight params derived from the selected
%   camera payload and is used to display the results of that calculations.
%
%%--------------------------------------------------------------------------------------------------
%  The inputs of this function are:
%   
%   - @iparam [graphics handle] log: handle of log console 
%   - @iparam [struct] display: handles to graphical elements in the GUI
%       -> [graphics handle] plot
%       -> [graphics handle] checkButtons: buttons used to modifi the visualization on the
%       -> GUI
%   - @iparam [float] polygon: vector with the polygon to be analized
%   - @iparam [struct] camerasSet: structure containing all available cameras
%   
%%--------------------------------------------------------------------------------------------------
%   The output for this function is:
%
%   - @oparam [struct] results: structure containing the obtained results:
%       -> [struct] photoParams: it is a struct that contains the following:
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
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 14/03/2017
%   ** @version 1.2
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------
[inputs, statusParse] = parseInputs(log, inputs, camerasSet);


if statusParse == 1
   
    % Do computing stuff
    
    % First get UTM coordinates.
    
    [x, y, Zone, Band] = geoToUTM(polygon(1,:), polygon(2,:));
    
    updateLog(log, '[1] Projectiong into UTM coordinates', 1);
    
    polygon(1,:) = x;
    polygon(2,:) = y;
    
    
    % Then, camera parameters
    
    updateLog(log, '[2] Obtaining photogrametry flight params', 1);
    
    [ photoParams ] = getFlightPhotoParams( camerasSet(inputs.selCamera), inputs.cameraPos, ...
        inputs.detSize, inputs.nPx, inputs.overlap, inputs.sidelap);

    % Now, compute the grid
    
    updateLog(log, '[3] Grid computations beginning', 1);
    
    cryteria = 'MinD';
    
    switch(inputs.startPos)
        
        case 1
            start = 'TopRight';
            
        case 2
            start = 'TopLeft';
        
        case 3
            start = 'BottomRight';
        
        case 4
            start = 'BottomLeft';
    end

    
    try
        
    [ Grid, flagComp, outerBox, PolyBounds ] = computeGrid( polygon, photoParams, start, cryteria );
    
    updateLog(log, '[4] Grid computations finished', 0);
    
    catch
        
        flagComp = -1;
        Grid = struct([]);
        outerBox = struct([]);
        PolyBounds = struct([]);
        
    end
    
end

% If computing stuff OK, do displayingStuff
switch(flagComp)
    
    case -1
    
        results = struct([]);
        updateLog(log,'',0)
        updateLog(log, '------FATAL ERROR------ Some parameters lead to incoherent grid formulation (grid does not intersect with polygon), please check sidelap and/or detection size and or starting position', 0);
        ok = 0;
    
    case 0
    
        results = struct([]);
        updateLog(log,'',0)
        updateLog(log, '------FATAL ERROR------ Sidelap value is not enough to cover all the polygon area, please try with another value', 0);    
        ok = 0;

    case 1
    
        updateLog(log, '------EVENT------ Grid OK!', 0);  
        ok = 1;
        
    case 2
        
        updateLog(log, '------WARNING------ Grid checks not succeeded, area might not be 100 % covered', 0);  
        
        ok = 1;
        
    otherwise
                     
        results = struct([]);
        updateLog(log,'',0)
        updateLog(log, '------FATAL ERROR------ Unknown error in computeGrid. Please contact with support for more info', 0);
        ok = 0;
        
        
end
        
 if ok == 1                            

        updateLog(log, sprintf('--DATA--> Flight Altitude: %2.2f [m]', photoParams.flyAlt), 1);
        updateLog(log, sprintf('--DATA--> Flight Distance: %2.2f [m]', Grid.distanceOverPath), 1);
        updateLog(log, sprintf('--DATA--> Area of the polygon: %2.2f [m^2]', Grid.area), 1);
        updateLog(log, sprintf('--DATA--> Sidelap: %i [%%]', inputs.sidelap), 1);
        updateLog(log, sprintf('--DATA--> Number of lines: %i', Grid.noStrips), 1);
        updateLog(log, sprintf('--DATA--> Separation between lines: %2.2f [m]', photoParams.A), 1);    
        updateLog(log, sprintf('--DATA--> Image Height (on ground): %2.2f [m]', photoParams.mHeight), 1);
        updateLog(log, sprintf('--DATA--> Image Width (on ground): %2.2f [m]', photoParams.mWidth), 0);



        axes(display.plot) 
        cla(display.plot)
        hold(display.plot,'on');
        axis on

        set(display.plot, 'Color', [0.8 0.8 0.8]);

         display.plot.XMinorGrid = 'on';
         display.plot.YMinorGrid = 'on';

        % Plot the polygon

        updateLog(log, '[5] Displaying Polygon', 1);
        hPoly = plot(PolyBounds.vertex(:,1), PolyBounds.vertex(:,2),'b--*', 'linewidth',3, 'markersize', 10,'Markerfacecolor', 'b');
        hold on
        
        hBBox = plot(PolyBounds.Rectvertex(:,1), PolyBounds.Rectvertex(:,2),'--*','Color', [0.4118 0.5725 1], 'linewidth',3, 'markersize', 10,'Markerfacecolor', [0.4118 0.5725 1]);

        % Plot the final grid

        updateLog(log, '[6] Displaying final grid over polygon', 1);

        hGrid = plot(Grid.Path.x, Grid.Path.y, '-s','Color',[0 0.8 0], 'linewidth', 3, 'Markersize', 10, 'markerfacecolor', [0 0.8 0]);


        % plot the outerBox
        updateLog(log, '[7] Displaying Outer Box', 1);

        hOutBox(1) = line([outerBox.BottomLeft(1) outerBox.BottomRight(1)], [outerBox.BottomLeft(2) ...
            outerBox.BottomRight(2)], 'linewidth', 3, 'Color',[0.0314 0.8118 1.0000], 'LineStyle', '--');             
        
        hold on
        hOutBox(2) = line([outerBox.TopLeft(1) outerBox.TopRight(1)], [outerBox.TopLeft(2) ...
            outerBox.TopRight(2)], 'linewidth', 3, 'Color',[0.0314 0.8118 1.0000], 'LineStyle', '--');

        hOutBox(3) = line([outerBox.BottomLeft(1) outerBox.TopLeft(1)], [outerBox.BottomLeft(2) ...
            outerBox.TopLeft(2)], 'linewidth', 3, 'Color',[0.0314 0.8118 1.0000], 'LineStyle', '--');

        hOutBox(4) = line([outerBox.BottomRight(1) outerBox.TopRight(1)], [outerBox.BottomRight(2) ...
            outerBox.TopRight(2)], 'linewidth', 3, 'Color',[0.0314 0.8118 1.0000], 'LineStyle', '--');

        % Plot the outer grid Waypoints
        hold on

        updateLog(log, '[8] Displaying Outer Box Grid', 1);
        hGridBox = plot(outerBox.WPaux(:,1), outerBox.WPaux(:,2), '-o', 'Color', [0.4667 0.6745 0.3373], 'linewidth', 2,'MarkerSize',10, 'MarkerFaceColor', [0.4667 0.6745 0.3373]);

        % Plot the start position
       
        updateLog(log, '[9] Displaying Start Position', 0);

        hStart = plot(Grid.Path.x(1), Grid.Path.y(1), 'k-x', 'linewidth', 3, 'Markersize', 10, 'markerfacecolor', 'k');

        xlabel('Easting [m]');
        ylabel('Northing [m]');

        legend([hPoly hBBox hGrid hOutBox(1) hGridBox hStart ],'Polygon', 'Polgon Bounding Box', 'Grid over polygon','Outer Box', ...
            'Grid over outer Box', 'Start position', 'Location', 'SouthEast');

        legend HIDE

        hold off
        hold(display.plot,'off')

        set(display.pol,'Value',1);
        set(display.bbox,'Value',1);
        set(display.grid,'Value',1);
        set(display.obox,'Value',1);
        set(display.ogrid,'Value',1);
        set(display.start,'Value',1);


        results.photoParams = photoParams;
        results.Grid = Grid;
        results.PolyBounds = PolyBounds;
        results.outerBox = outerBox;
        results.Zone = Zone(1);
        results.Band = Band(1);

        handGraphics.hOutBox = hOutBox;
        handGraphics.hPoly = hPoly;
        handGraphics.hBBox = hBBox;
        handGraphics.hGridBox = hGridBox;
        handGraphics.hGrid = hGrid;
        handGraphics.hStart = hStart;

        results.handGraphics = handGraphics;
        
   
end
end

