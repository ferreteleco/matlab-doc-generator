function [ X, Y ] = newPos( x0, y0, bearing, dist, mode )
%newPos gives the solution to the direct geodesic problem.
%   
%%--------------------------------------------------------------------------------------------------
%   @desc Computes destination given initial coordinates, bearing to destination and distance to
%   destination using the solution for the direct geodesic problem.
%
%   The default datum used for calculations is the WGS-84 but support for more datums
%   could be developed in future releases.
%
%   Supports the use of vectors in x and y coordinates, either geographical and UTM.
% 
%   If Vincenty formula fails to converge, then a warning is displayed and the value is
%   trapped to the one of the Haversine formula.
%
%%--------------------------------------------------------------------------------------------------
%   @ref http://www.movable-type.co.uk/scripts/latlong.html
%   @ref http://www.movable-type.co.uk/scripts/latlong-vincenty.html
%
%%--------------------------------------------------------------------------------------------------
%   The inputs of this function are:
%   
%   - @iparam [float] x0: initial latitude or Northing {deg. or m}
%   - @iparam [float] y0: initial longitude or Easting {deg. or m}
%   - @iparam [float] bearing: bearing or easting in decimal degrees or meters {deg. or m}
%   - @iparam [float] dist: distance to destination or northing in meters {deg. or m}
%   
%   - @iparam [String] mode: string that specifies the coordinates to be used in the
%   calculations. (Optional) Values:
%       -> 'GeoUTM': UTM Coordinates with bearing in degrees and distance in meters
%       (default)
%       -> 'UTM': UTM coordinates with easting and northing to destination
%       -> 'Geo': Geographical coordinates
%       -> 'Vin': Vincenty solution to direct problem
%
%%--------------------------------------------------------------------------------------------------
%   The putputs of this function are:
%   
%   - @oparam [float] X: Destination longitude or Easting {deg. or m}
%   - @oparam [float] Y: Destination latitude or Northing {deg. or m}
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 20/02/2017
%   ** @version 1.4
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------

% DATUM PARAMETERS (WGS-84)
%%%%%%%%%%%%%%%%%%%%%%%%%%%
MAJOR_SEMIAXIS = 6378137.000;                                         % Major semiaxis  
MINOR_SEMIAXIS = 6.356752314245179e+06;
FLATTENING = 1 / 298.257223563;                                       % Flattening  


MEAN_RADIUS = 6.371008771415059e+06;                                  % mean Earth Radius [m]

flag = 0;

if nargin < 4
    
        error('Not enough input arguments. Type "help newPos" in the command prompt for more info about function usage.');
        
elseif nargin > 5
    
            error('Too many input arguments. Type "help newPos" in the command prompt for more info about function usage.');
            
end

if nargin == 4
    
    mode = 'GeoUTM';
end

switch(mode)
    
    case 'GeoUTM'
        
        degN = 90 - bearing;

        if degN < 0
            degN = degN + 360;
        end

        X = x0 + dist*cosd(degN);
        Y = y0 + dist*sind(degN);

    case 'UTM'
        
        X = x0 + bearing;
        Y = y0 + dist;
        
    case 'Geo'
        
        % CONVERSION TO RADIANS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        lat1rad=y0.*pi./180;
        lon1rad=x0.*pi./180;
        bearingrad = bearing.*pi./180;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        Y = asin( sin(lat1rad).*cos( dist/MEAN_RADIUS ) + cos(lat1rad).*sin( dist/MEAN_RADIUS ).*cos(bearingrad) );
        
        X = mod( lon1rad + atan2( sin(bearingrad).*sin( dist/MEAN_RADIUS ).*cos(lat1rad), ...
            cos( dist/MEAN_RADIUS ) - sin(lat1rad).*sin(Y) ) + 3*pi,2*pi) - pi; 
        
        X = 180.*X./pi;
        Y = 180.*Y./pi;
        
     
    case 'Vin'
        
        
         % CONVERSION TO RADIANS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        lat1rad=y0.*pi./180;
        lon1rad=x0.*pi./180;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % PRELIMINARY CALCULATIONS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        tanU1 = (1 - FLATTENING).*tan(lat1rad);
        
        cosal1 = cosd(bearing);
        sinal1 = sind(bearing);
        
        
        cosU1 = 1./( sqrt( 1 + tanU1.^2 ) );
        
        sinU1 = tanU1.*cosU1;

        
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        sig1 = atan2(tanU1, cosal1);
        sinal = cosU1.*sinal1;
        
        cosqual = 1 - sinal.^2;
        uSq = cosqual.*(MAJOR_SEMIAXIS.^2 - MINOR_SEMIAXIS.^2)./ (MINOR_SEMIAXIS.^2);
        
        A = 1 + (uSq/16384).*( 4096 + uSq.*( -768.*uSq.*( 320 - 175.*uSq ) ) );
        
        B = (uSq./1024).*( 256 + uSq.*( -128 + uSq.*( 74 - 47.*uSq ) ) );
        
        
       sig = dist./( MINOR_SEMIAXIS.*A );
       sigdag = 0;
       
       iters = 1;
       
       while(sig - sigdag >1e-12  && iters < 200)
           
          
           cos2sigM = cos(2.*sig1 + sig);
           sinsig = sin(sig);
           cosig = cos(sig);
           
           deltasig = B.*sinsig.*( cos2sigM + (B./4)*cosig*( -1+2.*cos2sigM.^2 ) - ...
               (B./6).*cos2sigM.*( -3 + 4.*(sinsig.^2).*( -3 + 4.*(cos2sigM.^2) )));
           
           sigdag = sig;
           sig = dist./( MINOR_SEMIAXIS.*A ) + deltasig;
           
           iters = iters + 1;
           
       end
       
       if iters > 200
            
            warning('Vincenty Formula failed to converge');
            
            flag = 1;
            
       else
       
       tmp = sinU1.*sinsig - cosU1.*cosig.*cosal1;
       
       Y = (180/pi).*atan2( sinU1.*cosig + cosU1.*sinsig.*cosal1, (1-FLATTENING).*sqrt( sinal.^2 + tmp.^2 ) );
       C = (FLATTENING/16).*cosqual.*(4 + FLATTENING.*( 4 - 3.*cosqual ) );
       lambda = atan2(sinal1.^2, cosU1.*cosal1 - sinU1.*sinal.*cosal1);
       
       L = lambda - (1 - C).*FLATTENING.*sinal.*( sig + C.*sinsig.*( cos2sigM + C.*cosig.*( -1 + 2*cos2sigM.^2 ) ) );
        
       X = (180/pi).*(mod((lon1rad + L + 3.*pi), 2.*pi) - pi);
       
       al2 = atan2(sinal, -tmp);
       
       end
    otherwise
        
        error('Unrecognized computation method. Type "help newPos" in the command prompt for more info about function usage');
end

% TRAP WHEN VINCENTY METHOD FAILS TO CONVERGE


if flag == 1

        % CONVERSION TO RADIANS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        lat1rad=y0.*pi./180;
        lon1rad=x0.*pi./180;
        bearingrad = bearing.*pi./180;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        Y = asin( sin(lat1rad).*cos( dist/MEAN_RADIUS ) + cos(lat1rad).*sin( dist/MEAN_RADIUS ).*cos(bearingrad) );
        
        X = mod( lon1rad + atan2( sin(bearingrad).*sin( dist/MEAN_RADIUS ).*cos(lat1rad), ...
            cos( dist/MEAN_RADIUS ) - sin(lat1rad).*sin(Y) ) + 3*pi,2*pi) - pi; 
        
        X = 180.*X./pi;
        Y = 180.*Y./pi;
    
end

end

