%   @desc Script used for debugging o the ComputeGrid and getFlightPhotoParams functions
%%--------------------------------------------------------------------------------------------------
%   @author Andres Ferreiro Gonzalez (@aferreiro)
%   @company Galician Research and Development Center in Advanced Telecommunications (GRADIANT)
%   @date 14/03/17
%   @version 1.0
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

clear all
close all
clc

% polygon = [539944.015 539859.175 539859.423 539943.445; 4687039.714 4687039.664 4687101.704 4687102.237];
% polygon = [539859.168 539935.677 539971.455 539924.661 ; 4687039.661 4687029.326 4687035.254 4687101.229 ];
polygon = [533439.931 535154.159 538452.027 540741.769 540967.782 538125.585; ...
    4693510.197 4694831.204 4691632.382 4691591.817 4689308.522 4689281.51];
% % 
% polygon = [539193.654490281	539634.708703415 540803.934315498 540299.808344306;...
%     4687267.55544982 4686797.99921270 4687593.76861077 4687960.69257814];

flag = 0;

% 1. DEFINE CAMERA PARAMETERS AS A STRUCT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
camera = struct('model', 'Nikon aw100', 'focallen', 5, 'imwidth', 4608, 'imheight', 3456, ...
    'sensorwidth', 6.16, 'sensorheight', 4.62);


% 2. DEFINE ADDITIONAL MISSION PARAMETERS RELATED WITH PHOTOGRAMETRY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
overlap = 60;                                           % Overlap between consecutive photos [%]
sidelapIter = 25;                                  % Overlap between strips [%]

% Position of the camera in the RPAS, Landscape or Portrait
cameraPos = struct('Landscape', 1, 'Portrait', 2);

detSize = 40 ;             % Size of object to be detected [cm]
nPx = 2;                    % Number of Píxels to allow detection

dprev = 1e24;

for ll = 1 : length(sidelapIter)

% 3. COMPUTE PHOTOGRAMETRY PARAMETERS PRIOR TO FLIGHT PLANNING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ photoParamsIter ] = getFlightPhotoParams( camera, cameraPos.Landscape, detSize, nPx, overlap, sidelapIter(ll));


% 4. COMPUTE THE ROUTE THAT COVERS THE AREA OF INTEREST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

StartPos = 'BottomRight';
% cryteria = 'Pol';
cryteria = 'MinD';

[ GridIter, flagIter, outerBoxIter, PolyBoundsIter ] = computeGrid( polygon, photoParamsIter, StartPos, cryteria );

dnext = GridIter.distanceOverPath;


if flagIter && dnext <= dprev
    
    photoParams = photoParamsIter;
    Grid = GridIter;
    outerBox = outerBoxIter;
    PolyBounds =PolyBoundsIter;
    dprev = dnext;
    sidelap = sidelapIter(ll);
    flag = 1;

end

end

if flag == 1
    
    
    % 5. SHOW RESULTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % plot the outer grid

    figure()                                           % Create new figure

    h = line([outerBox.BottomLeft(1) outerBox.BottomRight(1)], [outerBox.BottomLeft(2) ...
        outerBox.BottomRight(2)], 'linewidth', 3, 'Color','g', 'LineStyle', '--');

    hold on
    line([outerBox.TopLeft(1) outerBox.TopRight(1)], [outerBox.TopLeft(2) ...
        outerBox.TopRight(2)], 'linewidth', 3, 'Color','g', 'LineStyle', '--');

    line([outerBox.BottomLeft(1) outerBox.TopLeft(1)], [outerBox.BottomLeft(2) ...
        outerBox.TopLeft(2)], 'linewidth', 3, 'Color','g', 'LineStyle', '--');

    line([outerBox.BottomRight(1) outerBox.TopRight(1)], [outerBox.BottomRight(2) ...
        outerBox.TopRight(2)], 'linewidth', 3, 'Color','g', 'LineStyle', '--');

    grid minor

    % Plot the polygon

    plot(PolyBounds.vertex(:,1), PolyBounds.vertex(:,2),'b--*', 'linewidth',3, 'markersize', 10,'Markerfacecolor', 'b');

    % Plot the outer grid Waypoints
    hold on

    plot(outerBox.WPaux(:,1), outerBox.WPaux(:,2), 'm-o', 'linewidth', 2,'MarkerSize',10, 'MarkerFaceColor', 'm')
    plot(outerBox.WPaux(1,1), outerBox.WPaux(1,2), 'k-x', 'linewidth', 2,'MarkerSize',10, 'MarkerFaceColor', 'k')
    
    
     line([PolyBounds.BottomLeft(1) PolyBounds.BottomRight(1)], [PolyBounds.BottomLeft(2) ...
        PolyBounds.BottomRight(2)], 'linewidth', 3, 'Color','c', 'LineStyle', '--');

    hold on
    line([PolyBounds.TopLeft(1) PolyBounds.TopRight(1)], [PolyBounds.TopLeft(2) ...
        PolyBounds.TopRight(2)], 'linewidth', 3, 'Color','c', 'LineStyle', '--');

    line([PolyBounds.BottomLeft(1) PolyBounds.TopLeft(1)], [PolyBounds.BottomLeft(2) ...
        PolyBounds.TopLeft(2)], 'linewidth', 3, 'Color','c', 'LineStyle', '--');

    line([PolyBounds.BottomRight(1) PolyBounds.TopRight(1)], [PolyBounds.BottomRight(2) ...
        PolyBounds.TopRight(2)], 'linewidth', 3, 'Color','c', 'LineStyle', '--');
    

    % Plot the final grid

    plot(Grid.Path.x, Grid.Path.y, 'r-s', 'linewidth', 3, 'Markersize', 10, 'markerfacecolor', 'r');
    plot(Grid.Path.x(1), Grid.Path.y(1), 'k-x', 'linewidth', 3, 'Markersize', 10, 'markerfacecolor', 'k');



    fprintf('\n--------------------------------------------------------------------------------\n');
    fprintf('---> Flight Altitude: %2.2f [m]\n', photoParamsIter.flyAlt);
    fprintf('--------------------------------------------------------------------------------\n');

    fprintf('\n--------------------------------------------------------------------------------\n');
    fprintf('---> Covered Area: %2.2f [m^2]\n', Grid.area);
    fprintf('--------------------------------------------------------------------------------\n');

    fprintf('\n--------------------------------------------------------------------------------\n');
    fprintf('---> Distance: %2.2f [m]\n', Grid.distanceOverPath);
    fprintf('--------------------------------------------------------------------------------\n');
    
    fprintf('\n--------------------------------------------------------------------------------\n');
    fprintf('---> Sidelap used for minumum distance travelling: %2.2f [%%]\n', sidelap);
    fprintf('--------------------------------------------------------------------------------\n');
    
else 
    
    % Bad, shouldn't happen
    string = 'Please consider the following:';
    string1 = sprintf('Error: \n - Try again in a while.\n - Change detection size and / or detection pixels. \n - Modify the polygon that defines the survey area.');
    
    error('Something went very very wrong while computing grid.\n%s\n%s', string, string1);
    
end
    


