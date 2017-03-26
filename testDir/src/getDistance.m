function [ d ] = getDistance(Y0, X0, Y1, X1, method)
%getDistance returns the distance between two locations in the suface of the Earth.
%   
%%--------------------------------------------------------------------------------------------------
%   @desc This function computes the distance between two locations in the suface of the Earth.
%   
%   The default datum used for calculations is the WGS-84 but support for more datums
%   could be developed in future releases.
%   
%   Both UTM and geographical coordinates could be used, taking into account that in UTM
%   case, both locations shall be in the same UTM Zone, in order to avoid lacks in the accuracy.
%   
%   Supports the use of vectors in the input coordinates, both UTM and geographical.
%   
%   Vincenty method gives more precise results but may fail to converge in the case of
%   antipodal points and also in random pairs of points.
%
%   If Vincenty formula fails to converge, then a warning is displayed and the value is
%   trapped to the one of the Haversine formula.
%   
%%--------------------------------------------------------------------------------------------------
%   @ref http://www.movable-type.co.uk/scripts/latlong.html
%   @ref http://www.movable-type.co.uk/scripts/latlong-vincenty.html
%   @ref http://www.movable-type.co.uk/scripts/latlong.html
%
%%--------------------------------------------------------------------------------------------------
%   The inputs for this function are:
%   
%   - @iparam [float] Y0: initial latitude or Northing {deg. or m}
%   - @iparam [float] X0: initial longitude or Easting {deg. or m}
%   - @iparam [float] Y1: final latitude or Northing {deg. or m}
%   - @iparam [float] X1: final longitude or Easting {deg. or m}
%   
%   - @iparam [String] method: string that defines the method to be used in the calculations
%       -> 'Hav: Haversine distance (only for Geo) (Default)  
%       -> 'Vin': Vincenty distance (only for Geo)
%       -> 'Pyt': Pythagarus distance (only for UTM)
%       -> 'Rh': Rhumb lines distance (only for Geo)
%       -> 'Hav2': Haversine distance computed by an aproximation of the Vincenty formula
%       -> that is accurate for all locations (only for Geo)      
%   
%%--------------------------------------------------------------------------------------------------
%   The output of this function is:
%
%   - @oparam [float] d: distance between locations in meters {m}
%
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 16/02/2017
%   ** @version 1.2
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------


% DATUM PARAMETERS (WGS-84)
%%%%%%%%%%%%%%%%%%%%%%%%%%%
MAJOR_SEMIAXIS = 6378137.000;                                         % Major semiaxis  
MINOR_SEMIAXIS = 6.356752314245179e+06;
FLATTENING = 1 / 298.257223563;                                       % Flattening  


MEAN_RADIUS = 6.371008771415059e+06;                                  % mean Earth Radius [m]

%%%%%%%%%%%%%%%%%%%%%%%%%%%

flag = 0;


if nargin < 4
    
        error('Not enough input arguments. Type "help getDistance" in the command prompt for more info about function usage.');
        
elseif nargin > 5
    
        error('Too many input arguments. Type "help getDistance" in the command prompt for more info about function usage.');
            
            
end


if nargin == 4
    
    method = 'Hav';
end

switch(method)
    
    case 'Hav'
        
        % CONVERSION TO RADIANS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        lat1rad=Y0.*pi./180;
        lat2rad=Y1.*pi./180;
        lon1rad=X0.*pi./180;
        lon2rad=X1.*pi./180;

        deltaLat=lat2rad-lat1rad;
        deltaLon=lon2rad-lon1rad;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % HAVERSINE DISTANCE COMPUTATION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%       
        ds = 2*asin(sqrt( sin( (deltaLat)./2 ).^2 + cos(lat1rad).*cos(lat2rad).*sin( deltaLon./2 ).^2));
       
        d = MEAN_RADIUS.*ds;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
    case 'Hav2'
        
        % CONVERSION TO RADIANS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        lat1rad=Y0.*pi./180;
        lat2rad=Y1.*pi./180;
        lon1rad=X0.*pi./180;
        lon2rad=X1.*pi./180;

        deltaLat=lat2rad-lat1rad;
        deltaLon=lon2rad-lon1rad;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        a = sqrt( ( cos(lat2rad).*sin(deltaLon) ).^2 + ( cos(lat1rad).*sin(lat2rad) - sin(lat1rad).*cos(lat2rad).*cos(deltaLon) ).^2 );
        b = sin(lat1rad).*sin(lat2rad) + cos(lat1rad).*cos(lat2rad).*cos(deltaLon);
        
        ds = atan2(a,b);
        
        d = MEAN_RADIUS.*ds;
        
        
    case 'Vin'
        
        % CONVERSION TO RADIANS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        lat1rad=Y0.*pi./180;
        lat2rad=Y1.*pi./180;
        lon1rad=X0.*pi./180;
        lon2rad=X1.*pi./180;

        deltaLat=lat2rad-lat1rad;
        deltaLon=lon2rad-lon1rad;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % PRELIMINARY CALCULATIONS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        tanU1 = (1 - FLATTENING).*tan(lat1rad);
        tanU2 = (1 - FLATTENING).*tan(lat2rad);
        
        
        cosU1 = 1./( sqrt( 1 + tanU1.^2 ) );
        cosU2 = 1./( sqrt( 1 + tanU2.^2 ) );
        
        sinU1 = tanU1.*cosU1;
        sinU2 = tanU2.*cosU2;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % ITERATIVE PROCESS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        lamb = deltaLon;                            % Initial approximation
        lambit =  500;                              % intitial iterator
        itLimit = 100;                              % Iteration limit
        
        
        while( abs(lamb - lambit) > 1e-12 && itLimit > 0)
            
            sinl = sin(lamb);
            cosl = cos(lamb);
            
            sinsig = sqrt( ( cosU2.*sinl ).^2 + ( cosU1.*sinU2 - sinU1.*cosU2.*cosl).^2 );
            
            if sinsig == 0
                
                error('The points to evaluate are the same!');
                
            end
            
            cosig = ( sinU1.*sinU2 ) + ( cosU1.*cosU2.*cosl );
            sig = atan2(sinsig, cosig);
            
            sinal = cosU1.*cosU2.*sinl./sinsig;
            
            cosinsq = 1 - sinal.*2;
            cos2sig = cosig - 2.*sinU1*sinU2./cosinsq;
            
            if isnan(cos2sig) 
                
                cos2sig = 0;
            end
            
            C = (FLATTENING/16).*cosinsq.*(4 + FLATTENING.*( 4 - 3.*cosinsq ) );
            
            lambit = lamb;
            
            lamb = deltaLon + (1 - C).*FLATTENING.*sinal.*( sig + C.*sinsig.*( cos2sig + C.*cosig.*( -1 + 2*cos2sig.^2 ) ) );
            
            itLimit = itLimit - 1;          
            
        end
        
        
        if itLimit == 0
            
            warning('Vincenty Formula failed to converge');
            
            flag = 1;
            
        else
        
        uSq = cosinsq.*( MAJOR_SEMIAXIS^2 - MINOR_SEMIAXIS^2)./( MINOR_SEMIAXIS^2 );
        
        A = 1 + (uSq/16384).*( 4096 + uSq.*( -768.*uSq.*( 320 - 175.*uSq ) ) );
        
        B = (uSq./1024).*( 256 + uSq.*( -128 + uSq.*( 74 - 47.*uSq ) ) );
        
        dsig = B.*sinsig.*( cos2sig +(B./4).*(cosig.*( -1 + 2.*cos2sig.^2 ) - (B./6).*cos2sig.*( -3 + 4.*sinsig.^2 ).*( -3 + 4.*cos2sig.^2 ) ) );
        
        d = MINOR_SEMIAXIS.*A.*( sig - dsig );
        
        end
        
    case 'Pyt'
        
        d = sqrt( ( X1 - X0 ).^2 + ( Y1 - Y0 ).^2 );
        
    case 'Rh'
        
        % CONVERSION TO RADIANS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        lat1rad=Y0.*pi./180;
        lat2rad=Y1.*pi./180;
        lon1rad=X0.*pi./180;
        lon2rad=X1.*pi./180;

        deltaLat=lat2rad-lat1rad;
        deltaLon=lon2rad-lon1rad;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        dPhi = log( tan( pi/4 + lat2rad./2 )./tan( pi/4 + lat1rad./2 ) );
        
        if abs(dPhi) > 10e-12
            
            q = deltaLat ./ dPhi;
            
        else
            
            q = cos(lat1rad);
            
        end
        
        if abs(deltaLon) > pi
            
            if deltaLon > 0
                
                deltaLon = -(2*pi - deltaLon);
                
            else
                
                deltaLon = 2.*pi + deltaLon;
            end
        end
        
        delta = sqrt( deltaLat.^2 + (q.^2).*deltaLon.^2 );
        
        d = MEAN_RADIUS.*delta;
        
         
            
    otherwise
        
        error('Unrecognized computation method. Type "help getDistance" in the command prompt for more info about function usage');
        
end    

% TRAP WHEN VINCENTY METHOD FAILS TO CONVERGE


if flag == 1
    
        % CONVERSION TO RADIANS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        lat1rad=Y0.*pi./180;
        lat2rad=Y1.*pi./180;
        lon1rad=X0.*pi./180;
        lon2rad=X1.*pi./180;

        deltaLon=lon2rad-lon1rad;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        a = sqrt( ( cos(lat2rad).*sin(deltaLon) ).^2 + ( cos(lat1rad).*sin(lat2rad) - sin(lat1rad).*cos(lat2rad).*cos(deltaLon) ).^2 );
        b = sin(lat1rad).*sin(lat2rad) + cos(lat1rad).*cos(lat2rad).*cos(deltaLon);
        
        ds = atan2(a,b);
        
        d = MEAN_RADIUS.*ds;
end
            
end

