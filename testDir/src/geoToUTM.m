function [ X, Y, varargout ] = geoToUTM( lat, lon, aprr )
%geoToUTM transforms the input geographical coordinates to its UTM projection.
%   
%%--------------------------------------------------------------------------------------------------   
%   @desc Transforms the input geographical coordinates to its UTM projection.
%   
%   The default datum used for calculations is the WGS-84 but support for more datums
%   could be developed in future releases.
%   
%   The bounds for the UTM projection are +-180 degrees in longitude and +-84 degrees in
%   latitude.
%   
%   Supports the use of vectors in latitude and longitude coordinates.
%   
%%--------------------------------------------------------------------------------------------------   
%   The inputs for this function are:
%   
%   - @iparam [float] lat: latitude to convert in decimal degrees {deg}
%   - @iparam [float] lon: longitude to convert in decimal degrees {deg}
%   
%   - @iparam [String] aprr: string that defines the form of expansion of the meridian on
%   the ellipsoid. (Optional) Values:
%       -> [String] 'Helm': Helmert expansion (default) 
%       -> [String] 'Hinks': Hinks expansion
%   
%%--------------------------------------------------------------------------------------------------   
%   The outputs for thos function are:
%   
%   - @oparam [float] X: UTM Easting {m}
%   - @oparam [float] Y: UTM Northing {m}
%   - @oparam [int] UTM_Zone: UTM Zone (Optional) {1 - 60}                       
%   - @oparam [char] UTM_Band: UTM Band (Optional) {C - X}
%   
%%--------------------------------------------------------------------------------------------------
%   ** @author Andrés Ferreiro González (@aferreiro)
%   ** @company Galician Research And Development Center In Advanced Telecommunications (GRADIANT)
%   ** @date 15/02/2017
%   ** @version 1.3
%%--------------------------------------------------------------------------------------------------
%%%-------------------------------------------------------------------------------------------------



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRELIMINARY CALCULATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% UTM BOUNDARIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%
MAX_LAT = 84;
MIN_LAT = -80;
MAX_LON = 180;
MIN_LON = -180;

BAND = 'CDEFGHJKLMNPQRSTUVWX';

%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DATUM CORRECTION VALUES 
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

if nargin < 2
    
        error('Not enough input arguments. Type "help geoToUTM" in the command prompt for more info about function usage.');
        
elseif nargin > 3
    
            error('Too many input arguments. Type "help geoToUTM" in the command prompt for more info about function usage.');


elseif (min(lat) < MIN_LAT || max(lat) > MAX_LAT)
    
    error('Latitude value out of bounds. Type "help geoToUTM" in the command prompt for more info about function usage.');
    
elseif (min(lon) < MIN_LON || max(lon) > MAX_LON)
    
    error('Longitude value out of bounds. Type "help geoToUTM" in the command prompt for more info about function usage.');
    
end

if nargin == 3 && strcmp(aprr,'Hinks')
   
    % HINKS (1927) BESSEL SERIES EXPANSION USED IN NGIA DEFINITION OF UTM
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    H0 = 1 - N + (N^2)*(5/4) - (N^3)*(5/4) + (N^4)*(81/64) - (N^5)*(81/64);
    H2 = 1.5*( N - N^2 + (N^3)*(7/8) - (N^4)*(7/8) + (N^5)*(55/64) );
    H4 = (15/16)*( N^2 - N^3 + (N^4)*(3/4) - (N^5)*(3/4) );
    H6 = (35/48)*( N^3 - N^4 + (N^5)*(11/16) );
    H8 = (315/512)*( N^4 - N^5 );

    % Length of the meridian arc
    S = MAJOR_SEMIAXIS.*( H0.*lat.*pi./180 - H2.*sind( 2.*lat ) + H4.*sind(4.*lat) - H6.*sind(6.*lat) + ...
    H8.*sind(8.*lat) );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
            

elseif nargin == 3 && (~strcmp(aprr,'Helm') && ~strcmp(aprr,'Hinks') )
    
    error('Incorrect value for parameter aprr. Type "help geoToUTM" in the command propt for more info about function usage.');
    
else

% HELMERT (1880) EXPANSSION & SIMPLIFICATION OF BESSEL SERIES (FASTER)
%%%%%%%%%%%%%%%%%%%%%%%%%%%
H0 = 1 + (N^2)/4 + (N^4)/64;
H2 = 1.5*( N - (N^3)/8 );
H4 = (15/16)*( N^2 - (N^4)/4 );
H6 = (35/48)*(N^3);
H8 = (315/512)*(N^4);


% Length of the meridian arc
S = ( MAJOR_SEMIAXIS/(1 + N) ).*( H0.*lat.*pi./180 - H2.*sind(2.*lat) + H4.*sind(.4*lat) ...
    - H6.*sind(6.*lat) + H8.*sind(8.*lat) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%

end




% UTM ZONE CALCULATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%UTM_Zone = floor( ( lon + 180 )/6 ) + 1;  % Method 1 original
UTM_Zone = floor( lon./6 ) + 31;        % Method 2 Goudarzi (faster)
UTM_Zone = UTM_Zone + ( UTM_Zone<=0 ).*60 - ( UTM_Zone>60 ).*60;      % Correction to avoid '0' zone

% Handling UTM exception 

for ll = 1:length(lat)
    
  if ((lat(ll) >= 56) && (lat(ll) < 64) && (lon(ll) >= 3) && (lon(ll) < 12)) 
      
      UTM_Zone(ll) = 32;            % South-Norway 31V-32V (32V extends to the west from 3 to 12 degrees, with degree 9 as meridian)

  elseif (lat(ll) >= 72) % Arctic region exceptions
            
                
                if ((lon(ll) >= 0) && (lon < 9)) 
                    
                    UTM_Zone(ll) = 31;
                
                elseif ((lon(ll) >= 9) && (lon(ll) < 21)) 
                        
                    UTM_Zone(ll) = 33;
                        
                elseif ((lon(ll) >= 21) && (lon(ll) < 33)) 
                    
                    UTM_Zone(ll) = 35;
                elseif ((lon(ll) >= 33) && (lon(ll) < 42)) 
                    
                    UTM_Zone(ll) = 37;
                    
                end
  end
            
bandIndex = floor ( 1 + ( lat + 80 ) ./ 8 );

UTM_Band = BAND(bandIndex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%


lcm = (pi/180 ).*( UTM_Zone*6 - 183 );               % longitude of central meridian [rad]
t = tand(lat);

lam = ( pi.*lon./180 ) - lcm;                         % longitude above meridian [rad]

lam = lam - ( lam>=pi ).*( 2.*pi );                   % correction


RN = MAJOR_SEMIAXIS./(1 - ESQ.*sind(lat).^2).^0.5;

h2 = ESQ*( cosd(lat).^2 )./(1 - ESQ);

%%%%%%%%%%%%%%%%%%%%%%%%%%%


% EASTING CALCULATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%
X1 = lam.*cosd(lat);

X2 = (lam.^3).*( ( cosd(lat).^3 )/6 ).*( 1 - t.^2 + h2 );

X3 = (lam.^5).*( ( cosd(lat).^5 )/120 ).*( 5 - 18.*(t.^2) + t.^4 + 14*h2 - 58.*(t.^2).*h2 + ...
   13.*(h2.^2) + 4.*(h2.^3) - 64.*(t.^2).*(h2.^2) - 24.*(t.^2).*(h2.^3) );

X4 = (lam.^7).*( ( cosd(lat).^7 )/5040 ).*( 61 - 479.*(t.^2) + 179.*(t.^4) - t.^6 );

X = FALSE_EASTING + SCALE_FACT * RN .*( X1 + X2 + X3 + X4 );


% NORTHING CALCULATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%
Y1 = S./RN;

Y2 = ( (lam.^2)/2 ).*sind(lat).*cosd(lat);

Y3 = ( (lam.^4)/24 ).*sind(lat).*( cosd(lat).^3 ).*( 5 - t.^2 + 9*h2 + 4.*(h2.^2) );

Y4 = ( (lam.^6)/720 ).*sind(lat).*( cosd(lat).^5 ).*( 61 - 58.*(t.^2) + t.^4 + ...
   270.*h2 - 330*(t.^2).*h2 + 445*(h2.^2) + 324.*(h2.^3) - 680.*(t.^2).*(h2.^2) + ...
   88.*(h2.^4) - 600.*(t.^2).*(h2.^3) - 192.*(t.^2).*(h2.^4) );

Y5 = ( (lam.^8)./40320 ).*sind(lat).*( cosd(lat).^7 ).*( 1385 - 311.*(t.^2) + 543 ...
    .*(t.^4) - t.^6 );

Y = SCALE_FACT * RN .* ( Y1 + Y2 + Y3 + Y4 + Y5 );

if lat < 0 
    
    Y = Y + FALSE_NORTHING;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%

varargout{1} = UTM_Zone;
varargout{2} = UTM_Band;

end

