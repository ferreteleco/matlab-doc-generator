function [ lat, lon ] = utmToGeo( X, Y, Zone, Band, aprr )
%utmToGeo transforms the input UTM projection to its geographical coordinates.
%   
%%--------------------------------------------------------------------------------------------------   
%   @desc Transforms the input UTM projection (needed zone and band) to its geographical coordinates.
%   
%   The default datum used for calculations is the WGS-84 but support for more datums
%   could be developed in future releases.
%   
%   The bounds for the UTM projection are +-180 degrees in longitude and +-84 degrees in
%   latitude.
%   
%   Supports the use of vectors in the parameters X and Y, but both UTM Zone and Band have
%   to be the same for all the coordinates.
%   
%%--------------------------------------------------------------------------------------------------   
%   The inputs of this function are:
%   
%   - @iparam [float] X: UTM Easting {m}
%   - @iparam [float] Y: UTM Northing {m}
%   - @iparam [int] Zone: Zone of the UTM Projection (1 to 60)
%   - @iparam [char] Band: Band of the  UTM Projection (C to X)
%
%   - @iparam [String] aprr: string that defines the form of expansion of the meridian on the
%   ellipsoid. (Optional) Values:
%       -> 'Kraw': Krakiwsky approximation (default)
%       -> 'Hinks': Hinks approximation
%       -> 'Helm': Helmert approximation
%   
%%--------------------------------------------------------------------------------------------------
%   The outputs of this function are:
%   
%   - @oparam [float] lat: latitude obtained {deg}
%   - @oparam [float] lon: longitude obtained {deg}
% 
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 16/02/2017
%   ** @version 1.1
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------


% UTM BOUNDARIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%
MAX_ZONE = 84;
MIN_ZONE = -80;
BAND = 'CDEFGHJKLMNPQRSTUVWX';


% UTM CORRECTION VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%
SCALE_FACT = 0.9996;                                                  % UTM Scale Factor
FALSE_EASTING = 500000;                                               % False Easting  
FALSE_NORTHING = 10000000;                                            % False northing  

%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DATUM PARAMETERS (WGS-84)
%%%%%%%%%%%%%%%%%%%%%%%%%%%
MAJOR_SEMIAXIS = 6378137.000;                                         % Major semiaxis  
FLATTENING = 1 / 298.257223563;                                       % Flattening  
ESQ = 1 - ( 1 - FLATTENING )^2;                                       % Eccentricity squared  
N = FLATTENING / (2 - FLATTENING);                                    % Third flattening

%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    
     error('Not enough input arguments. Type "help utmToGeo" in the command prompt for more info about function usage.');
        
elseif nargin > 5
    
     error('Too many input arguments. Type "help utmToGeo" in the command prompt for more info about function usage.');

elseif length(Zone) > 1
    
    error('UTM Zone parameter does not allow vectors. Type "help utmToGeo" in the command prompt for more info about function usage.');
    
elseif length(Band) > 1
    
    error('UTM Band parameter does not allow vectors. Type "help utmToGeo" in the command prompt for more info about function usage.');
  
elseif ((Zone) < MIN_ZONE || (Zone) > MAX_ZONE)
    
    error('UTM Zone value out of bounds. Type "help utmToGeo" in the command prompt for more info about function usage.');

elseif isempty(find(BAND == Band, 1))
    
    error('UTM Band value out of bounds. Type "help utmToGeo" in the command prompt for more info about function usage.');
    
end


% COMPENSATE FOR FALSE NORTHING AND EASTING
%%%%%%%%%%%%%%%%%%%%%%%%%%%
X = X - FALSE_EASTING;

for ll = 1 : length(Band)
    
    if Band(ll) < 'N' % If southern emisphere
        
        Y = Y - FALSE_NORTHING;
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%


% FOOT POINT LATITUDE
%%%%%%%%%%%%%%%%%%%%%%%%%%%
lat1 = Y ./ SCALE_FACT / MAJOR_SEMIAXIS;
dlat = 1;                                                               % Initialization


if nargin == 5 && ( strcmp(aprr,'Hinks') || ~strcmp(aprr,'Helm') )
    
    
    switch(aprr)
        
        case 'Hinks'

            while max(abs(dlat)) > 1e-12

              % HINKS (1927) BESSEL SERIES EXPANSION USED IN NGIA DEFINITION OF UTM
              %%%%%%%%%%%%%%%%%%%%%%%%%%%
              A0 = 1 - N + (N.^2)*5/4 - (N.^3)*5/4 + (N.^4)*81/64 - (N.^5)*81/64;
              A2 = 1.5*( N - N.^2 + (N.^3)*7/8 - N.^4*7/8 + N.^5*55/64 );
              A4 = (15/16)*( N.^2 - N.^3 + (N.^4)*0.75 - (N.^5)*0.75 );
              A6 = (35/48)*( N.^3 - N.^4 + (N.^5)*(11/16) );
              A8 = (315/512)*( N.^4 - N.^5 );

              f1 = MAJOR_SEMIAXIS.*( A0.*lat1.*pi./180 - A2.*sind(2.*lat1) + A4.*sind(4.*lat1) - A6.*sind(6.*lat1)...
              + A8.*sind(8.*lat1) ) - Y./SCALE_FACT;

              f2 = MAJOR_SEMIAXIS.*( A0 - 2.*A2.*cosd(2.*lat1) + 4.*A4.*cosd(4.*lat1) - 6.*A6.*cosd(6.*lat1) + ...
              8.*A8.*cosd(8.*lat1) );

              dlat = -f1./f2;
              lat1 = lat1+dlat;

            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        case 'Helm'
            
            while max(abs(dlat)) > 1e-12

              % HELMERT(1880) EXPANSION AND SIMPLIFICATION OF BESSEL SERIES (FASTER)
              %%%%%%%%%%%%%%%%%%%%%%%%%%%
              A0 = 1 + (N^2)/4 + (N^4)/64;
              A2 = 1.5*( N - (N^3)/8 );
              A4 = (15/16)*( N^2 - (N^4)/4 );
              A6 = (35/48)*N^3;
              A8 = (315/512)*N^4;

              f1 = ( MAJOR_SEMIAXIS/(1+N) )*( A0.*lat1.*pi./180 - A2.*sind(2.*lat1) + A4.*sind(4.*lat1) - ...
              A6.*sind(6.*lat1) + A8.*sind(8.*lat1) )- Y/SCALE_FACT;

              f2 = ( MAJOR_SEMIAXIS/(1+N)) *( A0 - 2.*A2.*cosd(2.*lat1) + 4.*A4.*cosd(4.*lat1) - ...
              6.*A6.*cosd(6.*lat1) + 8.*A8.*cosd(8.*lat1) );

              dlat = -f1./f2;
              lat1 = lat1 + dlat;

            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
  
elseif nargin == 3 && (~strcmp(aprr,'Kraw') && ~strcmp(aprr,'Hinks') && ~strcmp(aprr,'Helm') )
    
    error('Incorrect value for parameter aprr. Type "help utmToGeo" in the command propt for more info about function usage.');
    
else 
  
    while max(abs(dlat)) > 1e-12

      % KRAKIWSKY (1973) EXPANSION
      %%%%%%%%%%%%%%%%%%%%%%%%%%%
      A0 = 1 - (ESQ/4) - ( (ESQ^2)*(3/64) ) - ( (ESQ^3)*(5/256)) - ( (ESQ^4)*(175/16384) );
      A2 = (3/8)*( ESQ + ( (ESQ^2)/4 ) + ( (ESQ^3)*(15/128) ) - ( (ESQ^4)*(455/4096) ) );
      A4 = (15/256)*( ESQ^2+( (ESQ^3)*0.75 ) - ( (ESQ^4)*(77/128) ) );
      A6 = (35/3072)*( ESQ^3 - ( (ESQ^4)*(41/32) ) );
      A8 = -(315/131072)*ESQ^4;


      f1 = MAJOR_SEMIAXIS.*( A0.*lat1.*pi./180 - A2.*sind(2.*lat1) + A4.*sind(4.*lat1) - A6.*sind(6.*lat1)...
          + A8.*sind(8.*lat1) ) - Y/SCALE_FACT;

      f2 = MAJOR_SEMIAXIS*( A0 - 2.*A2.*cosd(2.*lat1) + 4.*A4.*cosd(4.*lat1) - 6.*A6.*cosd(6.*lat1) + ...
          8.*A8.*cosd(8.*lat1) );

      dlat = -f1./f2;
      lat1 = lat1 + dlat;

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
end

% AUXILIAR PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%
RN = MAJOR_SEMIAXIS./(1 - ESQ.*sind(lat1).^2).^0.5;
RM = MAJOR_SEMIAXIS*(1 - ESQ)./(1 - ESQ*sind(lat1).^2).^1.5;
h2 = ESQ*( cosd(lat1).^2 )./(1 - ESQ);
lcm = (pi / 180 ) * (Zone * 6 - 183);               % longitude of central meridian [rad]
t = tand(lat1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%


% LONGITUDE CALCULATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%
X0 = X./SCALE_FACT./RN;
X1 = X0;
X2 = ( (X0.^3)/6 ).*( 1 + 2.*(t.^2) + h2 );
X3 =( (X0.^5)/120 ).*( 5 + 6*h2 + 28*(t.^2) - 3*(h2.^2) + 8*(t.^2).*h2 + 24*(t.^4) - ...
   4*(h2.^3) + 4*(t.^2).*(h2.^2) + 24*(t.^2).*(h2.^3) );
X4 = ( (X0.^7)/5040 ).*( 61 + 662*(t.^2) + 1320*(t.^4) + 720*(t.^6) );

lon = (180/pi).*( secd(lat1).*(X1 - X2 + X3 - X4) + lcm );

%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LATITUDE CALCULATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%
X0 = X/SCALE_FACT;
Y1 = ( t.*(X0.^2) )./( 2*RM.*RN );
Y2 = ( t.*(X0.^4) )./( 24*RM.*(RN.^3) ).*( 5 + 3.*(t.^2) + h2 - 4*(h2.^2) - 9*h2.*(t.^2) );
Y3 = ( t.*(X0.^6) )./( 720*RM.*(RN.^5) ).*( 61 - 90*(t.^2) + 46*h2 + 45*(t.^4) - 252*(t.^2).*h2 - ...
   5*(h2.^2) + 100*(h2.^3) - 66*(t.^2).*(h2.^2) - 90*(t.^4).*h2 + 88*(h2.^4) + 225*(t.^4).*(h2.^2) + ...
   84*(t.^2).*(h2.^3) - 192*(t.^2).*(h2.^4) );
Y4 = ( t.*(X0.^8) )./( 40320*RM.*(RN.^7) ).*( 1385 + 3633*(t.^2) + 4095*(t.^4) + 1575*(t.^6) );

lat = lat1 - Y1 + Y2 - Y3 + Y4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
