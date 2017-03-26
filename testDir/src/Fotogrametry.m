%   @desc This script is used fot testing ad development of the photogrametry parameters
%   used along the grid computations of gridInspector
%
%%--------------------------------------------------------------------------------------------------
%   @ref https://es.mathworks.com/help/matlab/script-based-unit-tests.html
%
%%--------------------------------------------------------------------------------------------------
%   @author Andres Ferreiro Gonzalez (@aferreiro)
%   @company Galician Research and Development Center in Advanced Telecommunications (GRADIANT)
%   @date 20/02/17
%   @version 1.0
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------
clear all
close all
clc

fprintf('\n********************************************************************************\n');
fprintf('***************************SCRIPT Fotogrametría Test****************************\n');
fprintf('********************************************************************************\n');


% Selector de cámara, 0 = vertical, 1 = horizontal
camara = 1;

focallen = 5;                                      % distancia focal [mm]
imgwidth = 4608;                                   % anchura de la imagen [píxels]
imgheight = 3456;                                  % altura de la imagen [píxels]


sensorw = 6.16;                                    % ancho del sensor [mm]
sensorh = 4.62;                                    % alto del sensor [mm]


% Solapamiento [%]
overlap = 80;                                   % de frente
sidelap = 40;                                   % lateral

flyalt = 30;                                       % altura de vuelo [m]


flscale = (1000 * flyalt) / focallen;               % escala [mm / mm]


fprintf('\n--------------------------------------------------------------------------------\n');
fprintf('---> Scale: %2.2f [mm/mm]\n', flscale);
fprintf('--------------------------------------------------------------------------------\n');

% Footprint (FOV) [m]
viewwidth = (sensorw * flscale / 1000);
viewheight = (sensorh * flscale / 1000);

fprintf('---> Footprint width: %2.2f [m]\n', viewwidth);
fprintf('--------------------------------------------------------------------------------\n');
fprintf('---> Footprint height: %2.2f [m]\n', viewheight);
fprintf('--------------------------------------------------------------------------------\n');

% Footprint (FOV) [deg.]

fovh = 2*atan2d(sensorw,(2 * focallen));

fovv = 2*atan2d(sensorh, (2 * focallen));

fprintf('---> Footprint width: %2.2f [degrees]\n', fovh);
fprintf('--------------------------------------------------------------------------------\n');
fprintf('---> Footprint height: %2.2f [degrees]\n', fovv);
fprintf('--------------------------------------------------------------------------------\n');

% Centímetros por píxel en ancho y en alto
cmpixelh = ((viewheight/imgheight)*100);              % centímetros por píxel [cm/píxel]
cmpixelw = ((viewwidth/imgwidth)*100);

fprintf('---> Centimeters per píxel: %2.2f [cm/píxel]\n', cmpixelh);
fprintf('--------------------------------------------------------------------------------\n');

% Centímetros cuadrados por píxel

cm2 = cmpixelh*cmpixelw;

fprintf('---> Square centimeters per píxel: %2.2f [cm^2/píxel]\n', cm2);
fprintf('--------------------------------------------------------------------------------\n');


if camara == 0     

    spacing = ((1 - (overlap / 100)) * viewheight);
    distance = ((1 - (sidelap / 100)) * viewwidth);
else
    
    spacing = ((1 - (overlap / 100)) * viewwidth);
    distance = ((1 - (sidelap / 100)) * viewheight);
end

fprintf('---> Distance between images: %2.2f [m]\n', spacing);
fprintf('--------------------------------------------------------------------------------\n');
fprintf('---> Distance between lines: %2.2f [m]\n', distance);
fprintf('--------------------------------------------------------------------------------\n');
 
 %@todo 
 % - seleccionar las coordenadas TM apropiadas en base a la lat, long 
 % - calcular número de fotos, número de pasadas, tiempo de vuelo y distancia recorrida
 % - calcular intervalo de tiempo entre fotos
 % - implementar pruebas sobre esto

